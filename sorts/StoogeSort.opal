use compSwap;

new function stoogeSort(array, a, b) {
    compSwap(array, a, b);

    if b - a + 1 >= 3 {
        new int t = (b - a + 1) / 3;

        stoogeSort(array, a, b - t);
        stoogeSort(array, a + t, b);
        stoogeSort(array, a, b - t);
    }
}

@Sort(
    "Impractical Sorts",
    "Stooge Sort",
    "Stooge Sort"
);
new function stoogeSortRun(array) {
    stoogeSort(array, 0, len(array) - 1);
}