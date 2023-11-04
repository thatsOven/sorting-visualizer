new function cycleSort(array, a, b) {
    for cycleStart = a; cycleStart < b - 1; cycleStart++ {
        new Value val = array[cycleStart].copy();
        new int pos = cycleStart;

        for i = cycleStart + 1; i < b; i++ {
            if array[i] < val {
                pos++;
            }
            sortingVisualizer.highlight(pos);
        }

        if pos == cycleStart {
            continue;
        }

        while val == array[pos] {
            pos++;
            sortingVisualizer.highlight(pos);
        }

        new Value tmp = array[pos].copy();
        array[pos].write(val);
        val = tmp.copy();

        while pos != cycleStart {
            pos = cycleStart;

            for i = cycleStart + 1; i < b; i++ {
                if array[i] < val {
                    pos++;
                }
                sortingVisualizer.highlight(pos);
            }

            while val == array[pos] {
                pos++;
                sortingVisualizer.highlight(pos);
            }

            tmp = array[pos].copy();
            array[pos].write(val);
            val = tmp.copy();
        }
    }
}

@Sort(
    "Selection Sorts",
    "Cycle Sort",
    "Cycle Sort"
);
new function cycleSortRun(array) {
    cycleSort(array, 0, len(array));
}