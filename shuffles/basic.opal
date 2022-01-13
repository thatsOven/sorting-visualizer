@Shuffle("No shuffle").run;
new function noShuffle(array) {}

@Shuffle("Reversed").run;
new function reversedShuffle(array) {
    reverse(array, 0, len(array));
}

new function shuffleRandom(array, a, b) {
    for i = a; i < b; i++ {
        array[i].swap(array[random.randint(i, b - 1)]);
    }
}

@Shuffle("Random").run;
new function randomShuffle(array) {
    shuffleRandom(array, 0, len(array));
}