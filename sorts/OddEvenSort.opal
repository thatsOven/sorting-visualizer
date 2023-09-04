@Sort(
    "Exchange Sorts",
    "Odd-Even Sort",
    "Odd-Even Sort"
);
new function oddEvenSort(array) {
    do {
        new bool isSorted = True;

        for i = 1; i < len(array) - 1; i += 2 {
            if array[i] > array[i + 1] {
                array[i].swap(array[i + 1]);
                isSorted = False;
            }
        }

        for i = 0; i < len(array) - 1; i += 2 {
            if array[i] > array[i + 1] {
                array[i].swap(array[i + 1]);
                isSorted = False;
            }
        }
    } while !isSorted;
}