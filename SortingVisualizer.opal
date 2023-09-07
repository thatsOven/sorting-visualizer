package opal: import *;

new Vector RESOLUTION = Vector(1280, 720);

static {
    new int   FREQUENCY_SAMPLE = 48000;
    new float SAMPLE_DURATION  = 1.0 / 30.0;
    new str   VERSION          = "2023.9.7";
}

import math, random, time, os, numpy, sys, pygame_gui;
package timeit:      import default_timer;
package functools:   import total_ordering;
package pygame_gui:  import UIManager, elements;
package pygame:      import Rect;
package pygame.time: import Clock;
package scipy:       import signal;
package json:        import loads;
use exec, getattr;
$args ["--nostatic"]

sys.setrecursionlimit(65536);

enum RefreshMode {
    STANDARD, NOREFRESH, FULL
}

enum RotationMode {
    INDEXED, LENGTHS
}

new function checkType(value, type_) {
    try {
        new dynamic tmp = type_(value);
    } catch ValueError {
        return False;
    }
    return True;
}

new dynamic sortingVisualizer = None;

$include os.path.join(HOME_DIR, "GUI.opal")
$include os.path.join(HOME_DIR, "Value.opal")
$include os.path.join(HOME_DIR, "moduleClasses.opal")
$include os.path.join(HOME_DIR, "threadBuilder", "ThreadCommand.opal")

enum ArrayState {
    UNSORTED, SORTED, STABLY_SORTED
}

