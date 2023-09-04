@Sort(
    "Exchange Sorts",
    "Sandpaper Sort",
    "Sandpaper Sort"
);
new function sandpaperSort(array) {
    for i = 0; i < len(array) - 1; i++ {
        for j = i + 1; j < len(array); j++ {
            if array[j] < array[i] {
                array[i].swap(array[j]);
            }
        }
    }
}