new function uncheckedInsertionSort(array, a, b) {
    for i = a + 1; i < b; i++ {
        if array[i] < array[a] {
            array[i].swap(array[a]);
        }

        new <Value> key;
        new int     idx;
        
        dynamic: key, idx = array[i].readNoMark();

        for j = i - 1; array[j] > key; j-- {
            array[j + 1].write(array[j].noMark());
        }
        array[j + 1].writeRestoreIdx(key, idx);
    }
}

@Sort(
    "Insertion Sorts",
    "Unstable Insertion Sort",
    "Unstable Insertion"
);
new function uncheckedInsertionSortRun(array) {
    uncheckedInsertionSort(array, 0, len(array));
}