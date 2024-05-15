# MIT License
# 
# Copyright (c) 2021 EmeraldBlock
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

# Implements https://www.sciencedirect.com/science/article/pii/S1877050910005478.
#
# The shuffle algorithm is at https://arxiv.org/abs/0805.1598.
# Note that the unshuffle algorithm is not the shuffle algorithm in reverse,
# but rather, it is a variation of the shuffle algorithm.
#
# See also a proof of the time complexity at https://arxiv.org/abs/1508.00292.
# The implementation is based on the pseudocode found in this.

use compareValues, compSwap;

new class NewShuffleMergeSort {
    new method __init__(rot = None) {
        if rot is None {
            this.__rotate = sortingVisualizer.getRotation(
                id = sortingVisualizer.getUserSelection(
                    [r.name for r in sortingVisualizer.rotations],
                    "Select rotation algorithm (default: Gries-Mills)"
                )
            ).lengthFn;
        } else {
            this.__rotate = sortingVisualizer.getRotation(name = rot).lengthFn;
        }
    }

    new method rotate(array, m, a, b) {
        this.__rotate(array, m - a, a, b);
    }

    new method shuffleEasy(array, start, size) {
        for i = 1; i < size; i *= 3 {
            new Value val = array[start + i - 1].read();
            for j = (i * 2) % size; j != i; j = (j * 2) % size {
                new Value nval = array[start + j - 1].read();
                array[start + j - 1].write(val);
                val = nval;
            }
            array[start + i - 1].write(val);
        }
    }

    new method shuffle(array, start, end) {
        while end - start > 1 {
            new int n = (end - start) // 2;
            for l = 1; l * 3 - 1 <= 2 * n; l *= 3 {}
            new int m = (l - 1) // 2;

            this.rotate(array, start + n, n - m, m);
            this.shuffleEasy(array, start, l);
            start += l - 1;
        }
    }

    new method rotateShuffledEqual(array, a, b, size) {
        for i = 0; i < size; i += 2 {
            array[a + i].swap(array[b + i]);
        }
    }

    new method rotateShuffled(array, mid, a, b) {
        while a > 0 && b > 0 {
            if a > b {
                this.rotateShuffledEqual(array, mid - b, mid, b);
                mid -= b;
                a   -= b;
            } else {
                this.rotateShuffledEqual(array, mid - a, mid, a);
                mid += a;
                b   -= a;
            }
        }
    }

    new method rotateShuffledOuter(array, mid, a, b) {
        if a > b {
            this.rotateShuffledEqual(array, mid - b, mid + 1, b);
            mid -= b;
            a   -= b;
        } else {
            this.rotateShuffledEqual(array, mid - a, mid + 1, a);
            mid += a + 1;
            b   -= a;
        }

        this.rotateShuffled(array, mid, a, b);
    }

    new method unshuffleEasy(array, start, size) {
        for i = 1; i < size; i *= 3 {
            new int   prev = i;
            new Value val  = array[start + i - 1].read();
            for j = (i * 2) % size; j != i; j = (j * 2) % size {
                array[start + prev - 1].write(array[start + j - 1]);
                prev = j;
            }
            array[start + prev - 1].write(val);
        }
    }

    new method unshuffle(array, start, end) {
        while end - start > 1 {
            new int n = (end - start) // 2;
            for l = 1; l * 3 - 1 <= 2 * n; l *= 3 {}
            new int m = (l - 1) // 2;

            this.rotateShuffledOuter(array, start + 2 * m, 2 * m, 2 * n - 2 * m);
            this.unshuffleEasy(array, start, l);
            start += l - 1;
        }
    }

    new method mergeUp(array, start, end, type_) {
        new int i = start,
                j = i + 1;

        while j < end {
            new int cmp = compareValues(array[i], array[j]);
            if cmp < 0 || (!type_) && cmp == 0 {
                i++;
                if i == j {
                    j++;
                    !type_;
                }
            } elif end - j == 1 {
                this.rotate(array, j, j - i, 1);
                break;
            } else {
                new int r = 0;
                if type_ {
                    for ; j + 2 * r < end && compareValues(array[j + 2 * r], array[i]) != 1; r++ {}
                } else {
                    for ; j + 2 * r < end && array[j + 2 * r] < array[i]; r++ {}
                }

                j--;
                this.unshuffle(array, j, j + 2 * r);
                this.rotate(array, j, j - i, r);
                i += r + 1;
                j += 2 * r + 1;
            }
        }
    }

    new method merge(array, start, mid, end) {
        if mid - start <= end - mid {
            this.shuffle(array, start, end);
            this.mergeUp(array, start, end, True);
        } else {
            this.shuffle(array, start + 1, end);
            this.mergeUp(array, start, end, False);
        }
    }

    new method sort(array, a, b) {
        for i = a; i < b - 1; i += 2 {
            compSwap(array, i, i + 1);
        }

        new int r = 2;
        while r < b - a {
            new int twoR = r * 2;
            for i = a; i < b - twoR; i += twoR {
                this.merge(array, i, i + r, i + twoR);
            }

            if i + r < b {
                this.merge(array, i, i + r, b);
            }

            r = twoR;
        }
    }
}

@Sort(
    "Merge Sorts",
    "New Shuffle Merge Sort",
    "New Shuffle Merge"
);
new function newShuffleMergeSortRun(array) {
    NewShuffleMergeSort().sort(array, 0, len(array));
}