# MIT License
#
# Copyright (c) 2021-2022 aphitorite
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
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

use lrBinarySearch, blockSwap, BitArray, medianOfThreeIdx, partition,
    binaryInsertionSort;

namespace PacheSort {
    static: new int MIN_INSERT = 32,
                    MIN_HEAP   = 255;

    new classmethod log2(n) {
        return int(math.log2(n));
    }

    new classmethod siftDown(array, val, i, p, n) {
        while 4 * i + 1 < n {
            new Value max = val;
            new int  next = i,
                    child = 4 * i + 1;

            for j = child; j < min(child + 4, n); j++ {
                if array[p + j] > max {
                    max  = array[p + j].read();
                    next = j;
                }
            } 

            if next == i {
                break;
            }

            array[p + i].write(max);
            i = next;
        }
        array[p + i].write(val);
    }

    new classmethod optiHeapSort(array, a, b) {
        static: new int n = b - a;

        for i = (n - 1) // 4; i >= 0; i-- {
            this.siftDown(array, array[a + i].read(), i, a, n);
        }

        for i = n - 1; i > 0; i-- {
            new Value t = array[a + i].read();
            array[a + i].write(array[a]);
            this.siftDown(array, t, 0, a, i);
        }
    }

    new classmethod ninther(array, a) {
        static:
        new int a1 = medianOfThreeIdx(array,     a, a + 1, a + 2),
                m1 = medianOfThreeIdx(array, a + 3, a + 4, a + 5),
                b1 = medianOfThreeIdx(array, a + 6, a + 7, a + 8);

        return medianOfThreeIdx(array, a1, m1, b1);
    }

    new classmethod pivotSelect(array, a, b) {
        if b - a <= 256 {
            for i = a; i < a + 9; i++ {
                array[i].swap(array[random.randrange(i, b)]);
            }

            array[a].swap(array[this.ninther(array, a)]);
        } else {
            for i = a; i < a + 27; i++ {
                array[i].swap(array[random.randrange(i, b)]);
            }

            static: 
            new int a1 = this.ninther(array, a),
                    m1 = this.ninther(array, a + 9),
                    b1 = this.ninther(array, a + 18);

            array[a].swap(array[medianOfThreeIdx(array, a1, m1, b1)]);
        }
    }

    new classmethod dualQuickSelect(array, a, b, r1, r2) {
        static: new int a1 = a,
                        b1 = b;

        while b - a > PacheSort.MIN_INSERT {
            this.pivotSelect(array, a, b);
            new int m = partition(array, a, b, a);
            array[a].swap(array[m]);

            if m > r2 && m < b1 {
                b1 = m;
            } elif m < r2 && m + 1 > a1 {
                a1 = m + 1;
            } elif m == r2 {
                a1 = b1;
            }

            if m == r1 {
                break;
            }

            new int left  = m - a,
                    right = b - m - 1;

            if m > r1 {
                b = m;
            } else {
                a = m + 1;
            }
        }

        if b - a <= PacheSort.MIN_INSERT {
            binaryInsertionSort(array, a, b);
        }

        while b1 - a1 > PacheSort.MIN_INSERT {
            this.pivotSelect(array, a1, b1);
            new int m = partition(array, a1, b1, a1);
            array[a1].swap(array[m]);

            if m == r2 {
                return;
            }

            new int left  = m - a1,
                    right = b1 - m - 1;

            if m > r2 {
                b1 = m;
            } else {
                a1 = m + 1;
            }
        }

        if b1 - a1 <= PacheSort.MIN_INSERT {
            binaryInsertionSort(array, a1, b1);
        }
    }

    new classmethod optiLazyHeap(array, a, b, s) {
        for j = a; j < b; j += s {
            new int max = j;

            for i = max + 1; i < min(j + s, b); i++ {
                if array[i] > array[max] {
                    max = i;
                }
            }

            array[j].swap(array[max]);
        }

        for j = b; j > a; {
            new int k = a;

            for i = k + s; i < j; i += s {
                if array[i] > array[k] {
                    k = i;
                }
            }

            j--;
            new int k1 = j;

            for i = k + 1; i < min(k + s, j); i++ {
                if array[i] > array[k1] {
                    k1 = i;
                }
            }

            if k1 == j {
                array[k].swap(array[j]);
            } else {
                new Value t = array[j].read();
                array[j].write(array[k]);
                array[k].write(array[k1]);
                array[k1].write(t);
            }
        }
    }

    new classmethod sortBucket(array, a, b, s, val) {
        for i = b - 1; i >= a; i-- {
            if array[i] == val {
                b--;
                array[i].swap(array[b]);
            }
        }

        this.optiLazyHeap(array, a, b, s);
    }

    new classmethod sort(array, a, b) {
        if b - a <= PacheSort.MIN_HEAP {
            this.optiHeapSort(array, a, b);
            return;
        }

        static: new int log    = this.log2(b - a - 1) + 1,
                        pCnt   = (b - a) // (log ** 2),
                        bitLen = (pCnt + 1) * log,
                        a1     = a + bitLen,
                        b1     = b - bitLen;

        this.dualQuickSelect(array, a, b, a1, b1 - 1);
        this.optiHeapSort(array, b1, b);

        if array[a1] < array[b1 - 1] {
            new int a2 = a1;

            for i = 0; i < pCnt; i++, a2++ {
                array[a2].swap(array[random.randrange(a2, b1)]);
            }

            this.optiHeapSort(array, a1, a2);

            new BitArray cnts = BitArray(array, a, b1, pCnt + 1, log);

            for i = a2; i < b1; i++ {
                cnts.incr(lrBinarySearch(array, a1, a2, array[i], True) - a1);
            }

            for i = 1, sum = cnts.get(0); i < pCnt + 1; i++ {
                sum += cnts.get(i);
                cnts.set(i, sum);
            }

            for i = 0, j = 0; i < pCnt; i++ {
                new int cur = cnts.get(i);

                while j < cur {
                    new int loc = lrBinarySearch(array, a1 + i, a2, array[a2 + j], True) - a1;

                    if loc == i {
                        cur--;
                        array[a2 + j].swap(array[a2 + cur]);
                    } else {
                        cnts.decr(loc);
                        array[a2 + j].swap(array[a2 + cnts.get(loc)]);
                    }
                }
                j = lrBinarySearch(array, a2 + j, b1, array[a1 + i], False) - a2;
            }

            cnts.free();

            new int j = a2;

            for i = 0; i < pCnt; i++ {
                new int j1 = lrBinarySearch(array, j, b1, array[a1 + i], False);
                this.sortBucket(array, j, j1, log, array[a1 + 1].read());
                j = j1;
            }

            this.optiLazyHeap(array, j, b1, log);
            HeliumSort.mergeWithBufferFW(array, a1, a2, b1, a);
        }

        this.optiHeapSort(array, a, a1);
    }
}

@Sort(
    "Partition Sorts",
    "Pache Sort",
    "Pache Sort"
);
new function pacheSortRun(array) {
    PacheSort.sort(array, 0, len(array));
}