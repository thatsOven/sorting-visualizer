namespace BoseNelsonSort {
    new classmethod merge(array, a1, l1, a2, l2) {
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
            this.merge(array,      a1,      m1,      a2,      m2);
            this.merge(array, a1 + m1, l1 - m1, a2 + m2, l2 - m2);
            this.merge(array, a1 + m1, l1 - m1,      a2,      m2);
        }
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

    new classmethod sort(array, a, l) {
        if l > 1 {
            new int m = l // 2;

            this.sort(array,     a,     m);
            this.sort(array, a + m, l - m);
            this.merge(array, a, m, a + m, l - m);
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
    BoseNelsonSort.sort(array, 0, len(array));
}

@Sort(
    "Concurrent Sorts",
    "Bose Nelson Sort (Parallel)",
    "Bose Nelson (Parallel)",
    enabled = not CY_COMPILING
);
new function boseNelsonSortRun(array) {
    sortingVisualizer.runParallel(BoseNelsonSort.sortParallel, array, 0, len(array));
}