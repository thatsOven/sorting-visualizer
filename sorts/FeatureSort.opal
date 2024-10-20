use UtilsIterablesSort;

new class FeatureSort {
    new method sortSubarray(subarray, mainArray) {
        new int l = len(subarray);
        if l <= 1 {
            return;
        }
        UtilsIterablesSort(len(mainArray), mainArray).sort(subarray, 0, l);
    }

    new method __adaptAux(_) {
        new list result = list(chain.from_iterable(this.aux));

        if len(result) == 0 {
            result = [Value(0)];
            result[0].idx = 0;
            result[0].stabIdx = 0;
            result[0].setAux(this.aux);
            return result;
        }

        return result;
    }

    new method __adaptIdx(idx, aux) {
        static: new int out;
        for out = 0; idx >= 0; idx-- {
            if idx < len(this.aux) {
                out += len(this.aux[idx]);
            }
        }

        return out - 1;
    }

    new method sort(array, a, b) {
        new int min_, max_;

        min_, max_ = findMinMax(array, a, b);

        new float CONST = (b - a) / (max_ - min_ + 1);

        this.aux = [[] for _ in range(b - a + 1)];
        sortingVisualizer.setAdaptAux(this.__adaptAux, this.__adaptIdx);
        sortingVisualizer.addAux(this.aux);

        for i = a; i < b; i++ {
            new int idx = int((array[i].readInt() - min_) * CONST);

            new Value val = array[i].copy();
            val.idx = idx + len(this.aux[idx]);
            val.setAux(this.aux);

            new dynamic sTime = default_timer();
            this.aux[idx].append(val);
            sortingVisualizer.timer(sTime);
            sortingVisualizer.writes++;
            sortingVisualizer.highlight(idx, this.aux);
        }

        for i in range(b - a) {
            this.sortSubarray(this.aux[i], array);
        }

        for i = 0, r = a; i < len(this.aux); i++ {
            for j = 0; j < len(this.aux[i]); j++, r++ {
                array[r].write(this.aux[i][j]);
            }
        }
    }
}

@Sort(
    "Distribution Sorts",
    "Feature Sort",
    "Feature Sort",
    usesDynamicAux = True
);
new function featureSortRun(array) {
    FeatureSort().sort(array, 0, len(array));
}