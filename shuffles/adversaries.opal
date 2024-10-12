@Shuffle("Quicksort Adversary");
new function quickSortAdversary(array) {
    for j = len(array) - len(array) % 2 - 2, i = j - 1; i >= 0; i -= 2, j-- {
        array[i].swap(array[j]);
    }
}

use reverse, shuffleRandom, shift;

new class GrailSortAdversary {
    new method __init__() {
        this.rotate = sortingVisualizer.getRotation(
            name = "Gries-Mills"
        ).indexedFn;
    }

    new method push(array, a, b, bLen) {
        new int len  = b - a,
                b1   = b - len % bLen,
                len1 = b1 - a;
        if len1 <= 2 * bLen {
            return;
        }

        for m = bLen; 2 * m < len; m *= 2 {}
        m += a;

        if b1 - m < bLen {
            this.push(array, a, m, bLen);
        } else {
            m = a + b1 - m;
            this.rotate(array, m - (bLen - 2), b1 - (bLen - 1), b1);
            shift(array, a, m);
            this.rotate(array, a, m, b1);
            m = a + b1 - m;

            this.push(array, a, m, bLen);
            this.push(array, m, b, bLen);
        }
    }

    new method run(array) {
        if len(array) <= 16 {
            reverse(array, 0, len(array));
        } else {
            for bLen = 1; bLen * bLen < len(array); bLen *= 2 {}

            new int numKeys = (len(array) - 1) // bLen + 1;
            new int keys = bLen + numKeys;

            shuffleRandom(array, 0, len(array));
            shuffleSort(array, 0, keys);
            reverse(array, 0, keys);
            shuffleSort(array, keys, len(array));
            this.push(array, keys, len(array), bLen);
        }
    }
}

@Shuffle("Grailsort Adversary");
new function grailSortAdversary(array) {
    GrailSortAdversary().run(array);
}