new function oddEvenMergeSort(array, length) {
    for p = 1; p < length; p *= 2 {
        for k = p; k > 0; k //= 2 {
            for j = k % p; j + k < length; j += k * 2 {
                for i = 0; i < k; i++ {
                    if (i + j) // (p * 2) == (i + j + k) // (p * 2) {
                        if i + j + k < length {
                            compSwap(array, i + j, i + j + k);
                        }
                    }
                }
            }
        }
    }
}

use compSwap;

namespace OddEvenMergeSortParallel {
    new classmethod merge(array, lo, m2, n, r) {
        new int m = r * 2;
        if m < n {
            new dynamic t0, t1;
            if (n // r) % 2 != 0 {
                t0 = sortingVisualizer.createThread(this.merge, array, lo, (m2 + 1) // 2, n + r, m);
                t1 = sortingVisualizer.createThread(this.merge, array, lo + r, m2 // 2, n - r, m);
            } else {
                t0 = sortingVisualizer.createThread(this.merge, array, lo, (m2 + 1) // 2, n, m);
                t1 = sortingVisualizer.createThread(this.merge, array, lo + r, m2 // 2, n, m);
            }

            t0.start();
            t1.start();

            t0.join();
            t1.join();

            if m2 % 2 != 0 {
                for i = lo; i + r < lo + n; i += m {
                    compSwap(array, i, i + r);
                }
            } else {
                for i = lo + r; i + r < lo + n; i += m {
                    compSwap(array, i, i + r);
                }
            }
        } elif n > r {
            compSwap(array, lo, lo + r);
        }
    }

    new classmethod sort(array, lo, n) {
        if n > 1 {
            new int m = n // 2;
            new dynamic t0 = sortingVisualizer.createThread(this.sort, array, lo, m),
                        t1 = sortingVisualizer.createThread(this.sort, array, lo + m, n - m);

            t0.start();
            t1.start();

            t0.join();
            t1.join();

            this.merge(array, lo, m, n, 1);
        }
    }
}

@Sort(
    "Concurrent Sorts",
    "Odd Even Merge Sort",
    "Odd Even Merge"
);
new function oddEvenMergeSortRun(array) {
    oddEvenMergeSort(array, len(array));
}

@Sort(
    "Concurrent Sorts",
    "Odd Even Merge Sort (Parallel)",
    "Odd Even Merge (Parallel)"
);
new function oddEvenMergeSortParallelRun(array) {
    sortingVisualizer.runParallel(OddEvenMergeSortParallel.sort, array, 0, len(array));
}