# MIT License
#
# Copyright (c) 2022 aphitorite
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

use blockSwap, arrayCopy, log2, medianOfMedians,
    medianOf9, binaryInsertionSort, reverseArrayCopy;

namespace LogSort {
    new classmethod productLog(n) {
        for r = 1; (r << r) + r - 1 < n; r++ {}
        return r;
    }

    new classmethod pivCmp(v, piv, pCmp) {
        return compareValues(v, piv) < pCmp;
    }

    new classmethod pivBufSet(array, pa, pb, v, wLen) {
        while wLen > 0 {
            wLen--;
            if (v & 1) == 1 {
                array[pa + wLen].swap(array[pb + wLen]);
            }

            v >>= 1;
        }
    }

    new classmethod pivBufGet(array, pa, piv, pCmp, wLen, bit) {
        new int r = 0;

        while wLen > 0 {
            wLen--;
            r <<= 1;
            r |= bit if this.pivCmp(array[pa], piv, pCmp) else (bit ^ 1);
            pa++;
        }

        return r;
    }

    new classmethod partitionEasy(array, aux, a, b, piv, pCmp) {
        new int j = 0;

        for i = a; i < b; i++ {
            if this.pivCmp(array[i], piv, pCmp) {
                array[a].write(array[i]);
                a++;
            } else {
                aux[j].write(array[i]);
                j++;
            }
        }

        arrayCopy(aux, 0, array, a, j);
        return a;
    }

    new classmethod blockPartition(array, aux, a, b, bLen, piv, pCmp) {
        if b - a <= bLen {
            return this.partitionEasy(array, aux, a, b, piv, pCmp);
        }

        new int p  = a,
                l  = 0,
                r  = 0,
                lb = 0,
                rb = 0;

        for i = a; i < b; i++ {
            if this.pivCmp(array[i], piv, pCmp) {
                array[p + l].write(array[i]);
                l++;

                if l == bLen {
                    l = 0;
                    lb++;
                    p += bLen;
                }
            } else {
                aux[r].write(array[i]);
                r++;

                if r == bLen {
                    arrayCopy(array, p, array, p + bLen, l);
                    arrayCopy(aux, 0, array, p, bLen);
                    r = 0;
                    rb++;
                    p += bLen;
                }
            }
        }

        new int min_ = min(lb, rb),
                m    = a + lb * bLen;

        if min_ > 0 {
            new int bCnt = lb + rb,
                    wLen = log2(min_ - 1) + 1;

            for i = 0, j = 0, k = 0; i < min_; i++ {
                for ; !this.pivCmp(array[a + j * bLen + wLen], piv, pCmp); j++ {}
                for ;  this.pivCmp(array[a + k * bLen + wLen], piv, pCmp); k++ {}
                this.pivBufSet(array, a + j * bLen, a + k * bLen, i, wLen);
                j++; k++;
            }


            if lb < rb {
                for i = bCnt - 1, j = 0; j < rb; i-- {
                    if !this.pivCmp(array[a + i * bLen + wLen], piv, pCmp) {
                        j++;
                        blockSwap(array, a + i * bLen, a + (bCnt - j) * bLen, bLen);
                    }
                }

                for i = 0; i < lb; i++ {
                    new int dest = this.pivBufGet(array, a + i * bLen, piv, pCmp, wLen, 0);

                    while dest != i {
                        blockSwap(array, a + i * bLen, a + dest * bLen, bLen);
                        dest = this.pivBufGet(array, a + i * bLen, piv, pCmp, wLen, 0);
                    }

                    this.pivBufSet(array, a + i * bLen, m + i * bLen, i, wLen);
                }
            } else {
                for i = 0, j = 0; j < lb; i++ {
                    if this.pivCmp(array[a + i * bLen + wLen], piv, pCmp) {
                        blockSwap(array, a + i * bLen, a + j * bLen, bLen);
                        j++;
                    }
                }

                for i = 0; i < rb; i++ {
                    new int dest = this.pivBufGet(array, m + i * bLen, piv, pCmp, wLen, 1);

                    while dest != i {
                        blockSwap(array, m + i * bLen, m + dest * bLen, bLen);
                        dest = this.pivBufGet(array, m + i * bLen, piv, pCmp, wLen, 1);
                    }

                    this.pivBufSet(array, a + i * bLen, m + i * bLen, i, wLen);
                }
            }
        }

        arrayCopy(aux, 0, array, b - r, r);

        if l > 0 {
            arrayCopy(array, b - r - l, aux, 0, l);
            reverseArrayCopy(array, a + lb * bLen, array, a + lb * bLen + l, rb * bLen);
            arrayCopy(aux, 0, array, a + lb * bLen, l);
        }

        return a + lb * bLen + l;
    }

    new classmethod logSort(array, aux, a, b, bLen, badPartition) {
        while b - a > 32 {
            new int p;
            if badPartition {
                new int n = b - a;
                n -= ~n & 1;
                p = medianOfMedians(array, a, n);
                badPartition = False;
            } else {
                p = medianOf9(array, a, b);
            }

            new int m = this.blockPartition(array, aux, a, b, bLen, array[p].copy(), 0);
            new int left  = m - a,
                    right = b - m;

            if m == a {
                m = this.blockPartition(array, aux, a, b, bLen, array[p].copy(), 1);
                badPartition = left * 8 < right;
                a = m;
            } else {
                if right < left {
                    badPartition = right * 8 < left;
                    this.logSort(array, aux, m, b, bLen, badPartition);
                    b = m;
                } else {
                    badPartition = left * 8 < right;
                    this.logSort(array, aux, a, m, bLen, badPartition);
                    a = m;
                }
            }
        }

        binaryInsertionSort(array, a, b);
    }

    new classmethod sort(array, a, b, cBLen) {
        new int bLen = max(this.productLog(b - a), min(cBLen, b - a));
        new list aux = sortingVisualizer.createValueArray(bLen);
        sortingVisualizer.setAux(aux);

        this.logSort(array, aux, a, b, bLen, False);
    }
}

@Sort(
    "Quick Sorts",
    "Log Sort",
    "Log Sort"
);
new function logSortRun(array) {
    new int bLen = sortingVisualizer.getUserInput(
        "Set block size (default: calculates minimum block length for current length)", 
        str(LogSort.productLog(len(array)))
    );

    LogSort.sort(array, 0, len(array), bLen);
}