new class MergeInsertionSort {
    new classmethod blockSwap(array, a, b, s) {
        for ; s > 0; a--, b-- {
            s--;
            array[a].swap(array[b]);
        }
    }

    new classmethod blockInsert(array, a, b, s) {
        while a - s >= b {
            this.blockSwap(array, a - s, a, s);
            a -= s;
        }
    }

    new classmethod blockReversal(array, a, b, s) {
        b -= s;
        while b > a {
            this.blockSwap(array, a, b, s);
            a += s;
            b -= s;
        }
    }

    new classmethod blockSearch(array, a, b, s, val) {
        while a < b {
            new int m = a + (((b - a) // s) // 2) * s;

            if val < array[m] {
                b = m;
            } else {
                a = m + s;
            }
        }

        return a;
    }

    new classmethod order(array, a, b, s) {
        for i = a, j = i + s; j < b; i += s, j += 2 * s {
            this.blockInsert(array, j, i, s);
        }
        new int m = a + (((b - a) // s) // 2) * s;
        this.blockReversal(array, m, b, s);
    }

    new classmethod sort(array, length) {
        for k = 1; 2 * k <= length; k *= 2 {
            for i = 2 * k - 1; i < length; i += 2 * k {
                if array[i - k] > array[i] {
                    this.blockSwap(array, i - k, i, k);
                }
            }
        }

        for ; k > 0; k //= 2 {
            new int a = k - 1,
                    i = a + 2 * k,
                    g = 2,
                    p = 4;

            while i + 2 * k * g - k <= length {
                this.order(array, i, i + 2 * k * g - k, k);
                new int b = a + k * (p - 1);

                i += k * g - k;
                for j = i; j < i + k * g; j += k {
                    this.blockInsert(array, j, this.blockSearch(array, a, b, k, array[j]), k);
                }

                i += k * g + k;
                g = p - g;
                p *= 2;
            }

            for ; i < length; i += 2 * k {
                this.blockInsert(array, i, this.blockSearch(array, a, i, k, array[i]), k);
            }
        }
    }
}

@Sort(
    "Insertion Sorts",
    "Merge Insertion Sort [Ford-Johnson Algorithm]",
    "Merge Insert"
);
new function mergeInsertionSortRun(array) {
    MergeInsertionSort.sort(array, len(array));
}