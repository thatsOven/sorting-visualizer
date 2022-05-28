new class BitonicSort {
    new classmethod greaterPowerOfTwoLessThan(n) {
        for k = 1; k < n; k <<= 1 {}
        return k >> 1;
    }

    new classmethod compare(array, a, b, dir) {
        if dir {
            if array[a] > array[b] {
                array[a].swap(array[b]);
            }
        } else {
            if array[a] < array[b] {
                array[a].swap(array[b]);
            }
        }
    }

    new classmethod merge(array, a, l, dir) {
        if l > 1 {
            new int m = this.greaterPowerOfTwoLessThan(l);

            for i = a; i < a + l - m; i++ {
                this.compare(array, i, i + m, dir);
            }

            this.merge(array,     a,     m, dir);
            this.merge(array, a + m, l - m, dir);
        }
    }

    new classmethod sort(array, a, l, dir) {
        if l > 1 {
            new int m = l // 2;

            this.sort(array,     a,     m, not dir);
            this.sort(array, a + m, l - m, dir);
            this.merge(array, a, l, dir);
        }
    }
}

@Sort(
    "Concurrent Sorts",
    "Bitonic Sort",
    "Bitonic Sort"
);
new function bitonicSortRun(array) {
    BitonicSort.sort(array, 0, len(array), True);
}