new dynamic uncheckedInsertionSort;

new function dualPivotQuickSort(array, a, b) {
    while b - a > 32 {
        new int m = a + ((b - a) // 2);

        compSwap(array, m, m + 1);
        array[a].swap(array[m]);
        array[b].swap(array[m + 1]);

        new int p1, p2;
        dynamic: p1, p2 = dualPivotPartition(array, a, b);

        dualPivotQuickSort(array, a, p1);
        dualPivotQuickSort(array, p1, p2);
        a = p2;
    }
    uncheckedInsertionSort(array, a, b + 1);
}

@Sort(
    "Quick Sorts",
    "Dual Pivot QuickSort",
    "Dual Pivot Quick"
);
new function dualPivotQuickSortRun(array) {
    dualPivotQuickSort(array, 0, len(array) - 1);
}