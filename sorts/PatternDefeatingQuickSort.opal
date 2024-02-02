use MaxHeapSort;

namespace PDQSort {
    new int insertSortThreshold    = 24,
            nintherThreshold       = 128,
            partialInsertSortLimit = 8,
            blockSize              = 64,
            cachelineSize          = 64;

    new classmethod lessThan(a, b) {
        sortingVisualizer.comparisons++;
        sortingVisualizer.multiHighlight([a.idx, b.idx]);
        return 1 & ((1231 if a.getInt() < b.getInt() else 1237) >> 1);
    }

    new classmethod log(n) {
        n >>= 1;
        for log = 0; n != 0; log++, n >>= 1 {}
        return log;
    }

    new classmethod insertSort(array, begin, end) {
        if begin == end {
            return;
        }

        for i = begin + 1; i < end; i++ {
            new Value key;
            new int   idx;

            if array[i] < array[i - 1] {
                key, idx = array[i].readNoMark();

                for j = i - 1; array[j] > key and j >= begin; j-- {
                    array[j + 1].write(array[j]);
                }
                array[j + 1].writeRestoreIdx(key, idx);
            }
        }
    }

    new classmethod unguardInsertSort(array, begin, end) {
        if begin == end {
            return;
        }

        for i = begin + 1; i < end; i++ {
            new Value key;
            new int   idx;

            if array[i] < array[i - 1] {
                key, idx = array[i].readNoMark();

                for j = i - 1; array[j] > key; j-- {
                    array[j + 1].write(array[j]);
                }
                array[j + 1].writeRestoreIdx(key, idx);
            }
        }
    }

    new classmethod partialInsertSort(array, begin, end) {
        if begin == end {
            return True;
        }

        for i = begin + 1, limit = 0; i < end; i++ {
            if limit > this.partialInsertSortLimit {
                return False;
            }
            new Value key;
            new int j = i - 1, idx;

            if array[i] < array[i - 1] {
                key, idx = array[i].readNoMark();

                for ; array[j] > key and j >= begin; j-- {
                    array[j + 1].write(array[j]);
                }

                array[j + 1].writeRestoreIdx(key, idx);
                limit += i - j + 1;
            }
        }
        return True;
    }

    new classmethod sortTwo(array, a, b) {
        if array[b] < array[a] {
            array[a].swap(array[b]);
        }
    }

    new classmethod sortThree(array, a, b, c) {
        this.sortTwo(array, a, b);
        this.sortTwo(array, b, c);
        this.sortTwo(array, a, b);
    }

    new classmethod swapOffsets(
        array, first, last, leftOffsets, leftOffsetsPos, 
        rightOffsets, rightOffsetsPos, num, useSwaps
    ) {
        if useSwaps {
            for i in range(num) {
                array[first + leftOffsets[leftOffsetsPos + i].readInt()].swap(
                    array[last - rightOffsets[rightOffsetsPos + i].readInt()]
                );
            }
        } elif num > 0 {
            new int left  = first +  leftOffsets[ leftOffsetsPos].readInt(),
                    right = last  - rightOffsets[rightOffsetsPos].readInt();
            new Value tmp = array[left].copy();
            array[left].write(array[right]);
            for i = 1; i < num; i++ {
                left  = first +  leftOffsets[ leftOffsetsPos + i].readInt();
                array[right].write(array[left]);
                right = last  - rightOffsets[rightOffsetsPos + i].readInt();
                array[left].write(array[right]);
            }
            array[right].write(tmp);
        }
    }

