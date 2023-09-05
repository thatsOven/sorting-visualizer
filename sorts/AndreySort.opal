use blockSwap, compSwap;

namespace AndreySort {
    new classmethod sort(array, a, b) {
        while b > 1 {
            new int k = 0;
            for i = 1; i < b; i++ {
                if array[a + k] > array[a + i] {
                    k = i;
                }
            }
            array[a].swap(array[a + k]);
            a++;
            b--;
        }
    }

    new classmethod backmerge(array, a1, l1, a2, l2) {
        new int a0 = a2 + l1;
        while True {
            if array[a1] > array[a2] {
                array[a1].swap(array[a0]);
                a1--; a0--; l1--;
                if l1 == 0 {
                    return 0;
                }
            } else {
                array[a2].swap(array[a0]);
                a2--; a0--; l2--;
                if l2 == 0 {
                    break;
                }
            }
        }

        new int res = l1;
        do {
            array[a1].swap(array[a0]);
            a1--; a0--; l1--;
        } while l1 != 0;
        return res;
    }

    new classmethod rmerge(array, a, l, r) {
        for i = 0; i < l; i += r {
            new int q = i;
            for j = i + r; j < l; j += r {
                if array[a + q] > array[a + j] {
                    q = j;
                }
            }
            if q != i {
                blockSwap(array, a + i, a + q, r);
            }
            if i != 0 {
                blockSwap(array, a + l, a + i, r);
                this.backmerge(array, a + (l + r - 1), r, a + (i - 1), r);
            }
        }
    }

    new classmethod rbnd(len) {
        len //= 2;
        new int k = 0, i;
        for i = 1; i < len; i *= 2, k++ {}
        len //= k;
        for k = 1; k <= len; k *= 2 {}
        return k;
    }

    new classmethod msort(array, a, len) {
        if len < 12 {
            this.sort(array, a, len);
            return;
        }

        new int r  = this.rbnd(len),
                lr = (len // r - 1) * r;

        for p = 2; p <= lr; p += 2 {
            compSwap(array, a + (p - 2), a + (p - 1));

            if (p & 2) != 0 {
                continue;
            }

            blockSwap(array, a + (p - 2), a + p, 2);

            new int m = len - p,
                    q = 2;

            while True {
                new int q0 = 2 * q;
                if q0 > m || (p & q0) != 0 {
                    break;
                }
                this.backmerge(array, a + (p - q - 1), q, a + (p + q - 1), q);
                q = q0;
            }

            this.backmerge(array, a + (p + q - 1), q, a + (p - q - 1), q);
            new int q1 = q;
            q *= 2;

            while (q & p) == 0 {
                q *= 2;
                this.rmerge(array, a + (p - q), q, q1);
            }
        }

        new int q1 = 0;
        for q = r; q < lr; q *= 2 {
            if (lr & q) != 0 {
                q1 += q;
                if q1 != q {
                    this.rmerge(array, a + (lr - q1), q1, r);
                }
            }
        }

        new int s = len - lr;
        this.msort(array, a + lr, s);
        blockSwap(array, a, a + lr, s);
        s += this.backmerge(array, a + (s - 1), s, a + (lr - 1), lr - s);
        this.msort(array, a, s);
    }
}

@Sort(
    "Merge Sorts",
    "Andrey Astrelin's In-Place Merge Sort",
    "Andrey's Merge"
);
new function andreySortRun(array) {
    AndreySort.msort(array, 0, len(array));
}