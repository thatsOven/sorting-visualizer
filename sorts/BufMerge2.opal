# Copyright (c) 2023 thatsOven
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

use lrBinarySearch, binaryInsertionSort, log2;

new class BufMerge2 {
    new int RUN_SIZE = 32;

    new method __init__(rot = None) {
        if rot is None {
            this.rotate = sortingVisualizer.getRotation(
                id = sortingVisualizer.getUserSelection(
                    [r.name for r in sortingVisualizer.rotations],
                    "Select rotation algorithm (default: Helium)"
                )
            ).indexedFn;
        } else {
            this.rotate = sortingVisualizer.getRotation(name = rot).indexedFn;
        }
    }

    new method sortRuns(array, a, b) {
        new dynamic speed = sortingVisualizer.speed;
        sortingVisualizer.setSpeed(max(int(10 * (len(array) / 2048)), speed * 2));

        for i = a; i < b - BufMerge2.RUN_SIZE; i += BufMerge2.RUN_SIZE {
            binaryInsertionSort(array, i, i + BufMerge2.RUN_SIZE);
        }

        if i < b {
            binaryInsertionSort(array, i, b);
        }

        sortingVisualizer.setSpeed(speed);
    }

    new method mergeInPlaceBW(array, a, m, b) {
        new int s = b - 1,
                l = m - 1;

        while s > l && l >= a {
            if array[l] > array[s] {
                new int p = lrBinarySearch(array, a, l, array[s], False);
                this.rotate(array, p, l + 1, s + 1);
                s -= l + 1 - p;
                l = p - 1;
            } else {
                s--;
            }
        }
    }

    new classmethod mergeWithStatBufferBW(array, a0, b0, a1, b1, buf) {
        new int l = b0  - 1,
                r = b1  - 1,
                o = buf - 1;

        for ; l >= a0 && r >= a1; o-- {
            if array[r] >= array[l] {
                array[o].swap(array[r]);
                r--;
            } else {
                array[o].swap(array[l]);
                l--;
            }
        }

        for ; r >= a1; o--, r-- {
            array[o].swap(array[r]);
        }

        for ; l >= a0; o--, l-- {
            array[o].swap(array[l]);
        }
    }

    new classmethod gallopMerge(array, a0, b0, a1, b1, buf) {
        new int l = b0  - 1,
                r = b1  - 1,
                o = buf - 1;

        for ; l >= a0 && r >= a1; o-- {
            if array[l] > array[r] {
                new int k = lrBinarySearch(array, a0, l, array[r], False);
                for ; l >= k; l--, o-- {
                    array[l].swap(array[o]);
                }
            }

            array[r].swap(array[o]);
            r--;
        }

        for ; r >= a1; o--, r-- {
            array[o].swap(array[r]);
        }

        for ; l >= a0; o--, l-- {
            array[o].swap(array[l]);
        }
    }

    new classmethod mergeWithScrollingBufferFW(array, a, m, b) {
        new int o = a - (m - a),
                l = a,
                r = m;

        for ; l < m && r < b; o++ {
            if array[l] <= array[r] {
                array[o].swap(array[l]);
                l++;
            } else {
                array[o].swap(array[r]);
                r++;
            }
        }

        for ; l < m; o++, l++ {
            array[o].swap(array[l]);
        }

        for ; r < b; o++, r++ {
            array[o].swap(array[r]);
        }
    }

    new classmethod mergeWithScrollingBufferBW(array, a, m, b) {
        new int l = m - 1,
                r = b - 1,
                o = r + m - a;

        for ; r >= m && l >= a; o-- {
            if array[r] >= array[l] {
                array[o].swap(array[r]);
                r--;
            } else {
                array[o].swap(array[l]);
                l--;
            }
        }

        for ; r >= m; o--, r-- {
            array[o].swap(array[r]);
        }
        
        for ; l >= a; o--, l-- {
            array[o].swap(array[l]);
        }
    }

    new method buildFW(array, a, b) {
        new int s = a,
                e = b,
                r = BufMerge2.RUN_SIZE;

        while r < b - a {
            new int twoR = 2 * r, i;
            for i = s; i < e - twoR; i += twoR {
                this.mergeWithScrollingBufferFW(array, i, i + r, i + twoR);
            }

            if i + r < e {
                this.mergeWithScrollingBufferFW(array, i, i + r, e);
            }

            s -= r;
            e -= r;
            r = twoR;
        }
    }

    new method buildBW(array, a, b) {
        new int s = a,
                e = b,
                r = BufMerge2.RUN_SIZE;

        while r < b - a {
            new int twoR = 2 * r, i;
            for i = e; i >= s + twoR; i -= twoR {
                this.mergeWithScrollingBufferBW(array, i - twoR, i - r, i);
            }

            if i - r >= s {
                this.mergeWithScrollingBufferBW(array, s, i - r, i);
            }

            s += r;
            e += r;
            r = twoR;
        }
    }

    new method sortBuf(array, a, b) {
        new int n = b - a;

        if n <= this.sqrtn {
            binaryInsertionSort(array, a, b);
            return -1;
        }

        new int h = n // 2 - (n & 1);
        a += BufMerge2.RUN_SIZE;

        this.sortRuns(array, a, a + h);
        this.buildBW(array, a, a + h);

        return a + h - BufMerge2.RUN_SIZE;
    }

    new method sort(array, a, b) {
        new int n = b - a, h;

        if n <= BufMerge2.RUN_SIZE {
            binaryInsertionSort(array, a, b);
            return;
        }

        new int sqrtn = 1;
        for ; sqrtn * sqrtn < n; sqrtn *= 2 {}
        this.sqrtn = sqrtn;

        new int gallop = n // log2(n);

        h = n // 2 + (n & 1) - BufMerge2.RUN_SIZE;
        b -= BufMerge2.RUN_SIZE;

        this.sortRuns(array, a + h, b);
        this.buildFW(array, a + h, b);

        b += BufMerge2.RUN_SIZE;

        new int s = a + h + BufMerge2.RUN_SIZE;
        while True {
            new int p = this.sortBuf(array, s, b);
            if p == -1 {
                this.mergeInPlaceBW(array, a, s, b);
                return;
            }

            if b - p > gallop {
                this.mergeWithStatBufferBW(array, a, s, p, b, p);
            } else {
                this.gallopMerge(array, a, s, p, b, p);
            }

            s = p;
        }
    }
}

@Sort(
    "Merge Sorts",
    "thatsOven's In-Place Buffered Merge Sort II",
    "Buf Merge 2"
);
new function bufMerge2Run(array) {
    BufMerge2().sort(array, 0, len(array));
}