    new classmethod partRightBranchless(array, begin, end, leftOffsets, rightOffsets) {
        new Value pivot = array[begin].copy();
        new int first = begin,
                last  = end;

        do this.lessThan(array[first], pivot) == 1 {
            first++;
        }

        if first - 1 == begin {
            while first < last {
                last--;
                if this.lessThan(array[last], pivot) != 0 {
                    break;
                }
            }
        } else {
            do this.lessThan(array[last], pivot) == 0 {
                last--;
            }
        }

        new bool alreadyParted = first >= last;
        if !alreadyParted {
            array[first].swap(array[last]);
            first++;
        }

        new int leftNum    = 0, 
                rightNum   = 0, 
                leftStart  = 0, 
                rightStart = 0;

        while last - first > 2 * this.blockSize {
            if leftNum == 0 {
                leftStart = 0;
                new int it = first;
                for i = 0; i < this.blockSize; {
                    repeat 8 {
                        leftOffsets[leftNum].write(i);
                        i++;
                        leftNum += abs(this.lessThan(array[it], pivot) - 1);
                        it++;
                    }
                }
            }

            if rightNum == 0 {
                rightStart = 0;
                new int it = last;
                for i = 0; i < this.blockSize; {
                    repeat 8 {
                        i++;
                        rightOffsets[rightNum].write(i);
                        it--;
                        rightNum += this.lessThan(array[it], pivot);
                    }
                }
            }

            new int num = min(leftNum, rightNum);
            this.swapOffsets(
                array, first, last, leftOffsets, leftStart, 
                rightOffsets, rightStart, num, leftNum == rightNum
            );
            leftNum    -= num;
            rightNum   -= num;
            leftStart  += num;
            rightStart += num;

            if leftNum == 0 {
                first += this.blockSize;
            }

            if rightNum == 0 {
                last -= this.blockSize;
            }
        }

        new int leftSize  = 0,
                rightSize = 0,
                unknownLeft = last - first - (this.blockSize if (rightNum != 0 || leftNum != 0) else 0);
        
        if rightNum != 0 {
            leftSize  = unknownLeft;
            rightSize = this.blockSize;
        } elif leftNum != 0 {
            leftSize  = this.blockSize;
            rightSize = unknownLeft;
        } else {
            leftSize  = unknownLeft // 2;
            rightSize = unknownLeft - leftSize; 
        }

        if unknownLeft != 0 && leftNum == 0 {
            leftStart = 0;
            new int it = first;
            for i = 0; i < leftSize; {
                leftOffsets[leftNum].write(i);
                i++;
                leftNum += abs(this.lessThan(array[it], pivot) - 1);
                it++;
            }
        }

        if unknownLeft != 0 && rightNum == 0 {
            rightStart = 0;
            new int it = last;
            for i = 0; i < rightSize; {
                i++;
                rightOffsets[rightNum].write(i);
                it--;
                rightNum += this.lessThan(array[it], pivot);
            }
        }

        new int num = min(leftNum, rightNum);
        this.swapOffsets(
            array, first, last, leftOffsets, leftStart,
            rightOffsets, rightStart, num, leftNum == rightNum
        );
        leftNum    -= num;
        rightNum   -= num;
        leftStart  += num;
        rightStart += num;
        
        if leftNum == 0 {
            first += leftSize;
        }

        if rightNum == 0 {
            last -= rightSize;
        }

        new int leftOffsetsPos  = 0,
                rightOffsetsPos = 0;

        if leftNum != 0 {
            leftOffsetsPos += leftStart;
            while leftNum != 0 {
                leftNum--;
                last--;
                array[first + leftOffsets[leftOffsetsPos + leftNum].readInt()].swap(array[last]);
            }
            leftNum--;
            first = last;
        }

        if rightNum != 0 {
            rightOffsetsPos += rightStart;
            while rightNum != 0 {
                rightNum--;
                array[last - rightOffsets[rightOffsetsPos + rightNum].readInt()].swap(array[first]);
                first++;
            }
            rightNum--;
            last = first;
        }

        new int pivotPos = first - 1;
        array[begin].write(array[pivotPos]);
        array[pivotPos].write(pivot);

        return pivotPos, alreadyParted;
    }

    new classmethod partRight(array, begin, end) {
        new Value pivot = array[begin].copy();
        new int first = begin,
                last  = end;

        do array[first] < pivot {
            first++;
        }

        if first - 1 == begin {
            do not array[last] < pivot {
                if not (first < last) {
                    break;
                }
                last--;
            }
        } else {
            do not array[last] < pivot {
                last--;
            }
        }

        new bool alreadyParted = first >= last;

        while first < last {
            array[first].swap(array[last]);

            first++;
            for ; array[first] < pivot; first++ {}

            last--;
            for ; not array[last] < pivot; last-- {}
        }

        new int pivotPos = first - 1;
        array[begin].write(array[pivotPos]);
        array[pivotPos].write(pivot);

        return pivotPos, alreadyParted;
    }

    new classmethod partLeft(array, begin, end) {
        new Value pivot = array[begin].copy();
        new int first = begin,
                last  = end;

        do pivot < array[last] {
            last--;
        }

        if last + 1 == end {
            do not pivot < array[first] {
                if not (first < last) {
                    break;
                }
                first++;
            }
        } else {
            do not pivot < array[first] {
                first++;
            }
        }

        while first < last {
            array[first].swap(array[last]);

            last--;
            for ; pivot < array[last]; last-- {}

            first++;
            for ; not pivot < array[first]; first++ {}
        }

        new int pivotPos = last;
        array[begin].write(array[pivotPos]);
        array[pivotPos].write(pivot);

        return pivotPos;
    }

