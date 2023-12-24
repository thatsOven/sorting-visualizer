package itertools: import chain;

use UtilsIterablesStableSort;

new class FeatureSort {
    new method sortSubarray(subarray, mainArray) {
        new int l = len(subarray);
        if l <= 1 {
            return;
        }
        UtilsIterablesStableSort(len(mainArray), mainArray).sort(subarray, 0, l);
    }

    new method __adaptAux(array) {
        new list result = list(chain.from_iterable(array));

        if len(result) == 0 {
            result = [Value(0)];
            result[0].idx = 0;
            result[0].stabIdx = 0;
            result[0].setAux(array);
            return result;
        }

        return result;
    }

    new method __adaptIdx(idx, aux) {
        if aux is this.aux {
            return 0;
        }
        
        new dynamic i = 0;
        for j, bucket in enumerate(this.aux) {
            i += len(bucket);

            if j == idx {
                return i - 1;
            }
        }

        return 0;
    }

    new method sort(array, a, b) {
        new int min_, max_;

        min_, max_ = findMinMax(array, a, b);

        new float CONST = (b - a) / (max_ - min_ + 1);

        this.aux = [[] for _ in range(b - a + 1)];
        sortingVisualizer.setAdaptAux(this.__adaptAux, this.__adaptIdx);
        sortingVisualizer.setAux(this.aux);

        for i = a; i < b; i++ {
            new int idx = int((array[i].readInt() - min_) * CONST);
            new dynamic sTime = default_timer();
            this.aux[idx].append(array[i].copy());
            sortingVisualizer.timer(sTime);
            sortingVisualizer.writes++;
            sortingVisualizer.highlight(idx, True);
        }

        sortingVisualizer.resetAdaptAux();
        for i in range(b - a) {
            this.sortSubarray(this.aux[i], array);
        }

        sortingVisualizer.setAdaptAux(this.__adaptAux, this.__adaptIdx);
        sortingVisualizer.setAux(this.aux);
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