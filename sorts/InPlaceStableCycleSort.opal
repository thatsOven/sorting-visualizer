# MIT License
# 
# Copyright (c) 2021 aphitorite
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# stable sorting algorithm performing a worst case of 
# O(n^2) comparisons and O(n) moves in O(1) space

use blockSwap, compareValues, findMinMaxIndices, 
    compSwap, binaryInsertionSort, lrBinarySearch;

new class InPlaceStableCycleSort {
    new method __init__(rot = None) {
        if rot is None {
            this.rotate = sortingVisualizer.getRotation(
                id = sortingVisualizer.getUserSelection(
                    [r.name for r in sortingVisualizer.rotations],
                    "Select rotation algorithm (default: Cycle Reverse)"
                )
            ).indexedFn;
        } else {
            this.rotate = sortingVisualizer.getRotation(name = rot).indexedFn;
        }
    }

    new classmethod getRank(array, a, b, r) {
        new int c  = 0,
                ce = 0;

        for i = a; i < b; i++ {
            if i == r {
                continue;
            }

            new int cmp = compareValues(array[i], array[r]);

            c  += int(cmp == -1);
            ce += int(cmp <=  0); 
        }

        return c, ce;
    }

    new classmethod selectMedian(array, a, b) {
        new int med = (b - a) // 2, min_, max_;
        min_, max_ = findMinMaxIndices(array, a, b);

        new int r, re;
        r, re = this.getRank(array, a, b, min_);

        if med >= r && med <= re {
            return array[min_].copy();
        }

        r, re = this.getRank(array, a, b, max_);

        if med >= r && med <= re {
            return array[max_].copy();
        }

        for i = a;; i++ {
            if array[i] > array[min_] && array[i] < array[max_] {
                r, re = this.getRank(array, a, b, i);

                if med >= r && med <= re {
                    return array[i].copy();
                } elif re < med {
                    min_ = i;
                } else {
                    max_ = i;
                }
            }
        }
    }

    new classmethod resetBits(array, pa, pb, bLen) {        
        repeat bLen {
            compSwap(array, pa, pb);
            pa++;
            pb++;
        }
    }

    new method initBitBuffer(array, a, b, piv, bLen) {
        new int p    = b,
                aCnt = 0,
                bCnt = 0,
                tCnt = 0;

        for i = b; i > a && tCnt < 2 * bLen; i-- {
            new int pCmp = compareValues(array[i - 1], piv);

            if aCnt < bLen && pCmp < 0 {
                this.rotate(array, i, p - tCnt, p);
                p = i + tCnt;
                tCnt++;
                aCnt++;
            } elif bCnt < bLen && pCmp > 0 {
                this.rotate(array, i, p - tCnt, p);
                p = i + tCnt;
                tCnt++;
                this.rotate(array, i - 1, i, p - bCnt);
                bCnt++;
            }
        }

        this.rotate(array, p - tCnt, p, b);
        if tCnt == 2 * bLen {
            return False;
        }

        new int b1 = b - tCnt;

        if aCnt < bLen && bCnt < bLen {
            binaryInsertionSort(array, b1, b);
            this.rotate(array, a, b1, b - bCnt);
            return True;
        }

        new int eCnt = 0,
                eLen = tCnt - bLen;
        p = b1;

        for i = b1; eCnt < eLen; i-- {
            if array[i - 1] == piv {
                this.rotate(array, i, p - eCnt, p);
                p = i + eCnt;
                eCnt += 2;
            }
        }

        this.rotate(array, p - eLen,      p, b1);
        this.rotate(array, b - 2 * bLen, b1, b - bCnt);
        return False;
    }

    new classmethod blockCyclePartitionDest(array, a, a1, b1, b, pa, pb, piv, bLen, cmp) {
        new int d = a1,
                e = 0;
        new int pCmp = compareValues(array[a1], piv);

        for i = a1 + bLen; i < b; i += bLen {
            new int vCmp = compareValues(array[i], piv);

            if vCmp < pCmp {
                d += bLen;
            } elif (
                i < b1 &&
                compareValues(
                    array[pa + (i - a) // bLen], 
                    array[pb + (i - a) // bLen]
                ) != cmp &&
                vCmp == pCmp
            ) {
                e++;
            }
        }

        while True {
            if compareValues(
                array[pa + (d - a) // bLen], 
                array[pb + (d - a) // bLen]
            ) != cmp {
                if e <= 0 {
                    break;
                }

                e--;
            }

            d += bLen;
        }

        return d;
    }

    new classmethod blockCyclePartition(array, a, b, pa, pb, piv, bLen, cmp) {
        for i = a; i < b; i += bLen {
            if compareValues(array[pa + (i - a) // bLen], array[pb + (i - a) // bLen]) != cmp {
                new int j = i;

                while True {
                    new int k = this.blockCyclePartitionDest(array, a, i, j, b, pa, pb, piv, bLen, cmp);

                    array[pa + (k - a) // bLen].swap(array[pb + (k - a) // bLen]);
                    if k == i {
                        break;
                    }

                    blockSwap(array, i, k, bLen);
                    j = k;
                }
            }
        }
    }

    new method merge(array, cnt, a, m, b, piv) {
        new int m1 = lrBinarySearch(array,  m, b, piv, True),
                m2 = lrBinarySearch(array, m1, b, piv, False);

        new int aCnt = m1 - m,
                mCnt = m2 - m1,
                bCnt = b - m2;

        this.rotate(array, a + cnt[0], m, m1);
        cnt[0] += aCnt;

        this.rotate(array, a + cnt[0] + cnt[1], m1, m2);
        cnt[1] += mCnt;
        cnt[2] += bCnt;
    }

    new method mergeEasy(array, a, m, b, piv) {
        b = lrBinarySearch(array, m, b, piv, False);
        new int m1 = lrBinarySearch(array,  a, m, piv, True),
                m2 = lrBinarySearch(array, m1, m, piv, False);

        this.rotate(array, m2, m, b);

        b = lrBinarySearch(array, m2, b - (m - m2), piv, True);
        this.rotate(array, m1, m2, b);
    }

    new method partition(array, a, b, piv) {
        new int n    = b - a,
                bLen = int(math.sqrt(n - 1)) + 1;

        if this.initBitBuffer(array, a, b, piv, bLen) {
            return True;
        }

        new int b1  = b - 2 * bLen,
                pa  = b1,
                pb  = b1 + bLen,
                cmp = 1;

        for i = a; i < b1; i += bLen, cmp = -cmp {
            this.blockCyclePartition(array, i, min(i + bLen, b1), pa, pb, piv, 1, cmp);
        }
        this.resetBits(array, pa, pb, bLen);

        new int p = a;
        new list cnt = [0, 0, 0];

        for i = a; i < b1; i += bLen {
            this.merge(array, cnt, p, i, min(i + bLen, b1), piv);

            while cnt[0] >= bLen {
                cnt[0] -= bLen;
                p += bLen;
            }

            while cnt[1] >= bLen {
                this.rotate(array, p, p + cnt[0], p + cnt[0] + bLen);
                cnt[1] -= bLen;
                p += bLen;
            }

            while cnt[2] >= bLen {
                this.rotate(array, p, p + cnt[0] + cnt[1], p + cnt[0] + cnt[1] + bLen);
                cnt[2] -= bLen;
                p += bLen;
            }
        }

        this.blockCyclePartition(array, a, p, pa, pb, piv, bLen, 1);
        this.resetBits(array, pa, pb, bLen);

        this.mergeEasy(array, p, b1, b, piv);
        this.mergeEasy(array, a,  p, b, piv);

        return False;
    }

    new classmethod stableCycleDest(array, a1, b1, b, p, piv, cmp) {
        new int d = a1,
                e = 0;

        for i = a1 + 1; i < b; i++ {
            new int pCmp = compareValues(array[i], piv);
            new bool bit = pCmp == cmp || pCmp == 0;

            new Value val  = array[p + i] if bit else array[i];
            new int   vCmp = compareValues(val, array[a1]);

            if vCmp == -1 {
                d++;
            } elif i < b1 && (!bit) && vCmp == 0 {
                e++;
            }
        }

        while True {
            new int pCmp = compareValues(array[d], piv);
            new bool bit = pCmp == cmp || pCmp == 0;

            if !bit {
                if e == 0 {
                    break;
                }

                e--;
            }
            
            d++;
        }

        return d;
    }

    new classmethod stableCycle(array, a1, b, p, piv, cmp) {
        for i = a1; i < b; i++ {
            new int pCmp = compareValues(array[i], piv);
            new bool bit = pCmp == cmp || pCmp == 0;

            if !bit {
                new int j = i;

                while True {
                    new int k = this.stableCycleDest(array, i, j, b, p, piv, cmp);

                    if k == i {
                        break;
                    }

                    new Value t = array[i].copy();
                    array[i    ].write(array[k]);
                    array[k    ].write(array[p + k]);
                    array[p + k].write(t);

                    j = k;
                }

                array[i].swap(array[p + i]);
            }
        }
    }

    new method sort(array, length) {
        if length <= 32 {
            binaryInsertionSort(array, 0, length);
            return;
        }

        new Value piv = this.selectMedian(array, 0, length);
        if this.partition(array, 0, length, piv) {
            return;
        }

        new int n = length // 2,
                p = (length + 1) // 2;
        for ; array[n - 1] == array[p]; n--, p++ {}

        if array[p] == piv {
            new int p1    = p,
                    bSize = 1;
            for p1++; p1 < length && array[p1] == piv; p1++, bSize++ {}

            this.stableCycle(array, 0, n, p, piv, 1);
            blockSwap(array, 0, p, bSize);
            this.stableCycle(array, bSize, n, p, piv, -1);
        } elif array[n - 1] == piv {
            new int n1    = n,
                    bSize = 1;
            for n1--; n1 > 0 && array[n1 - 1] == piv; n1--, bSize++ {}

            this.stableCycle(array, 0, n1, p, piv, 1);
            blockSwap(array, n1, length - bSize, bSize);
            this.stableCycle(array, 0, n, p, piv, -1);
        } else {
            this.stableCycle(array, 0, n, p, piv, 1);
            this.stableCycle(array, 0, n, p, piv, -1);
        }
    }
}

@Sort(
    "Hybrid Sorts",
    "In-Place Stable Cycle Sort",
    "In-Place Stable Cycle"
);
new function inPlaceStableCycleRun(array) {
    InPlaceStableCycleSort().sort(array, len(array));
}