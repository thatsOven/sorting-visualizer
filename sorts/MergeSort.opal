new class MergeSort {
    new method __init__(length) {
        this.aux = sortingVisualizer.createValueArray(length);
        sortingVisualizer.setAux(this.aux);
    }

    new method merge(array, a, m, b) {
        new int left  = a,
                right = m,
                aux   = 0;

        while left < m and right < b {
            if array[left] <= array[right] {
                this.aux[aux].write(array[left]);
                left++;
            } else {
                this.aux[aux].write(array[right]);
                right++;
            }
            aux++;
        }

        for ; left < m; left++, aux++ {
            this.aux[aux].write(array[left]);
        }

        for ; right < b; right++, aux++ {
            this.aux[aux].write(array[right]);
        }

        for aux = 0; a < b; a++, aux++ {
            array[a].write(this.aux[aux]);
        }
    }

    new method mergeSort(array, a, b) {
        if b - a > 1 {
            new int m = a + ((b - a) // 2);

            this.mergeSort(array, a, m);
            this.mergeSort(array, m, b);

            this.merge(array, a, m, b);
        }
    }
}

@Sort(
    "Merge Sorts",
    "Merge Sort",
    "Merge Sort"
).run;
new function mergeSortRun(array) {
    MergeSort(len(array)).mergeSort(array, 0, len(array));
}