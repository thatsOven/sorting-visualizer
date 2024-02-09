# MIT License
#
# Copyright (c) 2021-2024 aphitorite
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

use lrBinarySearch, blockSwap, BitArray, binaryInsertionSort, 
    compareValues, javaNumberOfLeadingZeros;

namespace PacheSort {
    new int MIN_INSERT = 32,
            MIN_HEAP   = 255;

    new classmethod log2(n) {
        return int(math.log2(n));
    }

    new classmethod siftDown(array, pos, len, root, t) {
        new int curr = root,
                cmp  = 1 if (javaNumberOfLeadingZeros(root + 1) & 1) == 1 else -1,
                left = 2 * curr + 1;
        
        while left < len {
            new int next   = left,
                    gChild = 2 * left + 1;

            for node in [left + 1] + [gChild + i for i in range(4)] {
                if node >= len {
                    break;
                }

                if compareValues(array[pos + node], array[pos + next]) == cmp {
                    next = node;
                }
            }

            if next >= gChild {
                if compareValues(array[pos + next], t) == cmp {
                    array[pos + curr].write(array[pos + next]);

                    curr = next;
                    left = 2 * curr + 1;

                    new int parent = (next - 1) // 2;

                    if compareValues(array[pos + parent], t) == cmp {
                        array[pos + curr].write(t);
                        t = array[pos + parent].copy();
                        array[pos + parent].write(array[pos + curr]);
                    }
                } else {
                    break;
                }
            } else {
                if compareValues(array[pos + next], t) == cmp {
                    array[pos + curr].write(array[pos + next]);
                    curr = next;
                }

                break;
            }
        }

        array[pos + curr].write(t);
    }

    new classmethod heapify(array, pos, len) {
        for i = (len - 1) // 2; i >= 0; i-- {
            this.siftDown(array, pos, len, i, array[pos + i].copy());
        }
    }

    new classmethod minMaxHeap(array, a, b) {
        new int pos = a,
                len = b - a;

        this.heapify(array, pos, len);

        for i = len; i > 1; {
            i--;
            new Value t = array[pos + i].copy();
            array[pos + i].write(array[pos]);
            this.siftDown(array, pos, i, 0, t);
        }
    }

    new classmethod selectMinMax(array, a, b, s) {
        this.heapify(array, a, b - a);

        for i = 0; i < s; i++ {
            b--;
            new Value t = array[b].copy();
            array[b].write(array[a]);
            this.siftDown(array, a, b - a, 0, t);
        }

        for i = 0; i < s; i++ {
            b--;
            new Value t = array[b].copy();
            new   int c = 1;

            if array[a + c + 1] < array[a + c] {
                c++;
            }

            array[b].write(array[a + c]);
            this.siftDown(array, a, b - a, c, t);
        }

        new int a1 = a + s;

        while a1 > a {
            a1--;
            array[a1].swap(array[b]);
            b++;
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
            this.minMaxHeap(array, a, b);
            return;
        }

        new int log    = this.log2(b - a - 1) + 1,
                pCnt   = (b - a) // (log ** 2),
                bitLen = (pCnt + 1) * log,
                a1     = a + bitLen,
                b1     = b - bitLen;

        this.selectMinMax(array, a, b, bitLen);

        if array[a1] < array[b1 - 1] {
            new int a2 = a1;

            for i = 0; i < pCnt; i++, a2++ {
                array[a2].swap(array[random.randrange(a2, b1)]);
            }

            this.minMaxHeap(array, a1, a2);

            new BitArray cnts = BitArray(array, a, b1, pCnt + 1, log);

            for i = a2; i < b1; i++ {
                cnts.incr(lrBinarySearch(array, a1, a2, array[i], True) - a1);
            }

            for i = 1, sum = cnts.get(0); i < pCnt + 1; i++ {
                sum += cnts.get(i);
                cnts.set(i, sum);
            }

            for i = 0, j = 0; i < pCnt; i++ {
                new int cur = cnts.get(i),
                        loc = lrBinarySearch(array, a1 + i, a2, array[a2 + j], True) - a1;

                while j < cur {
                    if loc == i {
                        j++;
                        loc = lrBinarySearch(array, a1 + i, a2, array[a2 + j]) - a1;
                    } else {
                        cnts.decr(loc);
                        new int dest = cnts.get(loc);

                        while True {
                            new int newLoc = lrBinarySearch(array, a1 + i, a2, array[a2 + dest]) - a1;

                            if newLoc != loc {
                                loc = newLoc;
                                break;
                            }

                            cnts.decr(loc);
                            dest--;
                        }
                        array[a2 + j].swap(array[a2 + dest]);
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
            this.minMaxHeap(array, a, a + pCnt);
        }
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