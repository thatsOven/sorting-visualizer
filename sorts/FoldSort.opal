new class FoldSort {
    new method __init__(end) {
        this.end = end;
    }
    
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
    
    new method sortParallel(array, a, b, s, loop) {
        new int h = (b-a) // 2;
        
        for i in range(h) {
            this.compSwap(array, a + i, b-1 - i);
        }
        if h >= s//2 {
            new dynamic t0 = sortingVisualizer.createThread(this.sortParallel, array, a, a+h, s, False),
                        t1 = sortingVisualizer.createThread(this.sortParallel, array, a+h, b, s, False);
            
            t0.start();
            t1.start();
            
            t0.join();
            t1.join();
        }
        if loop and s > 2 {
            this.sortParallel(array, a, b, s // 2, True);
        }
    }
}

@Sort(
    "Concurrent Sorts",
    "Fold Sorting Network",
    "Fold Sort"
);
new function foldSortRun(array) {
    FoldSort(len(array)).sort(array, 0, len(array));
}

@Sort(
    "Concurrent Sorts",
    "Fold Sorting Network (Parallel)",
    "Fold Sort (Parallel)"
);
new function foldSortRun(array) {
    sortingVisualizer.runParallel(FoldSort(len(array)).sortParallel, array, 0, 2**math.ceil(math.log2(len(array))), 2**math.ceil(math.log2(len(array))), True);
}