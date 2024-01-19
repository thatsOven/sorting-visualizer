use shuffleRandom;

new function shuffleSort(array, a, b) {
    use FeatureSort;

    new dynamic speed = sortingVisualizer.speed,
                aux   = sortingVisualizer.settings["show-aux"];

    sortingVisualizer.setSpeed(max(int(50.0 * (len(array) / 2048.0)), speed * 2, 1));
    sortingVisualizer.settings["show-aux"] = False;

    FeatureSort().sort(array, a, b);

    sortingVisualizer.setSpeed(speed);
    sortingVisualizer.settings["show-aux"] = aux;
    sortingVisualizer.resetAdaptAux();
    sortingVisualizer.resetAux();
}

@Shuffle("Sorted");
new function sortedShuffle(array) {
    shuffleSort(array, 0, len(array));
}

@Shuffle("Real Final Merge");
new function realFinalMergeShuffle(array) {
    shuffleRandom(array, 0, len(array));
    shuffleSort(array, 0, len(array) // 2);
    shuffleSort(array, len(array) // 2, len(array));
}

@Shuffle("Partitioned");
new function partitionedShuffle(array) {
    shuffleSort(array, 0, len(array));
    shuffleRandom(array, 0, len(array) // 2);
    shuffleRandom(array, len(array) // 2, len(array));
}