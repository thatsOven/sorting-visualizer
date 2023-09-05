# MIT License
#
# Copyright (c) 2020-2022 aphitorite
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

use binaryInsertionSort, blockSwap, cycleReverseRotate, lrBinarySearch;

namespace KotaSort {
    new classmethod tLenCalc(n, bLen) {
        new int n1 = n - 2 * bLen,
                a  = 0,
                b  = 2 * bLen, m;

        while a < b {
            m = (a + b) // 2;

            if n1 - m < (m + 3) * bLen {
                b = m;
            } else {
                a = m + 1;
            }
        }

        return a;
    }

    new classmethod findKeysBW(array, a, b, nKeys) {
        new int f = 1,
                p = b - f, loc;

        for i = p; i > a && f < nKeys; i-- {
            loc = lrBinarySearch(array, p, p + f, array[i - 1], True) - p;

            if loc == f || array[i - 1] < array[p + loc] {
                cycleReverseRotate(array, i, p, p + f);
                f++;
                p = i - 1;
                cycleReverseRotate(array, i - 1, i, p + loc + 1);
            }
        }

        cycleReverseRotate(array, p, p + f, b);
        return f;
    }

    new classmethod mergeTo(array, a, m, b, p) {
        new int i = a,
                j = m;
        
        for ; i < m && j < b; p++ {
            if array[i] <= array[j] {
                array[p].swap(array[i]);
                i++;
            } else {
                array[p].swap(array[j]);
                j++;
            }
        }

        for ; i < m; p++, i++ {
            array[p].swap(array[i]);
        }

        for ; j < b; p++, j++ {
            array[p].swap(array[j]);
        }
    }

    new classmethod pingPongMerge(array, a, m1, m, m2, b, p) {
        new int p1   = p + m - a, 
                pEnd = p + b - a;
			
		this.mergeTo(array, a, m1, m, p);
		this.mergeTo(array, m, m2, b, p1);
		this.mergeTo(array, p, p1, pEnd, a);
    }

    new classmethod inPlaceMergeBW(array, a, m, b) {
        while b > m && m > a {
            new int i = lrBinarySearch(array, a, m, array[b - 1], False);

            cycleReverseRotate(array, i, m, b);

            new int t = m - i;
            m = i;
            b -= t + 1;

            if m == a {
                break;
            }

            b = lrBinarySearch(array, m, b, array[m - 1], True);
        }
    }

    new classmethod selectMin(array, a, b, bLen) {
        new int min = a;

        for i = min + bLen; i < b; i += bLen {
            if array[i] < array[min] {
                min = i;
            }
        }

        return min;
    }

    new classmethod blockSelect(array, a, b, t, bLen) {
        while a < b {
            new int min = this.selectMin(array, a, b, bLen);

            if min != a {
                blockSwap(array, a, min, bLen);
            }
            array[a].swap(array[t]);
            t++;

            a += bLen;
        }
    }

    new classmethod blockMerge(array, a, m, b, t, p, bLen) {
        new int c  = 0,
                tp = t,
                i  = a,
                j  = m,
                k  = p,
                l  = 0,
                r  = 0; 
        
        for ; c < 2 * bLen; k++, c++ {
            if array[i] <= array[j] {
                array[k].swap(array[i]);
                i++; l++;
            } else {
                array[k].swap(array[j]);
                j++; r++;
            }
        }

        new bool left = l >= r;
        k = i - l if left else j - r;
        c = 0;

        do {
            if i < m && (j == b || array[i] <= array[j]) {
                array[k].swap(array[i]);
                i++; l++;
            } else {
                array[k].swap(array[j]);
                j++; r++;
            }
            k++; 

            c++;
            if c == bLen {
                sortingVisualizer.delay(10);
                array[k - bLen].swap(array[tp]);
                tp++;

                if left {
                    l -= bLen;
                } else {
                    r -= bLen;
                }

                left = l >= r;
                k = i - l if left else j - r;
                c = 0;
            }
        } while i < m || j < b;

        new int b1 = b - c;

        blockSwap(array, k - c, b1, c);
        r -= c;

        blockSwap(array, m - l, a, l);
        blockSwap(array, b1 - r, a + l, r);
        blockSwap(array, a, p, 2 * bLen);

        this.blockSelect(array, a + 2 * bLen, b1, t, bLen);
    }

