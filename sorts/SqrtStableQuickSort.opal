use binaryInsertionSort;
use grailSortGivenAux;

new class SqrtStableQuickSort {
    new int SMALL_SORT = 32;

    new classmethod buildBlocks(array, a, b, p) {
        this.zeroPtr = 0;
        this.onePtr  = 0;

        new int last    = a,
                zeroKey = 0,
                oneKey  = -1,
                keyPtr  = 0;

        for i = a; i < b; i++ {
            if array[i] <= p {
                this.zeros[this.zeroPtr].write(array[i]);
                this.zeroPtr++;

                if this.zeroPtr == this.bufLen {
                    arrayCopy(this.zeros, 0, array, last, this.bufLen);
                    this.zeroPtr = 0;
                    last += this.bufLen;

                    this.keys[keyPtr].write(zeroKey);
                    keyPtr++;
                    zeroKey++;
                }
            } else {
                this.ones[this.onePtr].write(array[i]);
                this.onePtr++;

                if this.onePtr == this.bufLen {
                    arrayCopy(this.ones, 0, array, last, this.bufLen);
                    this.onePtr = 0;
                    last += this.bufLen;

                    this.keys[keyPtr].write(oneKey);
                    keyPtr++;
                    oneKey--;
                }
            }
        }

        keyPtr--;

        new int maxKey = 0,
                r      = keyPtr;
        for i = keyPtr; i >= 0; i-- {
            if this.keys[i] >= 0 {
                maxKey = this.keys[i].readInt();
                break;
            }
        }

        for ; keyPtr >= 0; keyPtr-- {
            if this.keys[keyPtr] < 0 {
                this.keys[keyPtr].write(maxKey - this.keys[keyPtr].getInt());
            }
        }

        return last, a + (zeroKey * this.bufLen), r;
    }

    new classmethod sortBlocks(array, a, k) {
        new int c;

        for i = 0; i < k; i++ {
            c = 0;
            for ; this.keys[i] != i and c < k; c++ {
                blockSwap(array, a + (i * this.bufLen), a + (this.keys[i].getInt() * this.bufLen), this.bufLen);
                this.keys[i].swap(this.keys[this.keys[i].getInt()]);
            }

            if c >= k - 1 {
                break;
            }
        }
    }

    new classmethod oopPartition(array, a, b, p) {
        this.zeroPtr = 0;
        this.onePtr  = 0;

        for i = a; i < b; i++ {
            if array[i] <= p {
                this.zeros[this.zeroPtr].write(array[i]);
                this.zeroPtr++;
            } else {
                this.ones[this.onePtr].write(array[i]);
                this.onePtr++;
            }
        }

        this.onePtr--;
        for i = b - 1; this.onePtr >= 0; this.onePtr--, i-- {
            array[i].write(this.ones[this.onePtr]);
        }

        new int r = this.zeroPtr;
        this.zeroPtr--;
        for ; this.zeroPtr >= 0; this.zeroPtr--, i-- {
            array[i].write(this.zeros[this.zeroPtr]);
        }

        return a + r;
    }

    new classmethod partition(array, a, b, p) {
        if b - a <= this.bufLen {
            return this.oopPartition(array, a, b, p);
        } elif b - a <= this.bufLen * 2 {
            this.zeroPtr = 0;
            this.onePtr  = 0;

            for i = a; i < b; i++ {
                if array[i] <= p {
                    this.zeros[this.zeroPtr].write(array[i]);
                    this.zeroPtr++;
                } else {
                    this.ones[this.onePtr].write(array[i]);
                    this.onePtr++;
                }

                if this.zeroPtr == this.bufLen or this.onePtr == this.bufLen {
                    new int p0   = a + this.zeroPtr,
                            ones = this.onePtr,
                            m    = p0 + ones, p1;

                    arrayCopy(this.zeros, 0, array,  a, this.zeroPtr);
                    arrayCopy( this.ones, 0, array, p0,         ones);

                    p1 = this.oopPartition(array, m, b, p);

                    this.rotate(array, p0, m, p1);

                    return p1 - ones;
                }
            }
        }

        new int last, m, k;
        last, m, k = this.buildBlocks(array, a, b, p);

        this.sortBlocks(array, a, k);

        for i = 0; i < this.onePtr; i++, last++ {
            array[last].write(this.ones[i]);
        }

        new int lz = this.zeroPtr;
        if lz > 0 {
            last--;
            for i = b - 1; last >= m; i--, last-- {
                array[i].write(array[last]);
            }

            lz--;
            for ; lz >= 0; lz--, i-- {
                array[i].write(this.zeros[lz]);
            }
        }

        return m + this.zeroPtr;
    }

    new classmethod getPivot(array, a, b) {
        new int sqrt = pow2Sqrt(b - a),
                g    = (b - a) // sqrt;

        for i = a, j = 0; i < b and j < sqrt; i += g, j++ {
            this.zeros[j].write(array[i]);
        }

        binaryInsertionSort(this.zeros, 0, sqrt);

        return this.zeros[sqrt // 2].copy();
    }

    new classmethod quickSorter(array, a, b, d) {
        while b - a > this.SMALL_SORT {
            if checkSorted(array, a, b) {
                return;
            }

            if d == 0 {
                grailSortGivenAux(array, a, b - a, this.zeros, False);
                return;
            }

            new int p, l, r;

            p = this.partition(array, a, b, this.getPivot(array, a, b));

            l = p - a;
            r = b - p;

            if (l == 0 or r == 0) or (l / r >= 64 or r / l >= 64) {
                grailSortGivenAux(array, a, b - a, this.zeros, False);
                return;
            }

            d--;
            this.quickSorter(array, a, p, d);
            a = p;
        }
        binaryInsertionSort(array, a, b);
    }

    new classmethod sort(array, a, b) {
        new int sqrt = pow2Sqrt(b - a);

        this.bufLen = sqrt;

        this.zeros = sortingVisualizer.createValueArray(sqrt);
        this.ones  = sortingVisualizer.createValueArray(sqrt);
        this.keys  = sortingVisualizer.createValueArray(((b - a - 1) // sqrt) + 1);

        this.quickSorter(array, a, b, 2 * math.log2(b - a));
    }
}

main {
    SqrtStableQuickSort.rotate = sortingVisualizer.getRotation(
        name = "Helium"
    ).indexedFn;
}

@Sort(
    "Quick Sorts",
    "Sqrt Stable QuickSort",
    "Sqrt Stable Quick"
);
new function sqrtStableQuickSortRun(array) {
    new dynamic rotate = sortingVisualizer.getRotation(
        id = sortingVisualizer.getUserSelection(
            [r.name for r in sortingVisualizer.rotations],
            "Select rotation algorithm (default: Helium)"
        )
    ).indexedFn;
    
    new dynamic oldRotate = SqrtStableQuickSort.rotate;
    SqrtStableQuickSort.rotate = rotate;
    SqrtStableQuickSort.sort(array, 0, len(array));
    SqrtStableQuickSort.rotate = oldRotate;
}