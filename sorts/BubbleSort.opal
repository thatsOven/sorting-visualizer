@Sort(
    "Exchange Sorts",
    "Bubble Sort",
    "Bubble Sort"
);
new function bubbleSort(array) {
    for i in range(len(array)) {
        new bool sorted = True;
        for j in range(len(array) - i - 1) {
            if array[j] > array[j + 1] {
                array[j].swap(array[j + 1]);
                sorted = False;
            }
        }
        if sorted { break;}
    }
}