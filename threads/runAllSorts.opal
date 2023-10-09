this.setVisual(runOpts["visual"]);

new function runAllSort(size, name, speed, toPush = [], killers = {}) {
    if type(toPush) in (list, tuple) {
        for item in toPush {
            this.pushAutoValue(item);
        }
    } else {
        this.pushAutoValue(toPush);
    }

    this.runSortingProcess(
        runOpts["distribution"], size, autoValue * size // 2, 
        runOpts["shuffle"], ct, name, speed * runOpts["speed"], 
        killers = killers
    );
}

new int autoValue;
if runOpts["distribution"] == 1 {
    autoValue = -1;
} else {
    autoValue = 1;
}

new list pivotSelections = [p.name for p in this.pivotSelections],
         rotations       = [r.name for r in this.rotations];


new str ct;
ct = "Exchange Sorts";
runAllSort(256,    "Bubble Sort", 80);
runAllSort(256,  "Odd-Even Sort", 20);
runAllSort(128,     "Gnome Sort",  3);
runAllSort(128, "Sandpaper Sort",  3);
runAllSort(512,    "Circle Sort",  5);
runAllSort(1024,     "Comb Sort", 10, 1.3);


ct = "Insertion Sorts";
runAllSort(256,  "Insertion Sort",     8);
runAllSort(256,  "Binary Insertion",   6);
runAllSort(256,  "Bin. Double Insert", 5);
runAllSort(256,  "Merge Insert",       5);
runAllSort(512,  "Shell Sort",         3);
runAllSort(1024, "Library Sort",       8, killers = {
    "Linear":    ["Reversed", "Reversed Sawtooth"], 
    "Quadratic": ["Reversed", "Reversed Sawtooth"], 
    "Quintic":   ["Reversed", "Reversed Sawtooth"], 
    "Sine Wave": ["Reversed", "Reversed Sawtooth", "No shuffle", "Sawtooth"]
});


ct = "Selection Sorts";
runAllSort(128,  "Selection Sort",   3);
runAllSort(128,  "Double Selection", 3);
runAllSort(64,   "Cycle Sort",       3);


ct = "Tree Sorts";
runAllSort(512,  "Tree Sort",        5, killers = {
    "Linear":    ["Reversed", "Reversed Sawtooth", "No Shuffle", "Sawtooth"],
    "Quadratic": ["Reversed", "Reversed Sawtooth", "No Shuffle", "Sawtooth"],
    "Quintic":   ["Reversed", "Reversed Sawtooth", "No Shuffle", "Sawtooth", "Random"],
    "Sine Wave": ["Reversed", "Reversed Sawtooth", "No shuffle", "Sawtooth"]
});
runAllSort(2048, "Max Heap Sort",   15);
runAllSort(2048, "Poplar Heap",     10);
runAllSort(1024, "Weak Heap Sort",   5);


ct = "Concurrent Sorts";
runAllSort(1024, "Bose Nelson",    7);
runAllSort(1024, "Fold Sort",      7);
runAllSort(1024, "Bitonic Sort",   5);
runAllSort(1024, "Pairwise",       5);
runAllSort(1024, "Odd Even Merge", 5);


ct = "Quick Sorts";

new dict centerKillers = {
    "Linear":    ["Reversed Sawtooth", "Sawtooth"], 
    "Quadratic": ["Reversed Sawtooth", "Sawtooth"], 
    "Quintic":   ["Reversed Sawtooth", "Sawtooth"]
};

runAllSort(1024, "LL Quick Sort", 4, pivotSelections.index("First"), {
    "Linear":    ["Reversed", "Reversed Sawtooth", "Sawtooth", "No shuffle"], 
    "Quadratic": ["Reversed", "Reversed Sawtooth", "Sawtooth", "No shuffle"], 
    "Quintic":   ["Reversed", "Reversed Sawtooth", "Sawtooth", "No shuffle"],
    "Sine Wave": ["Reversed", "Reversed Sawtooth", "Sawtooth", "No shuffle"],
});
runAllSort(1024, "LR Quick Sort",          4, pivotSelections.index("Middle"), centerKillers);
runAllSort(1024, "Stackless Quick",        4, pivotSelections.index("Median of three"), centerKillers);
runAllSort(1024, "Dual Pivot Quick",       4, killers = centerKillers);
runAllSort(2048, "Median-Of-16 A. Quick", 10);
runAllSort(2048, "PDQ Sort",              10); 
runAllSort(1024, "Aeos Quick",             3);
runAllSort(1024, "Log Sort",               3, 0);


ct = "Merge Sorts";
runAllSort(1024, "Merge Sort",            8);
runAllSort(1024, "Bottom Up Merge",       5);
runAllSort(256,  "Lazy Stable",           4, rotations.index("Gries-Mills"));
runAllSort(1024, "Adaptive Rotate Merge", 5, [128, rotations.index("Helium")]);
runAllSort(1024, "Uranium Sort",          2, rotations.index("Helium"));
runAllSort(1024, "Tim Sort",              5);
runAllSort(2048, "Andrey's Merge",        8);
runAllSort(2048, "Buf Merge 2",           7, rotations.index("Helium"));


ct = "Block Merge Sorts";
runAllSort(2048, "Wiki Sort",     7, [0, rotations.index("Triple Reversal")]);
runAllSort(2048, "Grail Sort",    7, [0, rotations.index("Gries-Mills")]);
runAllSort(2048, "Helium Sort",   3, [0, rotations.index("Helium")]);
runAllSort(1024, "Hydrogen Sort", 4, rotations.index("Helium"));
runAllSort(2048, "Kota Sort",     7, rotations.index("Cycle Reverse"));
runAllSort(1024, "Ecta Sort",     4);
runAllSort(2048, "Lithium Sort",  5, rotations.index("Helium"));


ct = "Partition Sorts";
runAllSort(1024, "Pache Sort", 5);


ct = "Distribution Sorts";
runAllSort(1024, "Counting Sort",      4);
runAllSort(1024, "LSD Radix Sort",     4, 4);
runAllSort(1024, "MSD Radix Sort",     4, 4);
runAllSort(1024, "American Flag Sort", 4, 128);
runAllSort(1024, "Feature Sort",       3);
runAllSort(1024, "Static Sort",        3);


ct = "Impractical Sorts";
runAllSort(64, "Stooge Sort", 7);
runAllSort(5,    "Bogo Sort", 1);
runAllSort(5,    "Bozo Sort", 1);