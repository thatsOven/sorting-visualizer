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

use binaryInsertionSort, arrayCopy;

new class EctaSort {
    new method mergeTo(from_, to, a, m, b, p) {
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

    new method pingPongMerge(array, buf, a, m1, m2, m3, b) {
        new int p    = 0,
                p1   = p + m2 - a,
                pEnd = p + b - a;

        this.mergeTo(array, buf, a, m1, m2, p);
		this.mergeTo(array, buf, m2, m3, b, p1);
		this.mergeTo(buf, array, p, p1, pEnd, a);
    }

    new method mergeBWExt(array, tmp, a, m, b) {
        new int s = b - m;

        arrayCopy(array, m, tmp, 0, s);

        new int i = s - 1,
                j = m - 1;

        while i >= 0 && j >= a {
            b--;
            if tmp[i] >= array[j] {
                array[b].write(tmp[i]);
                i--;
            } else {
                array[b].write(array[j]);
                j--;
            }
        }

        while i >= 0 {
            b--;
            array[b].write(tmp[i]);
            i--;
        }
    }

    new method blockCycle(array, buf, keys, a, bLen, bCnt) {
        for i = 0; i < bCnt; i++ {
            if keys[i] != i {
                arrayCopy(array, a + i * bLen, buf, 0, bLen);
                new int j    = i,
                        next = keys[i].readInt();

                do {
                    arrayCopy(array, a + next * bLen, array, a + j * bLen, bLen);
                    keys[j].write(j);

                    j = next;
                    next = keys[next].readInt();
                } while next != i;

                arrayCopy(buf, 0, array, a + j * bLen, bLen);
                keys[j].write(j);
            }
        }
    }

    new method blockMerge(array, buf, tags, a, m, b, bLen) {
        new int c = 0,
                t = 2,
                i = a,
                j = m,
                k = 0,
                l = 0,
                r = 0;

        for ; c < 2 * bLen; k++, c++ {
            if array[i] <= array[j] {
                buf[k].write(array[i]);
                i++; l++;
            } else {
                buf[k].write(array[j]);
                j++; r++;
            }
        }

        new bool left = l >= r;
        k = i - l if left else j - r;
        c = 0;

        do {
            if i < m && (j == b || array[i] <= array[j]) {
                array[k].write(array[i]);
                i++; l++;
            } else {
                array[k].write(array[j]);
                j++; r++;
            }
            k++;

            c++;
            if c == bLen {
                tags[t].write((k - a) // bLen - 1);
                t++;

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

        arrayCopy(array, k - c, array, b1, c);
        r -= c;

        t = 0; k = 0;

        while l > 0 {
            arrayCopy(buf, k, array, m - l, bLen);
            tags[t].write((m - a - l) // bLen);
            t++;
            k += bLen;
            l -= bLen;
        }

        while r > 0 {
            arrayCopy(buf, k, array, b1 - r, bLen);
            tags[t].write((b1 - a - r) // bLen);
            t++;
            k += bLen;
            r -= bLen;
        }

        this.blockCycle(array, buf, tags, a, bLen, (b - a) // bLen);
    }

    new method __adaptAux(array) {
        return array + this.tags;
    }

    new method __adaptIdx(idx, aux) {
        if aux is this.tags {
            return idx + len(this.buf);
        }

        return idx;
    }

    new method sort(array, a, b) {
        if b - a <= 32 {
            binaryInsertionSort(array, a, b);
            return;
        }

        new int bLen = 1;
        for ; bLen * bLen < b - a; bLen *= 2 {}

        new int tLen   = (b - a) // bLen,
                bufLen = 2 * bLen,
                j      = 16;

        new dynamic speed = sortingVisualizer.speed;
        sortingVisualizer.setSpeed(max(int(10 * (len(array) / 2048)), speed * 2));

        for i = a; i < b; i += j {
            binaryInsertionSort(array, i, min(i + j, b));
        }

        sortingVisualizer.setSpeed(speed);

        this.buf  = sortingVisualizer.createValueArray(bufLen);
        this.tags = sortingVisualizer.createValueArray(tLen);
        sortingVisualizer.setAux(this.buf);
        sortingVisualizer.setAdaptAux(this.__adaptAux, this.__adaptIdx);

        for ; 4 * j <= bufLen; j *= 4 {
            for i = a; i + 2 * j < b; i += 4 * j {
                this.pingPongMerge(array, this.buf, i, i + j, i + 2 * j, min(i + 3 * j, b), min(i + 4 * j, b));
            }

            if i + j < b {
                this.mergeBWExt(array, this.buf, i, i + j, b);
            }
        }

        for ; j <= bufLen; j *= 2 {
            for i = a; i + j < b; i += 2 * j {
                this.mergeBWExt(array, this.buf, i, i + j, min(i + 2 * j, b));
            }
        }

        for ; j < b - a; j *= 2 {
            for i = a; i + j + bufLen < b; i += 2 * j {
                this.blockMerge(array, this.buf, this.tags, i, i + j, min(i + 2 * j, b), bLen);
            }

            if i + j < b {
                this.mergeBWExt(array, this.buf, i, i + j, b);
            }
        } 
    }
}

@Sort(
    "Block Merge Sorts",
    "Ecta Sort",
    "Ecta Sort"
);
new function ectaSortRun(array) {
    EctaSort().sort(array, 0, len(array));
}