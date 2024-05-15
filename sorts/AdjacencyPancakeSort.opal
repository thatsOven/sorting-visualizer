# MIT License
# 
# Copyright (c) 2024 aphitorite
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

# implementation of Bill Gate's improved pancake sort with at most 5/3 N + O(1) flips
# uses this paper as a reference: https://www.sciencedirect.com/science/article/pii/S0304397508003575?via%3Dihub

use reverse;

new class AdjacencyPancakeSort  {
    new method dualSwap(array, a, b) {
        this.keys[a].swap(this.keys[b]);
        array[a].swap(array[b]);
    }

    new method reversal(array, a, b) {
        while b - a > 1 {
            b--;
            this.dualSwap(array, a, b);
            a++;
        }
    }

    new method isAdjacent(a, b, N) {
        return this.keys[b] == (this.keys[a].readInt() + 1) % N || 
               this.keys[a] == (this.keys[b].readInt() + 1) % N;
    }

    new method findAdjacent(e, a, N) {
        while !this.isAdjacent(a, e, N) {
            a++;
        }

        return a;
    }

    new method sort(array, a, b) {
        new int N = b - a;
        if N == 2 {
            if array[a] > array[a + 1] {
                reverse(array, a, a + 2);
            }

            return;
        }

        this.keys = sortingVisualizer.createValueArray(N);

        for j = a; j < b; j++ {
            new int c = 0;

            for i = a; i < b; i++ {
                if i == j {
                    continue;
                }

                new int cmp = compareValues(array[i], array[j]);
                if cmp < 0 || (cmp == 0 && i < j) {
                    c++;
                }
            }

            this.keys[j - a].write(c);
        }

        while True {
            for i = a; i < b - 1 && this.isAdjacent(i, i + 1, N); i++ {}

            if i == b - 1 {
                break;
            }

            if i == a {
                new int j = this.findAdjacent(a, a + 2, N);

                if !this.isAdjacent(j - 1, j, N) {
                    this.reversal(array, a, j);
                } else {
                    new int k = this.findAdjacent(a, j + 1, N);

                    if !this.isAdjacent(k - 1, k, N) {
                        this.reversal(array, a, k);
                    } else {
                        this.reversal(array, a, j + 1);
                        this.reversal(array, a, j);
                        this.reversal(array, a, k + 1);
                        this.reversal(array, a, a + k - j);
                    }
                }
            } else {
                new int j = this.findAdjacent(a, i + 1, N);

                if !this.isAdjacent(j - 1, j, N) {
                    this.reversal(array, a, j);
                } else {
                    new int k = this.findAdjacent(i, i + 2, N);

                    if k + 1 < b && this.isAdjacent(k + 1, k, N) {
                        this.reversal(array, a, i + 1);
                        this.reversal(array, a, k + 1);
                    } elif this.isAdjacent(k - 1, k, N) {
                        this.reversal(array, a, k + 1);
                        this.reversal(array, a, a + k - i);
                    } else {
                        this.reversal(array, a, k + 1);
                        this.reversal(array, a, a + k - i);

                        if j < k {
                            this.reversal(array, a, k + 1);
                            this.reversal(array, a, i + k - j + 1);
                        } else {
                            this.reversal(array, a, j + 1);
                            this.reversal(array, a, a + j - k);
                        }
                    }
                }
            }
        }

        for i = a; this.keys[i] != 0 && this.keys[i] != N - 1; i++ {}

        if this.keys[i] == 0 {
            if i == a {
                return;
            }

            this.reversal(array, a, b);
            i = b - 2 - (i - a);
        } elif i == a {
            this.reversal(array, a, b);
            return;
        }

        i++;
        this.reversal(array, a, i);
        this.reversal(array, a, b);
        this.reversal(array, a, b - i);
    }
}

@Sort(
    "Pancake Sorts",
    "Adjacency Pancake Sort",
    "Adjacency Pancake"
);
new function adjacencyPancakeSortRun(array) {
    AdjacencyPancakeSort().sort(array, 0, len(array));
}