new function sawtooth(array) {
    new int count = 4;

    new list temp = sortingVisualizer.createValueArray(len(array));
    sortingVisualizer.setAux(temp);

    for j = 0, k = 0; j < count; j++ {
        for i = j; i < len(array); i += count, k++ {
            temp[k].write(array[i]);
        }
    }

    for i in range(len(array)) {
        array[i].write(temp[i]);
    }
}

@Shuffle("Sawtooth");
new function sawtoothRun(array) {
    sawtooth(array);
}

@Shuffle("Reversed Sawtooth");
new function revSawtoothRun(array) {
    sawtooth(array);
    reverse(array, 0, len(array));
}