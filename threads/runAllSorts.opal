this.setVisual(runOpts["visual"]);

new function runAllSort(size, name, speed, ndAutoValue = 0, killers = {}) {
    this.runSortingProcess(
        runOpts["distribution"], size, runOpts["shuffle"], 
        ct, name, speed, stAutoValue = autoValue * size // 2, 
        ndAutoValue = ndAutoValue, killers = killers
    );
}

new int autoValue;
if runOpts["distribution"] == 1 {
    autoValue = -1;
} else {
    autoValue = 1;
}


new str ct;
ct = "Exchange Sorts";
runAllSort(256,    "Bubble Sort", 80);
runAllSort(256,  "Odd-Even Sort", 20);
runAllSort(128,     "Gnome Sort",  1);
runAllSort(128, "Sandpaper Sort",  1);
runAllSort(512,    "Circle Sort",  5);
runAllSort(1024,     "Comb Sort", 10);


ct = "Insertion Sorts";
runAllSort(256,  "Insertion Sort",     5);
runAllSort(256,  "Binary Insertion",   5);
runAllSort(256,  "Bin. Double Insert", 5);
runAllSort(256,  "Merge Insert",       2);
runAllSort(512,  "Shell Sort",         3);
runAllSort(1024, "Library Sort",       5, killers = {
    "Linear":    ["Reversed", "Reversed Sawtooth"], 
    "Quadratic": ["Reversed", "Reversed Sawtooth"], 
    "Quintic":   ["Reversed", "Reversed Sawtooth"], 
    "Sine Wave": ["Reversed", "Reversed Sawtooth", "No shuffle", "Sawtooth"]
});


ct = "Selection Sorts";
runAllSort(128,  "Selection Sort",   1);
runAllSort(128,  "Double Selection", 1);
runAllSort(64,   "Cycle Sort",       1);


ct = "Tree Sorts";
runAllSort(512,  "Tree Sort",        2);
runAllSort(2048, "Max Heap Sort",   15);
runAllSort(2048, "Poplar Heap",     10);
runAllSort(1024, "Weak Heap Sort",   2);


ct = "Concurrent Sorts";
runAllSort(1024, "Bose Nelson",    7);
runAllSort(1024, "Fold Sort",      5);
runAllSort(1024, "Bitonic Sort",   5);
runAllSort(1024, "Pairwise",       5);
runAllSort(1024, "Odd Even Merge", 5);


ct = "Quick Sorts";

new dict centerKillers = {
    "Linear":    ["Reversed Sawtooth", "Sawtooth"], 
    "Quadratic": ["Reversed Sawtooth", "Sawtooth"], 
    "Quintic":   ["Reversed Sawtooth", "Sawtooth"]
};

runAllSort(1024, "LL Quick Sort", 2, 1, {
    "Linear":    ["Reversed", "Reversed Sawtooth", "Sawtooth", "No shuffle"], 
    "Quadratic": ["Reversed", "Reversed Sawtooth", "Sawtooth", "No shuffle"], 
    "Quintic":   ["Reversed", "Reversed Sawtooth", "Sawtooth", "No shuffle"]
});
runAllSort(1024, "LR Quick Sort",          2, 3, centerKillers);
runAllSort(1024, "Stackless Quick",        2, 2, centerKillers);
runAllSort(1024, "Dual Pivot Quick",       2, killers = centerKillers);
runAllSort(2048, "Median-Of-16 A. Quick", 10);
runAllSort(2048, "PDQ Sort",              10);
runAllSort(1024, "Sqrt Stable Quick",      1);


ct = "Merge Sorts";
runAllSort(1024, "Merge Sort",            5);
runAllSort(1024, "Bottom Up Merge",       3);
runAllSort(256,  "Lazy Stable",           1);
runAllSort(1024, "Adaptive Rotate Merge", 5, 128);
runAllSort(1024, "Uranium Sort",          2);
runAllSort(1024, "Tim Sort",              5);
runAllSort(2048, "Andrey's Merge",        5);


ct = "Block Merge Sorts";
runAllSort(2048, "Wiki Sort",     7);
runAllSort(2048, "Grail Sort",    7);
runAllSort(2048, "Helium Sort",   5, 0);
runAllSort(1024, "Hydrogen Sort", 1);
runAllSort(2048, "Kota Sort",     7);
runAllSort(1024, "Ecta Sort",     1);


ct = "Partition Sorts";
runAllSort(1024, "Pache Sort", 4);


ct = "Distribution Sorts";
runAllSort(1024, "Counting Sort",      2);
runAllSort(1024, "LSD Radix Sort",     2, 4);
runAllSort(1024, "MSD Radix Sort",     2, 4);
runAllSort(1024, "American Flag Sort", 2, 128);
runAllSort(1024, "Feature Sort",       2);
runAllSort(2048, "Static Sort",        5);


ct = "Impractical Sorts";
runAllSort(64, "Stooge Sort", 4);
runAllSort(5,    "Bogo Sort", 1);
runAllSort(5,    "Bozo Sort", 1);