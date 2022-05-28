new function countingSort(array, a, b) {
    new int max_;
    max_ = findMax(array, a, b);

    new list output = sortingVisualizer.createValueArray(b - a),
             counts = sortingVisualizer.createValueArray(max_ + 1);
    sortingVisualizer.setInvisibleArray(output);
    sortingVisualizer.setAux(counts);

    arrayCopy(array, a, output, 0, b - a);

    for i = a; i < b; i++ {
        counts[array[i].readInt()]++;
    }

    for i = 1; i < max_ + 1; i++ {
        counts[i] += counts[i - 1];
    }

    for i = b - 1; i >= 0; i-- {
        output[counts[array[i].getInt()].readInt() - 1].write(array[i]);
        counts[array[i].getInt()]--;
    }

    reverseArrayCopy(output, 0, array, a, b - a);
}

@Sort(
    "Distribution Sorts",
    "Counting Sort",
    "Counting Sort"
);
new function countingSortRun(array) {
    countingSort(array, 0, len(array));
}