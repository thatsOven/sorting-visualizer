$define HOME_DIR PROJECT_DIRECTORY
package opal: import *;

new <Vector> RESOLUTION = Vector(1280, 720);

import math, random, time, os, numpy, sys;
package timeit:    import default_timer;
package functools: import total_ordering;
package scipy:     import signal;
package json:      import loads;
use exec as exec;

sys.setrecursionlimit(65536);

enum RefreshMode {
    STANDARD, NOREFRESH, FULL
}

new function checkType(value, type_) {
    try {
        new dynamic tmp = type_(value);
    } catch {
        return False;
    }
    return True;
}

new dynamic sortingVisualizer = None;

$include os.path.join("HOME_DIR", "TUI", "TUIManager.opal")
$include os.path.join("HOME_DIR", "Value.opal")
$include os.path.join("HOME_DIR", "VisualSizes.opal")
$include os.path.join("HOME_DIR", "moduleClasses.opal")
$include os.path.join("HOME_DIR", "ReadsWrites.opal")
$include os.path.join("HOME_DIR", "threadBuilder", "ThreadCommand.opal")

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

        this.__visual = None;
        this.graphics = None;
        this.__tui    = TUI();

        this.visualSizes = VisualSizes(this);

        this.writes = Writes();
        this.reads  = Reads();
        this.time   = 0;

        this.arrayMax = 1;
        this.auxMax   = 1;

        this.__enteredAuxMode = False;
        this.__adaptAux       = this.__defaultAdaptAux;

        this.__speed        = 1;
        this.__speedCounter = 0;
        this.__sleep        = 0;
        this.__tmpSleep     = 0;
        this.__dFramesPerc  = "0%";

        this.__currentlyRunning = "";
        this.__currentCategory  = "";

        this.__checking = False;

        this.__autoUserValue = None;
        this.__shufThread    = None;

        this.__forceLoadedIndices = [];
        this.__audioChs = None;

        this.__fontSize = round(11 * ((RESOLUTION.x / 1280) + (RESOLUTION.y / 720)));

        this.__soundSample = None;

        new auto f = open(os.path.join("HOME_DIR", "config.json"), "r");
        new dict settings = loads(f.read());
        f.close();

        this.__showText = settings["show-text"];
        this.__showAux  = settings["show-aux"];
        this.__record   = settings["record"];
        this.__moreInfo = settings["internal-info"];

        if this.__moreInfo {
            this.__movingTextSize = Vector(0, 20 * this.__fontSize);
        } else {
            this.__movingTextSize = Vector(0, 15 * this.__fontSize);
        }
    }

    new method swap(array, a, b) {
        new dynamic sTime = default_timer();
        unchecked:
        array[a], array[b] = array[b], array[a];
        this.timer(sTime);

        this.writes.addSwap();
    }

    new method write(array, i, val) {
        new dynamic sTime = default_timer();
        array[i] = val;
        this.timer(sTime);

        this.writes.addWrite();
    }

    new method initGraphics() {
        this.graphics = Graphics(RESOLUTION, caption = "thatsOven's Sorting Visualizer", font = "Times New Roman", fontSize = this.__fontSize);
        this.graphics.fill((0, 0, 0));

        this.__soundSample = numpy.arange(0, 1 / 10, 1 / this.graphics.frequencySample);
        this.__audioChs    = this.graphics.getAudioChs()[2];
    }

    new method timer(sTime) {
        this.time += (default_timer() - sTime) * 1000;
    }

    new method delay(dTime) {
        this.__speedCounter = 0;
        this.__tmpSleep     = dTime / 1000;
    }

    new method noRedrawUpdate() {
        this.graphics.forceDraw(drawBackground = False);
    }

    new method resetStats() {
        this.writes.reset();
        this.reads.reset();
        this.time = 0;
    }

    new method drawFullArray() {
        this.graphics.fill((0, 0, 0));
        this.__visual.func(this, this.array, [i for i in range(len(this.array))], "default");
    }

    new method __getSizes() {
        this.visualSizes.compute();
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
                IO.out("Invalid ", name, " name!\n");
                return 0;
            }
        } elif name is None {
            if id in range(0, len(array)) {
                return func(id, length);
            } else {
                IO.out("Invalid ", name, " ID!\n");
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

        this.visualSizes.compute();
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

        new float speed = len(this.array) / 256;

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
        this.noRedrawUpdate();
    }

    new method runShuffle(id = None, name = None) {
        this.__runSDModule("shuffle", this.__runShuffleById, this.shuffles, id, name, Shuffle);
    }

    new method __getPivotSelectionById(id, placeHolder) {
        return this.pivotSelections[id];
    }

    new method getPivotSelection(id = None, name = None) {
        return this.__runSDModule("pivot selection", this.__getPivotSelectionById, this.pivotSelections, id, name, PivotSelection);
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

        return 1 if maxVal == 0 else maxVal;
    }

    new method getMax() {
        this.arrayMax = this.getMaxViaKey(this.array);
    }

    new method getAuxMax() {
        this.auxMax = max(this.getMaxViaKey(this.__adaptAux(this.aux)), this.arrayMax);
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
                color = (255, 0, 0);
                this.setCurrentlyRunning("", "The list was not sorted");
                IO.out(sortName, " has failed\n");
            }
            case ArrayState.SORTED {
                color = (255, 255, 0);
                this.setCurrentlyRunning("", "The list was sorted");
                IO.out(sortName, " sorted the list unstably\n");
            }
            case ArrayState.STABLY_SORTED {
                color = (0, 0, 255);
                this.setCurrentlyRunning("", "The list was sorted stably");
                IO.out(sortName, " sorted the list stably\n");
            }
        }

        this.drawFullArray();
        this.renderStats();
        this.noRedrawUpdate();

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
                "Writes: " + str(this.writes.writes),
                "Swaps: "  + str(this.writes.swaps),
                "",
                "Reads: "  + str(this.reads.reads),
                "Comparisons: " + str(this.reads.comparisons),
                "",
                ete
            ], pos);
        } else {
            this.graphics.drawOutlineText([
                "Array length: " + str(len(this.array)) + " elements",
                this.__currentCategory + ": " + this.__currentlyRunning,
                "",
                "Writes: " + str(this.writes.writes),
                "Swaps: "  + str(this.writes.swaps),
                "",
                "Reads: "  + str(this.reads.reads),
                "Comparisons: " + str(this.reads.comparisons),
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
            tmp = 400 * signal.sawtooth(2 * numpy.pi  * int(((400 + (this.__adaptAux(this.aux)[i.idx].value * (500 / this.auxMax)))) + 50) * this.__soundSample);
        } else {
            tmp = 400 * signal.sawtooth(2 * numpy.pi  * int(((400 + (this.array[i.idx].value * (500 / this.arrayMax)))) + 50) * this.__soundSample);
        }

        if this.__audioChs > 1 {
            return numpy.repeat(tmp.reshape(tmp.size, 1), this.__audioChs, axis = 1);
        } else {
            return tmp;
        }
    }

    new method playSound(indices) {
        this.graphics.stopPlay([this.__getWaveformFromIdx(i) for i in indices]);
    }

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

                this.playSound(hList);

                if this.__showAux and this.aux is not None {
                    new dynamic auxList;
                    unchecked:
                    hList, auxList = this.__partitionIndices(hList);
                } else {
                    hList = [x.idx for x in hList];
                }

                this.__visual.func(this, this.array, hList, this.__visual.highlightColor);

                if this.__showAux and this.aux is not None {
                    this.__visual.auxFunc(this, this.__adaptAux(this.aux), auxList, this.__visual.highlightColor);
                }

                this.renderStats();

                this.noRedrawUpdate();
                this.__visual.func(this, this.array, set(hList + this.__forceLoadedIndices), "default");

                time.sleep(this.__sleep + this.__tmpSleep);

                this.__tmpSleep = 0;
            } else {
                this.__visual.func(this, this.array, this.__partitionIndices(hList)[0], "default");
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

        new float speed = len(this.array) / 256;

        if speed < 1 {
            this.setSpeed(speed);
        } else {
            this.setSpeed(round(speed));
        }

        for i = a; i < b; i++ {
            time.sleep(this.__sleep);

            this.__visual.func(this, this.array, [i], color);

            if this.__speedCounter >= this.__speed {
                this.__speedCounter = 0;

                this.playSound([HighlightPair(i, False)]);

                if len(this.__forceLoadedIndices) != 0 {
                    if i <= this.__forceLoadedIndices[-1] {
                        this.renderStats();
                    }
                }

                this.noRedrawUpdate();
            }
            this.__speedCounter++;
        }

        this.__checking = False;
    }

    new method setAutoValue(value) {
        this.__autoUserValue = value;
    }

    new method resetAutoValue() {
        this.__autoUserValue = None;
    }

    new method setSpeed(value) {
        match this.__visual.refresh {
            case RefreshMode.FULL {
                value *= 2;
            }
            case RefreshMode.NOREFRESH {
                value /= 2;

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

    new method getUserInput(message = "", default = "", common = [], type_ = int) {
        if this.__autoUserValue is None {
            this.__tui.userInputDialog(this.__currentlyRunning, message, type_, default, common);
            return this.__tui.run();
        } else {
            return this.__autoUserValue;
        }
    }

    new method getUserSelection(content, message = "") {
        if this.__autoUserValue is None {
            this.__tui.selection(this.__currentlyRunning, message, content);
            return this.__tui.run();
        } else {
            return this.__autoUserValue;
        }
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

    new method runSortingProcess(distribution, length, shuffle, categoryName, sortName, speed = 1, mult = 1, autoValue = True, stAutoValue = "default", ndAutoValue = 0, killers = {}) {
        if stAutoValue == "default" {
            stAutoValue = length;
        }

        if autoValue {
            this.setAutoValue(stAutoValue);
        }
        this.generateArray(distribution, shuffle, length);

        if autoValue {
            this.setAutoValue(ndAutoValue);
        }

        if killers != \{} {
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
            new <Value> item = Value(0);
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
                this.__sleep /= 10;
            } else {
                this.__speed *= 5;
            }
            this.__enteredAuxMode = True;

            this.visualSizes.adaptLineLengthAux();
            this.drawFullArray();
        }
    }

    new method resetAux() {
        this.aux = None;
        this.__enteredAuxMode = False;
        this.visualSizes.resetLineLength();
    }

    new method __loadThreadAndRun(thread, initGraph = False) {
        new auto f = open(thread, "r");
        new str threadCode = "";
        for line in f {
            threadCode += line;
        }
        f.close();

        if initGraph {
            this.initGraphics();
        }

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
            this.__tui.selection("Warning", "This thread was not intended to be used as a " + modeI + ". Run anyway?", ["No", "Yes"]);
            return this.__tui.run() == 1;
        }

        return True;
    }

    new method __selectThread(title, run, initGraph = False) {
        new list threads = [];
        new dynamic ldir;
        ldir = os.listdir(os.path.join("HOME_DIR", "threads"));

        for file in ldir {
            if file.endswith(".py") {
                threads.append(file);
            }
        }

        while True {
            this.__tui.selection(title, "Select thread: ", threads);
            new int sel = this.__tui.run();

            new str path = os.path.join("HOME_DIR", "threads", threads[sel]);

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

    $include os.path.join("HOME_DIR", "threadBuilder", "BuilderEvaluator.opal")

    new method run() {
        Utils.Iterables.stableSort(this.distributions);
        Utils.Iterables.stableSort(this.shuffles);
        Utils.Iterables.stableSort(this.visuals);
        Utils.Iterables.stableSort(this.categories);
        Utils.Iterables.stableSort(this.pivotSelections);

        for list_ in this.sorts {
            Utils.Iterables.stableSort(this.sorts[list_]);
        }

        new <Shuffle> threadShuf = Shuffle("Run thread");
        threadShuf.func = this.__threadShuf;
        this.addShuffle(threadShuf);

        this.__tui.setSv(this);

        this.__tui.selection("Mode", "Select mode: ", [
            "Run sort",
            "Run all sorts",
            "Threads"
        ]);
        new int sel = this.__tui.run();

        new bool graphicsInit = True;

        match sel {
            case 0 {
                do opt == 0 {
                    this.__tui.buildSV();
                    new dict runOpts = this.__tui.run();

                    if graphicsInit {
                        this.initGraphics();
                        graphicsInit = False;
                    }

                    this.__visual = this.visuals[runOpts["visual"]];

                    this.generateArray(runOpts["distribution"], runOpts["shuffle"], runOpts["array-size"]);

                    this.setSpeed(runOpts["speed"]);

                    this.runSort(this.categories[runOpts["category"]], id = runOpts["sort"]);

                    this.__resetShufThread();

                    this.__tui.selection("Done", "Continue?", [
                        "Yes",
                        "No"
                    ]);
                    new int opt = this.__tui.run();
                }
            }
            case 1 {
                this.__tui.buildRunAll();
                new dict runOpts = this.__tui.run();

                this.initGraphics();

                $include os.path.join("HOME_DIR", "threads", "runAllSorts.opal")
            }
            case 2 {
                this.__tui.selection("Threads", "Select: ", [
                    "Run thread",
                    "Run thread from threads folder",
                    "Thread builder"
                ]);
                sel = this.__tui.run();

                match sel {
                    case 0 {
                        while True {
                            IO.out("Drag here the thread you want to run\n");
                            new str thread = IO.read("> ").strip().replace('"', '').replace("'", "");

                            if os.path.isfile(thread) {
                                if this.__threadTypeChecker(thread, "Thread") {
                                    break;
                                }
                            } else {
                                UserWarn("Error", "Invalid thread file or input. Please retry.", this.__tui.termSize).run();
                            }
                        }

                        this.__loadThreadAndRun(thread, True);
                    }
                    case 1 {
                        this.__selectThread("Thread", True, True);
                    }
                    case 2 {
                        $include os.path.join("HOME_DIR", "threadBuilder", "ThreadBuilder.opal")
                    }
                }
            }
        }
    }
}

main {
    new <SortingVisualizer> sortingVisualizer = SortingVisualizer();

    $includeDirectory os.path.join("HOME_DIR", "utils")
    $includeDirectory os.path.join("HOME_DIR", "visuals")
    $includeDirectory os.path.join("HOME_DIR", "distributions")
    $includeDirectory os.path.join("HOME_DIR", "pivotSelections")
    $includeDirectory os.path.join("HOME_DIR", "shuffles")
    $includeDirectory os.path.join("HOME_DIR", "sorts")

    sortingVisualizer.run();
}
