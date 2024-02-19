use binaryInsertionSort;

new class TimSort {
    new int MIN_MERGE  = 32,
            MIN_GALLOP = 7,
            INITIAL_TMP_STORAGE_LENGTH = 256;

    new method __adaptAux(array) {
        return array + this.runBase + this.runLen;
    }

    new method __adaptIdx(idx, aux) {
        if aux is this.runBase {
            return idx + len(this.tmp);
        } elif aux is this.runLen {
            return idx + len(this.tmp) + len(this.runBase);
        }

        return idx;
    }

    new method __init__(a, length) {
        this.a = a;
        this.len = length;

        this.tmp = sortingVisualizer.createValueArray((this.len >> 1)
                                                   if (this.len < 2 * TimSort.INITIAL_TMP_STORAGE_LENGTH)
                                                   else TimSort.INITIAL_TMP_STORAGE_LENGTH);

        this.minGallop = TimSort.MIN_GALLOP;
        this.stackSize = 0;

        new int stackLen = 5 if (this.len < 120)
                             else (10 if (this.len < 1542)
                             else (19 if (this.len < 119151)
                             else 40));

        this.runBase = sortingVisualizer.createValueArray(stackLen);
        this.runLen  = sortingVisualizer.createValueArray(stackLen);

        sortingVisualizer.setAdaptAux(this.__adaptAux, this.__adaptIdx);
        sortingVisualizer.setAux(this.tmp);
    }

    new method sort(a, lo, hi) {
        new int nRemaining = hi - lo;

        if nRemaining < TimSort.MIN_MERGE {
            new int initRunLen;
            initRunLen = this.countRunAndMakeAscending(a, lo, hi);
            this.binarySort(a, lo, hi, lo + initRunLen);
            return;
        }

        new int minRun = TimSort.minRunLength(nRemaining);

        do nRemaining != 0 {
            new int runLen;
            runLen = this.countRunAndMakeAscending(a, lo, hi);

            if runLen < minRun {
                new int force = nRemaining if (nRemaining <= minRun) else minRun;

                this.binarySort(a, lo, lo + force, lo + runLen);
                runLen = force;
            }
            this.pushRun(lo, runLen);
            this.mergeCollapse();

            lo += runLen;
            nRemaining -= runLen;
        }

        this.mergeForceCollapse();
    }

    new method binarySort(a, lo, hi, start) {
        binaryInsertionSort(a, min(lo, start), hi);
    }

    new method countRunAndMakeAscending(a, lo, hi) {
        new int runHi = lo + 1;

        if runHi == hi {
            return 1;
        }

        if a[runHi] < a[lo] {
            runHi++;
            for ; runHi < hi and a[runHi] < a[runHi - 1]; runHi++ {}
            this.reverseRange(a, lo, runHi);
        } else {
            runHi++;
            for ; runHi < hi and a[runHi] >= a[runHi - 1]; runHi++ {}
        }

        return runHi - lo;
    }

    new method reverseRange(a, lo, hi) {
        reverse(a, lo, hi);
    }

    new classmethod minRunLength(n) {
        new int r = 0;
        while n >= TimSort.MIN_MERGE {
            r |= (n & 1);
            n >>= 1;
        }
        return n + r;
    }

    new method pushRun(runBase, runLen) {
        this.runBase[this.stackSize].write(runBase);
        this.runLen[this.stackSize].write(runLen);
        this.stackSize++;
    }

    new method mergeCollapse() {
        while this.stackSize > 1 {
            new int n = this.stackSize - 2;

            if (n >= 1 and this.runLen[n - 1] <= this.runLen[n] + this.runLen[n + 1]) or
               (n >= 2 and this.runLen[n - 2] <= this.runLen[n] + this.runLen[n - 1]) {

                if this.runLen[n - 1] < this.runLen[n + 1] {
                    n--;
                }
            } elif this.runLen[n] > this.runLen[n + 1] {
                break;
            }
            this.mergeAt(n);
        }
    }

    new method mergeForceCollapse() {
        while this.stackSize > 1 {
            new int n = this.stackSize - 2;

            if n > 0 and this.runLen[n - 1] < this.runLen[n + 1] {
                n--;
            }
            this.mergeAt(n);
        }
    }

    new method mergeAt(i) {
        new int base1 = this.runBase[i].readInt(),
                len1  = this.runLen[i].readInt(),
                base2 = this.runBase[i + 1].readInt(),
                len2  = this.runLen[i + 1].readInt();

        this.runLen[i].write(len1 + len2);

        if i == this.stackSize - 3 {
            this.runBase[i + 1].write(this.runBase[i + 2]);
            this.runLen[i + 1].write(this.runLen[i + 2]);
        }
        this.stackSize--;

        new int k;
        k = this.gallopRight(this.a[base2], this.a, base1, len1, 0);
        base1 += k;
        len1 -= k;

        if len1 == 0 {
            return;
        }

        len2 = this.gallopLeft(this.a[base1 + len1 - 1], this.a, base2, len2, len2 - 1);
        if len2 == 0 {
            return;
        }

        if len1 <= len2 {
            this.mergeLo(base1, len1, base2, len2);
        } else {
            this.mergeHi(base1, len1, base2, len2);
        }
    }

    new method gallopLeft(key, a, base, len, hint) {
        new int lastOfs = 0,
                ofs     = 1;

        if key > a[base + hint] {
            new int maxOfs = len - hint;

            while ofs < maxOfs and key > a[base + hint + ofs] {
                lastOfs = ofs;
                ofs = (ofs * 2) + 1;
                if ofs <= 0 {
                    ofs = maxOfs;
                }
            }

            if ofs > maxOfs {
                ofs = maxOfs;
            }

            lastOfs += hint;
            ofs     += hint;
        } else {
            new int maxOfs = hint + 1;

            while ofs < maxOfs and key <= a[base + hint - ofs] {
                lastOfs = ofs;
                ofs = (ofs * 2) + 1;
                if ofs <= 0 {
                    ofs = maxOfs;
                }
            }

            if ofs > maxOfs {
                ofs = maxOfs;
            }

            new int tmp = lastOfs;
            lastOfs = hint - ofs;
            ofs     = hint - tmp;
        }

        lastOfs++;
        while lastOfs < ofs {
            new int m = lastOfs + ((ofs - lastOfs) >> 1);

            if key > a[base + m] {
                lastOfs = m + 1;
            } else {
                ofs = m;
            }
        }
        return ofs;
    }

    new method gallopRight(key, a, base, len, hint) {
        new int ofs     = 1,
                lastOfs = 0;

        if key < a[base + hint] {
            new int maxOfs = hint + 1;

            while ofs < maxOfs and key < a[base + hint - ofs] {
                lastOfs = ofs;
                ofs = (ofs * 2) + 1;
                if ofs <= 0 {
                    ofs = maxOfs;
                }
            }

            if ofs > maxOfs {
                ofs = maxOfs;
            }

            new int tmp = lastOfs;
            lastOfs = hint - ofs;
            ofs     = hint - tmp;
        } else {
            new int maxOfs = len - hint;

            while ofs < maxOfs and key >= a[base + hint + ofs] {
                lastOfs = ofs;
                ofs = (ofs * 2) + 1;
                if ofs <= 0 {
                    ofs = maxOfs;
                }
            }

            if ofs > maxOfs {
                ofs = maxOfs;
            }

            lastOfs += hint;
            ofs     += hint;
        }

        lastOfs++;
        while lastOfs < ofs {
            new int m = lastOfs + ((ofs - lastOfs) >> 1);

            if key < a[base + m] {
                ofs = m;
            } else {
                lastOfs = m + 1;
            }
        }
        return ofs;
    }

    new method mergeLo(base1, len1, base2, len2) {
        new list a   = this.a,
                 tmp = this.ensureCapacity(len1);

        arrayCopy(a, base1, tmp, 0, len1);

        new int cursor1 = 0,
                cursor2 = base2,
                dest    = base1;

        a[dest].write(a[cursor2]);
        dest++;
        cursor2++;

        len2--;
        if len2 == 0 {
            arrayCopy(tmp, cursor1, a, dest, len1);
            return;
        }

        if len1 == 1 {
            arrayCopy(a, cursor2, a, dest, len2);
            a[dest + len2].write(tmp[cursor1]);
            return;
        }

        new int minGallop = this.minGallop;

        new bool breakOuter = False;

        while True {
            new int count1 = 0,
                    count2 = 0;

            do (count1 | count2) < minGallop {
                if a[cursor2] < tmp[cursor1] {
                    a[dest].write(a[cursor2]);
                    cursor2++;
                    dest++;
                    count2++;
                    count1 = 0;
                    len2--;
                    if len2 == 0 {
                        breakOuter = True;
                        break;
                    }
                } else {
                    a[dest].write(tmp[cursor1]);
                    dest++;
                    cursor1++;
                    count1++;
                    count2 = 0;
                    len1--;
                    if len1 == 1 {
                        breakOuter = True;
                        break;
                    }
                }
            }

            if breakOuter {
                break;
            }

            do count1 >= TimSort.MIN_GALLOP | count2 >= TimSort.MIN_GALLOP {
                count1 = this.gallopRight(a[cursor2], tmp, cursor1, len1, 0);
                if count1 != 0 {
                    arrayCopy(tmp, cursor1, a, dest, count1);
                    dest    += count1;
                    cursor1 += count1;
                    len1    -= count1;
                    if len1 <= 1 {
                        breakOuter = True;
                        break;
                    }
                }
                a[dest].write(a[cursor2]);
                dest++;
                cursor2++;
                len2--;
                if len2 == 0 {
                    breakOuter = True;
                    break;
                }

                count2 = this.gallopLeft(tmp[cursor1], a, cursor2, len2, 0);
                if count2 != 0 {
                    arrayCopy(a, cursor2, a, dest, count2);
                    dest    += count2;
                    cursor2 += count2;
                    len2    -= count2;
                    if len2 == 0 {
                        breakOuter = True;
                        break;
                    }
                }
                a[dest].write(tmp[cursor1]);
                dest++;
                cursor1++;
                len1--;
                if len1 == 1 {
                    breakOuter = True;
                    break;
                }
                minGallop--;
            }

            if breakOuter {
                break;
            }

            if minGallop < 0 {
                minGallop = 0;
            }
            minGallop += 2;
        }
        this.minGallop = 1 if (minGallop < 1) else minGallop;

        if len1 == 1 {
            arrayCopy(a, cursor2, a, dest, len2);
            a[dest + len2].write(tmp[cursor1]);
        } elif (len1 == 0) {
            IO.out("Comparison method violates its general contract!\n");
            return;
        } else {
            arrayCopy(tmp, cursor1, a, dest, len1);
        }
    }

    new method mergeHi(base1, len1, base2, len2) {
        new list a   = this.a,
                 tmp = this.ensureCapacity(len2);

        arrayCopy(a, base2, tmp, 0, len2);

        new int cursor1 = base1 + len1 - 1,
                cursor2 = len2 - 1,
                dest    = base2 + len2 - 1;

        a[dest].write(a[cursor1]);
        dest--;
        cursor1--;
        len1--;
        if len1 == 0 {
            reverseArrayCopy(tmp, 0, a, dest - (len2 - 1), len2);
            return;
        }
        if len2 == 1 {
            dest    -= len1;
            cursor1 -= len1;

            reverseArrayCopy(a, cursor1 + 1, a, dest + 1, len1);
            a[dest].write(tmp[cursor2]);
            return;
        }

        new int minGallop = this.minGallop;

        new bool breakOuter = False;

        while True {
            new int count1 = 0,
                    count2 = 0;

            do (count1 | count2) < minGallop {
                if tmp[cursor2] < a[cursor1] {
                    a[dest].write(a[cursor1]);
                    dest--;
                    cursor1--;
                    count1++;
                    count2 = 0;
                    len1--;
                    if len1 == 0 {
                        breakOuter = True;
                        break;
                    }
                } else {
                    a[dest].write(tmp[cursor2]);
                    dest--;
                    cursor2--;
                    count2++;
                    count1 = 0;
                    len2--;
                    if len2 == 1 {
                        breakOuter = True;
                        break;
                    }
                }
            }

            if breakOuter {
                break;
            }

            do count1 >= TimSort.MIN_GALLOP | count2 >= TimSort.MIN_GALLOP {
                count1 = len1 - this.gallopRight(tmp[cursor2], a, base1, len1, len1 - 1);
                if count1 != 0 {
                    dest    -= count1;
                    cursor1 -= count1;
                    len1    -= count1;
                    reverseArrayCopy(a, cursor1 + 1, a, dest + 1, count1);
                    if len1 == 0 {
                        breakOuter = True;
                        break;
                    }
                }
                a[dest].write(tmp[cursor2]);
                dest--;
                cursor2--;
                len2--;
                if len2 == 1 {
                    breakOuter = True;
                    break;
                }

                count2 = len2 - this.gallopLeft(a[cursor1], tmp, 0, len2, len2 - 1);
                if count2 != 0 {
                    dest    -= count2;
                    cursor2 -= count2;
                    len2    -= count2;
                    reverseArrayCopy(tmp, cursor2 + 1, a, dest + 1, count2);
                    if len2 <= 1 {
                        breakOuter = True;
                        break;
                    }
                }
                a[dest].write(a[cursor1]);
                dest--;
                cursor1--;
                len1--;
                if len1 == 0 {
                    breakOuter = True;
                    break;
                }
                minGallop--;
            }

            if breakOuter {
                break;
            }

            if minGallop < 0 {
                minGallop = 0;
            }
            minGallop += 2;
        }
        this.minGallop = 1 if (minGallop < 1) else minGallop;

        if len2 == 1 {
            dest    -= len1;
            cursor1 -= len1;
            reverseArrayCopy(a, cursor1 + 1, a, dest + 1, len1);
            a[dest].write(tmp[cursor2]);
        } elif (len2 == 0) {
            IO.out("Comparison method violates its general contract!\n");
            return;
        } else {
            reverseArrayCopy(tmp, 0, a, dest - (len2 - 1), len2);
        }
    }

    new method ensureCapacity(minCapacity) {
        if len(this.tmp) < minCapacity {
            new int newSize = minCapacity;

            newSize |= newSize >> 1;
            newSize |= newSize >> 2;
            newSize |= newSize >> 4;
            newSize |= newSize >> 8;
            newSize |= newSize >> 16;
            newSize++;

            if newSize < 0 {
                newSize = minCapacity;
            } else {
                newSize = min(newSize, this.len >> 1);
            }

            new list newArray = sortingVisualizer.createValueArray(newSize);
            this.tmp = newArray;
            sortingVisualizer.setAux(this.tmp);
        }
        return this.tmp;
    }
}

@Sort(
    "Merge Sorts",
    "Tim Sort",
    "Tim Sort",
    usesDynamicAux = True
);
new function timSortRun(array) {
    TimSort(array, len(array)).sort(array, 0, len(array));
}