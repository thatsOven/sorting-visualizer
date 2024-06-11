use binaryInsertionSort;

new class LibrarySort {
    new int R = 4;

    new classmethod getMinLevel(n) {
        while n >= 32 {
            n = (n - 1) // LibrarySort.R + 1;
        }
        return n;
    }

    new method rebalance(array, temp, m, b) {
        for i = 0; i < m; i++ {
            this.cnts[i + 1] += this.cnts[i] + 1;
        }

        for i = m, j = 0; i < b; i++, j++ {
            temp[this.cnts[this.locs[j].readInt()].readInt()].write(array[i]);
            this.cnts[this.locs[j].getInt()]++;
        }

        for i = 0; i < m; i++ {
            temp[this.cnts[i].readInt()].write(array[i]);
            this.cnts[i]++;
        }

        arrayCopy(temp, 0, array, 0, b);

        binaryInsertionSort(array, 0, this.cnts[0].readInt() - 1);
        for i = 0; i < m - 1; i++ {
            binaryInsertionSort(array, this.cnts[i].readInt(), this.cnts[i + 1].readInt() - 1);
        }
        binaryInsertionSort(array, this.cnts[m - 1].readInt(), this.cnts[m].readInt());

        for i = 0; i < m + 2; i++ {
            this.cnts[i].write(0);
        }
    }

    new method sort(array, length) {
        if length < 32 {
            binaryInsertionSort(array, 0, length);
            return;
        }

        new int j = this.getMinLevel(length);
        binaryInsertionSort(array, 0, j);

        for maxLevel = j; maxLevel * this.R < length; maxLevel *= this.R {}

        this.temp = sortingVisualizer.createValueArray(length);
        this.cnts = sortingVisualizer.createValueArray(maxLevel + 2);
        this.locs = sortingVisualizer.createValueArray(length - maxLevel);
        sortingVisualizer.setNonOrigAux(this.cnts, this.locs);

        for i = j, k = 0; i < length; i++ {
            if this.R * j == i {
                this.rebalance(array, this.temp, j, i);
                j = i;
                k = 0;
            }

            new int loc;
            loc = lrBinarySearch(array, 0, j, array[i], False);

            this.cnts[loc + 1]++;
            this.locs[k].write(loc);
            k++;
        }

        this.rebalance(array, this.temp, j, length);
    }
}


@Sort(
    "Insertion Sorts",
    "Library Sort",
    "Library Sort"
);
new function librarySortRun(array) {
    LibrarySort().sort(array, len(array));
}