use uncheckedInsertionSort, MaxHeapSort, adaptLow;

new class StaticSort {
    new method __init__() {
        this.count = None;
    }

    new method __adaptAux(arrays) {
        return adaptLow(arrays, (this.count, ));
    }

    new method sort(array, a, b) {
        new int min_, max_;
        min_, max_ = findMinMax(array, a, b);

        new int auxLen = b - a;

        sortingVisualizer.setAdaptAux(this.__adaptAux);
        new dynamic offset = sortingVisualizer.createValueArray(auxLen + 1);
        this.count         = sortingVisualizer.createValueArray(auxLen + 1);

        new float CONST = auxLen / (max_ - min_ + 1);

        for i = a; i < b; i++ {
            this.count[int((array[i].readInt() - min_) * CONST)]++;
        }
        offset[0].write(a);

        for i = 1; i < auxLen; i++ {
            offset[i].write(this.count[i - 1] + offset[i - 1]);
        }

        for v in range(auxLen) {
            while this.count[v] > 0 {
                new int origin = offset[v].readInt(),
                        from_  = origin;
                new Value num = array[from_].copy();

                array[from_].write(-1);

                do from_ != origin {
                    new int dig = int((num.readInt() - min_) * CONST),
                            to  = offset[dig].readInt();
                    offset[dig]++;
                    this.count[dig]--;

                    new Value temp = array[to].copy();
                    array[to].write(num);
                    num = temp.copy();
                    from_ = to;
                }
            }
        }

        this.count = None;

        for i in range(auxLen) {
            new int begin = offset[i - 1].readInt() if i > 0 else a,
                    end   = offset[i].readInt();

            if end - begin > 1 {
                if end - begin > 16 {
                    MaxHeapSort.sort(array, begin, end);
                } else {
                    uncheckedInsertionSort(array, begin, end);
                }
            }
        }
    }
}

@Sort(
    "Distribution Sorts",
    "Static Sort [Utils.Iterables.fastSort]",
    "Static Sort",
    usesDynamicAux = True
);
new function staticSortRun(array) {
    StaticSort().sort(array, 0, len(array));
}