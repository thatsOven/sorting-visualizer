new function bozoSort(array, a, b) {
    while not checkSorted(array, a, b) {
        array[random.randint(a, b - 1)].swap(array[random.randint(a, b - 1)]);
    }
}

@Sort(
    "Impractical Sorts",
    "Bozo Sort",
    "Bozo Sort"
);
new function bozoSortRun(array) {
    if len(array) > 10 {
        new int sel;
        sel = sortingVisualizer.getUserSelection(["No, go back", "Yes"], "Bozo Sort will take a very long time to finish on an array length of "
                                                                         + str(len(array)) +  ". Are you sure you want to continue?");

        if sel == 0 {
            return;
        }
    }

    bozoSort(array, 0, len(array));
}