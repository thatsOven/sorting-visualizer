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

    new method __adaptIdx(idx, aux) {
        if aux is this.lower {
            return idx;
        } elif aux is this.upper {
            return idx + len(this.lower);
        }

        return idx + len(this.lower) + len(this.upper);
    }

    new method sort(array) {
        this.lower = sortingVisualizer.createValueArray(len(array));
        this.upper = sortingVisualizer.createValueArray(len(array));
        this.tmp   = sortingVisualizer.createValueArray(len(array));
        sortingVisualizer.setAux(this.lower);
        sortingVisualizer.setAdaptAux(this.__adaptAux, this.__adaptIdx);

        for i = 1; i < len(array); i++ {
            new int c = 0;

            while True {
                new list next;
                if array[i] < array[c] {
                    next = this.lower;
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
        this.traverse(array, this.tmp, this.lower, this.upper, 0);
        arrayCopy(this.tmp, 0, array, 0, len(array));
    }
}

@Sort(
    "Tree Sorts",
    "Tree Sort",
    "Tree Sort",
    usesDynamicAux = True
);
new function treeSortRun(array) {
    TreeSort().sort(array);
}