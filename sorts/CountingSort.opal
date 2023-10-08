new class CountingSort {
    new method __adaptAux(array) {
        return array + this.output;
    }

    new method __adaptIdx(idx, aux) {
        if aux is this.output {
            return idx + len(this.counts);
        }

        return idx;
    }

    new method sort(array, a, b) {
        new int max_;
        max_ = findMax(array, a, b);

        this.counts = sortingVisualizer.createValueArray(max_ + 1);
        this.output = sortingVisualizer.createValueArray(b - a);
        sortingVisualizer.setAux(this.counts);
        sortingVisualizer.setAdaptAux(this.__adaptAux, this.__adaptIdx);

        arrayCopy(array, a, this.output, 0, b - a);

        for i = a; i < b; i++ {
            this.counts[array[i].readInt()]++;
        }

        for i = 1; i < max_ + 1; i++ {
            this.counts[i] += this.counts[i - 1];
        }

        for i = b - 1; i >= 0; i-- {
            this.output[this.counts[array[i].readInt()].readInt() - 1].write(array[i]);
            this.counts[array[i].getInt()]--;
        }

        reverseArrayCopy(this.output, 0, array, a, b - a);
    }
}

@Sort(
    "Distribution Sorts",
    "Counting Sort",
    "Counting Sort"
);
new function countingSortRun(array) {
    CountingSort().sort(array, 0, len(array));
}