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

# stable sorting algorithm that guarantees worst case performance of
# O(n log n) comparisons and O(n) moves in O(n^2/3) memory

use KWayMerge, compareValues, bidirArrayCopy;

new class RemiSort {
    new method __init__() {
        this.keys = None;
        this.buf  = None;
        this.heap = None;
        this.p    = None;
        this.pa   = None;
    }

    new classmethod ceilCbrt(n) {
        new int a = 0,
                b = min(1291, n);

        while a < b {
            new int m = (a + b) // 2;

            if m ** 3 >= n {
                b = m;
            } else {
                a = m + 1;
            }
        }

        return a;
    }

    new method __siftDown(array, r, len_, a, t) {
        new int j = r;

        while 2 * j + 1 < len_ {
            j = 2 * j + 1;

            if j + 1 < len_ {
                new int cmp = compareValues(
                    array[a + this.keys[j + 1].readInt()], 
                    array[a + this.keys[j    ].readInt()]
                );

                if cmp > 0 || (cmp == 0 && this.keys[j + 1] > this.keys[j]) {
                    j++;
                }
            }
        }

        for 
            cmp = compareValues(array[a + t.readInt()], array[a + this.keys[j].readInt()]);
            cmp > 0 || (cmp == 0 && this.keys[j] < t);
            j = (j - 1) // 2, cmp = compareValues(array[a + t.readInt()], array[a + this.keys[j].readInt()])
        {}

        new Value t2;
        for ; j > r; j = (j - 1) // 2 {
            t2 = this.keys[j].read();
            this.keys[j].write(t);
            t = t2;
        }

        this.keys[r].write(t);
    }

    new method siftDown(*args) {
        if type(args[1]) is list {
            KWayMerge.siftDown(*args);
        } else {
            this.__siftDown(*args);
        }
    }

    new method tableSort(array, a, b) {
        new int len_ = b - a;

        for i = (len_ - 1) // 2; i >= 0; i-- {
            this.siftDown(array, i, len_, a, this.keys[i].read());
        }

        for i = len_ - 1; i > 0; i-- {
            new Value t = this.keys[i].read();
            this.keys[i].write(this.keys[0]);
            this.siftDown(array, 0, i, a, t);
        }

        for i in range(len_) {
            if this.keys[i] != i {
                new Value t  = array[a + i].read();
                new int j    = i,
                        next = this.keys[i].readInt(); 

                do {
                    array[a + j].write(array[a + next]);
                    this.keys[j].write(j);

                    j    = next;
                    next = this.keys[next].readInt();
                } while next != i;

                array[a + j].write(t);
                this.keys[j].write(j);
            }
        }
    }

    new method blockCycle(array, a, bLen, bCnt) {
        for i in range(bCnt) {
            if this.keys[i] != i {
                bidirArrayCopy(array, a + i * bLen, this.buf, 0, bLen);
                new int j    = i,
                        next = this.keys[i].readInt(); 

                do {
                    bidirArrayCopy(array, a + next * bLen, array, a + j * bLen, bLen);
                    this.keys[j].write(j);

                    j    = next;
                    next = this.keys[next].readInt();
                } while next != i;

                bidirArrayCopy(this.buf, 0, array, a + j * bLen, bLen);
                this.keys[j].write(j);
            }
        }
    } 

    new method kWayMerge(array, b, bLen, rLen) {
        new int k    = len(this.p),
                size = k,
                a    = this.pa[0].readInt(),
                a1   = this.pa[1].readInt();

        for i in range(k) {
            this.heap[i].write(i);
        }

        for i = (k - 1) // 2; i >= 0; i-- {
            this.siftDown(array, this.heap, this.pa, this.heap[i].readInt(), i, k);
        }

        for i in range(rLen) {
            new int min_ = this.heap[0].readInt();

            this.buf[i].write(array[this.pa[min_].readInt()]);
            this.pa[min_]++;

            if this.pa[min_] == min(a + (min_ + 1) * rLen, b) {
                size--;
                this.siftDown(array, this.heap, this.pa, this.heap[size].readInt(), 0, size);
            } else {
                this.siftDown(array, this.heap, this.pa, this.heap[0].readInt(), 0, size);
            }
        }

        new int t   = 0,
                cnt = 0,
                c   = 0;
        
        for ; this.pa[c] - this.p[c] < bLen; c++ {}

        do {
            new int min_ = this.heap[0].readInt();

            array[this.p[c].readInt()].write(array[this.pa[min_].readInt()]);
            this.pa[min_]++;
            this.p[c]++;

            if this.pa[min_] == min(a + (min_ + 1) * rLen, b) {
                size--;
                this.siftDown(array, this.heap, this.pa, this.heap[size].readInt(), 0, size);
            } else {
                this.siftDown(array, this.heap, this.pa, this.heap[0].readInt(), 0, size);
            }

            cnt++;
            if cnt == bLen {
                if c > 0 {
                    this.keys[t].write(this.p[c] // bLen - bLen - 1);
                } else {
                    this.keys[t].write(-1);
                }
                t++;
                
                c   = 0;
                cnt = 0;
                for ; this.pa[c] - this.p[c] < bLen; c++ {}
            }
        } while size > 0;

        while cnt > 0 {
            cnt--; 
            this.p[c]--;
            b--;
            array[b].write(array[this.p[c].readInt()]);
        }

        this.pa[k - 1].write(b);
        this.keys[-1].write(-1);

        t = 0;
        for ; this.keys[t] != -1; t++ {}

        for i = 1, j = a; this.p[0] > j; i++ {
            for ; this.p[i] < this.pa[i]; j += bLen {
                this.keys[t].write(this.p[i] // bLen - bLen);
                for t++; this.keys[t] != -1; t++ {}

                bidirArrayCopy(array, j, array, this.p[i].readInt(), bLen);
                this.p[i] += bLen;
            }
        }

        bidirArrayCopy(this.buf, 0, array, a, rLen);
        this.blockCycle(array, a1, bLen, (b - a1) // bLen);
    }

    new method sort(array, a, b) {
        new int length = b - a;

        new int bLen = this.ceilCbrt(length),
                rLen = bLen * bLen,
                rCnt = (length - 1) // rLen + 1;

        if rCnt < 2 {
            this.keys = sortingVisualizer.createValueArray(length);
            sortingVisualizer.setNonOrigAux(this.keys);

            for i in range(length) {
                this.keys[i].write(i);
            }

            this.tableSort(array, a, b);
            return;
        }

        this.keys = sortingVisualizer.createValueArray(rLen);
        this.buf  = sortingVisualizer.createValueArray(rLen);
        this.heap = sortingVisualizer.createValueArray(rCnt);
        this.p    = sortingVisualizer.createValueArray(rCnt);
        this.pa   = sortingVisualizer.createValueArray(rCnt);
        sortingVisualizer.setNonOrigAux(this.keys, this.heap, this.p, this.pa);

        for i in range(rLen) {
            this.keys[i].write(i);
        }

        for i = a, j = 0; i < b; i += rLen, j++ {
            this.tableSort(array, i, min(i + rLen, b));
            this.pa[j].write(i);
        }
        bidirArrayCopy(this.pa, 0, this.p, 0, rCnt);

        this.kWayMerge(array, b, bLen, rLen);
    }  
}

@Sort(
    "Block Merge Sorts",
    "Remi Sort",
    "Remi Sort"
);
new function remiSortRun(array) {
    RemiSort().sort(array, 0, len(array));
}