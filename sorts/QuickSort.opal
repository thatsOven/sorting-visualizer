new class QuickSort {
    new method __init__(pSel = None) {
        if pSel is None {
            this.pSel = sortingVisualizer.getPivotSelection(
                id = sortingVisualizer.getUserSelection(
                    [p.name for p in sortingVisualizer.pivotSelections],
                    "Select pivot selection: "
                )
            );
        } else {
            this.pSel = sortingVisualizer.getPivotSelection(name = pSel);
        }
    }

    new method LRQuickSort(array, a, b) {
        while b - a > 1 {
            array[a].swap(array[this.pSel(array, a, b)])

            new int p;
            p = partition(array, a, b, a);

            array[a].swap(array[p]);

            this.LRQuickSort(array, a, p);
            a = p + 1;
        }
    }

    new method LLQuickSort(array, a, b) {
        while b - a > 1 {
            array[b - 1].swap(array[this.pSel(array, a, b)]);

            new int p;
            p = LLPartition(array, a, b);

            this.LLQuickSort(array, a, p);
            a = p + 1;
        }
    }
}

@Sort(
    "Quick Sorts",
    "Quick Sort - Left/Right Pointers",
    "LR Quick Sort"
);
new function LRQuickSortRun(array) {
    QuickSort().LRQuickSort(array, 0, len(array));
}

@Sort(
    "Quick Sorts",
    "Quick Sort - Left/Left Pointers",
    "LL Quick Sort"
);
new function LLQuickSortRun(array) {
    QuickSort().LLQuickSort(array, 0, len(array));
}
