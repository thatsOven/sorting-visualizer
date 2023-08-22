namespace BinaryDoubleInsertionSort {
    new classmethod insertToLeft(array, a, b, temp, idx) {
        while a > b {
            array[a].write(array[a - 1].noMark());
            a--;
        }
        array[b].writeRestoreIdx(temp, idx);
    }

    new classmethod insertToRight(array, a, b, temp, idx) {
        while a < b {
            array[a].write(array[a + 1].noMark());
            a++;
        }
        array[a].writeRestoreIdx(temp, idx);
    }

    new classmethod sort(array, a, b) {
        if b - a < 2 {
            return;
        }

        new int j = a + (b - a - 2) // 2 + 1,
                i = a + (b - a - 1) // 2;

        if j > i and array[i] > array[j] {
            array[i].swap(array[j]);
        }

        i--;
        j++;

        new Value l, r;
        new int lIdx, rIdx, m;
        for ; j < b; i--, j++ {
            if array[i] > array[j] {
                l, lIdx = array[j].readNoMark();
                r, rIdx = array[i].readNoMark();

                m = lrBinarySearch(array, i + 1, j, l, False);
                this.insertToRight(array, i, m - 1, l, lIdx);
                this.insertToLeft(array, j, lrBinarySearch(array, m, j, r), r, rIdx);
            } else {
                l, lIdx = array[i].readNoMark();
                r, rIdx = array[j].readNoMark();

                m = lrBinarySearch(array, i + 1, j, l);
                this.insertToRight(array, i, m - 1, l, lIdx);
                this.insertToLeft(array, j, lrBinarySearch(array, m, j, r, False), r, rIdx);
            }
        }
    }
}

@Sort(
    "Insertion Sorts",
    "Binary Double Insertion Sort",
    "Bin. Double Insert"
);
new function binaryDoubleInsertionSortRun(array) {
    BinaryDoubleInsertionSort.sort(array, 0, len(array));
}