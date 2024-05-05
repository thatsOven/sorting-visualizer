use lrBinarySearch;

new class RotateMergeSort {
    new method __init__(rot = None) {
        if rot is None {
            this.rotate = sortingVisualizer.getRotation(
                id = sortingVisualizer.getUserSelection(
                    [r.name for r in sortingVisualizer.rotations],
                    "Select rotation algorithm (default: Gries-Mills)"
                )
            ).indexedFn;
        } else {
            this.rotate = sortingVisualizer.getRotation(name = rot).indexedFn;
        }
    }

    new method rotateMerge(array, a, m, b) {
        new int m1, m2, m3;

        if m - a >= b - m {
            m1 = a + (m - a) // 2;
            m2 = lrBinarySearch(array, m, b, array[m1], True);
            m3 = m1 + m2 - m;
        } else {
            m2 = m + (b - m) // 2;
            m1 = lrBinarySearch(array, a, m, array[m2], False);
            m3 = m2 - m + m1;
            m2++;
        }

        this.rotate(array, m1, m, m2);

        if m2 - m3 - 1 > 0 && b - m2 > 0 {
            this.rotateMerge(array, m3 + 1, m2, b);
        } 

        if m1 - a > 0 && m3 - m1 > 0 {
            this.rotateMerge(array, a, m1, m3);
        }
    }

    new method rotateMergeParallel(array, a, m, b) {
        new int m1, m2, m3;

        if m - a >= b - m {
            m1 = a + (m - a) // 2;
            m2 = lrBinarySearch(array, m, b, array[m1], True);
            m3 = m1 + m2 - m;
        } else {
            m2 = m + (b - m) // 2;
            m1 = lrBinarySearch(array, a, m, array[m2], False);
            m3 = m2 - m + m1;
            m2++;
        }

        this.rotate(array, m1, m, m2);

        new dynamic t0 = None,
                    t1 = None;

        if m2 - m3 - 1 > 0 && b - m2 > 0 {
            t0 = sortingVisualizer.createThread(this.rotateMergeParallel, array, m3 + 1, m2, b);
            t0.start();
        } 

        if m1 - a > 0 && m3 - m1 > 0 {
            t1 = sortingVisualizer.createThread(this.rotateMergeParallel, array, a, m1, m3);
            t1.start();
        }

        if t0 is not None {
            t0.join();
        }

        if t1 is not None {
            t1.join();
        }
    }

    new method sort(array, a, b) {
        new int l = b - a;

        for j = 1; j < l; j *= 2 {
            for i = a; i + 2 * j <= b; i += 2 * j {
                this.rotateMerge(array, i, i + j, i + 2 * j);
            }

            if i + j < b {
                this.rotateMerge(array, i, i + j, b);
            }
        }
    }

    new method sortParallel(array, a, b) {
        if b - a > 1 {
            new int m = a + ((b - a) // 2);

            new dynamic t0 = sortingVisualizer.createThread(this.sortParallel, array, a, m),
                        t1 = sortingVisualizer.createThread(this.sortParallel, array, m, b);

            t0.start();
            t1.start();

            t0.join();
            t1.join();

            this.rotateMergeParallel(array, a, m, b);
        }
    }
}

@Sort(
    "Merge Sorts",
    "Rotate Merge Sort",
    "Rotate Merge"
);
new function rotateMergeSortRun(array) {
    RotateMergeSort().sort(array, 0, len(array));
}

@Sort(
    "Merge Sorts",
    "Rotate Merge Sort (Parallel)",
    "Rotate Merge (Parallel)"
);
new function rotateMergeSortRun(array) {
    sortingVisualizer.runParallel(RotateMergeSort().sortParallel, array, 0, len(array));
}