    new classmethod loop(array, begin, end, badAllowed, branchless, leftOffsets = None, rightOffsets = None) {
        new bool leftmost = True;

        while True {
            new int size = end - begin;

            if size < this.insertSortThreshold {
                if leftmost {
                    this.insertSort(array, begin, end);
                } else {
                    this.unguardInsertSort(array, begin, end);
                }
                return;
            }

            new int halfSize = size // 2;

            if size > this.nintherThreshold {
                this.sortThree(array, begin, begin + halfSize, end - 1);
                this.sortThree(array, begin + 1, begin + (halfSize - 1), end - 2);
                this.sortThree(array, begin + 2, begin + (halfSize + 1), end - 3);
                this.sortThree(array, begin + (halfSize - 1), begin + halfSize, begin + (halfSize + 1));
                array[begin].swap(array[begin + halfSize]);
            } else {
                this.sortThree(array, begin, begin + halfSize, end - 1);
            }

            if (not leftmost) and (not array[begin - 1] < array[begin]) {
                begin = this.partLeft(array, begin, end) + 1;
                continue;
            }

            new int pivotPos;
            new bool alreadyParted;

            if branchless {
                pivotPos, alreadyParted = this.partRightBranchless(array, begin, end, leftOffsets, rightOffsets);
            } else {
                pivotPos, alreadyParted = this.partRight(array, begin, end);
            }

            new int leftSize  = pivotPos - begin,
                    rightSize = end - (pivotPos + 1);
            new bool highUnbalance = leftSize < size / 8 or rightSize < size / 8;

            if highUnbalance {
                badAllowed--;
                if badAllowed == 0 {
                    MaxHeapSort.sort(array, begin, end);
                    return;
                }

                if leftSize >= this.insertSortThreshold {
                    sortingVisualizer.delay(1040);
                    array[begin].swap(array[begin + leftSize // 4]);
                    sortingVisualizer.delay(1040);
                    array[pivotPos - 1].swap(array[pivotPos - leftSize // 4]);

                    if leftSize > this.nintherThreshold {
                        sortingVisualizer.delay(1040);
                        array[begin + 1].swap(array[begin + (leftSize // 4 + 1)]);
                        sortingVisualizer.delay(1040);
                        array[begin + 2].swap(array[begin + (leftSize // 4 + 2)]);
                        sortingVisualizer.delay(1040);
                        array[pivotPos - 2].swap(array[pivotPos - (leftSize // 4 + 1)]);
                        sortingVisualizer.delay(1040);
                        array[pivotPos - 3].swap(array[pivotPos - (leftSize // 4 + 2)]);
                    }
                }

                if rightSize >= this.insertSortThreshold {
                    sortingVisualizer.delay(1040);
                    array[pivotPos + 1].swap(array[pivotPos + (1 + rightSize // 4)]);
                    sortingVisualizer.delay(1040);
                    array[end - 1].swap(array[end - rightSize // 4]);

                    if rightSize > this.nintherThreshold {
                        sortingVisualizer.delay(1040);
                        array[pivotPos + 2].swap(array[pivotPos + (2 + rightSize // 4)]);
                        sortingVisualizer.delay(1040);
                        array[pivotPos + 3].swap(array[pivotPos + (3 + rightSize // 4)]);
                        sortingVisualizer.delay(1040);
                        array[end - 2].swap(array[end - (1 + rightSize // 4)]);
                        sortingVisualizer.delay(1040);
                        array[end - 3].swap(array[end - (2 + rightSize // 4)]);
                    }
                }
            } else {
                if alreadyParted and this.partialInsertSort(array, begin, pivotPos)
                                 and this.partialInsertSort(array, pivotPos + 1, end) {
                    return;
                }
            }

            this.loop(array, begin, pivotPos, badAllowed, branchless, leftOffsets, rightOffsets);
            begin = pivotPos + 1;
            leftmost = False;
        }
    }
}

@Sort(
    "Quick Sorts",
    "Pattern-Defeating QuickSort",
    "PDQ Sort"
);
new function pdqSortRun(array) {
    PDQSort.loop(array, 0, len(array), PDQSort.log(len(array)), False);
}

@Sort(
    "Quick Sorts",
    "Branchless Pattern-Defeating QuickSort",
    "Branchless PDQ",
    enabled = False
);
new function branchlessPdqSortRun(array) {
    new list leftOffsets  = sortingVisualizer.createValueArray(PDQSort.blockSize + PDQSort.cachelineSize),
             rightOffsets = sortingVisualizer.createValueArray(PDQSort.blockSize + PDQSort.cachelineSize);
    sortingVisualizer.setAux(leftOffsets);
    sortingVisualizer.setAdaptAux(
        lambda array: array + rightOffsets,
        lambda idx, aux: idx + len(leftOffsets) if aux is rightOffsets else idx
    );

    PDQSort.loop(array, 0, len(array), PDQSort.log(len(array)), True, leftOffsets, rightOffsets);
}