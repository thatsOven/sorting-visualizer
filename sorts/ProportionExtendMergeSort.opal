# MIT License
# 
# Copyright (c) 2023 aphitorite
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

use binaryInsertionSort, blockSwap, partition;

namespace ProportionExtendMergeSort {
    new int MIN_INSERT = 8;

    new classmethod partition(array, a, b, p) {
        new int i = a - 1, j = b;

        while True {
            for i++; i <  b and array[i] < array[p]; i++ {}
            for j--; j >= a and array[j] > array[p]; j-- {}

            if i < j { 
                array[i].swap(array[j]);
            } else { 
                return i;
            }
        }
    }

    new classmethod mergeFW(array, a, m, b, p) {
        new int pLen = m - a;
        blockSwap(array, a, p, pLen);

        new int i = 0,
                j = m,
                k = a;

        for ; i < pLen && j < b; k++ {
            if array[p + i] <= array[j] {
                array[k].swap(array[p + i]);
                i++;
            } else {
                array[k].swap(array[j]);
                j++;
            }
        }

        for ; i < pLen; i++, k++ {
            array[k].swap(array[p + i]);
        }
    }

    new classmethod mergeBW(array, a, m, b, p) {
        new int pLen = b - m;
        blockSwap(array, m, p, pLen);

        new int i = pLen - 1,
                j = m - 1,
                k = b - 1;

        for ; i >= 0 && j >= a; k-- {
            if array[p + i] >= array[j] {
                array[k].swap(array[p + i]);
                i--;
            } else {
                array[k].swap(array[j]);
                j--;
            }
        }

        for ; i >= 0; i--, k-- {
            array[k].swap(array[p + i]);
        }
    }

    new classmethod smartMerge(array, a, m, b, p) {
        if m - a < b - m {
            this.mergeFW(array, a, m, b, p);
        } else {
            this.mergeBW(array, a, m, b, p);
        }
    }

    new classmethod mergeTo(array, a, m, b, p) {
        new int i = a,
                j = m;

        for ; i < m && j < b; p++ {
            if array[i] <= array[j] {
                array[p].swap(array[i]);
                i++;
            } else {
                array[p].swap(array[j]);
                j++;
            }
        }

        for ; i < m; p++, i++ {
            array[p].swap(array[i]);
        }

        for ; j < b; p++, j++ {
            array[p].swap(array[j]);
        }
    }

    new classmethod pingPongMerge(array, a, m1, m, m2, b, p) {
        new int p1   = p + m - a,
                pEnd = p + b - a;

        this.mergeTo(array, a, m1, m, p);
        this.mergeTo(array, m, m2, b, p1);
        this.mergeTo(array, p, p1, pEnd, a);
    }

    new classmethod mergeSort(array, a, b, p) {
        new int n = b - a,
                j = n;
        
        for ; (j + 3) // 4 >= ProportionExtendMergeSort.MIN_INSERT; j = (j + 3) // 4 {}

        for i = a; i < b; i += j {
            binaryInsertionSort(array, i, min(b, i + j));
        }

        for ; j < n; j *= 4 {
            for i = a; i + 2 * j < b; i += 4 * j {
                this.pingPongMerge(array, i, i + j, i + 2 * j, min(i + 3 * j, b), min(i + 4 * j, b), p);
            }

            if i + j < b {
                this.mergeBW(array, i, i + j, b, p);
            }
        }
    }

    new classmethod smartMergeSort(array, a, b, p, pb) {
        if b - a <= pb - p {
            this.mergeSort(array, a, b, p);
            return;
        }

        new int m = (a + b) // 2;

        this.mergeSort(array, a, m, p);
        this.mergeSort(array, m, b, p);
        this.mergeFW(array, a, m, b, p);
    }

    new classmethod sort(array, a, m, b) {
        new int n = b - a;

        if n < 4 * ProportionExtendMergeSort.MIN_INSERT {
            binaryInsertionSort(array, a, b);
            return;
        }

        if m - a <= n // 3 {
            new int t = (n + 2) // 3;
            this.smartMergeSort(array, m, b - t, b - t, b);
            this.smartMerge(array, a, m, b - t, b - t);
            m = b - t;
        }

        new int m1 = (a + m) // 2,
                m2 = this.partition(array, m, b, m1);

        new int i = m,
                j = m2;
        while i > m1 {
            i--;
            j--;
            array[i].swap(array[j]);
        }

        m = m2 - (m - m1);

        if m - m1 < b - m2 {
            this.mergeSort(array, m1, m, m2);
            this.smartMerge(array, a, m1, m, m2);
            this.sort(array, m + 1, m2, b);
        } else {
            this.mergeSort(array, m2, b, m1);
            this.smartMerge(array, m + 1, m2, b, m1);
            this.sort(array, a, m1, m);
        }
    }
}

@Sort(
    "Merge Sorts",
    "Proportion Extend Merge Sort",
    "Proportion Extend Merge"
);
new function proportionExtendMergeSortRun(array) {
    ProportionExtendMergeSort.sort(array, 0, 0, len(array));
}