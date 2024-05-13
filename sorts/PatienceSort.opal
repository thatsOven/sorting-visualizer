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

use compareValues, bidirArrayCopy, adaptLow;

new class PatienceSort {
    new method __init__() {
        this.tmp  = None;
        this.loc  = None;
        this.pa   = None;
        this.pb   = None;
        this.heap = None;
    }

    new classmethod pileSearch(array, b, val) int {
        new int a = 0;

        while a < b {
            new int m = (a + b) // 2;

            if array[m] <= val {
                b = m;
            } else {
                a = m + 1;
            }
        }

        return a;
    }

    new classmethod keyLessThan(src, pa, a, b) bool {
        new int cmp = compareValues(src[pa[a].readInt()], src[pa[b].readInt()]);
        return cmp < 0 || (cmp == 0 && a < b);
    }

    new classmethod siftDown(src, heap, pa, t, r, size) {
        while 2 * r + 2 < size {
            new int nxt  = 2 * r + 1,
                    min_ = nxt + int(!this.keyLessThan(src, pa, heap[nxt].readInt(), heap[nxt + 1].readInt()));

            if this.keyLessThan(src, pa, heap[min_].readInt(), t) {
                heap[r].write(heap[min_]);
                r = min_;
            } else {
                break;
            }
        }

        new int min_ = 2 * r + 1;

        if min_ < size && this.keyLessThan(src, pa, heap[min_].readInt(), t) {
            heap[r].write(heap[min_]);
            r = min_;
        } 

        heap[r].write(t);
    }

    new classmethod kWayMerge(src, dest, heap, pa, pb, size) {
        for i = 0; i < size; i++ {
            heap[i].write(i);
        }

        for i = (size - 1) // 2; i >= 0; i-- {
            this.siftDown(src, heap, pa, heap[i].readInt(), i, size);
        }

        for i = 0; size > 0; i++ {
            new int min_ = heap[0].readInt();

            dest[i].write(src[pa[min_].readInt()]);
            pa[min_]++;

            if pa[min_] == pb[min_] {
                size--;
                this.siftDown(src, heap, pa, heap[size].readInt(), 0, size);
            } else {
                this.siftDown(src, heap, pa, heap[0].readInt(), 0, size);
            }
        }
    }

    new method __adaptAux(arrays) {
        return adaptLow(arrays, (this.loc, this.heap));
    }

    new method sort(array, length) {
        sortingVisualizer.setAdaptAux(this.__adaptAux);
        this.tmp = sortingVisualizer.createValueArray(length);
        this.loc = sortingVisualizer.createValueArray(length);

        new int size = 1;
        this.tmp[0].write(array[0]);

        for i = 1; i < length; i++ {
            new int l = this.pileSearch(this.tmp, size, array[i]);

            this.loc[i].write(l);
            this.tmp[l].write(array[i]);

            if l == size {
                size++;
            }
        }

        if size > 1 {
            this.pa   = sortingVisualizer.createValueArray(size);
            this.pb   = sortingVisualizer.createValueArray(size);
            this.heap = sortingVisualizer.createValueArray(size);
                    
            for i = 0; i < length; i++ {
                this.pa[this.loc[i].readInt()]++;
            }

            for i = 1; i < size; i++ {
                this.pa[i] += this.pa[i - 1];
            }
            bidirArrayCopy(this.pa, 0, this.pb, 0, size);

            for i = length - 1; i >= 0; i-- {
                new int l = this.loc[i].readInt();
                this.pa[l]--;
                this.tmp[this.pa[l].readInt()].write(array[i]);
            }

            this.kWayMerge(this.tmp, array, this.heap, this.pa, this.pb, size);
        }
    }
}

@Sort(
    "Tree Sorts",
    "Patience Sort",
    "Patience Sort",
    usesDynamicAux = True
);
new function patienceSortRun(array) {
    PatienceSort().sort(array, len(array));
}