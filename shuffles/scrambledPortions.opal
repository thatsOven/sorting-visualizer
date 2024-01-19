use shuffleRandom;

@Shuffle("Scrambled Tail");
new function scrambledTailShuffle(array) {
    new list aux = sortingVisualizer.createValueArray(len(array));
    sortingVisualizer.setAux(aux);

    new int i = 0,
            j = 0,
            k = 0;

    for ; i < len(array); i++ {
        if random.random() < 1.0 / 7.0 {
            aux[k].write(array[i]);
            k++;
        } else {
            array[j].write(array[i]);
            j++;
        }
    }

    arrayCopy(aux, 0, array, j, k);
    shuffleRandom(array, j, len(array));
}

@Shuffle("Scrambled Head");
new function scrambledHeadShuffle(array) {
    new list aux = sortingVisualizer.createValueArray(len(array));
    sortingVisualizer.setAux(aux);

    new int i = len(array) - 1,
            j = i,
            k = 0;
    for ; i >= 0; i-- {
        if random.random() < 1.0 / 7.0 {
            aux[k].write(array[i]);
            k++;
        } else {
            array[j].write(array[i]);
            j--;
        }
    }

    arrayCopy(aux, 0, array, 0, k);
    shuffleRandom(array, 0, j);
}

@Shuffle("Noisy");
new function noisyShuffle(array) {
    new int size = max(4, int(math.sqrt(len(array)) // 2));

    for i = 0; i + size <= len(array); i += random.randint(1, size) {
        shuffleRandom(array, i, i + size);
    }

    shuffleRandom(array, i, len(array));
}