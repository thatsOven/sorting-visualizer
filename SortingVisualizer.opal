package opal: import *;

new Vector RESOLUTION = Vector(1280, 720);

new int FREQUENCY_SAMPLE        = 48000,
        FRAME_DIGS              = 9,
        NATIVE_FRAMERATE        = 120,
        RENDER_FRAMERATE        = 60,
        PREVIEW_MOD             = 5,
        MAX_UNCOMPRESSED_FRAMES = 2048;

new float UNIT_SAMPLE_DURATION = 1.0 / 30.0,
          MIN_SLEEP            = 1.0 / NATIVE_FRAMERATE;

new str VERSION = "2023.10.24";

import math, random, time, os, numpy, sys, 
       pygame_gui, json, subprocess, shutil,
       builtins;
package timeit:      import default_timer;
package functools:   import total_ordering;
package traceback:   import format_exception;
package pygame_gui:  import UIManager, elements, windows;
package pygame:      import Rect, image;
package sf2_loader:  import sf2_loader;
package pygame.time: import Clock;
package scipy:       import signal, io;
use exec, getattr, eval;
$args ["--nostatic"]
$define FRAME_NAME os.path.join(SortingVisualizer.IMAGE_BUF, str(this.__currFrame).zfill(FRAME_DIGS) + ".jpg")

enum RefreshMode {
    STANDARD, NOREFRESH, FULL
}

enum RotationMode {
    INDEXED, LENGTHS
}

new function formatException(e) {
    return (''.join(format_exception(e))).replace("<", "&lt;").replace(">", "&gt;");
}

new function getVideoDuration(file) {
    # using ffprobe to avoid adding dependencies

    return float(subprocess.run(
        [
            "ffprobe", "-v", "error", "-show_entries",
            "format=duration", "-of",
            "default=noprint_wrappers=1:nokey=1", file
        ],
        stdout = subprocess.PIPE,
        stderr = subprocess.PIPE
    ).stdout);
}

new function compare(a, b) {
    return (a > b) - (a < b);
}

new dynamic sortingVisualizer = None;

$include os.path.join(HOME_DIR, "GUI.opal")
$include os.path.join(HOME_DIR, "Value.opal")
$include os.path.join(HOME_DIR, "moduleClasses.opal")
$include os.path.join(HOME_DIR, "threadBuilder", "ThreadCommand.opal")

enum ArrayState {
    UNSORTED, SORTED, STABLY_SORTED, CONTENTS_CHANGED
}

new class VisualizerException: Exception {}

