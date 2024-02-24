use insertionSort, medianOf9, medianOfMedians, medianOfFewUnique;

new class AeosQuickSort {
    new method medianOfFewUnique(array, start, end) {
        new int i    = start,
                read = 0;

        while read == 0 {
            i++;
            read = compareValues(array[start], array[i]);
        }

        if read < 0 {
            return i;
        } else {
            return start;
        }
    }

    new method rotate(array, a, ll, rl) {
        new int j = a + ll,
                k = 0;
        for ; k < rl; k++, j++ {
            this.aux[k].write(array[j]);
        }

        k = a + ll;
        while k > a {
            j--; k--;
            array[j].write(array[k]);
        }

        j = 0;
        for ; j < rl; k++, j++ {
            array[k].write(this.aux[j]);
        }
    }

    new method partition(array, a, b, sqrt, piv) {
        new int smalls = 0,
                larges = 0,
                smallBlocks = 0,
                blockCnt    = 0;

        for i = a; i < b; i++ {
            if array[i] < piv {
                if larges != 0 {
                    array[a + blockCnt * sqrt + smalls].write(array[i]);
                }
                smalls++;
                if smalls == sqrt {
                    smalls = 0;
                    this.indices[blockCnt].write(smallBlocks);
                    blockCnt++;
                    smallBlocks++;
                }
            } else {
                this.aux[larges].write(array[i]);
                larges++;
                if larges == sqrt {
                    new int j = i;
                    for k = i - sqrt; k >= a + blockCnt * sqrt; j--, k-- {
                        array[j].write(array[k]);
                    }

                    for k = sqrt - 1; k >= 0; k--, j-- {
                        array[j].write(this.aux[k]);
                    }

                    larges = 0;
                    this.indices[blockCnt].write(-1);
                    blockCnt++;
                }
            }
        }

        for j = b - 1, k = larges - 1; k >= 0; k--, j-- {
            array[j].write(this.aux[k]);
        }

        if smallBlocks == blockCnt {
            return smallBlocks * sqrt + smalls;
        }

        if smallBlocks == 0 {
            if smalls != 0 {
                this.rotate(array, a, blockCnt * sqrt, smalls);
            }

            return smalls;
        }

        new int largeFinalPos = smallBlocks;
        for i in range(blockCnt) {
            if this.indices[i] == -1 {
                this.indices[i].write(largeFinalPos);
                largeFinalPos++;
            }
        }

        for i = 0; i < blockCnt && this.indices[i] == i; i++ {}
        while i < blockCnt {
            for j = a + i * sqrt, k = 0; k < sqrt; j++, k++ {
                this.aux[k].write(array[j]);
            }

            new int to      = this.indices[i].readInt(),
                    current = i,
                    next    = i;
            for ; this.indices[next] != current; next++ {}

            while next != to {
                for j = a + next * sqrt, k = a + current * sqrt;
                    j < a + (next + 1) * sqrt; j++, k++ 
                {
                    array[k].write(array[j]);
                }

                this.indices[current].write(current);
                current = next;
                next = i;
                for ; this.indices[next] != current; next++ {}
            }

            for j = a + next * sqrt, k = a + current * sqrt;
                j < a + (next + 1) * sqrt; j++, k++ 
            {
                array[k].write(array[j]);
            }

            this.indices[current].write(current);

            for j = 0, k = a + to * sqrt; j < sqrt; j++, k++ {
                array[k].write(this.aux[j]);
            }

            this.indices[to].write(to);

            do {
                i++;
            } while i < blockCnt && this.indices[i] == i;
        }

        if smalls != 0 {
            this.rotate(array, a + smallBlocks * sqrt, (blockCnt - smallBlocks) * sqrt, smalls);
        }

        return smallBlocks * sqrt + smalls;
    }

    new method sortRec(array, a, b, sqrt, badPartition) {
        while b - a >= 16 {
            new int pivPos;
            if badPartition == 0 {
                pivPos = medianOf9(array, a, b);
            } elif badPartition > 0 {
                new int len = b - a;
                if (len & 1) == 0 {
                    len -= 1;
                }
                pivPos = medianOfMedians(array, a, len);
            } else {
                pivPos = this.medianOfFewUnique(array, a, b);
                badPartition = ~badPartition;
            }

            new int piv = array[pivPos].readInt();
            pivPos = this.partition(array, a, b, sqrt, piv);

            new int newEnd   = a + pivPos,
                    newStart = newEnd;

            for ; newStart < b && array[newStart] == piv; newStart++ {}

            new int len1 = newEnd - a,
                    len2 = b - newStart;

            if len1 > len2 {
                badPartition += int(len1 > 8 * len2);
                this.sortRec(array, newStart, b, sqrt, badPartition);
                b = newEnd;
            } elif len2 > 8 * len1 {
                if len1 == 0 {
                    badPartition = ~badPartition;
                } else {
                    badPartition++;
                    this.sortRec(array, a, newEnd, sqrt, badPartition);
                    a = newStart;
                }
            } else {
                this.sortRec(array, a, newEnd, sqrt, badPartition);
                a = newStart;
            }
        }

        insertionSort(array, a, b);
    }

    new method sort(array, a, b) {
        if b - a < 16 {
            insertionSort(array, a, b);
            return;
        }

        new int lgSqrt = 2;
        for ; 1 << (lgSqrt << 1) < b - a; lgSqrt++ {}
        new int sqrt = 1 << lgSqrt;

        this.aux     = sortingVisualizer.createValueArray(sqrt);
        this.indices = sortingVisualizer.createValueArray((b - a) // sqrt);

        this.sortRec(array, a, b, sqrt, 0);
    }
}

@Sort(
    "Quick Sorts",
    "Aeos QuickSort",
    "Aeos Quick",
);
new function aeosQuicksortRun(array) {
    AeosQuickSort().sort(array, 0, len(array));
}