use checkSorted, findMaxIndex, reverse;

@Sort(
    "Pancake Sorts",
    "Pancake Sort",
    "Pancake Sort"
);
new function pancakeSort(array) {
    for i = len(array) - 1; i >= 0; i-- {
        if !checkSorted(array, 0, i) {
            new int index = findMaxIndex(array, 0, i + 1);

            if index == 0 {
                reverse(array, 0, i + 1);
            } elif index != i {
                reverse(array, 0, index + 1);
                reverse(array, 0, i + 1);
            }
        }
    }
}