new class SortingVisualizer {
    new str SETTINGS_FILE = os.path.join(HOME_DIR, "config.json"),
            IMAGE_BUF     = os.path.join(HOME_DIR, "frames"),
            SOUND_CONFIG  = os.path.join(HOME_DIR, "sounds", "config");

    new method __init__() {
        this.array = [];
        this.aux   = None;
        this.__verifyArray = None;

        this.distributions = [];
        this.shuffles      = [];

        this.visuals = [];
        this.sounds  = [];

        this.sorts      = {};
        this.categories = [];

        this.pivotSelections = [];
        this.rotations       = [];

        this.__fontSize = round(((RESOLUTION.x / 1280.0) + (RESOLUTION.y / 720.0)) * 11);

        this.__visual = None;
        this.__sound  = None;
        this.graphics = Graphics(
            RESOLUTION, caption = "thatsOven's Sorting Visualizer", 
            font = "Times New Roman", fontSize = this.__fontSize, 
            frequencySample = FREQUENCY_SAMPLE
        );
        this.__gui = GUI();

        this.resetStats();

        this.arrayMax = 1.0;
        this.auxMax   = 1.0;

        this.__auxMode    = False;
        this.__dynamicAux = False;
        this.__adaptAux   = this.__defaultAdaptAux;
        this.__adaptIdx   = this.__defaultAdaptIdx;
        this.__oldAuxLen  = 0;
        
        this.__tmpSleep   = 0;
        this.__unitSample = this.__makeSample(UNIT_SAMPLE_DURATION);
        this.resetSpeed();

        this.__currentlyRunning = "";
        this.__currentCategory  = "";

        this.__checking = False;
        this.__prepared = False;

        this.__autoUserValues = Queue();
        this.__shufThread     = None;

        this.__forceLoadedIndices     = {};
        this.__forceLoadedIndicesList = [];
        
        this.__rtHighlightFn = this.multiHighlightAdvanced;
        this.__rtSweepFn     = this.sweep;
        this.__currFrame     = 0;
        this.__iVideo        = 0;
        this.__audioPtr      = 0;
        this.__audio         = None;

        this.__audioChs = this.graphics.getAudioChs()[2];

        this.__loadSettings();

        if this.settings["internal-info"] {
            this.__movingTextSize = Vector(0, this.__fontSize * 20);
        } else {
            this.__movingTextSize = Vector(0, this.__fontSize * 15);
        }
    }

    new method __loadSettings() {
        with open(SortingVisualizer.SETTINGS_FILE, "r") as f {
            this.settings = json.loads(f.read());
        }
    }

    new method _writeSettings() {
        with open(SortingVisualizer.SETTINGS_FILE, "w") as f {
            json.dump(this.settings, f);
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

    new method __makeSample(sTime) {
        return numpy.arange(0, sTime, 1.0 / float(this.graphics.frequencySample));
    }

    new method delay(dTime) {
        new dynamic s = (dTime * max(this.__sleep, 0.001)) / this.__speed - this.__sleep;
        this.__speedCounter = this.__speed;
        this.__soundSample  = this.__makeSample(s);
        this.__tmpSleep     = s;
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
        if this.settings["render"] && !this.settings["lazy-render"] {
            this.__visual.draw(this.array, {});
        } else {
            this.__visual.fastDraw(this.array, {i: None for i in range(len(this.array))});
        }
    }

    new method __getSizes() {
        this.getMax();
        this.__visual.prepare();
        this.__prepared = True;
        this.__forceLoadedIndices     = {};
        this.__forceLoadedIndicesList = [];

        new int worstCaseTextWidth;

        if this.settings["render"] && !this.settings["lazy-render"] {
            return;
        } else {
            match this.__visual.refresh {
                case RefreshMode.STANDARD {
                    if this.settings["show-text"] {
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

            this.__forceLoadedIndices     = {i: None for i in range(round(Utils.translate(worstCaseTextWidth, 0, this.graphics.resolution.x, 0, len(this.array))))};
            this.__forceLoadedIndicesList = sorted([x for x in this.__forceLoadedIndices]);
        }
    }

    new method __runSDModule(mess, func, array, id, name, class_, length = None, unique = None) {
        if id is None and name is None {
            throw VisualizerException(f"Not enough information to start {mess}");
        }

        if id is None {
            new int id;
            id = Utils.Iterables.binarySearch(array, class_(name));

            if id != -1 {
                return func(id, length, unique);
            } else {
                throw VisualizerException(f"Invalid {mess} name");
            }
        } elif name is None {
            if id in range(0, len(array)) {
                return func(id, length, unique);
            } else {
                throw VisualizerException(f"Invalid {mess} ID");
            }
        }
    }

    new method __runDistributionById(id, length, unique) {
        this.array = [None for _ in range(length)];
        this.__currentlyRunning = this.distributions[id].name + " (distribution)";
        this.distributions[id].func(this.array, length);

        new float t = length / unique;
        for i in range(length) {
            this.array[i] = Value(int(t * (this.array[i] // t) + t // 2));
            this.array[i].stabIdx = i;
            this.array[i].idx     = i;
        }

        this.getMax();
        this.__visual.prepare();
        this.__prepared = True;
        this.drawFullArray();
    }

    new method runDistribution(length, unique, id = None, name = None) {
        this.__runSDModule("distribution", this.__runDistributionById, this.distributions, id, name, Distribution, length, unique);
    }

    new method __runShuffleById(id, placeHolder, ndPlaceHolder) {
        this.resetStats();
        this.__dynamicAux       = this.shuffles[id].dynAux;
        this.__currentlyRunning = this.shuffles[id].name;
        this.__currentCategory  = "Shuffles";

        this.__getSizes();

        this.setSpeed(len(this.array) / 128.0);

        this.shuffles[id].func(this.array);

        for i in range(len(this.array)) {
            this.array[i].stabIdx = i;
        }

        this.resetAux();
        this.resetAdaptAux();
        this.drawFullArray();
        this.renderStats();

        if this.settings["render"] {
            image.save(this.graphics.screen, FRAME_NAME);
            this.__currFrame++;
        } else {
            $call update
        }

        this.__verifyArray = [x.value for x in this.array];
        Utils.Iterables.fastSort(this.__verifyArray);
    }

    new method runShuffle(id = None, name = None) {
        this.__runSDModule("shuffle", this.__runShuffleById, this.shuffles, id, name, Shuffle);
    }

    new method __getPivotSelectionById(id, placeHolder, ndPlaceHolder) {
        return this.pivotSelections[id];
    }

    new method getPivotSelection(id = None, name = None) {
        return this.__runSDModule("pivot selection", this.__getPivotSelectionById, this.pivotSelections, id, name, PivotSelection).getFunc();
    }

    new method __getRotationById(id, placeHolder, ndPlaceHolder) {
        return this.rotations[id];
    }

    new method getRotation(id = None, name = None) {
        return this.__runSDModule("rotation", this.__getRotationById, this.rotations, id, name, Rotation);
    }

    new method __getVSModule(mess, array, id, name) {
        if id is None and name is None {
            throw VisualizerException(f"Not enough information to start {mess}");
        }

        if id is None {
            new int a = 0,
                    b = len(array),
                    id, cmp;
    
            while a < b {
                id = a + (b - a) / 2;

                cmp = compare(name, array[id].name);
                if cmp == 0 {
                    return array[id];
                }

                if cmp < 0 {
                    b = id;
                } else {
                    a = id + 1;
                }
            }

            throw VisualizerException(f"Invalid {mess} name");
        } elif name is None {
            if id in range(0, len(array)) {
                return array[id];
            } else {
                throw VisualizerException(f"Invalid {mess} ID");
            }
        }
    }

    new method _setSound(id = None, name = None) {
        this.__sound = this.__getVSModule("sound", this.sounds, id, name);
        this.__sound.prepare();
    }

    new method _refreshSoundConf() {
        this.__sound.prepare();
    }

    new method setVisual(id = None, name = None) {
        this.__visual = this.__getVSModule("visual style", this.visuals, id, name);
        this.__prepared = False;
    }

    new method __runSortById(category, id) {
        this.resetStats();
        this.__dynamicAux       = this.sorts[category][id].dynAux;
        this.__currentlyRunning = this.sorts[category][id].name;
        this.__currentCategory  = category;

        if this.settings["render"] {
            this.__renderedSleep(1.25);
        } else {
            time.sleep(1.25);
        }

        this.drawFullArray();

        this.sorts[category][id].func(this.array);

        this.resetAux();
        this.resetAdaptAux();
        this.drawFullArray();

        this.printArrayState();
    }

    new method runSort(category, id = None, name = None) {
        if id is None and name is None {
            throw VisualizerException("No id or name given to runSort");
        }

        if id is None {
            new int id;
            id = Utils.Iterables.binarySearch(this.sorts[category], Sort("", "", name));

            if id != -1 {
                this.__runSortById(category, id);
            } else {
                throw VisualizerException(f'Invalid sort name "{name}"');
            }
        } elif name is None {
            if id in range(0, len(this.sorts)) {
                this.__runSortById(category, id);
            } else {
                throw VisualizerException(f'Invalid sort ID "{id}"');
            }
        }
    }

    new method generateArray(selectedDistributionIdx, selectedShuffleIdx, length, unique) {
        this.runDistribution(length, unique, id = selectedDistributionIdx);
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

        new int eq = len(this.array) - 1;
        for i in range(len(this.array)) {
            if this.array[i].value != this.__verifyArray[i] {
                eq = i - 1;
                break;
            }
        }

        if sUntil == len(this.array) - 1 && eq == len(this.array) - 1 {
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
                    this.sweep(currentIdx, len(this.array), (255, 255, 0), 
                        hList = (
                            {x: (0, 0, 255) for x in range(currentIdx)} | 
                            {x: (0, 255, 0) for x in range(currentIdx, len(this.array))}
                        ) if this.settings["render"] else None
                    );

                    return ArrayState.SORTED;
                }

                this.sweep(currentIdx, currentIdx + len(stabilityCheck[unique]), (0, 0, 255), 
                    hList = (
                        {x: (0, 0, 255) for x in range(currentIdx)} | 
                        {x: (0, 255, 0) for x in range(currentIdx, len(this.array))}
                    ) if this.settings["render"] else None
                );
                currentIdx += len(stabilityCheck[unique]);
            }

            return ArrayState.STABLY_SORTED;

        } else {
            new int p = min(sUntil, eq);
            this.sweep(0,               p, (0, 255, 0));
            this.sweep(p, len(this.array), (255, 0, 0), 
                hList = {x: (0, 255, 0) for x in range(currentIdx)} if this.settings["render"] else None
            );

            if sUntil != len(this.array) - 1 {
                return ArrayState.UNSORTED;
            } else {    
                return ArrayState.CONTENTS_CHANGED;
            }
        }
    }

    new method printArrayState() {
        new str sortName = this.__currentlyRunning;

        this.setCurrentlyRunning("Checking...", "");
        new int state = this.checkArrayState();

        new tuple color;
        match state {
            case ArrayState.UNSORTED {
                this.setCurrentlyRunning("The list was not sorted", "");
                IO.out(sortName, " has failed\n");
            }
            case ArrayState.CONTENTS_CHANGED {
                this.setCurrentlyRunning("The list's original contents were changed", "");
                IO.out(sortName, " has failed (contents changed)\n");
            }
            case ArrayState.SORTED {
                this.setCurrentlyRunning("The list was sorted", "");
                IO.out(sortName, " sorted the list unstably\n");
            }
            case ArrayState.STABLY_SORTED {
                this.setCurrentlyRunning("The list was sorted stably", "");
                IO.out(sortName, " sorted the list stably\n");
            }
        }

        this.drawFullArray();
        this.renderStats();
        
        if this.settings["render"] {
            this.__renderedSleep(1.25);
        } else {
            $call update
            time.sleep(1.25);
        }
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

    new method addSound(snd) {
        this.sounds.append(snd);
    }

    new method renderStats() {
        if not this.settings["show-text"] {
            return;
        }

        new dynamic pos = Vector(2, 2), ete;

        ete = "Estimated time elapsed: " + ((str(round(this.time, 4)) + " ms") if this.time < 1000 else (str(round(this.time / 1000, 4)) + " s"));
        this.__movingTextSize.x = (len(ete) * this.__fontSize) // 2;

        if this.__visual.out and not this.__checking {
            this.graphics.fastRectangle(pos, this.__movingTextSize, (0, 0, 0));
        }

        if this.settings["internal-info"] {
            this.graphics.drawOutlineText([
                "Array length: " + str(len(this.array)) + " elements",
                this.__currentCategory + ": " + this.__currentlyRunning,
                "",
                "Dropped frames: " + this.__dFramesPerc,
                "Current delay: " + str(round((this.__sleep + this.__tmpSleep) * 1000, 2)) + " ms",
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

    new method __defaultAdaptIdx(idx, aux) {
        return idx;
    }

    new method setAdaptAux(func, idxFn = None) {
        this.__adaptAux = func;

        if idxFn is not None {
            this.__adaptIdx = idxFn;
        } else {
            this.__adaptIdx = this.__defaultAdaptIdx;
        }
    }

    new method resetAdaptAux() {
        this.__adaptAux = this.__defaultAdaptAux;
        this.__adaptIdx = this.__defaultAdaptIdx;
    }

    new method __getWaveformFromIdx(i, adapted) {
        new dynamic tmp;

        if i.aux and this.aux is not None {
            tmp = this.__sound.play(adapted[i.idx].value, this.auxMax, this.__soundSample);
        } else {
            tmp = this.__sound.play(this.array[i.idx].value, this.arrayMax, this.__soundSample);
        }

        if this.__audioChs > 1 {
            return numpy.repeat(tmp.reshape(tmp.size, 1), this.__audioChs, axis = 1).astype(numpy.int16);
        } else {
            return tmp.astype(numpy.int16);
        }
    }

    $macro playSound(hList, adapted)
        this.graphics.playWaveforms([this.__getWaveformFromIdx(x, adapted) for x in hList]);
    $end

    new method __partitionIndices(hList) {
        new dynamic internal = {},
                    aux      = {};

        for i in range(len(hList)) {
            if hList[i].aux is not None {
                if hList[i].color is None {
                    aux[hList[i].idx] = this.__visual.highlightColor;
                } else {
                    aux[hList[i].idx] = hList[i].color;
                }
            } else {
                if hList[i].color is None {
                    internal[hList[i].idx] = this.__visual.highlightColor;
                } else {
                    internal[hList[i].idx] = hList[i].color;
                }
            }
        }

        return internal, aux;
    }

    $macro auxSect
        if this.__dynamicAux && !this.settings["lazy-aux"] {
            length = len(adapted);

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
        }
    $end

    new method multiHighlightAdvanced(hList) {
        new dynamic sTime = default_timer();
        hList = [x for x in hList if x is not None];
        hList = [x for x in hList if x.idx is not None];

        static {
            new int length;
            new bint aux;
        }

        if len(hList) != 0 {
            if this.__speedCounter >= this.__speed {
                this.__speedCounter = 0;
                
                aux = this.settings["show-aux"] and this.aux is not None;
                new dynamic adapted = this.__adaptAux(this.aux) if aux else None;

                if this.settings["show-aux"] {
                    if aux && this.__adaptIdx is not this.__defaultAdaptIdx {
                        for i in range(len(hList)) {
                            if hList[i].aux is not None {
                                hList[i].idx = this.__adaptIdx(hList[i].idx, hList[i].aux);
                            }
                        }
                    }
                } else {
                    length = len(this.array);

                    for i in range(len(hList)) {
                        if hList[i].aux is not None {
                            hList[i].idx = hList[i].idx % length;
                            hList[i].aux = None;
                        }
                    }
                }
                
                $call playSound(hList, adapted)

                if aux {
                    new dynamic auxList;
                    hList, auxList = this.__partitionIndices(hList);
                } else {
                    hList = this.__partitionIndices(hList)[0];
                }

                this.__visual.fastDraw(this.array, hList);

                if aux {
                    $call auxSect
                    this.__visual.fastDrawAux(adapted, auxList);
                }

                this.renderStats();

                $call update

                for highlight in hList {
                    hList[highlight] = None;
                }

                this.__visual.fastDraw(this.array, hList | this.__forceLoadedIndices);
                this.__soundSample = this.__currSample;

                new dynamic tTime = max(this.__sleep + this.__tmpSleep, MIN_SLEEP) - default_timer() + sTime;
                if tTime > 0 {
                    time.sleep(tTime);
                }
                
                this.__tmpSleep = 0;
            } else {
                hList = this.__partitionIndices(hList)[0];

                for highlight in hList {
                    hList[highlight] = None;
                }

                this.__visual.fastDraw(this.array, hList);
            }
        } elif this.__speedCounter >= this.__speed {
            this.__speedCounter = 0;
        }

        this.__speedCounter++;
    }

    new method __videoGen() {
        new dynamic cwd = os.getcwd();
        os.chdir(SortingVisualizer.IMAGE_BUF);

        use f;
        with open("input.txt", "w") as f {
            for i in range(this.__currFrame) {
                f.write("file " + str(i).zfill(FRAME_DIGS) + f".jpg\nduration {1 / RENDER_FRAMERATE}\n");
            }
        }

        this.__currFrame = 0;

        this.__gui.saveBackground();
        this.__gui.renderScreen(subprocess.Popen([
            "ffmpeg", "-y", "-r", str(RENDER_FRAMERATE), "-f", "concat", "-i", "input.txt", 
            "-c:v", "libx264", "-pix_fmt", "yuvj420p", "tmp.mp4",
        ]), "Compressing frames...");
        
        this.__audio = this.__audio[:round(this.__audioPtr)];
        io.wavfile.write("audio.wav", FREQUENCY_SAMPLE, this.__audio);
        this.__audio    = None;
        this.__audioPtr = 0;

        this.__gui.renderScreen(subprocess.Popen([
            "ffmpeg", "-i", "tmp.mp4", "-i", "audio.wav",
            "-c:v", "copy", "-map", "0:v", "-map", "1:a",
            "-y", str(this.__iVideo).zfill(FRAME_DIGS) + ".mp4"
        ]), "Adding audio...");

        this.__iVideo++;
        
        return cwd;
    }

    $macro imgSave
        image.save(this.graphics.screen, FRAME_NAME);
        this.__currFrame++;
    $end

    $macro checkCompress
        if this.__currFrame >= MAX_UNCOMPRESSED_FRAMES {
            os.chdir(this.__videoGen());
        }
    $end

    $macro mixAudio(d)
        if this.__audio is None {
            this.__audio = currWave;
        } else {
            if round(this.__audioPtr) < len(this.__audio) {
                new dynamic zeros = numpy.zeros(round(this.__audioPtr));
                if this.__audioChs > 1 {
                    zeros = numpy.repeat(zeros.reshape(zeros.size, 1), this.__audioChs, axis = 1).astype(numpy.int16);
                } else {
                    zeros = zeros.astype(numpy.int16);
                }

                if round(this.__audioPtr) + len(currWave) <= len(this.__audio) {
                    new dynamic fillerZeros = numpy.zeros(len(this.__audio) - len(currWave) - round(this.__audioPtr));
                    if this.__audioChs > 1 {
                        fillerZeros = numpy.repeat(fillerZeros.reshape(fillerZeros.size, 1), this.__audioChs, axis = 1).astype(numpy.int16);
                    } else {
                        fillerZeros = fillerZeros.astype(numpy.int16);
                    }

                    this.__audio += numpy.concatenate((zeros, currWave, fillerZeros));
                } else {
                    new dynamic size = len(this.__audio) - round(this.__audioPtr);

                    this.__audio += numpy.concatenate((zeros, currWave[:size]));

                    this.__audio = numpy.concatenate((
                        this.__audio, currWave[size:]
                    ));
                }
            } else {
                this.__audio = numpy.concatenate((
                    this.__audio, currWave
                ));
            }
        }

        for t = 1.0 / RENDER_FRAMERATE; t < d; t += 1.0 / RENDER_FRAMERATE {}
        this.__audioPtr += t * FREQUENCY_SAMPLE;
    $end

    new method __renderedSleep(t) {
        new dynamic currWave = numpy.zeros(round(t * FREQUENCY_SAMPLE));

        if this.__audioChs > 1 {
            currWave = numpy.repeat(currWave.reshape(currWave.size, 1), this.__audioChs, axis = 1).astype(numpy.int16);
        } else {
            currWave = currWave.astype(numpy.int16);
        }

        $call mixAudio(t)

        for i = 0; i < t; i += 1.0 / RENDER_FRAMERATE {
            $call imgSave
        }

        $call checkCompress
    }

    new method __renderedHighlight(hList) {
        hList = [x for x in hList if x is not None];
        hList = [x for x in hList if x.idx is not None];
        new dynamic lazy = this.settings["lazy-render"];

        this.graphics.updateEvents();

        static {
            new int  length;
            new bint aux;
        }

        if len(hList) != 0 {
            if this.__speedCounter >= this.__speed {
                this.__speedCounter = 0;
                
                aux = this.settings["show-aux"] and this.aux is not None;
                new dynamic adapted = this.__adaptAux(this.aux) if aux else None;

                if this.settings["show-aux"] {
                    if aux && this.__adaptIdx is not this.__defaultAdaptIdx {
                        for i in range(len(hList)) {
                            if hList[i].aux is not None {
                                hList[i].idx = this.__adaptIdx(hList[i].idx, hList[i].aux);
                            }
                        }
                    }
                } else {
                    length = len(this.array);

                    for i in range(len(hList)) {
                        if hList[i].aux is not None {
                            hList[i].idx = hList[i].idx % length;
                            hList[i].aux = None;
                        }
                    }
                }

                new dynamic tSleep = max(1.0 / RENDER_FRAMERATE, this.__sleep + this.__tmpSleep);
                this.__soundSample = this.__makeSample(max(tSleep, UNIT_SAMPLE_DURATION));
                
                new dynamic currWave = this.__getWaveformFromIdx(hList[0], adapted);
                for h in hList {
                    currWave += this.__getWaveformFromIdx(h, adapted);
                }

                $call mixAudio(tSleep)

                if aux {
                    new dynamic auxList;
                    hList, auxList = this.__partitionIndices(hList);
                } else {
                    hList = this.__partitionIndices(hList)[0];
                }

                if lazy {
                    this.__visual.fastDraw(this.array, hList);
                } else {
                    this.graphics.fill((0, 0, 0));
                    this.__visual.draw(this.array, hList);
                }
                
                if aux {
                    $call auxSect

                    if lazy {
                        this.__visual.fastDrawAux(adapted, auxList);
                    } else {
                        this.__visual.drawAux(adapted, auxList);
                    }
                }

                this.renderStats();

                if this.__currFrame % PREVIEW_MOD == 0 {
                    $call update
                }

                for i = 0; i < tSleep; i += 1.0 / RENDER_FRAMERATE {
                    $call imgSave
                }

                $call checkCompress
                
                if lazy {
                    for highlight in hList {
                        hList[highlight] = None;
                    }

                    this.__visual.fastDraw(this.array, hList | this.__forceLoadedIndices);
                }
                
                this.__tmpSleep = 0;
            } else {
                if lazy {
                    hList = this.__partitionIndices(hList)[0];

                    for highlight in hList {
                        hList[highlight] = None;
                    }

                    this.__visual.fastDraw(this.array, hList);
                }
            }
        } elif this.__speedCounter >= this.__speed {
            this.__speedCounter = 0;
        }

        this.__speedCounter++;
    }

    new method highlightAdvanced(hInfo) {
        this.multiHighlightAdvanced([hInfo]);
    }

    new method multiHighlight(hList, aux = False) {
        this.multiHighlightAdvanced([HighlightInfo(x, aux, None) for x in hList]);
    }

    new method highlight(index, aux = False) {
        this.highlightAdvanced(HighlightInfo(index, aux, None));
    }

    new method sweep(a, b, color, hList = None) {
        this.renderStats();
        this.__checking = True;

        this.setSpeed(len(this.array) / 128.0);
        new dynamic sleep = max(this.__sleep, MIN_SLEEP);
        
        for i = a; i < b; i++ {
            new dynamic sTime = default_timer();
            this.__visual.fastDraw(this.array, {i: color});

            if this.__speedCounter >= this.__speed {
                this.__speedCounter = 0;

                this.graphics.playWaveforms([this.__getWaveformFromIdx(HighlightInfo(i, None, color), None)]);

                if len(this.__forceLoadedIndices) != 0 && i <= this.__forceLoadedIndicesList[-1] {
                    this.renderStats();
                }
            
                $call update

                new dynamic tTime = sleep - default_timer() + sTime;
                if tTime > 0 {
                    time.sleep(tTime);
                }    
            }

            this.__speedCounter++;
        }

        this.__checking = False;
    }

    new method __renderedSweep(a, b, color, hList = None) {
        if hList is None {
            hList = {};
        }

        this.renderStats();
        this.__checking = True;

        this.setSpeed(len(this.array) / 128.0);

        new dynamic lazy = this.settings["lazy-render"];
        new dynamic tSleep = max(1.0 / RENDER_FRAMERATE, this.__sleep);
        this.__soundSample = this.__makeSample(max(tSleep, UNIT_SAMPLE_DURATION));

        for i = a; i < b; i++ {
            this.graphics.updateEvents();

            new dynamic hInfo = HighlightInfo(i, None, color);
            
            if lazy {
                this.__visual.fastDraw(this.array, {i: color});
            } else {
                hList[i] = color;
            }

            if this.__speedCounter >= this.__speed {
                this.__speedCounter = 0;

                new dynamic currWave = this.__getWaveformFromIdx(hInfo, None);
                $call mixAudio(tSleep)
                
                if lazy {
                    if len(this.__forceLoadedIndices) != 0 && i <= this.__forceLoadedIndicesList[-1] {
                        this.renderStats();
                    }
                } else {
                    this.__visual.draw(this.array, hList);
                    this.renderStats();
                }

                if this.__currFrame % PREVIEW_MOD == 0 {
                    $call update
                }

                for j = 0; j < tSleep; j += 1.0 / RENDER_FRAMERATE {
                    $call imgSave
                }

                $call checkCompress
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
        if this.settings["render"] {
            value *= NATIVE_FRAMERATE / RENDER_FRAMERATE;
        }

        if value >= 1 {
            this.__speed       = round(value);
            this.__sleep       = 0;
            this.__currSample  = this.__unitSample;
            this.__dFramesPerc = str(round(((value - 1) / value) * 100, 4)) + "%";
        } else {
            this.__speed       = 1;
            this.__sleep       = 0.001 / value;
            this.__dFramesPerc = "0%";

            if this.__sleep > UNIT_SAMPLE_DURATION {
                this.__currSample = this.__makeSample(this.__sleep);
            } else {
                this.__currSample = this.__unitSample;
            }
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
        this.__currSample   = this.__unitSample;
        this.__soundSample  = this.__unitSample;
        this.__speedCounter = 0;
        this.__dFramesPerc  = "0%";
    }

    new method setCurrentlyRunning(name, category = None) {
        this.__currentlyRunning = name;

        if category is not None {
            this.__currentCategory = category;
        }
    }

    new method getUserInput(message = "", default = "", type_ = int) {
        if this.__autoUserValues.isEmpty() {
            this.__gui.saveBackground();
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
            this.__gui.saveBackground();
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
        this.__gui.saveBackground();
        this.__gui.userWarn(this.__currentlyRunning, message);
    }

    new method __reportException(e) {
        if this.__prepared {
            this.resetAux();
            this.resetAdaptAux();
            this.drawFullArray();
            this.renderStats();
        }

        new str f = formatException(e);
        IO.out(f, IO.endl);
        this.__gui.saveBackground();
        this.__gui.userWarn("Exception occurred", f);
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

    new method runSortingProcess(distribution, length, unique, shuffle, categoryName, sortName, speed = 1.0, mult = 1.0, killers = {}) {
        try {
            this.generateArray(distribution, shuffle, length, unique);

            if (killers != {}) {
                if shuffle in this.getKillerIds(killers, distribution) {
                    this.__speed = 50;
                } else {
                    this.setSpeed(speed * mult);
                }
            } else {
                this.setSpeed(speed * mult);
            }

            this.runSort(categoryName, name = sortName);
            this.resetSpeed();
        } catch Exception as e {
            this.__reportException(e);
        }   
    }

    new method createValueArray(length) {
        new list result = [];

        for i in range(length) {
            new Value item = Value(0);
            item.idx = i;
            item.stabIdx = i;
            item.setAux(result);
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

        if this.settings["show-aux"] and not this.__auxMode {
            this.__auxMode = True;
            new dynamic adapted = this.__adaptAux(this.aux);

            this.getAuxMax(adapted);

            if (!this.__dynamicAux) || this.settings["lazy-aux"] {
                this.auxMax = max(this.auxMax, this.arrayMax);
            }

            this.__visual.onAuxOn(len(adapted));
            this.drawFullArray();
        }
    }

    new method resetAux() {
        this.aux = None;
        this.__dynamicAux = False;
        this.__auxMode    = False;
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
            this.__reportException(e);
        }
    }

    new method __threadTypeChecker(path, modeI) {
        new auto f = open(path, "r");
        new list defLines = f.read().split("\n")[:2];
        f.close();
        new str version = defLines[0][2:].strip(),
                mode    = defLines[1][1:].strip();

        if version != VERSION {
            this.__gui.userWarn("Error - Incompatible", "This thread was built with an older version of this sorting visualizer.");
            return False;
        }

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

    new method __finalizeRender() {
        if this.settings["render"] && this.__audio is not None {
            new dynamic cwd;
            if this.__currFrame != 0 {
                cwd = this.__videoGen();
            } else {
                cwd = os.getcwd();
                os.chdir(SortingVisualizer.IMAGE_BUF);
            }

            use f;
            with open("input.txt", "w") as f {
                for i in range(this.__iVideo) {
                    new dynamic fileName = str(i).zfill(FRAME_DIGS) + ".mp4";
                    f.write("file " + fileName + f"\nduration {round(getVideoDuration(fileName), 4)}\n");
                }
            }

            this.__iVideo = 0;

            this.__gui.saveBackground();
            this.__gui.renderScreen(subprocess.Popen([
                "ffmpeg", "-y", "-r", str(RENDER_FRAMERATE), "-f", "concat", "-i", "input.txt", 
                "-c:v", "libx264", "-pix_fmt", "yuvj420p", "output.mp4",
            ]), "Merging videos...");

            os.chdir(cwd);
            shutil.copy(os.path.join(SortingVisualizer.IMAGE_BUF, "output.mp4"), cwd);
            shutil.rmtree(SortingVisualizer.IMAGE_BUF);
            this.__makeImageBufFolder();
        }
    }

    new method _makeSoundConfFolder() {
        if !os.path.exists(SortingVisualizer.SOUND_CONFIG) {
            os.mkdir(SortingVisualizer.SOUND_CONFIG);
        }
    }

    new method __makeImageBufFolder() {
        if !os.path.exists(SortingVisualizer.IMAGE_BUF) {
            try {
                os.mkdir(SortingVisualizer.IMAGE_BUF);
            } catch Exception as e {
                this.__gui.userWarn("Error", f"Unable to create image buffer folder. Exception:\n{formatException(e)}");
                quit;
            }
        }
    }

    new method fileDialog(allowed = None, initPath = None) {
        return this.__gui.fileDialog(allowed, initPath);
    }

    new method run() {
        this.graphics.event(QUIT)(lambda _: quit());

        Utils.Iterables.stableSort(this.distributions);
        Utils.Iterables.stableSort(this.shuffles);
        Utils.Iterables.stableSort(this.visuals);
        Utils.Iterables.stableSort(this.categories);
        Utils.Iterables.stableSort(this.pivotSelections);
        Utils.Iterables.stableSort(this.rotations);
        Utils.Iterables.stableSort(this.sounds);

        for list_ in this.sorts {
            Utils.Iterables.stableSort(this.sorts[list_]);
        }

        new Shuffle threadShuf = Shuffle("Run thread");
        threadShuf.func = this.__threadShuf;
        this.addShuffle(threadShuf);

        try {
            this._makeSoundConfFolder();
        } catch Exception as e {
            this.__gui.userWarn("Error", f"Unable to create sound configuration folder. Exception:\n{formatException(e)}");
            quit;
        }

        this.__gui.setSv(this);
        this._setSound(name = this.settings["sound"]);

        while True {
            if this.settings["render"] {
                this.__makeImageBufFolder();
                this.multiHighlightAdvanced = this.__renderedHighlight;
                this.sweep                  = this.__renderedSweep;
            } else {
                this.multiHighlightAdvanced = this.__rtHighlightFn;
                this.sweep                  = this.__rtSweepFn;
            }

            new int sel = this.__gui.selection("Mode", "Select mode: ", [
                "Run sort",
                "Run all sorts",
                "Threads",
                "Settings"
            ]);

            match sel {
                case 0 {
                    do opt == 0 {
                        this.__gui.saveBackground();
                        new dict runOpts = this.__gui.runSort();

                        try {
                            this.setVisual(runOpts["visual"]);
                            this.generateArray(runOpts["distribution"], runOpts["shuffle"], runOpts["array-size"], runOpts["unique"]);
                            this.setSpeed(runOpts["speed"]);
                            this.runSort(this.categories[runOpts["category"]], id = runOpts["sort"]);
                        } catch Exception as e {
                            this.__reportException(e);
                        } 

                        this.__resetShufThread();
                        this.__finalizeRender();

                        this.__gui.saveBackground();
                        new int opt = this.__gui.selection("Done", "Continue?", [
                            "Yes",
                            "No"
                        ]);
                    }
                }
                case 1 {
                    new dict runOpts = this.__gui.runAll();
                    $include os.path.join(HOME_DIR, "threads", "runAllSorts.opal")
                    this.__finalizeRender();
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
                            this.__finalizeRender();
                        }
                        case 1 {
                            $include os.path.join(HOME_DIR, "threadBuilder", "ThreadBuilder.opal")
                        }
                    }
                }
                case 3 {
                    this.__gui.settings();
                }
            }
        }
    }
}

main {
    sys.setrecursionlimit(65536);
    os.chdir(HOME_DIR);

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

    namespace Sounds {
        $includeDirectory os.path.join(HOME_DIR, "sounds")
    }

    new dynamic defaultIsInstance = builtins.isinstance;

    new function _customIsinstance(instance, cls) {
        if type(instance) is Sounds._FakeMPNote {
            return True;
        }

        return defaultIsInstance(instance, cls);
    }

    builtins.isinstance = _customIsinstance;

    for sound in dir(Sounds) {
        if !sound.startswith("_") {
            getattr(Sounds, sound)();
        }
    }

    $includeDirectory os.path.join(HOME_DIR, "distributions")
    $includeDirectory os.path.join(HOME_DIR, "pivotSelections")
    $includeDirectory os.path.join(HOME_DIR, "rotations")
    $includeDirectory os.path.join(HOME_DIR, "shuffles")
    $includeDirectory os.path.join(HOME_DIR, "sorts")

    sortingVisualizer.run();
}
