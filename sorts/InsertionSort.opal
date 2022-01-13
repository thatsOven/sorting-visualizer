new function insertionSort(array, a, b) {
    for i = a + 1; i < b; i++ {
        new <Value> key;
        new int     idx;
        
        dynamic: key, idx = array[i].readNoMark();

        for j = i - 1; array[j] > key and j >= a; j-- {
            array[j + 1].write(array[j].noMark());
        }
        array[j + 1].writeRestoreIdx(key, idx);
    }
}

@Sort(
    "Insertion Sorts",
    "Insertion Sort",
    "Insertion Sort"
).run;
new function runInsertionSort(array) {
    insertionSort(array, 0, len(array));
}