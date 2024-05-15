# MIT License
# 
# Copyright (c) 2023 aphitorite
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

use BitArray, javaNumberOfLeadingZeros, binaryInsertionSort, 
    lrBinarySearch, compareValues, blockSwap, bidirArrayCopy;

new class AdvancedLogMergeSort {
    new int MIN_INSERT = 16;

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

        this.aux = None;
    }

    new classmethod log2(n) {
        return 31 - javaNumberOfLeadingZeros(n);
    }

    new classmethod calcBLen(n) {
        new int h = n // 2,
                r = min(64, h // 2),
                c = h // r;
        
        for ; c * (this.log2(c - 1) + 1) + c <= h // 2; r--, c = h // r {}
        return r + 1;
    }

    new classmethod pivCmp(v, piv, pCmp) {
        return compareValues(v, piv) < pCmp;
    }

    new classmethod pivBufXor(array, pa, pb, v, wLen) {
        for ; wLen > 0; v >>= 1 {
            wLen--;
            if (v & 1) == 1 {
                array[pa + wLen].swap(array[pb + wLen]);
            }
        }
    }

    new classmethod pivBufGet(array, pa, piv, pCmp, wLen, bit) {
        new int r = 0;

        for ; wLen > 0; wLen--, pa++ {
            r <<= 1;
            r |= int(!this.pivCmp(array[pa], piv, pCmp)) ^ bit;
        }
        
        return r;
    }

    new classmethod blockCycle(array, p, n, p1, bLen, wLen, piv, pCmp, bit) {
        for i in range(n) {
            new int dest = this.pivBufGet(array, p + i * bLen, piv, pCmp, wLen, bit);

            while dest != i {
                blockSwap(array, p + i * bLen, p + dest * bLen, bLen);
                dest = this.pivBufGet(array, p + i * bLen, piv, pCmp, wLen, bit);
            }

            this.pivBufXor(array, p + i * bLen, p1 + i * bLen, i, wLen);
        }
    }

    new method mergeFWExt(array, a, m, b) {
        new int s = m - a;
        bidirArrayCopy(array, a, this.aux, 0, s);

        new int i = 0,
                j = m;
        for ; i < s && j < b; a++ {
            if this.aux[i] <= array[j] {
                array[a].write(this.aux[i]);
                i++;
            } else {
                array[a].write(array[j]);
                j++;
            }
        }

        for ; i < s; a++, i++ {
            array[a].write(this.aux[i]);
        }
    }

    new method mergeBWExt(array, a, m, b) {
        new int s = b - m;
        bidirArrayCopy(array, m, this.aux, 0, s);

        new int i = s - 1, 
                j = m - 1;
        while i >= 0 && j >= a {
            b--;

            if this.aux[i] >= array[j] {
                array[b].write(this.aux[i]);
                i--;
            } else {
                array[b].write(array[j]);
                j--;
            }
        }

        for ; i >= 0; i-- {
            b--;
            array[b].write(this.aux[i]);
        } 
    }

    new method blockMergeHelper(array, a, m, b, p, bLen, piv, pCmp, bit) {
        if m - a <= bLen {
            this.mergeFWExt(array, a, m, b);
            return;
        }

        bidirArrayCopy(array, m - bLen, this.aux, 0, bLen);

        new int wLen = this.log2((b - a) // bLen - 2) + 1,
                bCnt = 0,
                i    = a,
                j    = m,
                k    = 0,
                pc   = p;

        for ; i < m - bLen && j + bLen - 1 < b; pc += bLen, bCnt++, k++ {
            if array[i + bLen - 1] <= array[j + bLen - 1] {
                this.pivBufXor(array, i, pc, k, wLen);
                i += bLen;
            } else {
                this.pivBufXor(array, j, pc, (k << 1) | 1, wLen + 1);
                j += bLen;
            }
        }

        for ; i < m - bLen; i += bLen, pc += bLen, bCnt++, k++ {
            this.pivBufXor(array, i, pc, k, wLen);
        }

        bidirArrayCopy(array, a, array, m - bLen, bLen);

        new int a1 = a + bLen;
        this.blockCycle(array, a1, bCnt, p, bLen, wLen, piv, pCmp, bit);

        new int f = a1;
        new bool left = this.pivCmp(array[a1 + wLen], piv, pCmp) ^ bool(bit);

        if !left {
            array[a1 + wLen].swap(array[p + wLen]);
        }

        for k = 1, j = a; k < bCnt; k++ {
            new int nxt = a1 + k * bLen;
            new bool frag = this.pivCmp(array[nxt + wLen], piv, pCmp) ^ bool(bit);

            if !frag {
                array[nxt + wLen].swap(array[p + (nxt + wLen - a1)]);
            }

            if left ^ frag {
                i = f;
                f = nxt;

                for ; i < nxt; j++ {
                    new int cmp = compareValues(array[i], array[f]);
                    if cmp < 0 || (left && cmp == 0) {
                        array[j].write(array[i]);
                        i++;
                    } else {
                        array[j].write(array[f]);
                        f++;
                    }
                }

                !left;
            }
        }

        if left {
            k = a1 + bCnt * bLen;
            i = f;
            f = k;

            for ; i < k && f < b; j++ {
                if array[i] <= array[f] {
                    array[j].write(array[i]);
                    i++;
                } else {
                    array[j].write(array[f]);
                    f++;
                }
            }

            if f == b {
                for ; i < k; j++, i++ {
                    array[j].write(array[i]);
                }

                bidirArrayCopy(this.aux, 0, array, b - bLen, bLen);
                return;
            }
        }

        for i = 0; i < bLen && f < b; j++ {
            if this.aux[i] <= array[f] {
                array[j].write(this.aux[i]);
                i++;
            } else {
                array[j].write(array[f]);
                f++;
            }
        }

        for ; i < bLen; j++, i++ {
            array[j].write(this.aux[i]);
        }
    }

    new method blockMergeEasy(array, a, m, b, p, bLen, piv, pCmp, bit) {
        if b - m <= bLen {
            this.mergeBWExt(array, a, m, b);
            return;
        }

        if m - a <= bLen {
            this.mergeFWExt(array, a, m, b);
            return;
        }

        new int a1 = a + (m - a) % bLen;

        this.blockMergeHelper(array, a1, m, b, p, bLen, piv, pCmp, bit);
        this.mergeFWExt(array, a, a1, b);
    }

    new method blockMerge(array, a, m, b, bLen) {
        new int l = m - a,
                r = b - m,
                lCnt = (l + r + 1) // 2;

        new Value med;

        if r < l {
            if r <= bLen {
                this.mergeBWExt(array, a, m, b);
                return False;
            }

            new int la = 0,
                    lb = r;

            while la < lb {
                new int lm = (la + lb) // 2;

                if array[m + lm] <= array[a + (lCnt - lm) - 1] {
                    la = lm + 1;
                } else {
                    lb = lm;
                }
            }

            if la == 0 {
                med = array[a + lCnt - 1].copy();
            } elif array[m + la - 1] > array[a + (lCnt - la) - 1] {
                med = array[m + la - 1].copy();
            } else {
                med = array[a + (lCnt - la) - 1].copy();
            }
        } else {
            if l <= bLen {
                this.mergeFWExt(array, a, m, b);
                return False;
            }

            new int la = 0,
                    lb = l;

            while la < lb {
                new int lm = (la + lb) // 2;

                if array[a + lm] < array[m + (lCnt - lm) - 1] {
                    la = lm + 1;
                } else {
                    lb = lm;
                }
            }

            if l == r && la == l {
                med = array[m - 1].copy();
            } elif la == 0 {
                med = array[m + lCnt - 1].copy();
            } elif array[a + la - 1] >= array[m + (lCnt - la) - 1] {
                med = array[a + la - 1].copy();
            } else {
                med = array[m + (lCnt - la) - 1].copy();
            }
        }   

        new int m1  = lrBinarySearch(array, a, m, med, True),
                m2  = lrBinarySearch(array, m, b, med, False),
                ms2 = m - lrBinarySearch(array, m1, m, med, False),
                ms1 = lrBinarySearch(array, m, m2, med) - m;

        this.rotate(array, m - ms2, m, m2);
        this.rotate(array, m1, m - ms2, m + ms1 - ms2);

        this.blockMergeEasy(array, a, m1, m1 + ms1, a + lCnt, bLen, med, 0, 0);
        this.blockMergeEasy(array, m2 - ms2, m2, b, a, bLen, med, 1, 1);

        return m2 - m1 - (ms2 + ms1) <= lCnt;
    }

    new method blockMergeWithBufHelper(array, a, m, b, pa, pb, bLen) {
        if m - a <= bLen {
            this.mergeFWExt(array, a, m, b);
            return;
        }

        bidirArrayCopy(array, m - bLen, this.aux, 0, bLen);

        new int bCnt    = 0,
                maxBCnt = (b - a) // bLen - 1,
                wLen    = this.log2(maxBCnt) + 1;

        new BitArray pos  = BitArray(array, pa, pb, maxBCnt, wLen),
                     bits = BitArray(array, pb - maxBCnt, pb + pb - pa - maxBCnt, maxBCnt, 1);

        new int a1 = a + bLen,
                i  = a,
                j  = m, k, posV;

        for ; i < m - bLen && j + bLen - 1 < b; bCnt++ {
            if array[i + bLen - 1] <= array[j + bLen - 1] {
                if i == a {
                    posV = (m - a1) // bLen - 1;
                } else {
                    posV = (i - a1) // bLen;
                }

                bits.setXor(bCnt, 1);
                i += bLen;
            } else {
                posV = (j - a1) // bLen;
                j += bLen;
            }

            if bCnt != posV {
                pos.setXor(bCnt, posV + 1);
            }
        } 

        for ; i < m - bLen; i += bLen, bCnt++ {
            if i == a {
                posV = (m - a1) // bLen - 1;
            } else {
                posV = (i - a1) // bLen;
            }

            if bCnt != posV {
                pos.setXor(bCnt, posV + 1);
            }

            bits.setXor(bCnt, 1);
        }

        bidirArrayCopy(array, a, array, m - bLen, bLen);

        for i in range(bCnt) {
            k = pos.get(i);

            if k > 0 {
                bidirArrayCopy(array, a1 + i * bLen, array, a, bLen);
                j = i;

                do {
                    bidirArrayCopy(array, a1 + (k - 1) * bLen, array, a1 + j * bLen, bLen);
                    pos.setXor(j, k);

                    j = k - 1;
                    k = pos.get(j);
                } while k != i + 1;

                bidirArrayCopy(array, a, array, a1 + j * bLen, bLen);
                pos.setXor(j, k);
            }
        }

        new int f = a1;
        new bool left = bits.get(0) != 0;

        if left {
            bits.setXor(0, 1);
        }

        for k = 1, j = a; k < bCnt; k++ {
            new int nxt = a1 + k * bLen;
            new bool frag = bits.get(k) != 0;

            if frag {
                bits.setXor(k, 1);
            }

            if left ^ frag {
                i = f;
                f = nxt;

                for ; i < nxt; j++ {
                    new int cmp = compareValues(array[i], array[f]);

                    if cmp < 0 || (left && cmp == 0) {
                        array[j].write(array[i]);
                        i++;
                    } else {
                        array[j].write(array[f]);
                        f++;
                    }
                }

                !left;
            }
        }

        if left {
            k = a1 + bCnt * bLen;
            i = f;
            f = k;

            for ; i < k && f < b; j++ {
                if array[i] <= array[f] {
                    array[j].write(array[i]);
                    i++;
                } else {
                    array[j].write(array[f]);
                    f++;
                }
            }

            if f == b {
                for ; i < k; j++, i++ {
                    array[j].write(array[i]);
                }

                bidirArrayCopy(this.aux, 0, array, b - bLen, bLen);
                return;
            }
        }

        for i = 0; i < bLen && f < b; j++ {
            if this.aux[i] <= array[f] {
                array[j].write(this.aux[i]);
                i++;
            } else {
                array[j].write(array[f]);
                f++;
            }
        }

        for ; i < bLen; j++, i++ {
            array[j].write(this.aux[i]);
        }
    }

    new method blockMergeWithBuf(array, a, m, b, pa, pb, bLen) {
        if b - m <= bLen {
            this.mergeBWExt(array, a, m, b);
            return;
        }

        if m - a <= bLen {
            this.mergeFWExt(array, a, m, b);
            return;
        }

        new int a1 = a + (m - a) % bLen;

        this.blockMergeWithBufHelper(array, a1, m, b, pa, pb, bLen);
        this.mergeFWExt(array, a, a1, b);
    }

    new method pureLogMergeSort(array, a, b, bLen) {
        for j = b - a; (j + 1) // 2 >= AdvancedLogMergeSort.MIN_INSERT; j = (j + 1) // 2 {}

        new dynamic speed = sortingVisualizer.speed;
        sortingVisualizer.setSpeed(max(int(10 * (len(array) / 2048)), speed * 2));

        for i = a; i < b; i += j {
            binaryInsertionSort(array, i, min(b, i + j));
        }

        sortingVisualizer.setSpeed(speed);

        for ; j < b - a; j *= 2 {
            for k = a; k + j < b && !this.blockMerge(array, k, k + j, min(b, k + 2 * j), bLen); k += 2 * j {}

            for i = k + 2 * j; i + j < b; i += 2 * j {
                this.blockMergeWithBuf(array, i, i + j, min(b, i + 2 * j), k, k + j, bLen);
            }
        }
    }

    new method sort(array, a, b, mem) {
        new int length = b - a;
        if length <= AdvancedLogMergeSort.MIN_INSERT {
            binaryInsertionSort(array, a, b);
            return;
        }

        new int bLen = max(this.calcBLen(length), min(mem, length));
        this.aux = sortingVisualizer.createValueArray(bLen);

        this.pureLogMergeSort(array, a, b, bLen);
    }
}

@Sort(
    "Block Merge Sorts",
    "Advanced Log Merge Sort",
    "Advanced Log Merge"
);
new function advancedLogMergeSortRun(array) {
    new int mem = sortingVisualizer.getUserInput(
        "Set block size (default: calculates minimum block length for current length)", 
        str(AdvancedLogMergeSort.calcBLen(len(array)))
    );

    AdvancedLogMergeSort().sort(array, 0, len(array), mem);
}