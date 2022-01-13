new function selectionSort(array, a, b) {
    for i = a; i < b - 1; i++ {
        new int lowest = i;

        for j = i + 1; j < b; j++ {
            if array[j] < array[lowest] {
                lowest = j;
            }
        }

        if lowest != i {
            array[i].swap(array[lowest]);
        }
    }
}

new function doubleSelectionSort(array, a, b) {
    b--;

    for ; a <= b; a++, b-- {
        new int lowest  = a, 
                highest = a;

        for i = a + 1; i <= b; i++ {
            if array[i] > array[highest] {
                highest = i;
            } elif array[i] < array[lowest] {
                lowest  = i;
            }
        } 

        if highest == a {
            highest = lowest;
        }

        if a != lowest {
            array[a].swap(array[lowest]);
        }
        if b != highest {
            array[b].swap(array[highest]);
        }
    }
}

@Sort(
    "Selection Sorts",
    "Selection Sort",
    "Selection Sort"
).run;
new function selectionSortRun(array) {
    selectionSort(array, 0, len(array));
}

@Sort(
    "Selection Sorts",
    "Double Selection Sort",
    "Double Selection"
).run;
new function doubleSelectionSortRun(array) {
    doubleSelectionSort(array, 0, len(array));
}