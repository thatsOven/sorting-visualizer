# MIT License
# 
# Copyright (c) 2022 Control, implemented by aphitorite
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

use bidirArrayCopy, binaryInsertionSort, adaptLow;

new class KitaSort {
    new method __init__() {
        this.buf  = None;
        this.tags = None;
        this.tTmp = None;
    }
    
    new classmethod mergeTo(from_, to, a, m, b, p) {
        new int i = a,
                j = m;

        for ; i < m && j < b; p++ {
            if from_[i] <= from_[j] {
                to[p].write(from_[i]);
                i++;
            } else {
                to[p].write(from_[j]);
                j++;
            }
        }

        for ; i < m; p++, i++ {
            to[p].write(from_[i]);
        }

        for ; j < b; p++, j++ {
            to[p].write(from_[j]);
        }
    }

    new classmethod pingPongMerge(array, buf, a, m1, m2, m3, b) {
        new int p    = 0,
                p1   = p + m2 - a,
                pEnd = p + b - a;

        this.mergeTo(array,   buf,  a, m1,   m2, p);
        this.mergeTo(array,   buf, m2, m3,    b, p1);
        this.mergeTo(  buf, array,  p, p1, pEnd, a);
    }

    new classmethod mergeBWExt(array, tmp, a, m, b) {
        new int s = b - m;
        bidirArrayCopy(array, m, tmp, 0, s);

        new int i = s - 1,
                j = m - 1;

        for b--; i >= 0 && j >= a; b-- {
            if tmp[i] >= array[j] {
                array[b].write(tmp[i]);
                i--;
            } else {
                array[b].write(array[j]);
                j--;
            }
        } 

        for b--; i >= 0; b--, i-- {
            array[b].write(tmp[i]);
        }
    }

    new method blockMerge(array, a, m, b, bLen) {
        new int ta = a // bLen,
                tm = m // bLen,
                tb = b // bLen,
                ti = ta,
                tj = tm,
                i  = a + this.tags[ti].readInt() * bLen,
                j  = m + this.tags[tj].readInt() * bLen,
                c  = 0, 
                ci = 0, 
                cj = 0,
                bi = ti,
                bj = tj,
                l  = 0,
                r  = 0,
                t  = 2, p;

        new bool lLeft = True,
                 rLeft = True, lBuf;
                
        for k in range(2 * bLen) {
            if lLeft && ((!rLeft) || array[i] <= array[j]) {
                this.buf[k].write(array[i]);
                i++;
                l++;
                ci++;

                if ci == bLen {
                    ti++;

                    if ti == tm {
                        lLeft = False;
                    } else {
                        i  = a + this.tags[ti].readInt() * bLen;
                        ci = 0;
                    }
                } 
            } else {
                this.buf[k].write(array[j]);
                j++;
                r++;
                cj++;

                if cj == bLen {
                    tj++;

                    if tj == tb {
                        rLeft = False;
                    } else {
                        j  = m + this.tags[tj].readInt() * bLen;
                        cj = 0;
                    }
                }
            }
        }

        lBuf = l >= r;

        if lBuf {
            p = a + this.tags[bi].readInt() * bLen;
        } else {
            p = m + this.tags[bj].readInt() * bLen;
        }

        do {
            if lLeft && ((!rLeft) || array[i] <= array[j]) {
                array[p].write(array[i]);
                p++;
                i++;
                l++;
                ci++;

                if ci == bLen {
                    ti++;

                    if ti == tm {
                        lLeft = False;
                    } else {
                        i  = a + this.tags[ti].readInt() * bLen;
                        ci = 0;
                    }
                }
            } else {
                array[p].write(array[j]);
                p++;
                j++;
                r++;
                cj++;

                if cj == bLen {
                    tj++;

                    if tj == tb {
                        rLeft = False;
                    } else {
                        j  = m + this.tags[tj].readInt() * bLen;
                        cj = 0;
                    }
                }
            }

            c++;
            if c == bLen {
                if lBuf {
                    l -= bLen;
                    this.tTmp[t].write(this.tags[bi]);
                    t++;
                    bi++;
                } else {
                    r -= bLen;
                    this.tTmp[t].write(this.tags[bj] + tm - ta);
                    t++;
                    bj++;
                }

                lBuf = l >= r;
                p = a + this.tags[bi].readInt() * bLen if lBuf else m + this.tags[bj].readInt() * bLen;
                c = 0;
            }
        } while lLeft || rLeft;

        p = 0;
        t = 0;

        for ; l > 0; t++, bi++, p += bLen, l -= bLen {
            bidirArrayCopy(this.buf, p, array, a + this.tags[bi].readInt() * bLen, bLen);
            this.tTmp[t].write(this.tags[bi]);
        }

        for ; r > 0; t++, bj++, p += bLen, r -= bLen {
            bidirArrayCopy(this.buf, p, array, m + this.tags[bj].readInt() * bLen, bLen);
            this.tTmp[t].write(this.tags[bj] + tm - ta);
        }

        bidirArrayCopy(this.tTmp, 0, this.tags, ta, tb - ta);
    }

    new method blockCycle(array, a, bLen, bCnt) {
        for i in range(bCnt) {
            if this.tags[i] != i {
                bidirArrayCopy(array, a + i * bLen, this.buf, 0, bLen);
                new int j    = i,
                        next = this.tags[i].readInt();

                do {
                    bidirArrayCopy(array, a + next * bLen, array, a + j * bLen, bLen);
                    this.tags[j].write(j);

                    j    = next;
                    next = this.tags[next].readInt();
                } while next != i;

                bidirArrayCopy(this.buf, 0, array, a + j * bLen, bLen);
                this.tags[j].write(j);
            }
        }
    }

    new method __adaptAux(arrays) {
        return adaptLow(arrays, (this.tags, this.tTmp));
    }

    new method sort(array, a, b) {
        new int length = b - a;

        if length <= 32 {
            binaryInsertionSort(array, a, b);
            return;
        }

        new int sqrtLg = (32 - javaNumberOfLeadingZeros(length - 1)) // 2,
                bLen   = 1 << sqrtLg,
                tLen   = length // bLen,
                bufLen = 2 * bLen;

        sortingVisualizer.setAdaptAux(this.__adaptAux);
        this.buf  = sortingVisualizer.createValueArray(bufLen);
        this.tags = sortingVisualizer.createValueArray(tLen);
        this.tTmp = sortingVisualizer.createValueArray(tLen);

        new int b1 = b - length % bLen,
                j  = 1;

        if sqrtLg % 2 == 0 {
            for i = a + 1; i < b1; i += 2 {
                if array[i - 1] > array[i] {
                    array[i - 1].swap(array[i]);
                }
            }

            j *= 2;
        } 

        for ; j < bufLen; j *= 4 {
            for i = a; i + j < b1; i += 4 * j {
                this.pingPongMerge(array, this.buf, i, i + j, min(i + 2 * j, b1), min(i + 3 * j, b1), min(i + 4 * j, b1));
            }
        }

        for i in range(tLen) {
            this.tags[i].write(i & 1);
        }

        for ; j < length; j *= 2 {
            for i = a; i + j < b1; i += 2 * j {
                this.blockMerge(array, i, i + j, min(i + 2 * j, b1), bLen);
            }
        }

        this.blockCycle(array, a, bLen, tLen);

        if b1 < b {
            binaryInsertionSort(array, b1, b);
            this.mergeBWExt(array, this.buf, a, b1, b);
        }
    }
}

@Sort(
    "Block Merge Sorts",
    "Kita Sort",
    "Kita Sort",
    usesDynamicAux = True
);
new function kitaSortRun(array) {
    KitaSort().sort(array, 0, len(array));
}