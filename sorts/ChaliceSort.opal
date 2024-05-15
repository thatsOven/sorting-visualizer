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

# stable merge sort using O(cbrt n) dynamic external buffer

use binaryInsertionSort, bidirArrayCopy, lrBinarySearch, 
    insertToLeft, compareValues, blockSwap, MaxHeapSort,
    GrailSort;

new class ChaliceSort {
    new method __init__(rot = None) {
        if rot is None {
            this.rotate = sortingVisualizer.getRotation(
                id = sortingVisualizer.getUserSelection(
                    [r.name for r in sortingVisualizer.rotations],
                    "Select rotation algorithm (default: Gries-Mills)"
                )
            ).indexedFn;
        } else {
            this.rotate = sortingVisualizer.getRotation(name = rot).indexedFn;
        }
        
        this.aux = None;
    }

    new classmethod ceilCbrt(n) {
        new int a = 0,
                b = 11;

        while a < b {
            new int m = (a + b) // 2;

            if (1 << 3 * m) >= n {
                b = m;
            } else {
                a = m + 1;
            }
        }

        return 1 << a;
    }

    new classmethod calcKeys(bLen, n) {
        new int a = 1,
                b = n // 4;

        while a < b {
            new int m = (a + b) // 2;

            if (n - 4 * m - 1) // bLen - 2 < m {
                b = m;
            } else {
                a = m + 1;
            }
        }

        return a;
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

    new method laziestSortExt(array, a, b) {
        for i = a, s = len(this.aux); i < b; i += s {
            new int j = min(b, i + s);
            binaryInsertionSort(array, i, j);

            if i > a {
                this.mergeBWExt(array, a, i, j);
            }
        }
    }

    new method findKeysSm(array, a, b, a1, b1, full, n) {
        new int p    = a,
                pEnd = 0;

        if full {
            for ; p < b; p++ {
                new int loc = lrBinarySearch(array, a1, b1, array[p], True);

                if loc == b1 || array[p] != array[loc] {
                    pEnd = p + 1;
                    break;
                }
            }

            if pEnd != 0 {
                for i = pEnd; i < b && pEnd - p < n; i++ {
                    new int loc = lrBinarySearch(array, a1, b1, array[i], True);

                    if loc == b1 || array[i] != array[loc] {
                        loc = lrBinarySearch(array, p, pEnd, array[i], True);

                        if loc == pEnd || array[i] != array[loc] {
                            this.rotate(array, p, pEnd, i);

                            new int len1 = i - pEnd;
                            p   += len1;
                            loc += len1;
                            pEnd = i + 1;

                            insertToLeft(array, i, loc);
                        }
                    }
                }
            } else {
                pEnd = p;
            }
        } else {
            pEnd = p + 1;

            for i = pEnd; i < b && pEnd - p < n; i++ {
                new int loc = lrBinarySearch(array, p, pEnd, array[i], True);

                if loc == pEnd || array[i] != array[loc] {
                    this.rotate(array, p, pEnd, i);

                    new int len1 = i - pEnd;
                    p   += len1;
                    loc += len1;
                    pEnd = i + 1;

                    insertToLeft(array, i, loc);
                }
            }
        }

        return [p, pEnd];
    } 

    new method findKeys(array, a, b, n, s) {
        new int p, pEnd;
        p, pEnd = this.findKeysSm(array, a, b, 0, 0, False, min(n, s));

        if s < n && pEnd - p == s {
            for n -= s ;; n -= s {
                new list t = this.findKeysSm(array, pEnd, b, p, pEnd, True, min(s, n));
                new int keys = t[1] - t[0];

                if keys == 0 {
                    break;
                }

                if keys < s || n == s {
                    this.rotate(array, pEnd, t[0], t[1]);

                    t[0]  = pEnd;
                    pEnd += keys;

                    this.mergeBWExt(array, p, t[0], pEnd);
                    break;
                } else {
                    this.rotate(array, p, pEnd, t[0]);

                    p   += t[0] - pEnd;
                    pEnd = t[1];

                    this.mergeBWExt(array, p, t[0], pEnd);
                }
            }
        }

        this.rotate(array, a, p, pEnd);
        return pEnd - p;
    }

    new method findBitsSm(array, a, b, a1, bw, n) {
        new int p   = a,
                cmp = -1 if bw else 1, pEnd;

        for ; p < b && compareValues(array[p], array[a1]) != cmp; p++ {}
        a1++;

        if p < b {
            pEnd = p + 1;

            for i = pEnd; i < b && pEnd - p < n; i++ {
                if compareValues(array[i], array[a1]) == cmp {
                    this.rotate(array, p, pEnd, i);

                    p += i - pEnd;
                    pEnd = i + 1;
                    a1++;
                }
            }
        } else {
            pEnd = p;
        }

        return [p, pEnd];
    }

    new method findBits(array, a, b, n, s) {
        this.laziestSortExt(array, a, a + n);

        new int a0 = a,
                a1 = a + n,
                c  = 0,
                c0 = 0;

        for i = 0; c < n && i < 2; i++ {
            new int p    = a1,
                    pEnd = p;

            while True {
                new list t = this.findBitsSm(array, pEnd, b, a0, i == 1, min(s, n - c));
                new int bits = t[1] - t[0];

                if bits == 0 {
                    break;
                }

                a0 += bits;
                c  += bits;

                if bits < s || c == n {
                    this.rotate(array, pEnd, t[0], t[1]);

                    t[0]  = pEnd;
                    pEnd += bits;

                    break;
                } else {
                    this.rotate(array, p, pEnd, t[0]);

                    p += t[0] - pEnd;
                    pEnd = t[1];
                }
            }

            this.rotate(array, a1, p, pEnd);
            a1 += pEnd - p;

            if i == 0 {
                c0 = c;
            }
        }

        if c < n {
            return -1;
        } else {
            blockSwap(array, a + c0, a + n + c0, n - c0);
            return c0;
        }
    }

    new classmethod bitReversal(array, a, b) {
        new int len = b - a,
                m   = 0,
                d1  = len >> 1,
                d2  = d1 + (d1 >> 1);

        for i = 1; i < len - 1; i++ {
            new int j = d1;

            for k = i, n = d2; (k & 1) == 0; j -= n, k >>= 1, n >>= 1 {}
            m += j;

            if m > i {
                array[a + i].swap(array[a + m]);
            }
        }
    }

    new method unshuffle(array, a, b) {
        new int len = (b - a) >> 1,
                c   = 0;

        for n = 2; len > 0; len >>= 1, n *= 2 {
            if (len & 1) == 1 {
                new int a1 = a + c;

                this.bitReversal(array, a1         , a1 + n);
                this.bitReversal(array, a1         , a1 + n // 2);
                this.bitReversal(array, a1 + n // 2, a1 + n);
                this.rotate(array, a + c // 2, a1, a1 + n // 2);

                c += n;
            }
        }
    }

    new method redistBuffer(array, a, m, b) {
        new int s = len(this.aux);

        while m - a > s && m < b {
            new int i = lrBinarySearch(array, m, b, array[a + s], True);
            this.rotate(array, a + s, m, i);

            new int t = i - m;
            m = i;

            this.mergeFWExt(array, a, a + s, m);
            a += t + s;
        }

        if m < b {
            this.mergeFWExt(array, a, m, b);
        }
    }

    new classmethod shiftBW(array, a, m, b) {
        while m > a {
            b--;
            m--;
            array[b].swap(array[m]);
        }
    }

    new classmethod dualMergeBW(array, a, m, b, p) {
        new int i = m - 1;
        b--;

        while p > b + 1 && b >= m {
            p--;
            if array[b] >= array[i] {
                array[p].swap(array[b]);
                b--;
            } else {
                array[p].swap(array[i]);
                i--;
            }
        }

        if b < m {
            this.shiftBW(array, a, i + 1, p);
        } else {
            i++; 
            b++;
            p = m - (i - a);

            for ; a < i && m < b; p++ {
                if array[a] <= array[m] {
                    array[p].swap(array[a]);
                    a++;
                } else {
                    array[p].swap(array[m]);
                    m++;
                }
            }

            for ; a < i; p++, a++ {
                array[p].swap(array[a]);
            }
        }
    }

    new classmethod shiftBWExt(array, a, m, b) {
        while m > a {
            b--;
            m--;
            array[b].write(array[m]);
        }
    }

    new classmethod dualMergeBWExt(array, a, m, b, p) {
        new int i = m - 1;
        b--;

        while p > b + 1 && b >= m {
            p--;
            if array[b] >= array[i] {
                array[p].write(array[b]);
                b--;
            } else {
                array[p].write(array[i]);
                i--;
            }
        }

        if b < m {
            this.shiftBWExt(array, a, i + 1, p);
        } else {
            i++; 
            b++;
            p = m - (i - a);

            for ; a < i && m < b; p++ {
                if array[a] <= array[m] {
                    array[p].write(array[a]);
                    a++;
                } else {
                    array[p].write(array[m]);
                    m++;
                }
            }

            for ; a < i; p++, a++ {
                array[p].write(array[a]);
            }
        }
    }

    new classmethod smartMerge(array, p, a, m, rev) {
        new int i   = m,
                cmp = int(!rev);

        for ; a < m; p++ {
            if compareValues(array[a], array[i]) < cmp {
                array[p].write(array[a]);
                a++;
            } else {
                array[p].write(array[i]);
                i++;
            }
        }

        return i;
    }

    new classmethod shiftFWExt(array, a, m, b) {
        for ; m < b; a++, m++ {
            array[a].write(array[m]);
        }
    }

    new method smartTailMerge(array, p, a, m, b) {
        new int i    = m,
                bLen = len(this.aux);

        for ; a < m && i < b; p++ {
            if array[a] <= array[i] {
                array[p].write(array[a]);
                a++;
            } else {
                array[p].write(array[i]);
                i++;
            }
        }

        if a < m {
            if a > p {
                this.shiftFWExt(array, p, a, m);
            }

            bidirArrayCopy(this.aux, 0, array, b - bLen, bLen);
        } else {
            for a = 0; a < bLen && i < b; p++ {
                if this.aux[a] <= array[i] {
                    array[p].write(this.aux[a]);
                    a++;
                } else {
                    array[p].write(array[i]);
                    i++;
                }
            }

            for ; a < bLen; p++, a++ {
                array[p].write(this.aux[a]);
            }
        }
    }

    new classmethod blockCycle(array, a, t, tIdx, tLen, bLen) {
        for i in range(tLen - 1) {
            if array[t + i] > array[tIdx + i] || (i > 0 && array[t + i] < array[tIdx + i - 1]) {
                bidirArrayCopy(array, a + i * bLen, array, a - bLen, bLen);

                new int val  = i,
                        next = lrBinarySearch(array, tIdx, tIdx + tLen, array[t + i], True) - tIdx;

                do {
                    bidirArrayCopy(array, a + next * bLen, array, a + val * bLen, bLen);
                    array[t + i].swap(array[t + next]);

                    val  = next;
                    next = lrBinarySearch(array, tIdx, tIdx + tLen, array[t + i], True) - tIdx;
                } while next != i;

                bidirArrayCopy(array, a - bLen, array, a + val * bLen, bLen);
            }
        }
    }

    new method blockMerge(array, a, m, b, tl, tLen, t, tIdx, bp1, bp2, bLen) {
        if b - m <= bLen {
            this.mergeBWExt(array, a, m, b);
            return;
        }

        insertToLeft(array, t + tl - 1, t);

        new int i  = a + bLen - 1,
                j  = m + bLen - 1,
                ti = t,
                tj = t + tl,
                tp = tIdx;

        for ; ti < t + tl && tj < t + tLen; tp++, bp1++, bp2++ {
            if array[i] <= array[j] {
                array[tp].swap(array[ti]);
                ti++;
                i += bLen;
            } else {
                array[tp].swap(array[tj]);
                array[bp1].swap(array[bp2]);
                tj++;
                j += bLen;
            }
        }

        for ; ti < t + tl; tp++, ti++, bp1++, bp2++ {
            array[tp].swap(array[ti]);
        }

        for ; tj < t + tLen; tp++, tj++, bp1++, bp2++ {
            array[tp].swap(array[tj]);
            array[bp1].swap(array[bp2]);
        }

        t    ^= tIdx;
        tIdx ^= t;
        t    ^= tIdx;

        MaxHeapSort.sort(array, tIdx, tIdx + tLen);

        bidirArrayCopy(array, m - bLen, this.aux, 0, bLen);
        bidirArrayCopy(array, a, array, m - bLen, bLen);

        this.blockCycle(array, a + bLen, t, tIdx, tLen, bLen);
        blockSwap(array, t, tIdx, tLen);

        bp1 -= tLen;
        bp2 -= tLen;

        new int f   = a + bLen,
                a1  = f,
                bp3 = bp2 + tLen;

        new bool rev = array[bp1] > array[bp2];

        while True {
            do {
                if rev {
                    array[bp1].swap(array[bp2]);
                }

                bp1++;
                bp2++;
                a1 += bLen;
            } while bp2 < bp3 && compareValues(array[bp1], array[bp2]) == (1 if rev else -1);

            if bp2 == bp3 {
                this.smartTailMerge(array, f - bLen, f, (f if rev else a1), b);
                return;
            }

            f = this.smartMerge(array, f - bLen, f, a1, rev);
            !rev;
        }
    }

    new classmethod blockCycleEasy(array, a, t, tIdx, tLen, bLen) {
        for i in range(tLen - 1) {
            if array[t + i] > array[tIdx + i] || (i > 0 && array[t + i] < array[tIdx + i - 1]) {
                new int next = lrBinarySearch(array, tIdx, tIdx + tLen, array[t + i]) - tIdx;

                do {
                    blockSwap(array, a + i * bLen, a + next * bLen, bLen);
                    array[t + i].swap(array[t + next]);

                    next = lrBinarySearch(array, tIdx, tIdx + tLen, array[t + i]) - tIdx;
                } while next != i;
            }
        }
    }

    new method inPlaceMergeBW(array, a, m, b, rev) {
        new int f = lrBinarySearch(array, m, b, array[m - 1], !rev);
        b = f;

        while b > m && m > a {
            new int i = lrBinarySearch(array, a, m, array[b - 1], rev);
            this.rotate(array, i, m, b);

            new int t = m - i;
            m = i;
            b -= t + 1;

            if m == a {
                break;
            }

            b = lrBinarySearch(array, m, b, array[m - 1], !rev);
        }

        return f;
    }

    new method inPlaceMerge(array, a, m, b) {
        while a < m && m < b {
            a = lrBinarySearch(array, a, m, array[m], False);
            if a == m {
                return;
            }

            new int i = lrBinarySearch(array, m, b, array[a], True);
            this.rotate(array, a, m, i);

            new int t = i - m;
            m = i;
            a += t + 1;
        }
    }

    new method blockMergeEasy(array, a, m, b, lenA, lenB, tl, tLen, t, tIdx, bp1, bp2, bLen) {
        if b - m <= bLen {
            this.inPlaceMergeBW(array, a, m, b, False);
            return;
        }

        new int a1 = a + lenA,
                b1 = b - lenB,
                i  = a1 + bLen - 1,
                j  = m + bLen - 1,
                ti = tIdx,
                tj = tIdx + tl,
                tp = t;

        for ; ti < tIdx + tl && tj < tIdx + tLen; tp++, bp1++, bp2++ {
            if array[i] <= array[j] {
                array[ti].swap(array[tp]);
                ti++;
                i += bLen;
            } else {
                array[tj].swap(array[tp]);
                array[bp1].swap(array[bp2]);
                tj++;
                j += bLen;
            }
        }

        for ; ti < tIdx + tl; ti++, tp++, bp1++, bp2++ {
            array[ti].swap(array[tp]);
        }

        for ; tj < tIdx + tLen; tj++, tp++, bp1++, bp2++ {
            array[tj].swap(array[tp]);
            array[bp1].swap(array[bp2]);
        }

        t    ^= tIdx;
        tIdx ^= t;
        t    ^= tIdx;

        MaxHeapSort.sort(array, tIdx, tIdx + tLen);

        this.blockCycleEasy(array, a1, t, tIdx, tLen, bLen);
        blockSwap(array, t, tIdx, tLen);

        bp1 -= tLen;
        bp2 -= tLen;

        new int f   = a1,
                a2  = f,
                bp3 = bp2 + tLen;

        new bool rev = array[bp1] > array[bp2];

        while True {
            do {
                if rev {
                    array[bp1].swap(array[bp2]);                   
                }

                bp1++;
                bp2++;
                a2 += bLen;
            } while bp2 < bp3 && compareValues(array[bp1], array[bp2]) == (1 if rev else -1);

            if bp2 == bp3 {
                if !rev {
                    this.inPlaceMergeBW(array, a1, b1, b, False);
                }

                this.inPlaceMerge(array, a, a1, b);
                return;
            }

            f = this.inPlaceMergeBW(array, f, a2, a2 + bLen, rev);
            !rev;
        }
    }

    new method lazyStable(array, a, b) {
        for j = 1; j < n; j *= 2 {
            for i = a + j; i < b; i += 2 * j {
                this.inPlaceMergeBW(array, i - j, i, min(i + j, b));
            }
        }
    }

    new classmethod mergeWithBufFWExt(array, a, m, b, p) {
        new int i = m;

        for ; a < m && i < b; p++ {
            if array[a] <= array[i] {
                array[p].write(array[a]);
                a++;
            } else {
                array[p].write(array[i]);
                i++;
            }
        }

        if a > p {
            this.shiftFWExt(array, p, a, m);
        }

        this.shiftFWExt(array, p, i, b);
    }

    new classmethod mergeWithBufBWExt(array, a, m, b, p) {
        new int i = m - 1;
        
        for b--; b >= m && i >= a; {
            p--;
            if array[b] >= array[i] {
                array[p].write(array[b]);
                b--;
            } else {
                array[p].write(array[i]);
                i--;
            }
        }

        if p > b {
            this.shiftBWExt(array, m, b + 1, p);
        }

        this.shiftBWExt(array, a, i + 1, p);
    }

    new classmethod shiftFW(array, a, m, b) {
        for ; m < b; a++, m++ {
            array[a].swap(array[m]);
        }
    }

    new classmethod mergeWithBufFW(array, a, m, b, p) {
        new int i = m;

        for ; a < m && i < b; p++ {
            if array[a] <= array[i] {
                array[p].swap(array[a]);
                a++;
            } else {
                array[p].swap(array[i]);
                i++;
            }
        }

        if a > p {
            this.shiftFW(array, p, a, m);
        }

        this.shiftFW(array, p, i, b);
    }

    new classmethod mergeWithBufBW(array, a, m, b, p) {
        new int i = m - 1;
        
        for b--; b >= m && i >= a; {
            p--;
            if array[b] >= array[i] {
                array[p].swap(array[b]);
                b--;
            } else {
                array[p].swap(array[i]);
                i--;
            }
        }

        if p > b {
            this.shiftBW(array, m, b + 1);
        }

        this.shiftBW(array, a, i + 1, p);
    }

    new method sort(array, a, b) {
        new int n = b - a;

        if n < 128 {
            if n < 32 {
                binaryInsertionSort(array, a, b);
            } else {
                # original implementation uses Fifth Merge Sort,
                # but it doesn't really matter
                this.lazyStable(array, a, b); 
            }

            return;
        }

        new int cbrt = 2 * this.ceilCbrt(n // 4),
                bLen = 2 * cbrt,
                kLen = this.calcKeys(bLen, n);

        this.aux = sortingVisualizer.createValueArray(bLen);

        new int keys = this.findKeys(array, a, b, 2 * kLen, cbrt);

        if keys < 8 {
            this.lazyStable(array, a, b);
            return;
        } elif keys < 2 * kLen {
            keys -= keys % 4;
            kLen = keys // 2;
        }

        new int a1   = a  + keys,
                a2   = a1 + keys,
                bSep = this.findBits(array, a1, b, kLen, cbrt);
        
        if bSep == -1 {
            this.laziestSortExt(array, a, a2);
            this.inPlaceMerge(array, a, a2, b);
            return;
        }

        new int a3 = a2 + bLen,
                j  = 1,
                n  = b - a3, i;

        binaryInsertionSort(array, a2, a3);
        bidirArrayCopy(array, a2, this.aux, 0, bLen);

        for ; j < cbrt; j *= 2 {
            new int p = max(2, j);

            for i = a3; i + 2 * j < b; i += 2 * j {
                this.mergeWithBufFWExt(array, i, i + j, i + 2 * j, i - p);
            }

            if i + j < b {
                this.mergeWithBufFWExt(array, i, i + j, b, i - p);
            } else {
                this.shiftFWExt(array, i - p, i, b);
            }

            a3 -= p;
            b  -= p;
        }

        i = b - n % (2 * j);

        if i + j < b {
            this.mergeWithBufBWExt(array, i, i + j, b, b + j);
        } else {
            this.shiftBWExt(array, i, b, b + j);
        }

        for i -= 2 * j; i >= a3; i -= 2 * j {
            this.mergeWithBufBWExt(array, i, i + j, i + 2 * j, i + 3 * j);
        }

        a3 += j;
        b += j;
        j *= 2;

        for i = a3; i + 2 * j < b; i += 2 * j {
            this.mergeWithBufFWExt(array, i, i + j, i + 2 * j, i - j);
        }

        if i + j < b {
            this.mergeWithBufFWExt(array, i, i + j, b, i - j);
        } else {
            this.shiftFWExt(array, i - j, i, b);
        }

        a3 -= j;
        b -= j;
        j *= 2;

        i = b - n % (2 * j);

        if i + j < b {
            this.dualMergeBWExt(array, i, i + j, b, b + j // 2);
        } else {
            this.shiftBWExt(array, i, b, b + j // 2);
        }

        for i -= 2 * j; i >= a3; i -= 2 * j {
            this.dualMergeBWExt(array, i, i + j, i + 2 * j, i + 2 * j + j // 2);
        }

        a3 += j // 2;
        b  += j // 2;
        j *= 2;

        if keys >= j {
            this.rotate(array, a, a1, a3);
            a2 = a1 + bLen;

            if kLen >= j {
                for mLvl = 2 * j; j < kLen; j *= 2 {
                    new int p = max(mLvl, j);

                    for i = a3; i + 2 * j < b; i += 2 * j {
                        this.mergeWithBufFW(array, i, i + j, i + 2 * j, i - p);
                    }

                    if i + j < b {
                        this.mergeWithBufFW(array, i, i + j, b, i - p);
                    } else {
                        this.shiftFW(array, i - p, i, b);
                    }

                    a3 -= p;
                    b  -= p;
                }

                i = b - n % (2 * j);

                if i + j < b {
                    this.mergeWithBufBW(array, i, i + j, b, b + j);
                } else {
                    this.shiftBW(array, i, b, b + j);
                }

                for i -= 2 * j; i >= a3; i -= 2 * j {
                    this.mergeWithBufBW(array, i, i + j, i + 2 * j, i + 3 * j);
                }

                a3 += j;
                b  += j;
                j *= 2;
            }

            if keys >= j {
                for i = a3; i + 2 * j < b; i += 2 * j {
                    this.mergeWithBufFW(array, i, i + j, i + 2 * j, i - j);
                }

                if i + j < b {
                    this.mergeWithBufFW(array, i, i + j, b, i - j);
                } else {
                    this.shiftFW(array, i - j, i, b);
                }

                a3 -= j;
                b  -= j;
                j *= 2;

                i = b - n % (2 * j);

                if i + j < b {
                    this.dualMergeBW(array, i, i + j, b, b + j // 2);
                } else {
                    this.shiftBW(array, i, b, b + j // 2);
                }

                for i -= 2 * j; i >= a3; i -= 2 * j {
                    this.dualMergeBW(array, i, i + j, i + 2 * j, i + 2 * j + j // 2);
                }

                a3 += j // 2;
                b  += j // 2;
                j *= 2;
            }

            this.rotate(array, a, a2, a3);
            a2 = a1 + keys;
            MaxHeapSort.sort(array, a, a1);
        }

        bidirArrayCopy(this.aux, 0, array, a2, bLen);

        this.unshuffle(array, a, a1);
        new int limit = bLen * (kLen + 2);

        for k = j // bLen - 1; j < n && min(2 * j, n) <= limit; j *= 2, k = 2 * k + 1 {
            for i = a3; i + 2 * j <= b; i += 2 * j {
                this.blockMerge(array, i, i + j, i + 2 * j, k, 2 * k, a, a + kLen, a1, a1 + kLen, bLen);
            }

            if i + j < b {
                this.blockMerge(array, i, i + j, b, k, (b - i - 1) // bLen - 1, a, a + kLen, a1, a1 + kLen, bLen);
            }
        }

        for ; j < n; j *= 2 {
            bLen = (2 * j) // kLen;
            new int lenA = j % bLen,
                    lenB = lenA;

            for i = a3; i + 2 * j <= b; i += 2 * j {
                this.blockMergeEasy(array, i, i + j, i + 2 * j, lenA, lenB, kLen // 2, kLen, a, a + kLen, a1, a1 + kLen, bLen);
            }

            if i + j < b {
                this.blockMergeEasy(array, i, i + j, b, lenA, (b - i - j) % bLen, kLen // 2, kLen // 2 + (b - i - j) // bLen, a, a + kLen, a1, a1 + kLen, bLen);
            }
        }

        blockSwap(array, a1 + bSep, a1 + kLen + bSep, kLen - bSep);
        this.laziestSortExt(array, a, a3);
        this.redistBuffer(array, a, a3, b);
    }
}

@Sort(
    "Block Merge Sorts",
    "Chalice Sort",
    "Chalice Sort"
);
new function chaliceSortRun(array) {
    ChaliceSort().sort(array, 0, len(array));
}