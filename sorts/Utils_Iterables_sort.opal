new dynamic MaxHeapSort, uncheckedInsertionSort, ShellSort;

new class MedianOfSixteenAdaptiveQuickSort {
    new classmethod compNSwap(array, a, b, gap, start) {
        if array[start + (a * gap)] > array[start + (b * gap)] {
            array[start + (a * gap)].swap(array[start + (b * gap)]);
        }
    }

    new list medianOfSixteenSwaps;
    medianOfSixteenSwaps =  [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
        1, 3, 5, 7, 9, 11, 13, 15, 2, 4, 6, 8, 10, 12, 14, 16,
        1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15, 4, 8, 12, 16,
        1, 9, 2, 10, 3, 11, 4, 12, 5, 13, 6, 14, 7, 15, 8, 16,
        6, 11, 7, 10, 4, 13, 14, 15, 8, 12, 2, 3, 5, 9,
        2, 5, 8, 14, 3, 9, 12, 15, 6, 7, 10, 11,
        3, 5, 12, 14, 4, 9, 8, 13,
        7, 9, 11, 13, 4, 6, 8, 10,
        4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
        7, 8, 9, 10
    ];

    new classmethod sortSixteen(array, a, b, gap) {
        for i = 0; i < len(this.medianOfSixteenSwaps); i += 2 {
            this.compNSwap(
                array, this.medianOfSixteenSwaps[i],
                this.medianOfSixteenSwaps[i+1], gap, a
            );
        }
    }

    new classmethod medianOfSixteen(array, a, b) {
        new int gap = (b - 1 - a) // 16;
        MedianOfSixteenAdaptiveQuickSort.sortSixteen(array, a, b, gap);
        array[a].swap(array[a + (8 * gap)]);
    }

    new classmethod getSortedRuns(array, a, b) {
        new bool reverseSorted = True,
                      isSorted = True;

        for i = a; i < b - 1; i++ {
            if array[i] > array[i + 1] {
                isSorted = False;
            } else {
                reverseSorted = False;
            }

            if (not reverseSorted) and (not isSorted) {
                return False;
            }
        }

        if reverseSorted and not isSorted {
            reverse(array, a, b);
            return True;
        }

        return isSorted;
    }

    new classmethod __sorter(array, a, b, depth, unbalanced = False) {
        while b - a > 32 {
            if this.getSortedRuns(array, a, b) {
                return;
            }
            if depth == 0 {
                MaxHeapSort.sort(array, a, b);
                return;
            }

            new int p;
            if not unbalanced {
                medianOfThree(array, a, b);
                p = partition(array, a, b, a);
            } else {
                p = a;
            }

            new int  left = p - a,
                    right = b - (p + 1);
            if (left == 0 or right == 0) or (left / right >= 16 or right / left >= 16) or unbalanced {
                if b - a > 80 {
                    array[a].swap(array[p]);
                    if left < right {
                        this.__sorter(array, a, p, depth - 1, True);
                        a = p + 1;
                    } else {
                        this.__sorter(array, p + 1, b, depth - 1, True);
                        b = p;
                    }
                    this.medianOfSixteen(array, a, b);
                    p = partition(array, a + 1, b, a);
                } else {
                    ShellSort.sort(array, a, b);
                    return;
                }
            }

            array[a].swap(array[p]);

            depth--;
            this.__sorter(array, p + 1, b, depth);
            b = p;
        }
        uncheckedInsertionSort(array, a, b);
    }

    new classmethod sort(array, a, b) {
        this.__sorter(array, a, b, int(2 * math.log2(len(array))));
    }
}

@Sort(
    "Quick Sorts",
    "Median-Of-Sixteen Adaptive QuickSort [Utils.Iterables.sort]",
    "Median-Of-16 A. Quick"
);
new function medianOfSixteenAdaptiveQuickSortRun(array) {
    MedianOfSixteenAdaptiveQuickSort.sort(array, 0, len(array));
}