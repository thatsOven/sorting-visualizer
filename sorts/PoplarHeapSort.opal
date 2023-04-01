new class PoplarHeapSort {
    new classmethod hyperfloor(n) {
        return 2 ** int(math.log2(n));
    }

    new classmethod uncheckedInsertionSort(array, a, b) {
        for i = a + 1; i != b; i++ {
            new int sift  = i,
                    sift1 = i - 1;

            if array[sift] < array[sift1] {
                new Value tmp = array[sift].copy();

                do sift != a and tmp < array[sift1] {
                    array[sift].write(array[sift1].noMark());
                    sift--;
                    sift1--;
                }
                array[sift].write(tmp);
            }
        }
    }

    new classmethod insertionSort(array, a, b) {
        if a == b {
            return;
        }
        this.uncheckedInsertionSort(array, a, b);
    }

    new classmethod sift(array, a, l) {
        if l < 2 {
            return;
        }

        new int r  = a + l - 1,
                c1 = r - 1,
                c2 = a + (l // 2 - 1);

        while True {
            new int maxR = r;
            if array[maxR] < array[c1] {
                maxR = c1;
            }
            if array[maxR] < array[c2] {
                maxR = c2;
            }
            if maxR == r {
                return;
            }

            array[r].swap(array[maxR]);

            l //= 2;
            if l < 2 {
                return;
            }

            r = maxR;
            c1 = r - 1;
            c2 = maxR - (l - l // 2);
        }
    }

    new classmethod popHeapWithSize(array, a, b, l) {
        new int poplarSize = PoplarHeapSort.hyperfloor(l + 1) - 1,
                lR         = b - 1,
                bigger     = lR,
                biggerSize = poplarSize,
                it         = a;

        while True {
            new int r = it + poplarSize - 1;

            if r == lR {
                break;
            }

            if array[bigger] < array[r] {
                bigger = r;
                biggerSize = poplarSize;
            }
            it = r + 1;

            l -= poplarSize;
            poplarSize = this.hyperfloor(l + 1) - 1;
        }

        if bigger != lR {
            array[bigger].swap(array[lR]);
            this.sift(array, bigger - (biggerSize - 1), biggerSize);
        }
    }

    new classmethod makeHeap(array, a, b) {
        new int l = b - a;
        if l < 2 {
            return;
        }

        new int smallPoplarSize = 15;
        if l <= smallPoplarSize {
            this.uncheckedInsertionSort(array, a, b);
            return;
        }

        new int poplarLevel = 1,
                it          = a,
                next        = it + smallPoplarSize;

        while True {
            this.uncheckedInsertionSort(array, it, next);

            new int poplarSize = smallPoplarSize;

            for i = (poplarLevel & (-poplarLevel)) >> 1; i != 0; i >>= 1 {
                it -= poplarSize;
                poplarSize = 2 * poplarSize + 1;
                this.sift(array, it, poplarSize);
                next++;
            }

            if b - next <= smallPoplarSize {
                this.insertionSort(array, next, b);
                return;
            }

            it = next;
            next += smallPoplarSize;
            poplarLevel++;
        }
    }

    new classmethod sortHeap(array, a, b) {
        new int l = b - a;

        if l < 2 {
            return;
        }

        do l > 1 {
            this.popHeapWithSize(array, a, b, l);
            b--;
            l--;
        }
    }

    new classmethod sort(array, a, b) {
        this.makeHeap(array, a, b);
        this.sortHeap(array, a, b);
    }
}

@Sort(
    "Selection Sorts",
    "Poplar Heap Sort",
    "Poplar Heap"
);
new function poplarHeapSortRun(array) {
    PoplarHeapSort.sort(array, 0, len(array));
}