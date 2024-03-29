use binaryInsertionSort;

namespace BottomUpMergeSort {
    new classmethod merge(c, d, lt, md, rt) {
        new int i = lt,
                j = md + 1,
                k = lt;

        for ; i <= md and j <= rt; k++ {
            if c[i] <= c[j] {
                d[k].write(c[i]);
                i++;
            } else {
                d[k].write(c[j]);
                j++;
            }
        }

        for ; i <= md; i++, k++ {
            d[k].write(c[i]);
        }

        for ; j <= rt; j++, k++ {
            d[k].write(c[j]);
        }
    }

    new classmethod mergePass(x, y, s, n) {
        for i = 0; i <= n - 2 * s; i += 2 * s {
            this.merge(x, y, i, i + s - 1, i + 2 * s - 1);
        }

        if i + s < n {
            this.merge(x, y, i, i + s - 1, n - 1);
        } else {
            for j = i; j <= n - 1; j++ {
                y[j].write(x[j]);
            }
        }
    }

    new classmethod sort(array, n) {
        if n < 16 {
            binaryInsertionSort(array, 0, n);
            return;
        }

        new int s = 16;

        new dynamic speed = sortingVisualizer.speed;
        sortingVisualizer.setSpeed(max(int(10 * (len(array) / 2048)), speed * 2));

        for i = 0; i <= n - 16; i += 16 {
            binaryInsertionSort(array, i, i + 16);
        }
        binaryInsertionSort(array, i, n);

        sortingVisualizer.setSpeed(speed);

        new dynamic b = sortingVisualizer.createValueArray(n);
        while s < n {
            this.mergePass(array, b, s, n);
            s *= 2;
            this.mergePass(b, array, s, n);
            s *= 2;
        }
    }
}

@Sort(
    "Merge Sorts",
    "Bottom Up Merge Sort",
    "Bottom Up Merge"
);
new function bottomUpMergeSortRun(array) {
    BottomUpMergeSort.sort(array, len(array));
}