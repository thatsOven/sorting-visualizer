package itertools: import chain;

use UtilsIterablesStableSort;

new class FeatureSort {
    new classmethod sortSubarray(subarray, mainArray) {
        new int l = len(subarray);
        if l <= 1 {
            return;
        }
        UtilsIterablesStableSort(len(mainArray), mainArray).sort(subarray, 0, l);
    }

    new classmethod adaptAux(array) {
        new list result = list(chain.from_iterable(
            [([Value(0)] if x == [] else x) for x in array]
                              ));
        for i in range(len(result)) {
            if result[i].idx is None {
                result[i].idx = i;
                result[i].stabIdx = i;
                result[i].setAux(True);
            }
        }
        return result;
    }

    new classmethod sort(array, a, b) {
        new int min_, max_;

        min_, max_ = findMinMax(array, a, b);

        new float CONST = (b - a) / (max_ - min_ + 4);

        new list aux = [[] for _ in range(b - a + 1)];
        sortingVisualizer.setAdaptAux(this.adaptAux);
        sortingVisualizer.setAux(aux);

        for i = a; i < b; i++ {
            new int idx = int((array[i].readInt() - min_) * CONST);
            new dynamic sTime = default_timer();
            aux[idx].append(array[i].copy());
            sortingVisualizer.timer(sTime);
            sortingVisualizer.writes.addWrite();
            sortingVisualizer.highlight(idx, True);
        }

        sortingVisualizer.resetAdaptAux();
        for i in range(b - a) {
            this.sortSubarray(aux[i], array);
        }

        sortingVisualizer.setAdaptAux(this.adaptAux);
        sortingVisualizer.setAux(aux);
        for i = 0, r = a; i < len(aux); i++ {
            for j = 0; j < len(aux[i]); j++, r++ {
                array[r].write(aux[i][j]);
            }
        }
    }
}

@Sort(
    "Distribution Sorts",
    "featureSort",
    "featureSort",
);
new function featureSortRun(array) {
    FeatureSort.sort(array, 0, len(array));
}