    new classmethod blockMergeNoBuf(array, a, m, b, t, bLen) {
        for i = a + bLen, j = t; i < m; i += bLen, j++ {
            sortingVisualizer.delay(10);
            array[i].swap(array[j]);
        }

        new int i  = a + bLen,
                b1 = b - (b - m) % bLen;

        while i < m && m < b1 {
            if array[i - 1] > array[m + bLen - 1] {
                blockSwap(array, i, m, bLen);
                this.inPlaceMergeBW(array, a, i, i + bLen);

                m += bLen;
            } else {
                new int min = this.selectMin(array, i, m, bLen);

                if min > i {
                    blockSwap(array, i, min, bLen);
                }
                array[t].swap(array[i]);
                t++;
            }
            i += bLen;
        }

        if i < m {
            do {
                new int min = this.selectMin(array, i, m, bLen);

                if min > i {
                    blockSwap(array, i, min, bLen);
                }
                array[t].swap(array[i]);
                t++;
                i += bLen;
            } while i < m;
        } else {
            while m < b1 && array[m - 1] > array[m] {
                this.inPlaceMergeBW(array, a, m, m + bLen);
                m += bLen;
            }
        }
        this.inPlaceMergeBW(array, a, b1, b);
    }

    new classmethod sort(array, a, b) {
        if b - a <= 32 {
            binaryInsertionSort(array, a, b);
            return;
        }

        new int bLen = 1;
        for ; bLen * bLen < b - a; bLen *= 2 {}

        new int tLen   = this.tLenCalc(b - a, bLen),
                bufLen = 2 * bLen,
                j      = 16;

        new int keys = this.findKeysBW(array, a, b, bufLen + tLen);

        if keys == 1 {
            return;
        } elif keys <= 8 {
            for i = a; i < b; i += j {
                binaryInsertionSort(array, i, min(i + j, b));
            }

            for ; j < length; j *= 2 {
                for i = a; i + j < b; i += 2 * j {
                    this.inPlaceMergeBW(array, i, i + j, min(i + 2 * j, b));
                }
            }

            return;
        }

        if keys < bufLen + tLen {
            for ; bufLen > 2 * (keys - bufLen); bufLen //= 2 {}

            bLen = bufLen // 2;
            tLen = keys - bufLen; 
        }

        new int b1 = b - keys,
                t  = b1,
                p  = b1 + tLen;

        for i = a; i < b1; i += j {
            binaryInsertionSort(array, i, min(i + j, b1));
        }

        for ; 4 * j <= bufLen; j *= 4 {
            for i = a; i + 2 * j < b1; i += 4 * j {
                this.pingPongMerge(array, i, i + j, i + 2 * j, min(i + 3 * j, b1), min(i + 4 * j, b1), p);
            }

            if i + j < b1 {
                HeliumSort.mergeWithBufferBW(array, i, i + j, b1, p);
            }
        }

        for ; j <= bufLen; j *= 2 {
            for i = a; i + j < b1; i += 2 * j {
                HeliumSort.mergeWithBufferBW(array, i, i + j, min(i + 2 * j, b1), p);
            }
        }

        new int limit = bLen * (tLen + 3);

        for ; j < b1 - a && min(2 * j, b1 - a) < limit; j *= 2 {
            for i = a; i + j + bufLen < b1; i += 2 * j {
                this.blockMerge(array, i, i + j, min(i + 2 * j, b1), t, p, bLen);
            }

            if i + j < b1 {
                HeliumSort.mergeWithBufferBW(array, i, i + j, b1, p);
            }
        } 

        binaryInsertionSort(array, p, b);

        if bufLen <= tLen {
            bufLen *= 2;
        }
        bLen = 2 * j // bufLen;

        for ; j < b1 - a; j *= 2, bLen *= 2 {
            for i = a; i + j + 2 * bLen < b1; i += 2 * j {
                this.blockMergeNoBuf(array, i, i+j, min(i+2*j, b1), t, bLen);
            }

            if i + j < b1 {
                this.inPlaceMergeBW(array, i, i + j, b1);
            }
        }

        this.inPlaceMergeBW(array, a, b1, b);
    }
}

@Sort(
    "Block Merge Sorts",
    "Kota Sort",
    "Kota Sort"
);
new function kotaSortRun(array) {
    KotaSort.sort(array, 0, len(array));
}