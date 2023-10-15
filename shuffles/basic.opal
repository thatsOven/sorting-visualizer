@Shuffle("No shuffle");
new function noShuffle(array) {
    for i in range(len(array)) {
        sortingVisualizer.highlight(i);
    }
}

@Shuffle("Reversed");
new function reversedShuffle(array) {
    reverse(array, 0, len(array));
}

new function shuffleRandom(array, a, b) {
    for i = a; i < b; i++ {
        array[i].swap(array[random.randint(i, b - 1)]);
    }
}

@Shuffle("Random");
new function randomShuffle(array) {
    shuffleRandom(array, 0, len(array));
}

@Shuffle("Few random");
new function fewRandomShuffle(array) {
    unchecked: repeat max(len(array) // 20, 1) {
        array[random.randint(0, len(array) - 1)].swap(array[random.randint(0, len(array) - 1)]);
    }
}

@Shuffle("Final Merge Pass");
new function finalMergeShuffle(array) {
    new int count = 2;

    new list temp = sortingVisualizer.createValueArray(len(array));
    sortingVisualizer.setAux(temp);

    new int k = 0;
    for j = 0; j < count; j++ {
        for i = j; i < len(array); i += count, k++ {
            temp[k].write(array[i]);
        }
    }

    arrayCopy(temp, 0, array, 0, len(array));
}

