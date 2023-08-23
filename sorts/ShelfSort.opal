# https://github.com/bhauth/shelfsort

use arrayCopy;

new class ShelfSort {
    static: new int SMALL_SORT = 4;

    new classmethod smallSort(array, start) {
        new Value a = array[start    ].copy(),
                  b = array[start + 1].copy(),
                  c = array[start + 2].copy(),
                  d = array[start + 3].copy();
        
        new Value a2, b2, c2, d2;

        if b < a {
            a2 = b;
            b2 = a;
        } else {
            a2 = a;
            b2 = b;
        }

        if d < c {
            c2 = d;
            d2 = c;
        } else {
            c2 = c;
            d2 = d;
        }
                
        if b2 <= c2 {
            array[start    ].write(a2);
            array[start + 1].write(b2);
            array[start + 2].write(c2);
            array[start + 3].write(d2);
            return;
        }

        new Value b3, c3;

        if a2 <= c2 {
            b3 = c2;
            array[start].write(a2);
        } else {
            b3 = a2;
            array[start].write(c2);
        }

        if b2 <= d2 {
            c3 = b2;
            array[start + 3].write(d2);
        } else {
            c3 = d2;
            array[start + 3].write(b2);
        }

        if a2 <= d2 {
            array[start + 1].write(b3);
            array[start + 2].write(c3);
        } else {
            array[start + 1].write(c3);
            array[start + 2].write(b3);
        }
    }

    new classmethod mergePair(array, start1, start2, output, oStart, n) {
        static: new int i1 = n,
                        i2 = n, i;

        for i = n * 2 + 1; i1 >= 0 && i2 >= 0; i-- {
            new Value x = array[start1 + i1],
                      y = array[start2 + i2];

            if y < x {
                i1--;
                output[oStart + i].write(x);
            } else {
                i2--;
                output[oStart + i].write(y);
            }
        }

        if i1 >= 0 {
            arrayCopy(array, start1, output, oStart, i1 + 1);
        } else {
            arrayCopy(array, start2, output, oStart, i2 + 1);
        }
    }

    $macro shelfSortUnloadScratch
        arrayCopy(scratch, 0, output, outOffs, bSize);
        arrayCopy(scratch, bSize, array, start + nextClearBId * bSize, bSize);
        static: new int last = bCount1 + bCount2 - 1;
        this.indicesB[iStart + last - 1].write(clearBId);
        this.indicesB[iStart + last    ].write(nextClearBId); 
    $end

    new classmethod blockMerge(array, start, scratch, iStart, bCount1, bCount2, bSize) {
        static: new int ii1          = bCount1 - 1,
                        ii2          = bCount2 - 1,
                        bId1         = this.indicesA[iStart + ii1].readInt(),
                        bId2         = this.indicesA[iStart + bCount1 + ii2].readInt(),
                        p1           = start + bId1 * bSize,
                        p2           = start + (bCount1 + bId2) * bSize,
                        outBCount    = bCount1 + bCount2 - 2,
                        clearBId     = 0,
                        nextClearBId = 0,
                        i            = bSize * 2 - 1,
                        i1           = bSize - 1,
                        i2           = i1,
                        outOffs      = 0;

        new list output = scratch;

        new Value lastOfFirst = array[p1 + (this.indicesA[iStart].readInt() * bSize) + bSize - 1],
                  firstOfLast = array[start + (bCount1 + this.indicesA[iStart + bCount1].readInt()) * bSize];
        
        if lastOfFirst <= firstOfLast {
            for i in range(bCount1) {
                this.indicesB[iStart + i].write(this.indicesA[iStart + i]);
            }

            for i = bCount1; i < bCount1 + bCount2; i++ {
                this.indicesB[iStart + i].write(this.indicesA[iStart + i] + bCount1);
            }

            return;
        }

        while True {
            for ; i1 >= 0 && i2 >= 0 && i >= 0; i-- {
                new Value x = array[p1 + i1],
                          y = array[p2 + i2];

                if y < x {
                    output[outOffs + i].write(x);
                    i1--;
                } else {
                    output[outOffs + i].write(y);
                    i2--;
                }
            }

            if i < 0 {
                outOffs = start + nextClearBId * bSize;
                output  = array;

                outBCount--;
                this.indicesB[iStart + outBCount].write(nextClearBId);
                i = bSize - 1;
            }

            if i1 < 0 {
                nextClearBId = bId1;
                ii1--;
                if ii1 < 0 {
                    while True {
                        for ; i2 >= 0 && i >= 0; i2--, i-- {
                            output[outOffs + i].write(array[p2 + i2]);
                        }

                        if i < 0 {
                            clearBId = nextClearBId;
                            outOffs  = start + nextClearBId * bSize;
                            output   = array;

                            if i2 >= 0 {
                                this.indicesB[iStart + outBCount].write(nextClearBId);
                            }

                            outBCount--;
                            i = bSize - 1;
                        }

                        if i2 < 0 {
                            nextClearBId = bCount1 + bId2;
                            ii2--;
                            if ii2 < 0 {
                                $call shelfSortUnloadScratch
                                return;
                            }

                            bId2 = this.indicesA[iStart + bCount1 + ii2].readInt();
                            p2   = start + (bCount1 + bId2) * bSize;
                            i2   = bSize - 1; 
                        }
                    }
                }

                bId1 = this.indicesA[iStart + ii1].readInt();
                p1   = start + bId1 * bSize;
                i1   = bSize - 1;
            }

            if i2 < 0 {
                nextClearBId = bCount1 + bId2;
                ii2--;
                if ii2 < 0 {
                    while True {
                        for ; i1 >= 0 && i >= 0; i1--, i-- {
                            output[outOffs + i].write(array[p1 + i1]);
                        }

                        if i < 0 {
                            clearBId = nextClearBId;
                            outOffs  = start + nextClearBId * bSize;
                            output   = array;

                            if i1 >= 0 {
                                this.indicesB[iStart + outBCount].write(nextClearBId);
                            }

                            outBCount--;
                            i = bSize - 1;
                        }

                        if i1 < 0 {
                            nextClearBId = bId1;
                            ii1--;
                            if ii1 < 0 {
                                $call shelfSortUnloadScratch
                                return;
                            }

                            bId1 = this.indicesA[iStart + ii1].readInt();
                            p1   = start + bId1 * bSize;
                            i1   = bSize - 1;
                        }
                    }
                }

                bId2 = this.indicesA[iStart + bCount1 + ii2].readInt();
                p2   = start + (bCount1 + bId2) * bSize;
                i2   = bSize - 1;
            }
        }
    }

    new classmethod finalBlockSorting(array, start, scratch, blocks, bSize) {
        for b in range(blocks) {
            static: new int ix = this.indicesA[b].readInt();

            if ix != b {
                arrayCopy(array, start + b * bSize, scratch, 0, bSize);
                static: new int emptyBlock = b;

                while ix != b {
                    arrayCopy(array, start + ix * bSize, array, start + emptyBlock * bSize, bSize);
                    this.indicesA[emptyBlock].write(emptyBlock);
                    emptyBlock = ix;
                    ix = this.indicesA[ix].readInt();
                }

                arrayCopy(scratch, 0, array, start + emptyBlock * bSize, bSize);
                this.indicesA[emptyBlock].write(emptyBlock);
            }
        }
    }

    new classmethod __adaptAux(array) {
        return array + this.indicesA + this.indicesB;
    }

    new classmethod sort(array, start, size) {
        static: new int logSize = 0,
                              v = size;

        while v := v // 2 {
            logSize++;
        }

        static: new int scratchSize = 1 << (2 + (logSize + 1) // 2);

        for i = 0; i < size; i += ShelfSort.SMALL_SORT {
            this.smallSort(array, start + i);
        }

        new list scratch = sortingVisualizer.createValueArray(scratchSize);
        this.indicesA    = sortingVisualizer.createValueArray(scratchSize);
        this.indicesB    = sortingVisualizer.createValueArray(scratchSize);
        sortingVisualizer.setAux(scratch);
        sortingVisualizer.setAdaptAux(this.__adaptAux);

        static: new int sortedZoneSize = ShelfSort.SMALL_SORT, runLen, i;
        for ; sortedZoneSize < scratchSize // 2; sortedZoneSize *= 2 {
            runLen = sortedZoneSize;
            sortedZoneSize *= 2;

            for i = 0; i < size; i += sortedZoneSize * 2 {
                static {
                    new int p1 = start + i,
                            p2 = start + i + runLen,
                            p3 = p2 + runLen,
                            p4 = p3 + runLen;

                    new bint less1 = array[p2 - 1] <= array[p2],
                             less2 = array[p4 - 1] <= array[p4];
                } 

                if !less1 {
                    this.mergePair(array, p1, p2, scratch, 0, runLen - 1);
                }

                if !less2 {
                    this.mergePair(array, p3, p4, scratch, sortedZoneSize, runLen - 1);
                }

                if less1 || less2 {
                    if !less1 {
                        arrayCopy(array, p3, scratch, sortedZoneSize, sortedZoneSize);
                    } elif !less2 {
                        arrayCopy(array, p1, scratch, 0, sortedZoneSize);
                    } elif array[p1 + sortedZoneSize - 1] <= array[p3] {
                        continue;
                    } else {
                        arrayCopy(array, p1, scratch, 0, sortedZoneSize * 2);
                    }
                }

                this.mergePair(scratch, 0, sortedZoneSize, array, p1, sortedZoneSize - 1);
            }
        }

        static: new int bSize = scratchSize // 2,
                        total = size // bSize,
                        blocksPerRun = sortedZoneSize // bSize, j, blocks1, blocks2;

        for i = 0; i < total; i += blocksPerRun {
            for j in range(blocksPerRun) {
                this.indicesA[i + j].write(j);
            }
        }

        while sortedZoneSize <= (size // 2) {
            runLen  = sortedZoneSize;
            blocks1 = sortedZoneSize // bSize;
            blocks2 = blocks1;
            sortedZoneSize *= 2;

            for i = 0; i < total; i += blocks1 + blocks2 {
                this.blockMerge(array, start + i * bSize, scratch, i, blocks1, blocks2, bSize);
            }

            for i in range(len(this.indicesA)) {
                new Value tmp = this.indicesA[i].copy();
                this.indicesA[i].write(this.indicesB[i]);
                this.indicesB[i].write(tmp);
            }
        }

        this.finalBlockSorting(array, start, scratch, sortedZoneSize // bSize, bSize);
    }
}

@Sort(
    "Block Merge Sorts",
    "Shelf Sort",
    "Shelf Sort"
);
new function shelfSortRun(array) {
    ShelfSort.sort(array, 0, len(array));
}