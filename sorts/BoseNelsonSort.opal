new class BoseNelsonSort {
    new method __init__(end) {
        this.end = end;
    }
    
    new method compSwapCheck(array, a, b) {
        if b < this.end {
            compSwap(array, a, b);
        }
    }
    
    new method boseNelsonMerge(array, a1, a2, n, f) {
        if f {
            for i = 0; i < n; i++ {
                this.compSwapCheck(array, a1+i, a2+i);
            }
        }
        
        new int h = n // 2;
        
        if h > 1 {
            this.boseNelsonMerge(array, a1,   a2,   h, False),
            this.boseNelsonMerge(array, a1+h, a2+h, h, False);
        }
        if h > 0 {
            this.boseNelsonMerge(array, a1+h, a2, h, True);
        }
    }
    
    new method boseNelsonSort(array, a, n) {
        new int h = n // 2;
        
        if h > 1 {
            this.boseNelsonSort(array, a,   h),
            this.boseNelsonSort(array, a+h, h);
        }
        this.boseNelsonMerge(array, a, a+h, h, True);
    }
    
    new classmethod mergeParallel(array, a1, l1, a2, l2) {
        if l1 == 1 and l2 == 1 {
            compSwap(array, a1, a2);
        } elif l1 == 1 and l2 == 2 {
            compSwap(array, a1, a2 + 1);
            compSwap(array, a1, a2);
        } elif l1 == 2 and l2 == 1 {
            compSwap(array, a1, a2);
            compSwap(array, a1 + 1, a2);
        } else {
            new int m1 = l1 // 2,
                    m2 = (l2 // 2) if (l1 % 2 == 1) else ((l2 + 1) // 2);

            new dynamic t0 = sortingVisualizer.createThread(this.mergeParallel, array,      a1,      m1,      a2,      m2),
                        t1 = sortingVisualizer.createThread(this.mergeParallel, array, a1 + m1, l1 - m1, a2 + m2, l2 - m2);
            
            t0.start();
            t1.start();

            t0.join();
            t1.join();

            this.mergeParallel(array, a1 + m1, l1 - m1, a2, m2);
        }
    }
    
    new classmethod sortParallel(array, a, l) {
        if l > 1 {
            new int m = l // 2;

            new dynamic t0 = sortingVisualizer.createThread(this.sortParallel, array,     a,     m),
                        t1 = sortingVisualizer.createThread(this.sortParallel, array, a + m, l - m);

            t0.start();
            t1.start();

            t0.join();
            t1.join();

            this.mergeParallel(array, a, m, a + m, l - m);
        }
    }
}

@Sort(
    "Concurrent Sorts",
    "Bose Nelson Sort",
    "Bose Nelson"
);
new function boseNelsonSortRun(array) {
    BoseNelsonSort(len(array)).boseNelsonSort(array, 0, 2**math.ceil(math.log2(len(array))));
}

@Sort(
    "Concurrent Sorts",
    "Bose Nelson Sort (Parallel)",
    "Bose Nelson (Parallel)"
);
new function boseNelsonSortRun(array) {
    sortingVisualizer.runParallel(BoseNelsonSort.sortParallel, array, 0, len(array));
}