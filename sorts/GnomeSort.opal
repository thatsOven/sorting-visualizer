new function gnomeSort(array, a, b) {
    for i = a + 1; i < b; {
        if array[i] >= array[i - 1] { 
            i++;
        } else {
            array[i].swap(array[i - 1]);

            if i > 1 {
                i--;
            }
        }
    }
}

@Sort(
    "Exchange Sorts",
    "Gnome Sort",
    "Gnome Sort"
);
new function gnomeSortRun(array) {
    gnomeSort(array, 0, len(array));
}