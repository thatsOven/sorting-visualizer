new class FoldSort {
    new method compSwap(array, a, b) {
        if b < this.end and array[a] > array[b] {
            array[a].swap(array[b]);
        }
    }

    new method halver(array, a, b) {
        for ; a < b; a++, b-- {
            this.compSwap(array, a, b);
        }
    }

    new method sort(array, a, b) {
        this.end = b;

        for ceilLog = 1; (1 << ceilLog) < (b - a); ceilLog++ {}

        new int size = 1 << ceilLog;

        for k = size >> 1; k > 0; k >>= 1 {
            for i = size; i >= k; i >>= 1 {
                for j = a; j < b; j += i {
                    this.halver(array, j, j + i - 1);
                }
            }
        }
    }
}

@Sort(
    "Concurrent Sorts",
    "Fold Sorting Network",
    "Fold Sort"
);
new function foldSortRun(array) {
    FoldSort().sort(array, 0, len(array));
}