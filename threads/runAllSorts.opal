this.setVisual(runOpts["visual"]);

new int autoValue;
if runOpts["distribution"] == 1 {
    autoValue = -1;
} else {
    autoValue = 1;
}

if this.__record {
    IO.read("Press enter when ready.");
}

new str ct;
ct = "Exchange Sorts";
this.runSortingProcess(runOpts["distribution"], 256, runOpts["shuffle"], ct, "Bubble Sort", 80, stAutoValue = autoValue * 256);
this.runSortingProcess(runOpts["distribution"], 128, runOpts["shuffle"], ct, "Gnome Sort", 1, stAutoValue = autoValue * 128);
this.runSortingProcess(runOpts["distribution"], 512, runOpts["shuffle"], ct, "Circle Sort", 5, stAutoValue = autoValue * 512);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Comb Sort", 10, stAutoValue = autoValue * 1024);

ct = "Insertion Sorts";
this.runSortingProcess(runOpts["distribution"], 256, runOpts["shuffle"], ct, "Insertion Sort", 5, stAutoValue = autoValue * 256);
this.runSortingProcess(runOpts["distribution"], 256, runOpts["shuffle"], ct, "Unstable Insertion", 5, stAutoValue = autoValue * 256);
this.runSortingProcess(runOpts["distribution"], 256, runOpts["shuffle"], ct, "Binary Insertion", 5, stAutoValue = autoValue * 256);
this.runSortingProcess(runOpts["distribution"], 256, runOpts["shuffle"], ct, "Bin. Double Insert", 5, stAutoValue = autoValue * 256);
this.runSortingProcess(runOpts["distribution"], 256, runOpts["shuffle"], ct, "Merge Insert", 2, stAutoValue = autoValue * 256);
this.runSortingProcess(runOpts["distribution"], 512, runOpts["shuffle"], ct, "Shell Sort", 3, stAutoValue = autoValue * 512);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Library Sort", 5, stAutoValue = autoValue * 1024, killers = {"Linear": ["Reversed", "Reversed Sawtooth"], "Quadratic": ["Reversed", "Reversed Sawtooth"], "Quintic": ["Reversed", "Reversed Sawtooth"], "Sine Wave": ["No shuffle", "Reversed", "Sawtooth", "Reversed Sawtooth"]});

ct = "Selection Sorts";
this.runSortingProcess(runOpts["distribution"], 128, runOpts["shuffle"], ct, "Selection Sort", 1, stAutoValue = autoValue * 128);
this.runSortingProcess(runOpts["distribution"], 128, runOpts["shuffle"], ct, "Double Selection", 1, stAutoValue = autoValue * 128);
this.runSortingProcess(runOpts["distribution"], 64, runOpts["shuffle"], ct, "Cycle Sort", 1, stAutoValue = autoValue * 64);
this.runSortingProcess(runOpts["distribution"], 2048, runOpts["shuffle"], ct, "Max Heap Sort", 15, stAutoValue = autoValue * 2048);
this.runSortingProcess(runOpts["distribution"], 2048, runOpts["shuffle"], ct, "Poplar Heap", 10, stAutoValue = autoValue * 2048);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Weak Heap Sort", 2, stAutoValue = autoValue * 1024);

ct = "Concurrent Sorts";
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Bose Nelson", 7, stAutoValue = autoValue * 1024);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Fold Sort", 5, stAutoValue = autoValue * 1024);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Bitonic Sort", 5, stAutoValue = autoValue * 1024);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Pairwise", 5, stAutoValue = autoValue * 1024);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Odd Even Merge", 5, stAutoValue = autoValue * 1024);

new dict centerKillers;
centerKillers = {"Linear": ["Reversed Sawtooth", "Sawtooth"], "Quadratic": ["Reversed Sawtooth", "Sawtooth"], "Quintic": ["Reversed Sawtooth", "Sawtooth"]};
ct = "Quick Sorts";
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "LL Quick Sort", 2, stAutoValue = autoValue * 1024, ndAutoValue = 1, killers = {"Linear": ["Reversed", "Reversed Sawtooth", "Sawtooth", "No shuffle"], "Quadratic": ["Reversed", "Reversed Sawtooth", "Sawtooth", "No shuffle"], "Quintic": ["Reversed", "Reversed Sawtooth", "Sawtooth", "No shuffle"]});
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "LR Quick Sort", 2, stAutoValue = autoValue * 1024, ndAutoValue = 3, killers = centerKillers);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Stackless Quick", 2, stAutoValue = autoValue * 1024, ndAutoValue = 2, killers = centerKillers);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Dual Pivot Quick", 2, stAutoValue = autoValue * 1024, killers = centerKillers);
this.runSortingProcess(runOpts["distribution"], 2048, runOpts["shuffle"], ct, "Median-Of-16 A. Quick", 10, stAutoValue = autoValue * 2048);
this.runSortingProcess(runOpts["distribution"], 2048, runOpts["shuffle"], ct, "PDQ Sort", 10, stAutoValue = autoValue * 2048);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Sqrt Stable Quick", 1, stAutoValue = autoValue * 1024);

ct = "Merge Sorts";
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Merge Sort", 5, stAutoValue = autoValue * 1024);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Bottom Up Merge", 5, stAutoValue = autoValue * 1024);
this.runSortingProcess(runOpts["distribution"], 512, runOpts["shuffle"], ct, "Lazy Stable", 2, stAutoValue = autoValue * 512);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "thatsOven's Adaptive Merge", 5, stAutoValue = autoValue * 1024, ndAutoValue = 512);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Tim Sort", 5, stAutoValue = autoValue * 1024);

ct = "Block Merge Sorts";
this.runSortingProcess(runOpts["distribution"], 2048, runOpts["shuffle"], ct, "Wiki Sort", 7, stAutoValue = autoValue * 2048);
this.runSortingProcess(runOpts["distribution"], 2048, runOpts["shuffle"], ct, "Grail Sort", 7, stAutoValue = autoValue * 2048);

ct = "Distribution Sorts";
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "Counting Sort", 2, stAutoValue = autoValue * 1024);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "LSD Radix Sort", 2, stAutoValue = autoValue * 1024, ndAutoValue = 4);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "MSD Radix Sort", 2, stAutoValue = autoValue * 1024, ndAutoValue = 4);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "American Flag Sort", 2, stAutoValue = autoValue * 1024, ndAutoValue = 128);
this.runSortingProcess(runOpts["distribution"], 1024, runOpts["shuffle"], ct, "featureSort", 2, stAutoValue = autoValue * 1024);
this.runSortingProcess(runOpts["distribution"], 2048, runOpts["shuffle"], ct, "staticSort", 5, stAutoValue = autoValue * 2048);

ct = "Impractical Sorts";
this.runSortingProcess(runOpts["distribution"], 5, runOpts["shuffle"], ct, "Bogo Sort", 1, stAutoValue = autoValue * 5);