new class SortingVisualizer {
    new method __init__() {
        this.array = [];
        this.aux   = None;

        this.distributions = [];
        this.shuffles      = [];
        this.visuals       = [];

        this.sorts      = {};
        this.categories = [];

        this.pivotSelections = [];
        this.rotations       = [];

        this.__fontSize = round(((RESOLUTION.x / 1280) + (RESOLUTION.y / 720)) * 11);

        this.__visual = None;
        this.graphics = Graphics(
            RESOLUTION, caption = "thatsOven's Sorting Visualizer", 
            font = "Times New Roman", fontSize = this.__fontSize, 
            frequencySample = FREQUENCY_SAMPLE
        );
        this.__running = False;
        this.__gui     = GUI();

        this.resetStats();

        this.arrayMax = 1.0;
        this.auxMax   = 1.0;

        this.__enteredAuxMode = False;
        this.__adaptAux       = this.__defaultAdaptAux;
        this.__oldAuxLen      = 0;

        this.__speed        = 1;
        this.__speedCounter = 0;
        this.__sleep        = 0;
        this.__tmpSleep     = 0;
        this.__dFramesPerc  = "0%";

        this.__currentlyRunning = "";
        this.__currentCategory  = "";

        this.__checking = False;
        this.__prepared = False;

        this.__autoUserValues = Queue();
        this.__shufThread     = None;

        this.__forceLoadedIndices = [];

        this.__soundSample = numpy.arange(0, SAMPLE_DURATION, 1.0 / float(this.graphics.frequencySample));
        this.__audioChs    = this.graphics.getAudioChs()[2];

        new auto f = open(os.path.join(HOME_DIR, "config.json"), "r");
        new dict settings = loads(f.read());
        f.close();

        this.__showText = settings["show-text"];
        this.__showAux  = settings["show-aux"];
        this.__moreInfo = settings["internal-info"];

        if this.__moreInfo {
            this.__movingTextSize = Vector(0, this.__fontSize * 20);
        } else {
            this.__movingTextSize = Vector(0, this.__fontSize * 15);
        }
    }

    property swaps {
        get {
            return this.__swaps;
        }

        set {
            this.writes += 2 * (value - this.__swaps);
            this.__swaps = value;
        }
    }

    property comparisons {
        get {
            return this.__comps;
        }

        set {
            this.reads += 2 * (value - this.__comps);
            this.__comps = value;
        }
    }

    new method swap(array, a, b) {
        new dynamic sTime = default_timer();
        array[a], array[b] = array[b], array[a];
        this.timer(sTime);

        this.swaps++;
    }

    new method write(array, i, val) {
        new dynamic sTime = default_timer();
        array[i] = val;
        this.timer(sTime);

        this.writes++;
    }

    new method timer(sTime) {
        this.time += (default_timer() - sTime) * 1000;
    }

    new method delay(dTime) {
        this.__speedCounter = 0;
        this.__tmpSleep     = dTime / 1000;
    }

    $macro update
        this.graphics.forceDraw(drawBackground = False);
    $end

    new method resetStats() {
        this.writes  = 0;
        this.reads   = 0;
        this.__swaps = 0;
        this.__comps = 0;
        this.time    = 0;
    }

    new method drawFullArray() {
        this.graphics.fill((0, 0, 0));
        this.__visual.draw(this.array, [i for i in range(len(this.array))], None);
    }

    new method __getSizes() {
        this.getMax();
        this.__visual.prepare();
        this.__prepared = True;
        this.__forceLoadedIndices = [];

        new int worstCaseTextWidth;

        match this.__visual.refresh {
            case RefreshMode.STANDARD {
                if this.__showText {
                    worstCaseTextWidth = round(35 * (this.__fontSize / 2.25));
                } else {
                    return;
                }
            }
            case RefreshMode.NOREFRESH {
                return;
            }
            case RefreshMode.FULL {
                worstCaseTextWidth = this.graphics.resolution.x;
            }
        }

        this.__forceLoadedIndices = [i for i in range(round(Utils.translate(worstCaseTextWidth, 0, this.graphics.resolution.x, 0, len(this.array))))];
    }

    new method __runSDModule(mess, func, array, id, name, class_, length=None) {
        if id is None and name is None {
            IO.out("Not enough information to start ", mess, IO.endl);
            return;
        }

        if id is None {
            new int id;
            id = Utils.Iterables.binarySearch(array, class_(name));

            if id != -1 {
                return func(id, length);
            } else {
                IO.out("Invalid ", mess, " name!\n");
                return 0;
            }
        } elif name is None {
            if id in range(0, len(array)) {
                return func(id, length);
            } else {
                IO.out("Invalid ", mess, " ID!\n");
                return 0;
            }
        }
    }

    new method __runDistributionById(id, length) {
        this.array = [None for _ in range(length)];
        this.__currentlyRunning = this.distributions[id].name + " (distribution)";
        this.distributions[id].func(this.array, length);

        for i in range(length) {
            this.array[i].stabIdx = i;
            this.array[i].idx     = i;
        }

        this.getMax();
        this.__visual.prepare();
        this.__prepared = True;
        this.drawFullArray();
    }

    new method runDistribution(length, id = None, name = None) {
        this.__runSDModule("distribution", this.__runDistributionById, this.distributions, id, name, Distribution, length);
    }

    new method __runShuffleById(id, placeHolder) {
        this.resetStats();
        this.__currentlyRunning = this.shuffles[id].name;
        this.__currentCategory  = "Shuffles";

        this.__getSizes();

        new float speed = len(this.array) / 256.0;

        if speed < 1 {
            this.setSpeed(speed);
        } else {
            this.setSpeed(round(speed));
        }

        this.shuffles[id].func(this.array);

        for i in range(len(this.array)) {
            this.array[i].stabIdx = i;
        }

        this.resetAux();
        this.resetAdaptAux();
        this.drawFullArray();
        this.renderStats();
        $call update
    }

    new method runShuffle(id = None, name = None) {
        this.__runSDModule("shuffle", this.__runShuffleById, this.shuffles, id, name, Shuffle);
    }

    new method __getPivotSelectionById(id, placeHolder) {
        return this.pivotSelections[id];
    }

    new method getPivotSelection(id = None, name = None) {
        return this.__runSDModule("pivot selection", this.__getPivotSelectionById, this.pivotSelections, id, name, PivotSelection).getFunc();
    }

    new method __getRotationById(id, placeHolder) {
        return this.rotations[id];
    }

    new method getRotation(id = None, name = None) {
        return this.__runSDModule("rotation", this.__getRotationById, this.rotations, id, name, Rotation);
    }

    new method __runSortById(category, id) {
        this.resetStats();
        this.__currentlyRunning = this.sorts[category][id].name;
        this.__currentCategory  = category;
        time.sleep(1.25);
        this.sorts[category][id].func(this.array);
        this.resetAux();
        this.resetAdaptAux();
        this.drawFullArray();
        this.printArrayState();
    }

    new method runSort(category, id = None, name = None) {
        if id is None and name is None {
            IO.out("No id or name given to runSort!\n");
            return;
        }

        if id is None {
            new int id;
            id = Utils.Iterables.binarySearch(this.sorts[category], Sort("", "", name));

            if id != -1 {
                this.__runSortById(category, id);
            } else {
                IO.out("Invalid sort name!\n");
            }
        } elif name is None {
            if id in range(0, len(this.sorts)) {
                this.__runSortById(category, id);
            } else {
                IO.out("Invalid sort name!\n");
            }
        }
    }

    new method setVisual(id) {
        if id in range(0, len(this.visuals)) {
            this.__visual = this.visuals[id];
            this.__prepared = False;
        } else {
            IO.out("Invalid visual id!\n");
        }
    }

    new method generateArray(selectedDistributionIdx, selectedShuffleIdx, length) {
        this.runDistribution(length, id = selectedDistributionIdx);
        this.runShuffle(id = selectedShuffleIdx);
    }

    new method getMaxViaKey(array, getVal = lambda x : x.value) {
        new dynamic maxVal = getVal(array[0]), val;

        for i = 1; i < len(array); i++ {
            val = getVal(array[i]);

            if val > maxVal {
                maxVal = val;
            }
        }

        return 1 if maxVal == 0 else maxVal + 1;
    }

    new method getMax() {
        this.arrayMax = float(this.getMaxViaKey(this.array));
    }

    new method getAuxMax(array = None) {
        if array is None {
            this.auxMax = float(this.getMaxViaKey(this.__adaptAux(this.aux)));
        } else {
            this.auxMax = float(this.getMaxViaKey(array));
        }
    }

    new method checkSorted(array, getVal = lambda x : x.value) {
        for i = 0; i < len(array) - 1; i++ {
            if getVal(array[i]) > getVal(array[i + 1]) {
                return i;
            }
        }
        return len(array) - 1;
    }

    new method checkArrayState() {
        new int state, sUntil;

        sUntil = this.checkSorted(this.array);

        if sUntil == len(this.array) - 1 {
            this.sweep(0, len(this.array), (0, 255, 0));

            new dict stabilityCheck = {};

            for i = 0; i < len(this.array); i++ {
                if not this.array[i].value in stabilityCheck {
                    stabilityCheck[this.array[i].value] = [this.array[i]];
                } else {
                    stabilityCheck[this.array[i].value].append(this.array[i]);
                }
            }

            new dynamic currentIdx = 0;

            for unique in stabilityCheck {
                if this.checkSorted(stabilityCheck[unique], lambda x : x.stabIdx) != len(stabilityCheck[unique]) - 1 {
                    this.sweep(currentIdx, len(this.array), (255, 255, 0));

                    return ArrayState.SORTED;
                }

                this.sweep(currentIdx, currentIdx + len(stabilityCheck[unique]), (0, 0, 255));
                currentIdx += len(stabilityCheck[unique]);
            }

            return ArrayState.STABLY_SORTED;

        } else {
            this.sweep(     0,          sUntil, (0, 255, 0));
            this.sweep(sUntil, len(this.array), (255, 0, 0));

            return ArrayState.UNSORTED;
        }
    }

    new method printArrayState() {
        new str sortName = this.__currentlyRunning;

        this.setCurrentlyRunning("", "Checking...");
        new int state = this.checkArrayState();

        new tuple color;
        match state {
            case ArrayState.UNSORTED {
                this.setCurrentlyRunning("", "The list was not sorted");
                IO.out(sortName, " has failed\n");
            }
            case ArrayState.SORTED {
                this.setCurrentlyRunning("", "The list was sorted");
                IO.out(sortName, " sorted the list unstably\n");
            }
            case ArrayState.STABLY_SORTED {
                this.setCurrentlyRunning("", "The list was sorted stably");
                IO.out(sortName, " sorted the list stably\n");
            }
        }

        this.drawFullArray();
        this.renderStats();
        $call update

        time.sleep(1.25);
    }

    new method addDistribution(distribution) {
        this.distributions.append(distribution);
    }

    new method addShuffle(shuffle) {
        this.shuffles.append(shuffle);
    }

    new method addSort(sort) {
        if sort.category in this.sorts {
            this.sorts[sort.category].append(sort);
        } else {
            this.sorts[sort.category] = [sort];
            this.categories.append(sort.category);
        }
    }

    new method addVisual(visual) {
        this.visuals.append(visual);
    }

    new method addPivotSelection(pSel) {
        this.pivotSelections.append(pSel);
    }

    new method addRotation(rot) {
        this.rotations.append(rot);
    }

    new method renderStats() {
        if not this.__showText {
            return;
        }

        new dynamic pos = Vector(2, 2), ete;

        ete = "Estimated time elapsed: " + ((str(round(this.time, 4)) + " ms") if this.time < 1000 else (str(round(this.time / 1000, 4)) + " s"));
        this.__movingTextSize.x = (len(ete) * this.__fontSize) // 2;

        if this.__visual.out and not this.__checking {
            this.graphics.fastRectangle(pos, this.__movingTextSize, (0, 0, 0));
        }

        if this.__moreInfo {
            this.graphics.drawOutlineText([
                "Array length: " + str(len(this.array)) + " elements",
                this.__currentCategory + ": " + this.__currentlyRunning,
                "",
                "Dropped frames: " + this.__dFramesPerc,
                "Current delay: " + str(this.__sleep + this.__tmpSleep) + " ms",
                "",
                "Writes: " + str(this.writes),
                "Swaps: "  + str(this.__swaps),
                "",
                "Reads: "  + str(this.reads),
                "Comparisons: " + str(this.__comps),
                "",
                ete
            ], pos);
        } else {
            this.graphics.drawOutlineText([
                "Array length: " + str(len(this.array)) + " elements",
                this.__currentCategory + ": " + this.__currentlyRunning,
                "",
                "Writes: " + str(this.writes),
                "Swaps: "  + str(this.__swaps),
                "",
                "Reads: "  + str(this.reads),
                "Comparisons: " + str(this.__comps),
                "",
                ete
            ], pos);
        }
    }

    new method __defaultAdaptAux(array) {
        return array;
    }

    new method setAdaptAux(func) {
        this.__adaptAux = func;
    }

    new method resetAdaptAux() {
        this.__adaptAux = this.__defaultAdaptAux;
    }

    new method __getWaveformFromIdx(i) {
        new dynamic tmp;

        if i.aux and this.aux is not None {
            tmp = 200.0 * signal.square(2.0 * numpy.pi  * int(((400.0 + (this.__adaptAux(this.aux)[i.idx].value * (500.0 / this.auxMax)))) + 50.0) * this.__soundSample);
        } else {
            tmp = 200.0 * signal.square(2.0 * numpy.pi  * int(((400.0 + (this.array[i.idx].value * (500.0 / this.arrayMax)))) + 50.0) * this.__soundSample);
        }

        if this.__audioChs > 1 {
            return numpy.repeat(tmp.reshape(tmp.size, 1), this.__audioChs, axis = 1);
        } else {
            return tmp;
        }
    }

    $macro playSound(hList)
        this.graphics.playWaveforms([this.__getWaveformFromIdx(x) for x in hList]);
    $end

    new method __partitionIndices(hList) {
        new dynamic internal = [],
                    aux      = [];

        for i in range(len(hList)) {
            if hList[i].aux {
                aux.append(hList[i].idx);
            } else {
                internal.append(hList[i].idx);
            }
        }

        return internal, aux;
    }

    new method internalMultiHighlight(hList) {
        hList = [x for x in hList if x is not None];
        hList = [x for x in hList if x.idx is not None];

        if len(hList) != 0 {
            if this.__speedCounter >= this.__speed {
                this.__speedCounter = 0;

                $call playSound(hList)

                if this.__showAux and this.aux is not None {
                    new dynamic auxList;
                    hList, auxList = this.__partitionIndices(hList);
                } else {
                    hList = [x.idx for x in hList];
                }

                this.__visual.draw(this.array, hList, this.__visual.highlightColor);

                if this.__showAux and this.aux is not None {
                    new dynamic adapted = this.__adaptAux(this.aux);
                    static: new int length = len(adapted);

                    if this.__oldAuxLen != length {
                        this.__visual.onAuxOn(length);
                        this.__oldAuxLen = length;
                    } else {
                        new dynamic oldMax = this.auxMax;
                        this.getAuxMax(adapted);
                        if this.auxMax != oldMax {
                            this.__visual.onAuxOn(length);
                        }
                    }

                    this.__visual.drawAux(adapted, auxList, this.__visual.highlightColor);
                }

                this.renderStats();

                $call update

                this.__visual.draw(this.array, set(hList + this.__forceLoadedIndices), None);

                time.sleep(this.__sleep + this.__tmpSleep);

                this.__tmpSleep = 0;
            } else {
                this.__visual.draw(this.array, this.__partitionIndices(hList)[0], None);
            }
        } elif this.__speedCounter >= this.__speed {
            this.__speedCounter = 0;
            this.__tmpSleep = 0;
        }
        this.__speedCounter++;
    }

    new method internalHighlight(index) {
        this.internalMultiHighlight([index]);
    }

    new method multiHighlight(hList, aux = False) {
        this.internalMultiHighlight([HighlightPair(x, aux) for x in hList]);
    }

    new method highlight(index, aux = False) {
        this.internalHighlight(HighlightPair(index, aux));
    }

    new method sweep(a, b, color) {
        this.__checking = True;

        this.renderStats();

        new float speed = len(this.array) / 256.0;

        if speed < 1 {
            this.setSpeed(speed);
        } else {
            this.setSpeed(round(speed));
        }

        for i = a; i < b; i++ {
            time.sleep(this.__sleep);

            this.__visual.draw(this.array, [i], color);

            if this.__speedCounter >= this.__speed {
                this.__speedCounter = 0;

                $call playSound([HighlightPair(i, False)])

                if len(this.__forceLoadedIndices) != 0 {
                    if i <= this.__forceLoadedIndices[-1] {
                        this.renderStats();
                    }
                }

                $call update
            }
            this.__speedCounter++;
        }

        this.__checking = False;
    }

    new method pushAutoValue(value) {
        this.__autoUserValues.push(value);
    }

    new method popAutoValue() {
        return this.__autoUserValues.pop();
    }

    new method resetAutoValues() {
        while this.__autoUserValues.pop() is not None {}
    }

    new method setSpeed(value) {
        match this.__visual.refresh {
            case RefreshMode.FULL {
                value *= 2.0;
            }
            case RefreshMode.NOREFRESH {
                value /= 2.0;

                if value >= 1 {
                    value = int(value);
                }
            }
        }

        if value >= 1 {
            this.__speed       = value;
            this.__sleep       = 0;
            this.__dFramesPerc = str(round(((value - 1) / value) * 100, 4)) + "%";
        } else {
            this.__speed       = 1;
            this.__sleep       = 0.001 / value;
            this.__dFramesPerc = "0%";
        }
    }

    property speed {
        get {
            if this.__sleep == 0 {
                return this.__speed;
            } else {
                return this.__speed / (this.__sleep * 1000);
            }
        }
    }

    new method resetSpeed() {
        this.__speed        = 1;
        this.__sleep        = 0;
        this.__speedCounter = 0;
        this.__dFramesPerc  = "0%";
    }

    new method setCurrentlyRunning(category, name) {
        this.__currentlyRunning = name;
        this.__currentCategory  = category;
    }

    new method getUserInput(message = "", default = "", type_ = int) {
        if this.__autoUserValues.isEmpty() {
            new dynamic res = this.__gui.userInputDialog(this.__currentlyRunning, message, type_, default);
            
            if this.__prepared {
                this.drawFullArray();
                this.renderStats();
            }

            return res;
        } else {
            return this.popAutoValue();
        }
    }

    new method getUserSelection(content, message = "") {
        if this.__autoUserValues.isEmpty() {
            new dynamic res = this.__gui.selection(this.__currentlyRunning, message, content);
            
            if this.__prepared {
                this.drawFullArray();
                this.renderStats();
            }
            
            return res;
        } else {
            return this.popAutoValue();
        }
    }

    new method userWarn(message) {
        this.__gui.userWarn(this.__currentlyRunning, message);
    }

    new method getKillerIds(killers, distribution) {
        if this.distributions[distribution].name in killers {
            new list tmp;
            tmp = [Utils.Iterables.binarySearch(this.shuffles, Shuffle(killer)) for killer in killers[this.distributions[distribution].name]];
            return [x for x in tmp if x != -1];
        } else {
            return [];
        }
    }

    new method runSortingProcess(distribution, length, shuffle, categoryName, sortName, speed = 1.0, mult = 1.0, killers = {}) {
        this.generateArray(distribution, shuffle, length);

        if (killers != {}) {
            if shuffle in this.getKillerIds(killers, distribution) {
                this.__speed = 1000;
            } else {
                this.setSpeed(speed * mult);
            }
        } else {
            this.setSpeed(speed * mult);
        }

        this.runSort(categoryName, name = sortName);
        this.resetSpeed();
    }

    new method createValueArray(length) {
        new list result = [];

        for i in range(length) {
            new Value item = Value(0);
            item.idx = i;
            item.stabIdx = i;
            item.setAux(True);
            result.append(item);
        }

        return result;
    }

    new method setInvisibleArray(array) {
        for i in range(len(array)) {
            array[i].idx = None;
        }
    }

    new method setAux(array) {
        this.aux = array;

        if this.__showAux and not this.__enteredAuxMode {
            if this.__sleep != 0 {
                this.__sleep /= 10.0;
            } else {
                this.__speed *= 5.0;
            }
            this.__enteredAuxMode = True;
            
            new dynamic adapted = this.__adaptAux(this.aux);
            this.getAuxMax(adapted);
            this.__visual.onAuxOn(len(adapted));
            this.drawFullArray();
        }
    }

    new method resetAux() {
        this.aux = None;
        this.__enteredAuxMode = False;
        this.__visual.onAuxOff();
    }

    new method __loadThreadAndRun(thread, initGraph = False) {
        new auto f = open(thread, "r");
        new str threadCode = "";
        for line in f {
            threadCode += line;
        }
        f.close();

        try {
            exec(threadCode);
        } catch Exception as e {
            IO.out("The thread thrown the following exception: \n", e, IO.endl);
        }
    }

    new method __threadTypeChecker(path, modeI) {
        new auto f = open(path, "r");
        new str mode = f.read().split("\n")[0][1:];
        f.close();

        modeI = modeI.upper();

        if mode != modeI {
            return this.__gui.selection("Warning", "This thread was not intended to be used as a " + modeI + ". Run anyway?", ["No", "Yes"]) == 1;
        }

        return True;
    }

    new method __selectThread(title, run, initGraph = False) {
        new list threads = [];
        new dynamic ldir;
        ldir = os.listdir(os.path.join(HOME_DIR, "threads"));

        for file in ldir {
            if file.endswith(".py") {
                threads.append(file);
            }
        }

        while True {
            new int sel = this.__gui.selection(title, "Select thread: ", threads);

            new str path = os.path.join(HOME_DIR, "threads", threads[sel]);

            if this.__threadTypeChecker(path, title) {
                break;
            }
        }

        if run {
            this.__loadThreadAndRun(path, initGraph);
        } else {
            return path;
        }
    }

    new method __compileCommandList(commands, fileName) {
        new auto f = open(fileName, "a");

        for i in range(len(commands)) {
            f.write(commands[i].compile());
        }
        f.close();
    }

    new method __threadShuf(array) {
        if this.__shufThread is None {
            this.__shufThread = this.__selectThread("Shuffle", False);
        }
        this.__loadThreadAndRun(this.__shufThread);
    }

    new method __resetShufThread() {
        this.__shufThread = None;
    }

    $include os.path.join(HOME_DIR, "threadBuilder", "BuilderEvaluator.opal")

    new method run() {
        this.graphics.event(QUIT)(lambda _: quit());

        Utils.Iterables.stableSort(this.distributions);
        Utils.Iterables.stableSort(this.shuffles);
        Utils.Iterables.stableSort(this.visuals);
        Utils.Iterables.stableSort(this.categories);
        Utils.Iterables.stableSort(this.pivotSelections);

        for list_ in this.sorts {
            Utils.Iterables.stableSort(this.sorts[list_]);
        }

        new Shuffle threadShuf = Shuffle("Run thread");
        threadShuf.func = this.__threadShuf;
        this.addShuffle(threadShuf);

        this.__gui.setSv(this);

        while True {
            new int sel = this.__gui.selection("Mode", "Select mode: ", [
                "Run sort",
                "Run all sorts",
                "Threads"
            ]);

            match sel {
                case 0 {
                    do opt == 0 {
                        new dict runOpts = this.__gui.runSort();

                        this.__visual = this.visuals[runOpts["visual"]];
                        this.__prepared = False;
                        this.generateArray(runOpts["distribution"], runOpts["shuffle"], runOpts["array-size"]);
                        this.setSpeed(runOpts["speed"]);
                        this.runSort(this.categories[runOpts["category"]], id = runOpts["sort"]);
                        this.__resetShufThread();

                        new int opt = this.__gui.selection("Done", "Continue?", [
                            "Yes",
                            "No"
                        ]);
                    }
                }
                case 1 {
                    new dict runOpts = this.__gui.runAll();
                    $include os.path.join(HOME_DIR, "threads", "runAllSorts.opal")
                    this.__gui.userWarn("Finished", "All sorts have been visualized.");
                }
                case 2 {
                    sel = this.__gui.selection("Threads", "Select: ", [
                        "Run thread from threads folder",
                        "Thread builder"
                    ]);

                    match sel {
                        case 0 {
                            this.__selectThread("Thread", True, True);
                        }
                        case 1 {
                            $include os.path.join(HOME_DIR, "threadBuilder", "ThreadBuilder.opal")
                        }
                    }
                }
            }
        }
    }
}

main {
    new SortingVisualizer sortingVisualizer = SortingVisualizer();

    $includeDirectory os.path.join(HOME_DIR, "utils")

    namespace Visuals {
        $includeDirectory os.path.join(HOME_DIR, "visuals")
    }

    for visual in dir(Visuals) {
        if !visual.startswith("_") {
            getattr(Visuals, visual)();
        }
    }

    $includeDirectory os.path.join(HOME_DIR, "distributions")
    $includeDirectory os.path.join(HOME_DIR, "pivotSelections")
    $includeDirectory os.path.join(HOME_DIR, "rotations")
    $includeDirectory os.path.join(HOME_DIR, "shuffles")
    $includeDirectory os.path.join(HOME_DIR, "sorts")

    sortingVisualizer.run();
}
