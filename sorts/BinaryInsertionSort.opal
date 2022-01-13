new function binaryInsertionSort(array, a, b) {
    for i = a + 1; i < b; i++ {
        if array[i] < array[i - 1] {
            insertToLeft(array, i, lrBinarySearch(array, a, i, array[i], False));
        }
    }
}

@Sort(
    "Insertion Sorts",
    "Binary Insertion Sort",
    "Binary Insertion"
).run;
new function binaryInsertionSortRun(array) {
    binaryInsertionSort(array, 0, len(array));
}