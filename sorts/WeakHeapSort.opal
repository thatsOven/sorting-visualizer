new class WeakHeapSort {
    new method __init__(array, length) {
        this.array  = array;
        this.length = length;
        this.bits   = sortingVisualizer.createValueArray((this.length + 7) // 8);
    }

    new method getBitwiseFlag(x) {
        return (this.bits[x >> 3] >> (x & 7)) & 1;
    }

    new method toggleBitwiseFlag(x) {
        new dynamic flag = this.bits[x >> 3].copy();
        flag ^= 1 << (x & 7);
        this.bits[x >> 3].write(flag);
    }

    new method merge(i, j) {
        if this.array[i] < this.array[j] {
            this.toggleBitwiseFlag(j);
            this.array[i].swap(this.array[j]);
        }
    }

    new method sort() {
        sortingVisualizer.setAux(this.bits);

        new int n = this.length, i, j, x, y, Gparent;

        for i = n - 1; i > 0; i-- {
            j = i;

            for ; (j & 1) == this.getBitwiseFlag(j >> 1); j >>= 1 {}
            Gparent = j >> 1;

            this.merge(Gparent, i);
        }

        for i = n - 1; i >= 2; i-- {
            this.array[0].swap(this.array[i]);

            x = 1;

            for y = 2 * x + this.getBitwiseFlag(x); y < i; x = y {
                y = 2 * x + this.getBitwiseFlag(x);
                if y >= i {
                    break;
                }
            }

            for ; x > 0; x >>= 1 {
                this.merge(0, x);
            }
        }

        this.array[0].swap(this.array[1]);
    }
}

@Sort(
    "Tree Sorts",
    "Weak Heap Sort",
    "Weak Heap Sort"
);
new function weakHeapSortRun(array) {
    WeakHeapSort(array, len(array)).sort();
}