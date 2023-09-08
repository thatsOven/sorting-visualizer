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