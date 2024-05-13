# MIT License
# 
# Copyright (c) 2021-2023 aphitorite
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

use reverse;

namespace OptimizedPancakeSort {
    new classmethod flip(array, n) {
        reverse(array, 0, n);
    }

    new classmethod merge(array, h1, h2) bool {
        if h1 == 1 && h2 == 1 {
            if array[0] > array[1] {
                this.flip(array, 2);
            }

            return True;
        }

        new int n = h1 + h2, 
                m = n // 2;

        if h2 < h1 {
            if h2 < 1 {
                return True;
            }

            new int i = 0,
                    j = h2;

            while i < j {
                new int k = (i + j) // 2;

                if array[n - 1 - k - m] > array[n - 1 - k] {
                    i = k + 1;
                } else {
                    j = k;
                }
            }

            this.flip(array, n - m - i);
            this.flip(array, n - i);

            if this.merge(array, h2 - i, i + m - h2) {
                this.flip(array, m);
            }

            this.flip(array, n);
            if !this.merge(array, i, n - m - i) {
                this.flip(array, n - m);
            }
        } else {
            if h1 < 1 {
                return False;
            }

            new int i = 0,
                    j = h1;

            while i < j {
                new int k = (i + j) // 2;

                if array[k] < array[k + m] {
                    i = k + 1;
                } else {
                    j = k;
                }
            }

            this.flip(array, i);
            this.flip(array, i + m);

            if this.merge(array, i + m - h1, h1 - i) {
                this.flip(array, m);
            }

            this.flip(array, n);

            if !this.merge(array, n - m - i, i) {
                this.flip(array, n - m);
            }
        }

        return True;
    }

    new classmethod sort(array, n) {
        if n < 2 {
            return;
        }

        new int h = n // 2;

        this.sort(array, h);
        this.flip(array, n);
        this.sort(array, n - h);
        this.merge(array, n - h, h);
    }
}

@Sort(
    "Pancake Sorts",
    "Optimized Pancake Sort",
    "Optimized Pancake"
);
new function optimizedPancakeSortRun(array) {
    OptimizedPancakeSort.sort(array, len(array));
}