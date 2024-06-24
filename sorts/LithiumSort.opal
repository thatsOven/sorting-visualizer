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

# Lithium Sort
# 
# A conceptually optimal in-place block merge sorting algorithm.
# This algorithm introduces some ideas, that in conjunction with code optimizations and 
# other tricks (like the ones in Holy GrailSort), minimizes moves and comparisons for 
# every step of the in-place block merge sorting procedure.
# 
# Time complexity: O(n log n) best/average/worst
# Space complexity: O(1)
# Stable: Yes
# 
# Special thanks to aphitorite for creating the kota merging algorithm, which enables
# strategy 1's block merging routine to be optimal; the dualMerge routine, which simplifies
# the rest of the code as well as improving performance; the buffer redistribution algorithm, 
# found in Adaptive Grailsort; the smarter block selection algorithm, used in the blockSelect
# routine, and part of the code for some of the other routines.
 
use blockSwap, backwardBlockSwap, compareValues,
    compareIntToValue, insertToRight, lrBinarySearch, 
    binaryInsertionSort, log2, BufMerge2, BitArray;

new class LithiumSort {
    new int RUN_SIZE           = 32,
            SMALL_SORT         = 256,
            MAX_STRAT3_UNIQUE  = 8,
            SMALL_MERGE        = 16;

    new method __init__() {
        this.bufLen = 0;
    }

    new classmethod multiTriSwap(array, a, b, c, len) {
        for i in range(len) {
            new Value t = array[a + i].copy();
            array[a + i].write(array[b + i]);
            array[b + i].write(array[c + i]);
            array[c + i].write(t);
        }
    }

    new method rotate(array, a, m, b) {
        new int rl   = b - m,
                ll   = m - a,
                bl   = this.bufLen,
                min_ = bl if rl != ll && min(bl, rl, ll) > LithiumSort.SMALL_MERGE else 1;

        while (rl > min_ && ll > min_) || (rl < LithiumSort.SMALL_MERGE && rl > 1 && ll < LithiumSort.SMALL_MERGE && ll > 1) {
            if rl < ll {
                blockSwap(array, a, m, rl);
                a  += rl;
                ll -= rl;
            } else {
                b  -= ll;
                rl -= ll;
                backwardBlockSwap(array, a, b, ll);
            }
        }

        if rl == 1 {
            insertToLeft(array, m, a);
        } elif ll == 1 {
            insertToRight(array, a, b - 1);
        }

        if min == 1 || rl <= 1 || ll <= 1 {
            return;
        }            
        
        if rl < ll {
            backwardBlockSwap(array, m, this.bufPos, rl);

            for i = m + rl - 1; i >= a + rl; i-- {
                array[i].swap(array[i - rl]);
            }

            backwardBlockSwap(array, this.bufPos, a, rl);
        } else {
            blockSwap(array, a, this.bufPos, ll);

            for i = a; i < b - ll; i++ {
                array[i].swap(array[i + ll]);
            }

            blockSwap(array, this.bufPos, b - ll, ll);
        }
    }

    new method findKeys(array, a, b, q) {
        new int n = 1,
                p = b - 1;

        for i = p; i > a && n < q; i-- {
            new int l = lrBinarySearch(array, p, p + n, array[i - 1], True) - p;
            if l == n || array[i - 1] < array[p + l] {
                this.rotate(array, i, p, p + n);
                n++;
                p = i - 1;
                insertToRight(array, i - 1, p + l);
            }
        }

        this.rotate(array, p, p + n, b);
        return n;
    }

    new method sortRuns(array, a, b) {
        new dynamic speed = sortingVisualizer.speed;
        sortingVisualizer.setSpeed(max(int(10 * (len(array) / 2048)), speed * 2));

        for i = a; i < b - LithiumSort.RUN_SIZE; i += LithiumSort.RUN_SIZE {
            binaryInsertionSort(array, i, i + LithiumSort.RUN_SIZE);
        }

        if i < b {
            binaryInsertionSort(array, i, b);
        }

        sortingVisualizer.setSpeed(speed);
    }

    new method mergeInPlaceBW(array, a, m, b, left) {
        new int s = b - 1,
                l = m - 1;

        while s > l && l >= a {
            new int cmp = compareValues(array[l], array[s]);
            if cmp > 0 if left else cmp >= 0 {
                new int p = lrBinarySearch(array, a, l, array[s], !left);
                this.rotate(array, p, l + 1, s + 1);
                s -= l + 1 - p;
                l = p - 1;
            } else {
                s--;
            }
        }
    }

    new method mergeWithBufferBW(array, a, m, b, left) {
        new int rl = b - m;

        if rl <= LithiumSort.SMALL_MERGE || rl > this.bufLen {
            this.mergeInPlaceBW(array, a, m, b, left);
            return;
        }

        backwardBlockSwap(array, m, this.bufPos, rl);

        new int l = m - 1,
                r = this.bufPos + rl - 1,
                o = b - 1;

        for ; l >= a && r >= this.bufPos; o-- {
            new int cmp = compareValues(array[r], array[l]);
            if cmp >= 0 if left else cmp > 0 {
                array[o].swap(array[r]);
                r--;
            } else {
                array[o].swap(array[l]);
                l--;
            }
        }

        for ; r >= this.bufPos; o--, r-- {
            array[o].swap(array[r]);
        }
    }

    new method mergeRestWithBufferFW(array, a, m, b, pLen, left) {
        new int l = this.bufPos,
                r = m,
                o = a,
                e = l + pLen;

        for ; l < e && r < b; o++ {
            new int cmp = compareValues(array[l], array[r]);
            if cmp <= 0 if left else cmp < 0 {
                array[o].swap(array[l]);
                l++;
            } else {
                array[o].swap(array[r]);
                r++;
            }
        }

        for ; l < e; o++, l++ {
            array[o].swap(array[l]);
        }
    }

    new classmethod mergeWithScrollingBufferFW(array, a, m, b, p, left) {
        new int i = a,
                j = m;

        for ; i < m && j < b; p++ {
            new int cmp = compareValues(array[i], array[j]);
            if cmp <= 0 if left else cmp < 0 {
                array[p].swap(array[i]);
                i++;
            } else {
                array[p].swap(array[j]);
                j++;
            }
        }

        if i > p {
            for ; i < m; p++, i++ {
                array[p].swap(array[i]);
            }
        }

        return j;
    }

    new classmethod shift(array, a, m, b, left) {
        if left {
            if m == b {
                return;
            }

            while m > a {
                b--; m--;
                array[b].swap(array[m]);
            }
        } else {
            if (m == a) {
                return;
            }

            for ; m < b; a++, m++ {
                array[a].swap(array[m]);
            }
        }
    }

    new method dualMergeFW(array, a, m, b, r) {
        new int i = a,
                j = m,
                k = a - r;

        for ; k < i && i < m; k++ {
            if array[i] <= array[j] {
                array[k].swap(array[i]);
                i++;
            } else {
                array[k].swap(array[j]);
                j++;
            }
        }

        if k < i {
            this.shift(array, j - r, j, b, False);
        } else {
            new int i2 = m - 1,
                    j2 = b - 1;
            k = i2 + b - j;

            for ; i2 >= i && j2 >= j; k-- {
                if array[i2] > array[j2] {
                    array[k].swap(array[i2]);
                    i2--;
                } else {
                    array[k].swap(array[j2]);
                    j2--;
                }
            }

            for ; j2 >= j; k--, j2-- {
                array[k].swap(array[j2]);
            }
        }
    }

    new method swapKeys(array, bits, a, b) {
        if bits is None {
            array[this.keyPos + a].swap(array[this.keyPos + b]);
        } else {
            bits.swap(a, b);
        }
    }

    new method compareKeys(array, bits, a, b) {
        if bits is None {
            return compareValues(array[this.keyPos + a], array[this.keyPos + b]);
        } else {
            return compareValues(bits.get(a), bits.get(b));
        }
    }

    new method blockSelect(array, bits, a, leftBlocks, rightBlocks, blockLen) {
        new int total = leftBlocks + rightBlocks;

        for j = 0, k = leftBlocks + 1; j < k - 1; j++ {
            new int min = j;

            for i = max(leftBlocks - 1, j + 1); i < k; i++ {
                new int cmp = compareValues(array[a + (i + 1) * blockLen - 1], array[a + (min + 1) * blockLen - 1]);

                if cmp < 0 || (cmp == 0 && this.compareKeys(array, bits, i, min) < 0) {
                    min = i;
                }
            }

            if min != j {
                blockSwap(array, a + j * blockLen, a + min * blockLen, blockLen);
                this.swapKeys(array, bits, j, min);

                if k < total && min == k - 1 {
                    k++;
                }
            }
        }
    }

    new method compareMidKey(array, bits, i, midKey) {
        if bits is None {
            return array[this.keyPos + i] < midKey;
        } else {
            return bits.get(i) < midKey;
        }
    }

    new method mergeBlocksWithBuf(array, a, midKey, leftBlocks, rightBlocks, b, blockLen, bits) {
        new int t  = leftBlocks + rightBlocks,
                a1 = a + blockLen,
                i  = a1,
                j  = a,
                k  = -1,
                l  = -1,
                r  = leftBlocks - 1;

        new bool left = True;
        while l < leftBlocks && r < t {
            if left {
                do {
                    j += blockLen;
                    l++;
                    k++;
                } while l < leftBlocks && this.compareMidKey(array, bits, k, midKey);

                if l == leftBlocks {
                    i = this.mergeWithScrollingBufferFW(array, i, j, b, i - blockLen, True);
                    this.mergeRestWithBufferFW(array, i - blockLen, i, b, blockLen, True);
                } else {
                    i = this.mergeWithScrollingBufferFW(array, i, j, j + blockLen - 1, i - blockLen, True);
                }

                left = False;
            } else {
                do {
                    j += blockLen;
                    r++;
                    k++;
                } while r < t && !this.compareMidKey(array, bits, k, midKey);

                if r == t {
                    this.shift(array, i - blockLen, i, b, False);
                    blockSwap(array, this.bufPos, b - blockLen, blockLen);
                } else {
                    i = this.mergeWithScrollingBufferFW(array, i, j, j + blockLen - 1, i - blockLen, False);
                }

                left = True;
            }
        }
    }

    new method mergeBlocksLazy(array, a, midKey, blockQty, blockLen, lastLen, bits) {
        new int f = a;
        new bool left = this.compareMidKey(array, bits, 0, midKey);
        
        for i = 1; i < blockQty; i++ {
            if left ^ this.compareMidKey(array, bits, i, midKey) {
                new int next    = a + i * blockLen,
                        nextEnd = lrBinarySearch(array, next, next + blockLen, array[next - 1], left);

                this.mergeWithBufferBW(array, f, next, nextEnd, left);
                f = nextEnd;
                !left;
            }
        }

        if left && lastLen != 0 {
            new int lastFrag = a + blockQty * this.blockLen;
            this.mergeWithBufferBW(array, f, lastFrag, lastFrag + lastLen, left);
        }
    }

    new method blockCycle(array, a, blockQty, blockLen, bits) {
        for i = 0; i < blockQty; i++ {
            new int k = bits.get(i);
            if k != i {
                new int j = i;

                do {
                    blockSwap(array, a + k * blockLen, a + j * blockLen, blockLen);
                    bits.set(j, j);

                    j = k;
                    k = bits.get(k);
                } while k != i;
            
                bits.set(j, j);
            }
        }
    }
    
    new method kotaMerge(array, a, m, b1, blockLen, bits) {
        new int i = a,
                j = m,
                l = a,
                r = m,
                t = 1;

        for k = 0; k < blockLen; k++ {
            if array[i] <= array[j] {
                array[this.bufPos + k].swap(array[i]);
                i++;
            } else {
                array[this.bufPos + k].swap(array[j]);
                j++;
            }
        }

        for ; l < m && r < b1; t++ {
            new bool left = i - l > 0 && (i - l == blockLen || array[l + blockLen - 1] <= array[r + blockLen - 1]);
            new int p = l if left else r;

            for k = 0; k < blockLen; k++, p++ {
                if j == b1 || (i < m && array[i] <= array[j]) {
                    array[p].swap(array[i]);
                    i++;
                } else {
                    array[p].swap(array[j]);
                    j++;
                }
            }

            if left {
                l = p;
            } else {
                r = p;
            }

            bits.set(t, (p - a) // blockLen - 1);
        }

        new int p = l if l < m else r;

        blockSwap(array, this.bufPos, p, blockLen);
        bits.set(0, (p - a) // blockLen);

        while True {
            l += blockLen;
            if l >= m {
                break;
            }

            bits.set(t, (l - a) // blockLen);
            t++;
        }

        while True {
            r += blockLen;
            if r >= b1 {
                break;
            }

            bits.set(t, (r - a) // blockLen);
            t++;
        }
    }

    new method getBlocksIndicesLazy(array, a, leftBlocks, rightBlocks, blockLen, indices, bits) {
        new int l = 0,
                m = leftBlocks,
                r = m,
                b = m + rightBlocks,
                o = 0;

        for ; l < m && r < b; o++ {
            if array[a + (l + 1) * blockLen - 1] <= array[a + (r + 1) * blockLen - 1] {
                bits.set(o, l);
                indices.set(o, l);
                l++;
            } else {
                bits.set(o, r);
                indices.set(o, r);
                r++;
            }
        }

        for ; l < m; o++, l++ {
            bits.set(o, l);
            indices.set(o, l);
        }

        for ; r < b; o++, r++ {
            bits.set(o, r);
            indices.set(o, r);
        }
    }

    new method getBlocksIndices(array, a, leftBlocks, rightBlocks, blockLen, indices, bits) {
        new int m = leftBlocks - 1,
                l = m,
                r = leftBlocks,
                b = r + rightBlocks,
                o = 0;

        if l != -1 {
            new int lb = a + (l + 1) * blockLen - 1;
            while True {
                if r == b || array[lb] <= array[a + (r + 1) * blockLen - 1] {
                    bits.set(o, l);
                    indices.set(o, l);
                    o++;
                    break;
                }

                bits.set(o, r);
                indices.set(o, r);
                o++;
                r++;
            }

            if l != 0 {
                l = 0;

                for ; l < m && r < b; o++ {
                    if array[a + (l + 1) * blockLen - 1] <= array[a + (r + 1) * blockLen - 1] {
                        bits.set(o, l);
                        indices.set(o, l);
                        l++;
                    } else {
                        bits.set(o, r);
                        indices.set(o, r);
                        r++;
                    }
                }

                for ; l < m; o++, l++ {
                    bits.set(o, l);
                    indices.set(o, l);
                }
            }
        }

        for ; r < b; o++, r++ {
            bits.set(o, r);
            indices.set(o, r);
        }
    }

    new method prepareKeysLazy(bits, q) {
        for i in range(q) {
            bits.set(i, i);
        }
    }

    new method prepareKeys(bits, q, leftBlocks) {
        for i = 0; i < leftBlocks - 1; i++ {
            bits.set(i, i + 1);
        }

        bits.set(i, 0);

        for i++; i < q; i++ {
            bits.set(i, i);
        }
    }

    new method combine(array, a, m, b, bits, indices, lazy) {
        if b - m <= this.bufLen {
            this.mergeWithBufferBW(array, a, m, b, True);
            return;
        }

        if this.strat1 {
            new int blockQty = (b - a) // this.blockLen,
                    b1       = a + blockQty * this.blockLen;

            this.kotaMerge(array, a, m, b1, this.blockLen, bits);
            this.blockCycle(array, a, blockQty, this.blockLen, bits);
            this.mergeWithBufferBW(array, a, b1, b, True);
        } else {
            new int leftBlocks  = (m - a) // this.blockLen,
                    rightBlocks = (b - m) // this.blockLen,
                    blockQty    = leftBlocks + rightBlocks,
                    frag        = (b - a) - blockQty * this.blockLen;

            new dynamic midKey;
            if lazy {
                if bits is None {
                    binaryInsertionSort(array, this.keyPos, this.keyPos + blockQty + 1);
                    midKey = array[this.keyPos + leftBlocks].copy();
                    this.blockSelect(array, bits, a, leftBlocks, rightBlocks, this.blockLen);
                } else {
                    midKey = leftBlocks;

                    if indices is None {
                        this.prepareKeysLazy(bits, blockQty);
                        this.blockSelect(array, bits, a, leftBlocks, rightBlocks, this.blockLen);
                    } else {
                        this.getBlocksIndicesLazy(array, a, leftBlocks, rightBlocks, this.blockLen, indices, bits);
                        this.blockCycle(array, a, blockQty, this.blockLen, indices);
                    }
                }

                this.mergeBlocksLazy(array, a, midKey, blockQty, this.blockLen, frag, bits);
            } else {
                this.multiTriSwap(array, this.bufPos, m - this.blockLen, a, this.blockLen);
                leftBlocks--;
                blockQty--;

                if bits is None {
                    binaryInsertionSort(array, this.keyPos, this.keyPos + blockQty + 1);
                    midKey = array[this.keyPos + leftBlocks].copy();
                    insertToRight(array, this.keyPos, this.keyPos + leftBlocks - 1);
                    this.blockSelect(array, bits, a + this.blockLen, leftBlocks, rightBlocks, this.blockLen);
                } else {
                    midKey = leftBlocks;

                    if indices is None {
                        this.prepareKeys(bits, blockQty, leftBlocks);
                        this.blockSelect(array, bits, a + this.blockLen, leftBlocks, rightBlocks, this.blockLen);
                    } else {
                        this.getBlocksIndices(array, a + this.blockLen, leftBlocks, rightBlocks, this.blockLen, indices, bits);
                        this.blockCycle(array, a + this.blockLen, blockQty, this.blockLen, indices);
                    }
                }

                this.mergeBlocksWithBuf(array, a, midKey, leftBlocks, rightBlocks, b, this.blockLen, bits);
            }
        }
    }

    new method strat2BLenCalc(twoR, r) {
        new int sqrtTwoR = 1;
        for ; sqrtTwoR * sqrtTwoR < twoR; sqrtTwoR *= 2 {}
        for ; twoR // sqrtTwoR > r // (2 * (log2(twoR // sqrtTwoR) + 1)); sqrtTwoR *= 2 {}
        this.blockLen = sqrtTwoR;
    }

    new method noBitsBLenCalc(twoR) {
        new int sqrtTwoR = 1;
        for ; sqrtTwoR * sqrtTwoR < twoR; sqrtTwoR *= 2 {}

        new int kCnt = twoR // sqrtTwoR + 1;
        if kCnt < this.keyLen {
            this.bufLen = this.keyLen - kCnt;
            this.bufPos = this.keyPos + kCnt;
        } else {
            for ; twoR // sqrtTwoR + 1 > this.keyLen; sqrtTwoR *= 2 {}
            this.bufLen = 0;
        }

        this.blockLen = sqrtTwoR;
    }

    new method resetBuf() {
        this.bufPos   = this.keyPos;
        this.bufLen   = this.keyLen;
        this.blockLen = this.origBlockLen;
    }

    new method checkValidBitArray(array, a, b, size) {
        return a + size < b - size && array[a + size] < array[b - size];
    }

    new method adjust(array, a, m, b, aSub) {
        new bool frag = False;

        if aSub {
            new int mN = a + ((m - a) // this.blockLen) * this.blockLen,
                    bN = b - (m - mN);

            # a [ - A0 - ] mN [frag] m [ - A1 - ] b 

            frag = mN != m;
            if frag {
                this.rotate(array, mN, m, b);
            }

            # a [ - A0 - ] mN [ - A1 - ] b [frag] bN  

            m = mN;
            b = bN;
        } else {
            a = m - ((m - a) // this.blockLen) * this.blockLen;
        }

        return a, m, b, frag;
    }

    new method firstMergePart(array, a, m, b, bA, bB, strat2, aSub) {
        if b - m <= this.bufLen {
            this.mergeWithBufferBW(array, a, m, b, True);
            return;
        }

        new bool frag = False;
        new int origB = b;

        new int twoR = b - a;
        if strat2 {
            this.strat2BLenCalc(twoR, bB - bA);
        }

        new bool lazy = this.blockLen > this.bufLen;

        new int nW   = twoR // this.blockLen - int(!(lazy || this.strat1)),
                w    = log2(nW) + 1,
                size = nW * w;

        if (!this.strat1) && this.checkValidBitArray(array, bA, bB, size * 2) {
            a, m, b, frag = this.adjust(array, a, m, b, aSub);

            new BitArray bits    = BitArray(array, bA       , bB - size * 2, nW, w),
                         indices = BitArray(array, bA + size, bB - size    , nW, w); 

            this.combine(array, a, m, b, bits, indices, lazy);

            bits.free();
            indices.free();
        } elif this.checkValidBitArray(array, bA, bB, size) {
            a, m, b, frag = this.adjust(array, a, m, b, aSub);

            new BitArray bits = BitArray(array, bA, bB - size, nW, w);
            this.combine(array, a, m, b, bits, None, lazy);
            bits.free();
        } else {
            this.noBitsBLenCalc(twoR);
            a, m, b, frag = this.adjust(array, a, m, b, aSub);

            new bool strat1 = this.strat1;
            this.strat1 = False;
            this.combine(array, a, m, b, None, None, this.blockLen > this.bufLen);
            this.strat1 = strat1;
            this.resetBuf();
        }

        if frag {
            this.mergeWithBufferBW(array, a, origB, b, False);
        }
    }

    new method firstMerge(array, a, m, b, strat2) {
        if b - m <= this.bufLen {
            this.mergeWithBufferBW(array, a, m, b, True);
            return;
        }

        # a [ -    -   AT    -    -]  m [ -    -   BT   -    - ] b

        new int m1 = a + (m - a) // 2,
                m2 = lrBinarySearch(array, m, b, array[m1], True),
                m3 = m1 + m2 - m;

        this.rotate(array, m1, m, m2);

        new int lAT = m3 - a,
                lBT = b  - m3,
                lA0 = m1 - a,
                lA1 = m3 - m1,
                lB0 = m2 - m3,
                lB1 = b  - m2;

        # a [ - A0 - ] m1 [ - A1 - ] m3 [ - B0 - ] m2 [ - B1 - ] b

        new int bA, bB;
        if lAT < lBT {
            if lB0 > lB1 {
                bA = m3;
                bB = m2;
            } else {
                bA = m2;
                bB = b;
            }

            this.firstMergePart(array,  a, m1, m3, bA, bB, strat2, True);
            this.firstMergePart(array, m3, m2,  b,  a, m3, strat2, False);
        } else {
            if lA0 > lA1 {
                bA = a;
                bB = m1;
            } else {
                bA = m1;
                bB = m3;
            }

            this.firstMergePart(array, m3, m2,  b, bA, bB, strat2, False);
            this.firstMergePart(array,  a, m1, m3, m3,  b, strat2, True);
        }
    }

    new method lithiumLoop(array, a, b) {
        new int r = LithiumSort.RUN_SIZE,
                e = b - this.keyLen;
        while r <= this.bufLen {
            new int twoR = r * 2;
            for i = a; i < e - twoR; i += twoR {}

            if i + r < e {
                BufMerge2.mergeWithScrollingBufferBW(array, i, i + r, e);
            } else {
                this.shift(array, i, e, e + r, True);
            }

            for i -= twoR; i >= a; i -= twoR {
                BufMerge2.mergeWithScrollingBufferBW(array, i, i + r, i + twoR);
            }

            new int oldR = r;
            r = twoR;
            twoR *= 2;

            for i = a + oldR; i + twoR < e + oldR; i += twoR {
                this.dualMergeFW(array, i, i + r, i + twoR, oldR);
            }

            if i + r < e + oldR {
                this.dualMergeFW(array, i, i + r, e + oldR, oldR);
            } else {
                this.shift(array, i - oldR, i, e + oldR, False);
            }

            r = twoR;
        }

        b = e;
        e += this.keyLen;

        new bool strat2 = this.blockLen == 0;

        new int twoR = r * 2;
        while twoR < b - a {
            new int i = a + twoR;
            this.firstMerge(array, a, a + r, i, strat2);

            if strat2 {
                this.strat2BLenCalc(twoR, twoR);
            }

            new bool lazy   = this.blockLen > this.bufLen,
                     strat1 = this.strat1;

            new int nW   = twoR // this.blockLen - int(!(lazy || strat1)),
                    w    = log2(nW) + 1,
                    size = nW * w;

            new dynamic bits, indices;
            if (!strat1) && this.checkValidBitArray(array, a, a + twoR, size * 2) {
                bits    = BitArray(array, a       , a + twoR - size * 2, nW, w);
                indices = BitArray(array, a + size, a + twoR - size    , nW, w);
            } elif this.checkValidBitArray(array, a, a + twoR, size) {
                bits    = BitArray(array, a, a + twoR - size, nW, w);
                indices = None;
            } else {
                bits    = None;
                indices = None;
                this.strat1 = False;
                this.noBitsBLenCalc(twoR);
                lazy = this.blockLen > this.bufLen;
            }

            for ; i < b - twoR; i += twoR {
                this.combine(array, i, i + r, i + twoR, bits, indices, lazy);
            }

            if i + r < b {
                this.combine(array, i, i + r, b, bits, indices, lazy);
            }

            if bits is None {
                this.resetBuf();
                this.strat1 = strat1;
            } else {
                bits.free();
            }

            if indices is not None {
                indices.free();
            }

            r = twoR;
            twoR *= 2;
        }

        this.firstMerge(array, a, a + r, b, strat2);

        new bool single = this.bufLen <= LithiumSort.SMALL_MERGE;
        this.bufLen = 0;
        binaryInsertionSort(array, b, e);

        if single {
            this.mergeInPlaceBW(array, a, b, e, True);
            return;
        }
        
        r = lrBinarySearch(array, a, b, array[e - 1], False);
        this.rotate(array, r, b, e);

        new int d = b - r;
        e -= d;
        b -= d;

        new int b0 = b + (e - b) // 2;
        r = lrBinarySearch(array, a, b, array[b0 - 1], False);
        this.rotate(array, r, b, b0);

        d   = b - r;
        b0 -= d;
        b  -= d;

        this.mergeInPlaceBW(array, b0, b0 + d, e, True);
        this.mergeInPlaceBW(array, a, b, b0, True);
    }

    new method inPlaceMergeSort(array, a, b) {
        this.sortRuns(array, a, b);

        new int r = LithiumSort.RUN_SIZE;
        while r < b - a {
            new int twoR = r * 2;
            for i = a; i < b - twoR; i += twoR {
                this.mergeInPlaceBW(array, i, i + r, i + twoR, True);
            }

            if i + r < b {
                this.mergeInPlaceBW(array, i, i + r, b, True);
            }

            r = twoR;
        }
    }

    new method sort(array, a, b) {
        new int n = b - a;
        if n <= LithiumSort.SMALL_SORT {
            this.inPlaceMergeSort(array, a, b);
            return;
        }

        new int sqrtn = 1;
        for ; sqrtn * sqrtn < n; sqrtn *= 2 {}

        new int keysFound = this.findKeys(array, a, b, sqrtn);

        if keysFound <= LithiumSort.MAX_STRAT3_UNIQUE {
            this.inPlaceMergeSort(array, a, b);
            return;
        }

        this.bufPos       = b - keysFound;
        this.bufLen       = keysFound;
        this.keyLen       = keysFound;
        this.keyPos       = this.bufPos;
        this.origBlockLen = sqrtn;

        if keysFound == sqrtn {
            this.blockLen = sqrtn;
            this.strat1   = True;
        } else {
            this.blockLen = 0;
            this.strat1   = False;
        }

        this.sortRuns(array, a, b - keysFound);
        this.lithiumLoop(array, a, b);
    }
}

@Sort(
    "Block Merge Sorts",
    "Lithium Sort",
    "Lithium Sort",
);
new function lithiumSortRun(array) {
    LithiumSort().sort(array, 0, len(array));
}