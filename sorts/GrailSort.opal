 #
 # MIT License
 # 
 # Copyright (c) 2013 Andrey Astrelin
 # Copyright (c) 2020 The Holy Grail Sort Project
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
 #
 #
 # The Holy Grail Sort Project
 # Project Manager:      Summer Dragonfly
 # Project Contributors: 666666t
 #                       Anonymous0726
 #                       aphitorite
 #                       Control
 #                       dani_dlg
 #                       DeveloperSort
 #                       EilrahcF
 #                       Enver
 #                       Gaming32
 #                       lovebuny
 #                       Morwenn
 #                       MP
 #                       phoenixbound
 #                       Spex_guy
 #                       thatsOven
 #                       _fluffyy
 #                       
 #                       
 #                       
 # Special thanks to "The Studio" Discord community!

# REWRITTEN GRAILSORT FOR OPAL - A heavily refactored C/C++-to-Python version of
#                                  Andrey Astrelin's GrailSort.h, aiming to be as
#                                  readable and intuitive as possible.
#
# ** Written and maintained by The Holy Grail Sort Project
#
# Primary author: thatsOven
#
# Current status: Working (Passing all tests) + Stable

new class GrailSort() {
    new int GRAIL_STATIC_EXT_BUF_LEN = 512;

    new dynamic extBuffer    = None;
    new int     extBufferLen = 0;

    enum Subarray {
        LEFT, RIGHT
    }

    new classmethod compareVal(a, b) {
        return compareValues(a, b);
    }

    new classmethod grailSwap(array, a, b) {
        array[a].swap(array[b]);
    }

    new classmethod grailBlockSwap(array, a, b, blockLen) {
        for i = 0; i < blockLen; i++ {
            GrailSort.grailSwap(array, a + i, b + i);
        }
    }

    new classmethod grailRotate(array, start, leftLen, rightLen) {
        while leftLen > 0 and rightLen > 0 {
            if leftLen <= rightLen {
                this.grailBlockSwap(array, start, start + leftLen, leftLen);
                start    += leftLen;
                rightLen -= leftLen;
            } else {
                this.grailBlockSwap(array, start + leftLen - rightLen, start + leftLen, rightLen);
                leftLen -= rightLen;
            }
        }
    }

    new classmethod grailInsertSort(array, start, length) {
        for item = 1; item < length; item++ {
            new int left  = start + item - 1,
                    right = start + item;

            while left >= start and array[left] > array[right] {
                this.grailSwap(array, left, right);
                left--;
                right--;
            }
        }
    }

    new classmethod grailBinarySearchLeft(array, start, length, target) {
        new int left  = 0,
                right = length;

        while left < right {
            new int middle = left + ((right - left) // 2);

            if array[start + middle] < target {
                left = middle + 1;
            } else {
                right = middle;
            }
        }

        return left;
    }

    new classmethod grailBinarySearchRight(array, start, length, target) {
        new int left  = 0,
                right = length;

        while left < right {
            new int middle = left + ((right - left) // 2);

            if array[start + middle] > target {
                right = middle;
            } else {
                left = middle + 1;
            }
        }

        return right;
    }

    new classmethod grailCollectKeys(array, start, length, idealKeys) {
        new int keysFound = 1,
                 firstKey = 0,
                  currKey = 1;

        for ; currKey < length and keysFound < idealKeys; currKey++ {
            new int insertPos;
            insertPos = this.grailBinarySearchLeft(array, start + firstKey, keysFound, array[start + currKey].read());

            if insertPos == keysFound or array[start + currKey] != array[start + firstKey + insertPos] {
                this.grailRotate(array, start + firstKey, keysFound, currKey - (firstKey + keysFound));

                firstKey = currKey - keysFound;

                this.grailRotate(array, start + firstKey + insertPos, keysFound - insertPos, 1);

                keysFound++;
            }
        }

        this.grailRotate(array, start, firstKey, keysFound);
        return keysFound;
    }

    new classmethod grailPairwiseSwaps(array, start, length) {
        for index = 1; index < length; index += 2 {
            new int  left = start + index - 1,
                    right = start + index;
                
            if array[left] > array[right] {
                this.grailSwap(array,  left - 2, right);
                this.grailSwap(array, right - 2,  left);
            } else {
                this.grailSwap(array,  left - 2,  left);
                this.grailSwap(array, right - 2, right);
            }
        }

        left = start + index - 1;
        if left < start + length {
            this.grailSwap(array, left - 2, left);
        }
    }

    new classmethod grailPairwiseWrites(array, start, length) {
        for index = 1; index < length; index += 2 {
            new int  left = start + index - 1,
                    right = start + index;
                
            if array[left] > array[right] {
                array[left - 2].write(array[right]);
                array[right - 2].write(array[left]);
            } else {
                array[left - 2].write(array[left]);
                array[right - 2].write(array[right]);
            }
        }

        left = start + index - 1;
        if left < start + length {
            array[left - 2].write(array[left]);
        }
    }

    new classmethod grailMergeForwards(array, start, leftLen, rightLen, bufferOffset) {
        new int left   = start,
                middle = start + leftLen,
                right  = middle,
                end    = middle + rightLen,
                buffer = start - bufferOffset;

        for ; right < end; buffer++ {
            if left == middle or array[left] > array[right] {
                this.grailSwap(array, buffer, right);
                right++;
            } else {
                this.grailSwap(array, buffer, left);
                left++;
            }
        }

        if buffer != left {
            this.grailBlockSwap(array, buffer, left, middle-left);
        }
    }

    new classmethod grailMergeOutOfPlace(array, start, leftLen, rightLen, bufferOffset) {
        new int left   = start,
                middle = start + leftLen,
                right  = middle,
                end    = middle + rightLen,
                buffer = start - bufferOffset;

        for ; right < end; buffer++ {
            if left == middle or array[left] > array[right] {
                array[buffer].write(array[right]);
                right++;
            } else {
                array[buffer].write(array[left]);
                left++;
            }
        }

        if buffer != left {
            for ; left < middle; buffer++, left++ {
                array[buffer].write(array[left]);
            }
        }
    }

    new classmethod grailMergeBackwards(array, start, leftLen, rightLen, bufferOffset) {
        new int end    = start - 1,
                left   = end + leftLen,
                middle = left,
                right  = middle + rightLen,
                buffer = right + bufferOffset;

        for ; left > end; buffer-- {
            if right == middle or array[left] > array[right] {
                this.grailSwap(array, buffer, left);
                left--;
            } else {
                this.grailSwap(array, buffer, right);
                right--;
            }
        }

        if right != buffer {
            for ; right > middle; buffer--, right-- {
                this.grailSwap(array, buffer, right);
            }
        }
    }

    new classmethod grailBuildInPlace(array, start, length, currentLen, bufferLen) {
        for mergeLen = currentLen; mergeLen < bufferLen; mergeLen *= 2 {
            new int fullMerge    = 2 * mergeLen,
                    mergeEnd     = start + length - fullMerge,
                    bufferOffset = mergeLen;

            for mergeIndex = start; mergeIndex <= mergeEnd; mergeIndex += fullMerge {
                this.grailMergeForwards(array, mergeIndex, mergeLen, mergeLen, bufferOffset);
            }

            new int leftOver = length - (mergeIndex - start);

            if leftOver > mergeLen {
                this.grailMergeForwards(array, mergeIndex, mergeLen, leftOver - mergeLen, bufferOffset);
            } else {
                this.grailRotate(array, mergeIndex - mergeLen, mergeLen, leftOver);
            }

            start -= mergeLen;
        }

        fullMerge = 2 * bufferLen;
        new int lastBlock  = length % fullMerge,
                lastOffset = start + length - lastBlock;

        if lastBlock <= bufferLen {
            this.grailRotate(array, lastOffset, lastBlock, bufferLen);
        } else {
            this.grailMergeBackwards(array, lastOffset, bufferLen, lastBlock - bufferLen, bufferLen);
        }

        for mergeIndex = lastOffset - fullMerge; mergeIndex >= start; mergeIndex -= fullMerge {
            this.grailMergeBackwards(array, mergeIndex, bufferLen, bufferLen, bufferLen);
        }
    }

    new classmethod grailBuildOutOfPlace(array, start, length, bufferLen, extLen) {
        arrayCopy(array, start - extLen, this.extBuffer, 0, extLen);

        this.grailPairwiseWrites(array, start, length);
        start -= 2;

        for mergeLen = 2; mergeLen < extLen; start -= mergeLen, mergeLen *= 2 {
            new int fullMerge    = 2 * mergeLen,
                    mergeEnd     = start + length - fullMerge,
                    bufferOffset = mergeLen;

            for mergeIndex = start; mergeIndex <= mergeEnd; mergeIndex += fullMerge {
                this.grailMergeOutOfPlace(array, mergeIndex, mergeLen, mergeLen, bufferOffset);
            }

            new int leftOver = length - (mergeIndex - start);

            if leftOver > mergeLen {
                this.grailMergeOutOfPlace(array, mergeIndex, mergeLen, leftOver - mergeLen, bufferOffset);
            } else {
                arrayCopy(array, mergeIndex, array, mergeIndex - mergeLen, leftOver);
            }
        }

        arrayCopy(this.extBuffer, 0, array, start + length, extLen);
        this.grailBuildInPlace(array, start, length, mergeLen, bufferLen);
    }

    new classmethod grailBuildBlocks(array, start, length, bufferLen) {
        if this.extBuffer is not None {
            new int extLen;
            if bufferLen < this.extBufferLen {
                extLen = bufferLen;
            } else {
                for extLen = 1; extLen * 2 <= this.extBufferLen; extLen *= 2 {}
            }
            this.grailBuildOutOfPlace(array, start, length, bufferLen, extLen);
        } else {
            this.grailPairwiseSwaps(array, start, length);
            this.grailBuildInPlace(array, start - 2, length, 2, bufferLen);
        }
    }

    new classmethod grailBlockSelectSort(array, firstKey, start, medianKey, blockCount, blockLen) {
        for firstBlock in range(blockCount) {
            new int selectBlock = firstBlock;

            for currBlock = firstBlock + 1; currBlock < blockCount; currBlock++ {
                new int compare;
                compare = this.compareVal(   array[start + (currBlock   * blockLen)],
                                                  array[start + (selectBlock * blockLen)]     );

                if compare < 0 or (compare == 0 and array[firstKey + currBlock] < array[firstKey + selectBlock]) {
                    selectBlock = currBlock;
                }
            }

            if selectBlock != firstBlock {
                this.grailBlockSwap(array, start + (firstBlock * blockLen), start + (selectBlock * blockLen), blockLen);

                this.grailSwap(array, firstKey + firstBlock, firstKey + selectBlock);

                if     medianKey == firstBlock  { medianKey = selectBlock;}  
                else { 
                    if medianKey == selectBlock { medianKey = firstBlock;}}
            }
        }

        return medianKey;
    }

    new classmethod grailInPlaceBufferReset(array, start, length, bufferOffset) {
        for buffer = start + length - 1, index  = buffer - bufferOffset; buffer >= start; buffer--, index-- {
            this.grailSwap(array, index, buffer);
        }
    }

    new classmethod grailOutOfPlaceBufferReset(array, start, length, bufferOffset) {
        for buffer = start + length - 1, index  = buffer - bufferOffset; buffer >= start; buffer--, index-- {
            array[buffer].write(array[index]);
        }
    }

    new classmethod grailInPlaceBufferRewind(array, start, leftBlock, buffer) {
        for ; leftBlock >= start; buffer--, leftBlock-- {
            this.grailSwap(array, buffer, leftBlock);
        }
    }

    new classmethod grailOutOfPlaceBufferRewind(array, start, leftBlock, buffer) {
        for ; leftBlock >= start; buffer--, leftBlock-- {
            array[buffer].write(array[leftBlock]);
        }
    }

    new classmethod grailGetSubarray(array, currentKey, medianKey) {
        if array[currentKey] < array[medianKey] {
            return this.Subarray.LEFT;
        } else {
            return this.Subarray.RIGHT;
        }
    }

    new classmethod grailCountLastMergeBlocks(array, offset, blockCount, blockLen) {
        new int blocksToMerge = 0,
                lastRightFrag = offset + (blockCount * blockLen),
                prevLeftBlock = lastRightFrag - blockLen;

        while (blocksToMerge < blockCount) and (array[lastRightFrag] < array[prevLeftBlock]) {
            blocksToMerge++;
            prevLeftBlock -= blockLen;
        }

        return blocksToMerge;
    }

    new classmethod grailSmartMerge(array, start, leftLen, leftOrigin, rightLen, bufferOffset) {
        new int left   = start,
                middle = start + leftLen,
                right  = middle,
                end    = middle + rightLen,
                buffer = start - bufferOffset;

        if leftOrigin == this.Subarray.LEFT {
            for ; left < middle and right < end; buffer++ {
                if array[left] <= array[right] {
                    this.grailSwap(array, buffer, left);
                    left++;
                } else {
                    this.grailSwap(array, buffer, right);
                    right++;
                }
            }
        } else {
            for ; left < middle and right < end; buffer++ {
                if array[left] < array[right] {
                    this.grailSwap(array, buffer, left);
                    left++;
                } else {
                    this.grailSwap(array, buffer, right);
                    right++;
                }
            }
        }

        if left < middle {
            this.currBlockLen = middle - left;
            this.grailInPlaceBufferRewind(array, left, middle - 1, end - 1);
        } else {
            this.currBlockLen = end - right;
            if leftOrigin == this.Subarray.LEFT {
                this.currBlockOrigin = this.Subarray.RIGHT;
            } else {
                this.currBlockOrigin = this.Subarray.LEFT;
            }
        }
    }

    new classmethod grailSmartLazyMerge(array, start, leftLen, leftOrigin, rightLen) {
        new int middle = start + leftLen, mergeLen;

        if leftOrigin == this.Subarray.LEFT {
            if array[middle- 1] > array[middle] {
                while leftLen != 0 {
                    mergeLen = this.grailBinarySearchLeft(array, middle, rightLen, array[start]);

                    if mergeLen != 0 {
                        this.grailRotate(array, start, leftLen, mergeLen);
                        start    += mergeLen;
                        rightLen -= mergeLen;
                        middle   += mergeLen;
                    }

                    if rightLen == 0 {
                        this.currBlockLen = leftLen;
                        return;
                    } else {
                        do leftLen != 0 and array[start] <= array[middle] {
                            start++;
                            leftLen--;
                        }
                    }
                }
            }
        } else {
            if array[middle - 1] >= array[middle] {
                while leftLen != 0 {
                    mergeLen = this.grailBinarySearchRight(array, middle, rightLen, array[start]);

                    if mergeLen != 0 {
                        this.grailRotate(array, start, leftLen, mergeLen);
                        start    += mergeLen;
                        rightLen -= mergeLen;
                        middle   += mergeLen;
                    }

                    if rightLen == 0 {
                        this.currBlockLen = leftLen;
                        return;
                    } else {
                        do leftLen !=  0 and array[start] < array[middle] {
                            start++;
                            leftLen--;
                        }
                    }
                }
            }
        }

        this.currBlockLen = rightLen;
        if leftOrigin == this.Subarray.LEFT {
            this.currBlockOrigin = this.Subarray.RIGHT;
        } else {
            this.currBlockOrigin = this.Subarray.LEFT;
        }
    }

    new classmethod grailSmartMergeOutOfPlace(array, start, leftLen, leftOrigin, rightLen, bufferOffset) {
        new int left   = start,
                middle = start + leftLen,
                right  = middle,
                end    = middle + rightLen,
                buffer = start - bufferOffset;

        if leftOrigin == this.Subarray.LEFT {
            for ; left < middle and right < end; buffer++ {
                if array[left] <= array[right] {
                    array[buffer].write(array[left]);
                    left++;
                } else {
                    array[buffer].write(array[right]);
                    right++;
                }
            }
        } else {
            for ; left < middle and right < end; buffer++ {
                if array[left] < array[right] {
                    array[buffer].write(array[left]);
                    left++;
                } else {
                    array[buffer].write(array[right]);
                    right++;
                }
            }
        }

        if left < middle {
            this.currBlockLen = middle - left;
            this.grailOutOfPlaceBufferRewind(array, left, middle - 1, end - 1);
        } else {
            this.currBlockLen = end - right;

            if leftOrigin == this.Subarray.LEFT {
                this.currBlockOrigin = this.Subarray.RIGHT;
            } else {
                this.currBlockOrigin = this.Subarray.LEFT;
            }
        }
    }

    new classmethod grailMergeBlocks(array, firstKey, medianKey, start, blockCount, blockLen, lastMergeBlocks, lastLen) {
        new int nextBlock = start + blockLen;

        this.currBlockLen    = blockLen;
        this.currBlockOrigin = this.grailGetSubarray(array, firstKey, medianKey);

        for keyIndex = 1; keyIndex < blockCount; keyIndex++, nextBlock += blockLen {
            new int currBlock  = nextBlock - this.currBlockLen, nextBlockOrigin;
            nextBlockOrigin = this.grailGetSubarray(array, firstKey + keyIndex, medianKey);

            if nextBlockOrigin == this.currBlockOrigin {
                new int buffer = currBlock - blockLen;

                this.grailBlockSwap(array, buffer, currBlock, this.currBlockLen);
                this.currBlockLen = blockLen;
            } else {
                this.grailSmartMerge(array, currBlock, this.currBlockLen, this.currBlockOrigin, blockLen, blockLen);
            }
        }

        new int currBlock = nextBlock - this.currBlockLen,
                buffer    = currBlock - blockLen;

        if lastLen != 0 {
            if this.currBlockOrigin == this.Subarray.RIGHT {
                this.grailBlockSwap(array, buffer, currBlock, this.currBlockLen);

                currBlock                 = nextBlock;
                this.currBlockLen    = blockLen * lastMergeBlocks;
                this.currBlockOrigin = this.Subarray.LEFT;
            } else {
                this.currBlockLen += blockLen * lastMergeBlocks;
            }

            this.grailMergeForwards(array, currBlock, this.currBlockLen, lastLen, blockLen);
        } else {
            this.grailBlockSwap(array, buffer, currBlock, this.currBlockLen);
        }
    }

    new classmethod grailLazyMergeBlocks(array, firstKey, medianKey, start, blockCount, blockLen, lastMergeBlocks, lastLen) {
        new int nextBlock = start + blockLen;

        this.currBlockLen    = blockLen;
        this.currBlockOrigin = this.grailGetSubarray(array, firstKey, medianKey);

        for keyIndex = 1; keyIndex < blockCount; keyIndex++, nextBlock += blockLen {
            new int currBlock = nextBlock - this.currBlockLen, nextBlockOrigin;
            nextBlockOrigin = this.grailGetSubarray(array, firstKey + keyIndex, medianKey);

            if nextBlockOrigin == this.currBlockOrigin {
                this.currBlockLen = blockLen;
            } else {
                this.grailSmartLazyMerge(array, currBlock, this.currBlockLen, this.currBlockOrigin, blockLen);
            }
        }

        currBlock = nextBlock - this.currBlockLen;

        if lastLen != 0 {
            if this.currBlockOrigin == this.Subarray.RIGHT {
                currBlock                 = nextBlock;
                this.currBlockLen    = blockLen * lastMergeBlocks;
                this.currBlockOrigin = this.Subarray.LEFT;
            } else {
                this.currBlockLen += blockLen * lastMergeBlocks;
            }

            this.grailLazyMerge(array, currBlock, this.currBlockLen, lastLen);
        }
    }

    new classmethod grailMergeBlocksOutOfPlace(array, firstKey, medianKey, start, blockCount, blockLen, lastMergeBlocks, lastLen) {
        new int nextBlock = start + blockLen;

        this.currBlockLen    = blockLen;
        this.currBlockOrigin = this.grailGetSubarray(array, firstKey, medianKey);

        new int buffer;
        for keyIndex = 1; keyIndex < blockCount; keyIndex++, nextBlock += blockLen {
            new int currBlock = nextBlock - this.currBlockLen, nextBlockOrigin;
            nextBlockOrigin = this.grailGetSubarray(array, firstKey + keyIndex, medianKey);

            if nextBlockOrigin == this.currBlockOrigin {
                buffer = currBlock - blockLen;

                arrayCopy(array, currBlock, array, buffer, this.currBlockLen);
                this.currBlockLen = blockLen;
            } else {
                this.grailSmartMergeOutOfPlace(array, currBlock, this.currBlockLen, this.currBlockOrigin, blockLen, blockLen);
            }
        }

        currBlock = nextBlock - this.currBlockLen;
        buffer    = currBlock - blockLen;

        if lastLen != 0 {
            if this.currBlockOrigin == this.Subarray.RIGHT {
                arrayCopy(array, currBlock, array, buffer, this.currBlockLen);

                currBlock                 = nextBlock;
                this.currBlockLen    = blockLen * lastMergeBlocks;
                this.currBlockOrigin = this.Subarray.LEFT;
            } else {
                this.currBlockLen += blockLen * lastMergeBlocks;
            }

            this.grailMergeOutOfPlace(array, currBlock, this.currBlockLen, lastLen, blockLen);
        } else {
            arrayCopy(array, currBlock, array, buffer, this.currBlockLen);
        }
    }

    new classmethod grailCombineInPlace(array, firstKey, start, length, subarrayLen, blockLen, mergeCount, lastSubarrays, buffer) {
        new int fullMerge  = 2 * subarrayLen,
                blockCount = fullMerge // blockLen, offset;

        for mergeIndex in range(mergeCount) {
            offset = start + (mergeIndex * fullMerge);

            this.grailInsertSort(array, firstKey, blockCount);

            new int medianKey = subarrayLen // blockLen;
            medianKey = this.grailBlockSelectSort(array, firstKey, offset, medianKey, blockCount, blockLen);

            if buffer {
                this.grailMergeBlocks(array, firstKey, firstKey + medianKey, offset, blockCount, blockLen, 0, 0);
            } else {
                this.grailLazyMergeBlocks(array, firstKey, firstKey + medianKey, offset, blockCount, blockLen, 0, 0);
            }
        }

        if lastSubarrays != 0 {
            offset = start + (mergeCount * fullMerge);
            blockCount = lastSubarrays // blockLen;

            this.grailInsertSort(array, firstKey, blockCount + 1);

            medianKey = subarrayLen // blockLen;
            medianKey = this.grailBlockSelectSort(array, firstKey, offset, medianKey, blockCount, blockLen);

            new int lastFragment = lastSubarrays - (blockCount * blockLen), lastMergeBlocks;

            if lastFragment != 0 {
                lastMergeBlocks = this.grailCountLastMergeBlocks(array, offset, blockCount, blockLen);
            } else {
                lastMergeBlocks = 0;
            }

            new int smartMerges = blockCount - lastMergeBlocks;

            if smartMerges == 0 {
                new int leftLen = lastMergeBlocks * blockLen;

                if buffer {
                    this.grailMergeForwards(array, offset, leftLen, lastFragment, blockLen);
                } else {
                    this.grailLazyMerge(array, offset, leftLen, lastFragment);
                }
            } else {
                if buffer {
                    this.grailMergeBlocks(array, firstKey, firstKey + medianKey, offset, smartMerges, blockLen, lastMergeBlocks, lastFragment);
                } else {
                    this.grailLazyMergeBlocks(array, firstKey, firstKey + medianKey, offset, smartMerges, blockLen, lastMergeBlocks, lastFragment);
                }
            }
        }

        if buffer {
            this.grailInPlaceBufferReset(array, start, length, blockLen);
        }
    }

    new classmethod grailCombineOutOfPlace(array, firstKey, start, length, subarrayLen, blockLen, mergeCount, lastSubarrays) {
        arrayCopy(array, start - blockLen, this.extBuffer, 0, blockLen);

        new int fullMerge = 2 * subarrayLen,
                blockCount = fullMerge // blockLen, offset;

        for mergeIndex in range(mergeCount) {
            offset = start + (mergeIndex * fullMerge);

            this.grailInsertSort(array, firstKey, blockCount);

            new int medianKey = subarrayLen // blockLen;
            medianKey = this.grailBlockSelectSort(array, firstKey, offset, medianKey, blockCount, blockLen);

            this.grailMergeBlocksOutOfPlace(array, firstKey, firstKey + medianKey, offset, blockCount, blockLen, 0, 0);
        }

        if lastSubarrays != 0 {
            offset = start + (mergeCount * fullMerge);
            blockCount = lastSubarrays // blockLen;

            this.grailInsertSort(array, firstKey, blockCount + 1);

            new int medianKey = subarrayLen // blockLen;
            medianKey = this.grailBlockSelectSort(array, firstKey, offset, medianKey, blockCount, blockLen);

            new int lastFragment = lastSubarrays - (blockCount * blockLen), lastMergeBlocks;
            if lastFragment != 0 {
                lastMergeBlocks = this.grailCountLastMergeBlocks(array, offset, blockCount, blockLen);
            } else {
                lastMergeBlocks = 0;
            }

            new int smartMerges = blockCount - lastMergeBlocks;

            if smartMerges == 0 {
                new int leftLen = lastMergeBlocks * blockLen;

                this.grailMergeOutOfPlace(array, offset, leftLen, lastFragment, blockLen);
            } else {
                this.grailMergeBlocksOutOfPlace(array, firstKey, firstKey + medianKey, offset, smartMerges, blockLen, lastMergeBlocks, lastFragment);
            }
        }

        this.grailOutOfPlaceBufferReset(array, start, length, blockLen);
        arrayCopy(this.extBuffer, 0, array, start - blockLen, blockLen);
    }

    new classmethod grailCombineBlocks(array, firstKey, start, length, subarrayLen, blockLen, buffer) {
        new int fullMerge     = 2 * subarrayLen,
                mergeCount    = length // fullMerge,
                lastSubarrays = length - (fullMerge * mergeCount);

        if lastSubarrays <= subarrayLen {
            length -= lastSubarrays;
            lastSubarrays = 0;
        }

        if buffer and blockLen <= this.extBufferLen {
            this.grailCombineOutOfPlace(array, firstKey, start, length, subarrayLen, blockLen, mergeCount, lastSubarrays);
        } else {
            this.grailCombineInPlace(array, firstKey, start, length, subarrayLen, blockLen, mergeCount, lastSubarrays, buffer);
        }
    }

    new classmethod grailLazyMerge(array, start, leftLen, rightLen) {
        new int mergeLen, middle;
        if leftLen < rightLen {
            middle = start + leftLen;

            while leftLen != 0 {
                mergeLen = this.grailBinarySearchLeft(array, middle, rightLen, array[start].read());

                if mergeLen != 0 {
                    this.grailRotate(array, start, leftLen, mergeLen);
                    start    += mergeLen;
                    rightLen -= mergeLen;
                    middle   += mergeLen;
                }

                if rightLen == 0 { break;}
                else {
                    do leftLen != 0 and array[start] <= array[middle] {
                        start++;
                        leftLen--;
                    }
                }
            }
        } else {
            new int end = start + leftLen + rightLen - 1;

            while rightLen != 0 {
                mergeLen = this.grailBinarySearchRight(array, start, leftLen, array[end].read());

                if mergeLen != leftLen {
                    this.grailRotate(array, start + mergeLen, leftLen - mergeLen, rightLen);
                    end     -= leftLen - mergeLen;
                    leftLen  = mergeLen;
                }

                if leftLen == 0 { break;}
                else {
                    middle = start + leftLen;

                    do rightLen != 0 and array[middle - 1] <= array[end] {
                        rightLen--;
                        end--;
                    }
                }
            }
        }
    }

    new classmethod grailLazyStableSort(array, start, length) {
        for index = 1; index < length; index += 2 {
            new int left  = start + index - 1,
                    right = start + index;

            if array[left] > array[right] {
                this.grailSwap(array, left, right);
            }
        }

        for mergeLen = 2; mergeLen < length; mergeLen *= 2 {
            new int fullMerge = 2 * mergeLen,
                    mergeEnd  = length - fullMerge;

            for mergeIndex = 0; mergeIndex <= mergeEnd; mergeIndex += fullMerge {
                this.grailLazyMerge(array, start + mergeIndex, mergeLen, mergeLen);
            }

            new int leftOver = length - mergeIndex;
            if leftOver > mergeLen {
                this.grailLazyMerge(array, start + mergeIndex, mergeLen, leftOver - mergeLen);
            }
        }
    }

    new classmethod grailCommonSort(array, start, length, extBuffer, extBufferLen) {
        if length < 16 {
            this.grailInsertSort(array, start, length);
            return;
        } else {
            for blockLen = 1; blockLen ** 2 < length; blockLen *= 2 {}

            new int keyLen    = ((length - 1) // blockLen) + 1,
                    idealKeys = keyLen + blockLen, keysFound;

            keysFound = this.grailCollectKeys(array, start, length, idealKeys);

            new bool idealBuffer;
            if keysFound < idealKeys {
                if keysFound < 4 {
                    this.grailLazyStableSort(array, start, length);
                    return;
                } else {
                    keyLen      = blockLen;
                    blockLen    = 0;
                    idealBuffer = False;

                    while keyLen > keysFound {
                        keyLen //= 2;
                    }
                }
            } else { idealBuffer = True;}

            new int bufferEnd = blockLen + keyLen, subarrayLen;

            if idealBuffer {
                subarrayLen = blockLen;
            } else {
                subarrayLen = keyLen;
            }

            if idealBuffer and extBuffer != None {
                this.extBuffer    = extBuffer;
                this.extBufferLen = extBufferLen;
            }

            this.grailBuildBlocks(array, start + bufferEnd, length - bufferEnd, subarrayLen);

            while length - bufferEnd > 2 * subarrayLen {
                subarrayLen *= 2;

                new int  currentBlockLen = blockLen;
                new bool scrollingBuffer = idealBuffer;

                if not idealBuffer {
                    new int keyBuffer = keyLen // 2;

                    if keyBuffer >= (2 * subarrayLen) // keyBuffer {
                        currentBlockLen = keyBuffer;
                        scrollingBuffer = True;
                    } else {
                        currentBlockLen = (2 * subarrayLen) // keyLen;
                    }
                }

                this.grailCombineBlocks(array, start, start + bufferEnd, length - bufferEnd, subarrayLen, currentBlockLen, scrollingBuffer);
            }

            this.grailInsertSort(array, start, bufferEnd);
            this.grailLazyMerge(array, start, bufferEnd, length - bufferEnd);
        }
    }
}

new function grailSortInPlace(array, start, length) {
    GrailSort.extBuffer    = None;
    GrailSort.extBufferLen = 0;
    GrailSort.grailCommonSort(array, start, length, None, 0);
}

new function grailSortStaticOOP(array, start, length) {
    GrailSort.extBuffer    = sortingVisualizer.createValueArray(GrailSort.GRAIL_STATIC_EXT_BUF_LEN);
    sortingVisualizer.setAux(GrailSort.extBuffer);
    GrailSort.extBufferLen = GrailSort.GRAIL_STATIC_EXT_BUF_LEN;
    GrailSort.grailCommonSort(array, start, length, GrailSort.extBuffer, GrailSort.GRAIL_STATIC_EXT_BUF_LEN);
}

new function grailSortDynamicOOP(array, start, length) {
    for GrailSort.extBufferLen = 1; GrailSort.extBufferLen ** 2 < length ; {
        GrailSort.extBufferLen *= 2;
    }

    GrailSort.extBuffer = sortingVisualizer.createValueArray(GrailSort.extBufferLen);
    sortingVisualizer.setAux(GrailSort.extBuffer);
    GrailSort.grailCommonSort(array, start, length, GrailSort.extBuffer, GrailSort.extBufferLen);
}

new function grailSortGivenAux(array, start, length, aux, set = True) {
    GrailSort.extBuffer = aux;
    if set {
        sortingVisualizer.setAux(GrailSort.extBuffer);
    }
    GrailSort.extBufferLen = len(aux);
    GrailSort.grailCommonSort(array, start, length, GrailSort.extBuffer, GrailSort.extBufferLen);
}

@Sort(
    "Block Merge Sorts",
    "Grail Sort",
    "Grail Sort"
).run;
new function grailSortRun(array) {
    new int mode;
    mode = sortingVisualizer.getUserInput("Insert buffer size (0 for in-place, -1 for dynamic)", "0", ["-1", "512"]);

    match mode {
        case 0 {
            grailSortInPlace(array, 0, len(array));
        }
        case -1 {
            grailSortDynamicOOP(array, 0, len(array));
        }
        default {
            GrailSort.GRAIL_STATIC_EXT_BUF_LEN = mode;

            grailSortStaticOOP(array, 0, len(array));
        }
    }
}

@Sort(
    "Merge Sorts",
    "Lazy Stable Sort",
    "Lazy Stable"
).run;
new function lazyStableSortRun(array) {
    GrailSort.grailLazyStableSort(array, 0, len(array));
}