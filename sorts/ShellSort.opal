new class ShellSort {
    new list seq;
    seq = [8861, 3938, 1750, 701, 301, 132, 57, 23, 10, 4, 1];

    new classmethod sort(array, a, b) {
        for gap in this.seq {
            if gap >= b - a {
                continue;
            }

            for i = a + gap; i < b; i++ {
                new <Value> tmp;
                new int     idx;

                dynamic: tmp, idx = array[i].readNoMark();

                for j = i; j >= a + gap and array[j - gap] > tmp; j -= gap {
                    array[j].write(array[j - gap].noMark());
                }
                array[j].writeRestoreIdx(tmp, idx);
            }
        }
    }
}

@Sort(
    "Insertion Sorts",
    "Shell Sort",
    "Shell Sort"
);
new function shellSortRun(array) {
    ShellSort.sort(array, 0, len(array));
}