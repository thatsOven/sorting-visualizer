new class TreeSort {
    new method traverse(array, tmp, lower, upper, r) {
        if lower[r] != 0 {
            this.traverse(array, tmp, lower, upper, lower[r].readInt());
        }

        tmp[this.idx].write(array[r]);
        this.idx++;

        if upper[r] != 0 {
            this.traverse(array, tmp, lower, upper, upper[r].readInt());
        }
    }

    new method __adaptAux(array) {
        return array + this.upper + this.tmp;
    }

    new method sort(array) {
        new list lower = sortingVisualizer.createValueArray(len(array));
        this.upper     = sortingVisualizer.createValueArray(len(array));
        this.tmp       = sortingVisualizer.createValueArray(len(array));
        sortingVisualizer.setAux(lower);
        sortingVisualizer.setAdaptAux(this.__adaptAux);

        for i = 1; i < len(array); i++ {
            new int c = 0;

            while True {
                new list next;
                if array[i] < array[c] {
                    next = lower;
                } else {
                    next = this.upper;
                }

                if next[c] == 0 {
                    next[c].write(i);
                    break;
                } else {
                    c = next[c].readInt();
                }
            }
        } 

        this.idx = 0;
        this.traverse(array, this.tmp, lower, this.upper, 0);
        arrayCopy(this.tmp, 0, array, 0, len(array));
    }
}

@Sort(
    "Tree Sorts",
    "Tree Sort",
    "Tree Sort"
);
new function treeSortRun(array) {
    TreeSort().sort(array);
}