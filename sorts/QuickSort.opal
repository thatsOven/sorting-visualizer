new class QuickSort {
    new method __init__(pSel = None) {
        if pSel is None {
            this.pSel = sortingVisualizer.getPivotSelection(
                id = sortingVisualizer.getUserSelection(
                    [p.name for p in sortingVisualizer.pivotSelections],
                    "Select pivot selection: "
                )
            ).getFunc();
        } else {
            this.pSel = pSel;
        }
    }

    new method LRQuickSort(array, a, b) {
        while b - a > 1 {
            this.pSel(array, a, b, a);

            new int p;
            p = partition(array, a, b, a);

            array[a].swap(array[p]);

            this.LRQuickSort(array, a, p);
            a = p + 1;
        }
    }

    new method LLQuickSort(array, a, b) {
        while b - a > 1 {
            this.pSel(array, a, b, b - 1);

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
).run;
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
