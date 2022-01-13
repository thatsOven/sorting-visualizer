new dynamic binaryInsertionSort;

new class LibrarySort() {
    new int R = 4;

    new classmethod getMinLevel(n) {
        while n >= 32 {
            n = (n - 1) // LibrarySort.R + 1;
        }
        return n;
    }

    new classmethod rebalance(array, temp, cnts, locs, m, b) {
        for i = 0; i < m; i++ {
            cnts[i + 1] += cnts[i] + 1;
            sortingVisualizer.writes.addWrite();
            sortingVisualizer.multiHighlight([i, i + 1], True);
        }

        for i = m, j = 0; i < b; i++, j++ {
            temp[cnts[locs[j]]].write(array[i]);
            cnts[locs[j]]++;
            sortingVisualizer.writes.addWrite();
        }

        for i = 0; i < m; i++ {
            temp[cnts[i]].write(array[i]);
            cnts[i]++;
            sortingVisualizer.writes.addWrite();
        }

        arrayCopy(temp, 0, array, 0, b);

        binaryInsertionSort(array, 0, cnts[0] - 1);
        for i = 0; i < m - 1; i++ {
            binaryInsertionSort(array, cnts[i], cnts[i + 1] - 1);
        }
        binaryInsertionSort(array, cnts[m - 1], cnts[m]);

        for i = 0; i < m + 2; i++ {
            cnts[i] = 0;
            sortingVisualizer.writes.addWrite();
        }
    }

    new classmethod sort(array, length) {
        if length < 32 {
            binaryInsertionSort(array, 0, length);
            return;
        }

        new int j = this.getMinLevel(length);
        binaryInsertionSort(array, 0, j);

        for maxLevel = j; maxLevel * this.R < length; maxLevel *= this.R {}

        new list temp = sortingVisualizer.createValueArray(length),
                 cnts = [0 for _ in range(maxLevel + 2)],
                 locs = [0 for _ in range(length - maxLevel)];
        sortingVisualizer.setAux(temp);

        for i = j, k = 0; i < length; i++ {
            if this.R * j == i {
                this.rebalance(array, temp, cnts, locs, j, i);
                j = i;
                k = 0;
            }

            new int loc;
            loc = lrBinarySearch(array, 0, j, array[i], False);

            cnts[loc + 1]++;
            sortingVisualizer.writes.addWrite();
            locs[k] = loc;
            sortingVisualizer.writes.addWrite();
            k++;
        }

        this.rebalance(array, temp, cnts, locs, j, length);
    }
}


@Sort(
    "Insertion Sorts",
    "Library Sort",
    "Library Sort"
).run;
new function librarySortRun(array) {
    LibrarySort.sort(array, len(array));
}