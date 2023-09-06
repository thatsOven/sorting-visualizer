new class WikiRange {
    new method __init__(start = 0, end = 0) {
        this.start = start;
        this.end   = end;
    }

    new method set(start, end) {
        this.start = start;
        this.end   = end;
    }

    new method length() {
        return this.end - this.start;
    }
}

new class WikiPull {
    new method __init__() {
        this.range = WikiRange(0, 0);

        this.from_  = 0;
        this.to    = 0;
        this.count = 0;
    }

    new method reset() {
        this.range.set(0, 0);

        this.from_ = 0;
        this.to    = 0;
        this.count = 0;
    }
}

new class WikiIterator {
    new classmethod floorPowerOfTwo(value) {
        new int x = value;

        x = x | (x >> 1);
        x = x | (x >> 2);
        x = x | (x >> 4);
        x = x | (x >> 8);
        x = x | (x >> 16);
        return x - (x >> 1);
    }

    new method __init__(size, min_level) {
        this.size           = size;
        this.power_of_two   = WikiIterator.floorPowerOfTwo(this.size);
        this.denominator    = this.power_of_two // min_level;
        this.numerator_step = this.size % this.denominator;
        this.decimal_step   = this.size // this.denominator;
        this.begin();
    }

    new method begin() {
        this.numerator = 0;
        this.decimal   = 0;
    }

    new method nextRange() {
        new int start = this.decimal;

        this.decimal   += this.decimal_step;
        this.numerator += this.numerator_step;

        if this.numerator >= this.denominator {
            this.numerator -= this.denominator;
            this.decimal++;
        }

        return WikiRange(start, this.decimal);
    }

    new method finished() {
        return this.decimal >= this.size;
    }

    new method nextLevel() {
        this.decimal_step   += this.decimal_step;
        this.numerator_step += this.numerator_step;

        if this.numerator_step >= this.denominator {
            this.numerator_step -= this.denominator;
            this.decimal_step++;
        }

        return this.decimal_step < this.size;
    }

    new method length() {
        return this.decimal_step;
    }
}

new class WikiSort {
    new method __init__(cacheSize, cache = None, rot = None) {
        this.cache_size = cacheSize;

        if this.cache_size != 0 {
            if cache is None {
                this.cache = sortingVisualizer.createValueArray(this.cache_size);
            } else {
                this.cache = cache;
            }

            sortingVisualizer.setAux(this.cache);
        } else {
            this.cache = None;
        }

        if rot is None {
            this.internalRotate = sortingVisualizer.getRotation(
                id = sortingVisualizer.getUserSelection(
                    [r.name for r in sortingVisualizer.rotations],
                    "Select rotation algorithm (default: Triple Reversal)"
                )
            ).indexedFn;
        } else {
            this.internalRotate = sortingVisualizer.getRotation(name = rot).indexedFn;
        }
    }

    new method binaryFirst(array, value, range) {
        new int start = range.start, end = range.end - 1;

        while start < end {
            new int mid = start + ((end - start) // 2);

            if array[mid] < value {
                start = mid + 1;
            } else {
                end = mid;
            }
        }

        if start == range.end - 1 and array[start] < value {
            start++;
        }
        return start;
    }

    new method binaryLast(array, value, range) {
        new int start = range.start, end = range.end - 1;

        while start < end {
            new int mid = start + ((end - start) // 2);

            if compareIntToValue(value, array[mid]) >= 0 {
                start = mid + 1;
            } else {
                end = mid;
            }
        }

        if start == range.end - 1 and array[start] <= value {
            start++;
        }
        return start;
    }

    new method findFirstForward(array, value, range, unique) {
        if range.length() == 0 {
            return range.start;
        }

        new int index, skip;
        skip = max(range.length() // unique, 1);

        for index = range.start + skip; array[index - 1] < value; index += skip {
            if index >= range.end - skip {
                return this.binaryFirst(array, value, WikiRange(index, range.end));
            }
        }

        return this.binaryFirst(array, value, WikiRange(index - skip, index));
    }

    new method findLastForward(array, value, range, unique) {
        if range.length() == 0 {
            return range.start;
        }

        new int index, skip;
        skip = max(range.length() // unique, 1);

        for index = range.start + skip; compareIntToValue(value, array[index - 1]) >= 0; index += skip {
            if index >= range.end - skip {
                return this.binaryLast(array, value, WikiRange(index, range.end));
            }
        }

        return this.binaryLast(array, value, WikiRange(index - skip, index));
    }

    new method findFirstBackward(array, value, range, unique) {
        if range.length() == 0 {
            return range.start;
        }
        new int index, skip;
        skip = max(range.length() // unique, 1);

        for index = range.end - skip; index > range.start and array[index - 1] >= value; index -= skip {
            if index < range.start + skip {
                return this.binaryFirst(array, value, WikiRange(range.start, index));
            }
        }
        return this.binaryFirst(array, value, WikiRange(index, index + skip));
    }

    new method findLastBackward(array, value, range, unique) {
        if range.length() == 0 {
            return range.start;
        }
        new int index, skip;
        skip = max(range.length() // unique, 1);

        for index = range.end - skip; index > range.start and compareIntToValue(value, array[index - 1]) < 0; index -= skip {
            if index < range.start + skip {
                return this.binaryLast(array, value, WikiRange(range.start, index));
            }
        }
        return this.binaryLast(array, value, WikiRange(index, index + skip));
    }

    new method insertionSort(array, range) {
        insertionSort(array, range.start, range.end - 1);
    }

    new method reverse(array, range) {
        reverse(array, range.start, range.end);
    }

    new method rotate(array, amount, range, use_cache) {
        if range.length() == 0 {
            return;
        }

        new int split;
        if amount >= 0 {
            split = range.start + amount;
        } else {
            split = range.end + amount;
        }

        new WikiRange range1, range2;

        range1 = WikiRange(range.start, split);
        range2 = WikiRange(      split, range.end);

        if use_cache {
            if range1.length() <= range2.length() {
                if range1.length() <= this.cache_size {
                    if this.cache is not None {
                        arrayCopy(array, range1.start, this.cache,                              0, range1.length());
                        arrayCopy(array, range2.start,      array,                   range1.start, range2.length());
                        arrayCopy(this.cache,       0,      array, range1.start + range2.length(), range1.length());
                    }
                    return;
                }
            } elif range2.length() <= this.cache_size {
                if this.cache is not None {
                    reverseArrayCopy(     array, range2.start, this.cache,                            0, range2.length());
                    reverseArrayCopy(     array, range1.start,      array, range2.end - range1.length(), range1.length());
                    reverseArrayCopy(this.cache,            0,      array,                 range1.start, range2.length());
                }
                return;
            }
        }

        this.internalRotate(array, range.start, split, range.end);
    }

    new method mergeInto(from_, A, B, into, at_index) {
        new int A_index, B_index, insert_index, A_last, B_last;

        A_index      = A.start;
        B_index      = B.start;
        insert_index = at_index;
        A_last       = A.end;
        B_last       = B.end;

        while True {
            if from_[B_index] >= from_[A_index] {
                into[insert_index].write(from_[A_index]);

                A_index++;
                insert_index++;

                if A_index == A_last {
                    arrayCopy(from_, B_index, into, insert_index, B_last - B_index);
                    break;
                }
            } else {
                into[insert_index].write(from_[B_index]);

                B_index++;
                insert_index++;

                if B_index == B_last {
                    arrayCopy(from_, A_index, into, insert_index, A_last - A_index);
                    break;
                }
            }
        }
    }

    new method mergeExternal(array, A, B) {
        new int A_index, B_index, insert_index, A_last, B_last;

        A_index      = 0;
        B_index      = B.start;
        insert_index = A.start;
        A_last       = A.length();
        B_last       = B.end;

        if B.length() > 0 and A.length() > 0 {
            while True {
                if array[B_index] >= this.cache[A_index] {
                    array[insert_index].write(this.cache[A_index]);
                    A_index++;
                    insert_index++;

                    if A_index == A_last {
                        break;
                    }
                } else {
                    array[insert_index].write(array[B_index]);
                    B_index++;
                    insert_index++;

                    if B_index == B_last {
                        break;
                    }
                }
            }
        }

        if this.cache is not None {
            arrayCopy(this.cache, A_index, array, insert_index, A_last - A_index);
        }
    }

    new method mergeInternal(array, A, B, buffer) {
        new int A_count = 0, B_count = 0, insert = 0;

        if B.length() > 0 and A.length() > 0 {
            while True {
                if array[B.start + B_count] >= array[buffer.start + A_count] {
                    array[A.start + insert].swap(array[buffer.start + A_count]);
                    A_count++;
                    insert++;

                    if A_count >= A.length() {
                        break;
                    }
                } else {
                    array[A.start + insert].swap(array[B.start + B_count]);
                    B_count++;
                    insert++;

                    if B_count >= B.length() {
                        break;
                    }
                }
            }
        }

        blockSwap(array, buffer.start + A_count, A.start + insert, A.length() - A_count);
    }

    new method mergeInPlace(array, A, B) {

        A = WikiRange(A.start, A.end);
        B = WikiRange(B.start, B.end);

        new int mid, amount;

        while True {
            mid = this.binaryFirst(array, array[A.start].readInt(), B);

            amount = mid - A.end;
            this.rotate(array, -amount, WikiRange(A.start, mid), True);
            if B.end == mid {
                break;
            }

            B.start = mid;
            A.set(A.start + amount, B.start);
            A.start = this.binaryLast(array, array[A.start].readInt(), A);
            if A.length() == 0 {
                break;
            }
        }
    }

    new method netSwap(array, order, range, x, y) {
        new int compare;
        compare = compareValues(array[range.start + x].readInt(), array[range.start + y].readInt());
        if compare > 0 or (order[x] > order[y] and compare == 0) {
            array[range.start + x].swap(array[range.start + y]);
            sortingVisualizer.swap(order, x, y);
        }
    }

    new method sort(array, len) {
        new int size = len;

        if size < 4 {
            match size {
                case 3 {
                    if array[1] < array[0] {
                        array[0].swap(array[1]);
                    }
                    if array[2] < array[1] {
                        array[1].swap(array[2]);

                        if array[1] < array[0] {
                            array[0].swap(array[1]);
                        }
                    }
                }
                case 2 {
                    if array[1] < array[0] {
                        array[0].swap(array[1]);
                    }
                }
            }
            return;
        }

        new WikiIterator iterator = WikiIterator(size, 4);

        while not iterator.finished() {
            new list order;
            order = [0, 1, 2, 3, 4, 5, 6, 7];
            new WikiRange range = iterator.nextRange();

            match range.length() {
                case 8 {
                    this.netSwap(array, order, range, 0, 1); this.netSwap(array, order, range, 2, 3);
                    this.netSwap(array, order, range, 4, 5); this.netSwap(array, order, range, 6, 7);
                    this.netSwap(array, order, range, 0, 2); this.netSwap(array, order, range, 1, 3);
                    this.netSwap(array, order, range, 4, 6); this.netSwap(array, order, range, 5, 7);
                    this.netSwap(array, order, range, 1, 2); this.netSwap(array, order, range, 5, 6);
                    this.netSwap(array, order, range, 0, 4); this.netSwap(array, order, range, 3, 7);
                    this.netSwap(array, order, range, 1, 5); this.netSwap(array, order, range, 2, 6);
                    this.netSwap(array, order, range, 1, 4); this.netSwap(array, order, range, 3, 6);
                    this.netSwap(array, order, range, 2, 4); this.netSwap(array, order, range, 3, 5);
                    this.netSwap(array, order, range, 3, 4);
                }
                case 7 {
                    this.netSwap(array, order, range, 1, 2); this.netSwap(array, order, range, 3, 4); this.netSwap(array, order, range, 5, 6);
                    this.netSwap(array, order, range, 0, 2); this.netSwap(array, order, range, 3, 5); this.netSwap(array, order, range, 4, 6);
                    this.netSwap(array, order, range, 0, 1); this.netSwap(array, order, range, 4, 5); this.netSwap(array, order, range, 2, 6);
                    this.netSwap(array, order, range, 0, 4); this.netSwap(array, order, range, 1, 5);
                    this.netSwap(array, order, range, 0, 3); this.netSwap(array, order, range, 2, 5);
                    this.netSwap(array, order, range, 1, 3); this.netSwap(array, order, range, 2, 4);
                    this.netSwap(array, order, range, 2, 3);
                }
                case 6 {
                    this.netSwap(array, order, range, 1, 2); this.netSwap(array, order, range, 4, 5);
                    this.netSwap(array, order, range, 0, 2); this.netSwap(array, order, range, 3, 5);
                    this.netSwap(array, order, range, 0, 1); this.netSwap(array, order, range, 3, 4); this.netSwap(array, order, range, 2, 5);
                    this.netSwap(array, order, range, 0, 3); this.netSwap(array, order, range, 1, 4);
                    this.netSwap(array, order, range, 2, 4); this.netSwap(array, order, range, 1, 3);
                    this.netSwap(array, order, range, 2, 3);
                }
                case 5 {
                    this.netSwap(array, order, range, 0, 1); this.netSwap(array, order, range, 3, 4);
                    this.netSwap(array, order, range, 2, 4);
                    this.netSwap(array, order, range, 2, 3); this.netSwap(array, order, range, 1, 4);
                    this.netSwap(array, order, range, 0, 3);
                    this.netSwap(array, order, range, 0, 2); this.netSwap(array, order, range, 1, 3);
                    this.netSwap(array, order, range, 1, 2);
                }
                case 4 {
                    this.netSwap(array, order, range, 0, 1); this.netSwap(array, order, range, 2, 3);
                    this.netSwap(array, order, range, 0, 2); this.netSwap(array, order, range, 1, 3);
                    this.netSwap(array, order, range, 1, 2);
                }
            }
        }
        if size < 8 {
            return;
        }

        new WikiRange buffer1, buffer2,
                       blockA,  blockB,
                        lastA,   lastB,
                       firstA, A, B;

        buffer1 = WikiRange();
        buffer2 = WikiRange();
        blockA  = WikiRange();
        blockB  = WikiRange();
        lastA   = WikiRange();
        lastB   = WikiRange();
        firstA  = WikiRange();
        A       = WikiRange();
        B       = WikiRange();

        new list pull;
        pull = [
            WikiPull(),
            WikiPull()
        ];

        while True {
            if iterator.length() < this.cache_size {
                if (iterator.length() + 1) * 4 <= this.cache_size and iterator.length() * 4 <= size {
                    iterator.begin();

                    while not iterator.finished() {
                        new WikiRange A1, B1,
                                        A2, B2;

                        A1 = iterator.nextRange();
                        B1 = iterator.nextRange();
                        A2 = iterator.nextRange();
                        B2 = iterator.nextRange();

                        if array[B1.end - 1] < array[A1.start] {
                            arrayCopy(array, A1.start, this.cache, B1.length(), A1.length());
                            arrayCopy(array, B1.start, this.cache,           0, B1.length());
                        } elif array[B1.start] < array[A1.end - 1] {
                            this.mergeInto(array, A1, B1, this.cache, 0);
                        } else {
                            if array[B2.start] >= array[A2.end - 1] and array[A2.start] >= array[B1.end - 1] {
                                continue;
                            }

                            arrayCopy(array, A1.start, this.cache,           0, A1.length());
                            arrayCopy(array, B1.start, this.cache, A1.length(), B1.length());
                        }
                        A1.set(A1.start, B1.end);

                        if array[B2.end - 1] < array[A2.start] {
                            arrayCopy(array, A2.start, this.cache, A1.length() + B2.length(), A2.length());
                            arrayCopy(array, B2.start, this.cache,               A1.length(), B2.length());
                        } elif array[B2.start] < array[A2.end - 1] {
                            this.mergeInto(array, A2, B2, this.cache, A1.length());
                        } else {
                            arrayCopy(array, A2.start, this.cache,               A1.length(), A2.length());
                            arrayCopy(array, B2.start, this.cache, A1.length() + A2.length(), B2.length());
                        }
                        A2.set(A2.start, B2.end);

                        new WikiRange A3, B3;

                        A3 = WikiRange(0, A1.length());
                        B3 = WikiRange(A1.length(), A1.length() + A2.length());

                        if this.cache[B3.end - 1] < this.cache[A3.start] {
                            arrayCopy(this.cache, A3.start, array, A1.start + A2.length(), A3.length());
                            arrayCopy(this.cache, B3.start, array,               A1.start, B3.length());
                        } elif this.cache[B3.start] < this.cache[A3.end - 1] {
                            this.mergeInto(this.cache, A3, B3, array, A1.start);
                        } else {
                            arrayCopy(this.cache, A3.start, array,               A1.start, A3.length());
                            arrayCopy(this.cache, B3.start, array, A1.start + A1.length(), B3.length());
                        }
                    }
                    iterator.nextLevel();
                } else {
                    iterator.begin();

                    while not iterator.finished() {
                        A = iterator.nextRange();
                        B = iterator.nextRange();

                        if array[B.end - 1] < array[A.start] {
                            this.rotate(array, A.length(), WikiRange(A.start, B.end), True);
                        } elif array[B.start] < array[A.end - 1] {
                            arrayCopy(array, A.start, this.cache, 0, A.length());
                            this.mergeExternal(array, A, B);
                        }
                    }
                }
            } else {
                new int block_size, buffer_size, index, last, count, pull_index = 0;
                block_size  = math.sqrt(iterator.length());
                buffer_size = iterator.length()//block_size + 1;

                buffer1.set(0, 0);
                buffer2.set(0, 0);

                pull[0].reset();
                pull[1].reset();

                new int             find = buffer_size + buffer_size;
                new bool find_separately = False;

                if block_size <= this.cache_size {
                    find = buffer_size;
                } elif find > iterator.length() {
                    find = buffer_size;
                    find_separately = True;
                }

                iterator.begin();
                while not iterator.finished() {
                    A = iterator.nextRange();
                    B = iterator.nextRange();

                    for last = A.start, count = 1; count < find; last = index, count++ {
                        index = this.findLastForward(array, array[last].readInt(), WikiRange(last + 1, A.end), find - count);
                        if index == A.end {
                            break;
                        }
                    }
                    index = last;

                    if count >= buffer_size {
                        pull[pull_index].range.set(A.start, B.end);
                        pull[pull_index].count = count;
                        pull[pull_index].from_ = index;
                        pull[pull_index].to    = A.start;
                        pull_index = 1;

                        if count == buffer_size + buffer_size {
                            buffer1.set(A.start, A.start + buffer_size);
                            buffer2.set(A.start + buffer_size, A.start + count);
                            break;
                        } elif find == buffer_size + buffer_size {
                            buffer1.set(A.start, A.start + count);
                            find = buffer_size;
                        } elif block_size <= this.cache_size {
                            buffer1.set(A.start, A.start + count);
                            break;
                        } elif find_separately {
                            buffer1 = WikiRange(A.start, A.start + count);
                            find_separately = False;
                        } else {
                            buffer2.set(A.start, A.start + count);
                            break;
                        }
                    } elif pull_index == 0 and count > buffer1.length() {
                        buffer1.set(A.start, A.start + count);

                        pull[pull_index].range.set(A.start, B.end);
                        pull[pull_index].count = count;
                        pull[pull_index].from_ = index;
                        pull[pull_index].to    = A.start;
                    }

                    for last = B.end - 1, count = 1; count < find; last = index - 1, count++ {
                        index = this.findFirstBackward(array, array[last].readInt(), WikiRange(B.start, last), find - count);
                        if index == B.start {
                            break;
                        }
                    }
                    index = last;

                    if count >= buffer_size {
                        pull[pull_index].range.set(A.start, B.end);
                        pull[pull_index].count = count;
                        pull[pull_index].from_ = index;
                        pull[pull_index].to    = B.end;
                        pull_index = 1;

                        if count == buffer_size + buffer_size {
                            buffer1.set(B.end - count, B.end - buffer_size);
                            buffer2.set(B.end - buffer_size, B.end);
                            break;
                        } elif find == buffer_size + buffer_size {
                            buffer1.set(B.end - count, B.end);
                            find = buffer_size;
                        } elif block_size <= this.cache_size {
                            buffer1.set(B.end - count, B.end);
                            break;
                        } elif find_separately {
                            buffer1 = WikiRange(B.end - count, B.end);
                            find_separately = False;
                        } else {
                            if pull[0].range.start == A.start {
                                pull[0].range.end -= pull[1].count;
                            }

                            buffer2.set(B.end - count, B.end);
                            break;
                        }
                    } elif pull_index == 0 and count > buffer1.length() {
                        buffer1.set(B.end - count, B.end);

                        pull[pull_index].range.set(A.start, B.end);
                        pull[pull_index].count = count;
                        pull[pull_index].from_ = index;
                        pull[pull_index].to    = B.end;
                    }
                }

                for pull_index = 0; pull_index < 2; pull_index++ {
                    new int length = pull[pull_index].count;

                    if pull[pull_index].to < pull[pull_index].from_ {
                        index = pull[pull_index].from_;

                        for count = 1; count < length; count++ {
                            index = this.findFirstBackward(array, array[index - 1].readInt(), WikiRange(pull[pull_index].to, pull[pull_index].from_ - (count - 1)), length - count);
                            new WikiRange range;
                            range = WikiRange(index + 1, pull[pull_index].from_ + 1);
                            this.rotate(array, range.length() - count, range, True);
                            pull[pull_index].from_ = index + count;
                        }
                    } elif pull[pull_index].to > pull[pull_index].from_ {
                        index = pull[pull_index].from_ + 1;

                        for count = 1; count < length; count++ {
                            index = this.findLastForward(array, array[index].readInt(), WikiRange(index, pull[pull_index].to), length - count);
                            new WikiRange range;
                            range = WikiRange(pull[pull_index].from_, index - 1);
                            this.rotate(array, count, range, True);
                            pull[pull_index].from_ = index - 1 - count;
                        }
                    }
                }

                buffer_size = buffer1.length();
                block_size = iterator.length() // buffer_size + 1;

                iterator.begin();
                while not iterator.finished() {
                    A = iterator.nextRange();
                    B = iterator.nextRange();

                    new int start = A.start;
                    if start == pull[0].range.start {
                        if pull[0].from_ > pull[0].to {
                            A.start += pull[0].count;

                            if A.length() == 0 {
                                continue;
                            }
                        } elif pull[0].from_ < pull[0].to {
                            B.end -= pull[0].count;

                            if B.length() == 0 {
                                continue;
                            }
                        }
                    }
                    if start == pull[1].range.start {
                        if pull[1].from_ > pull[1].to {
                            A.start += pull[1].count;

                            if A.length() == 0 {
                                continue;
                            }
                        } elif pull[1].from_ < pull[1].to {
                            B.end -= pull[1].count;

                            if B.length() == 0 {
                                continue;
                            }
                        }
                    }

                    if array[B.end - 1] < array[A.start] {
                        this.rotate(array, A.length(), WikiRange(A.start, B.end), True);
                    } elif array[A.end] < array[A.end - 1] {
                        blockA.set(A.start, A.end);
                        firstA.set(A.start, A.start + blockA.length() % block_size);

                        new int indexA = buffer1.start;
                        for index = firstA.end; index < blockA.end; index += block_size {
                            array[indexA].swap(array[index]);
                            indexA++;
                        }

                        lastA.set(firstA.start, firstA.end);
                        lastB.set(0, 0);
                        blockB.set(B.start, B.start + min(block_size, B.length()));
                        blockA.start += firstA.length();
                        indexA = buffer1.start;

                        if lastA.length() <= this.cache_size and this.cache is not None {
                            arrayCopy(array, lastA.start, this.cache, 0, lastA.length());
                        } elif buffer2.length() > 0 {
                            blockSwap(array, lastA.start, buffer2.start, lastA.length());
                        }

                        if blockA.length() > 0 {
                            while True {
                                if (lastB.length() > 0 and array[lastB.end - 1] >= array[indexA]) or blockB.length() == 0 {
                                    new int B_split, B_remaining, minA;

                                    B_split     = this.binaryFirst(array, array[indexA].readInt(), lastB);
                                    B_remaining = lastB.end - B_split;

                                    minA = blockA.start;
                                    for findA = minA + block_size; findA < blockA.end; findA += block_size {
                                        if array[findA] < array[minA] {
                                            minA = findA;
                                        }
                                    }
                                    blockSwap(array, blockA.start, minA, block_size);

                                    array[blockA.start].swap(array[indexA]);
                                    indexA++;

                                    if lastA.length() <= this.cache_size {
                                        this.mergeExternal(array, lastA, WikiRange(lastA.end, B_split));
                                    } elif buffer2.length() > 0 {
                                        this.mergeInternal(array, lastA, WikiRange(lastA.end, B_split), buffer2);
                                    } else {
                                        this.mergeInPlace(array, lastA, WikiRange(lastA.end, B_split));
                                    }

                                    if buffer2.length() > 0 or block_size <= this.cache_size {
                                        if block_size <= this.cache_size {
                                            arrayCopy(array, blockA.start, this.cache, 0, block_size);
                                        } else {
                                            blockSwap(array, blockA.start, buffer2.start, block_size);
                                        }

                                        blockSwap(array, B_split, blockA.start + block_size - B_remaining, B_remaining);
                                    } else {
                                        this.rotate(array, blockA.start - B_split, WikiRange(B_split, blockA.start + block_size), True);
                                    }

                                    lastA.set(blockA.start - B_remaining, blockA.start - B_remaining + block_size);
                                    lastB.set(lastA.end, lastA.end + B_remaining);

                                    blockA.start += block_size;
                                    if blockA.length() == 0 {
                                        break;
                                    }
                                } elif blockB.length() < block_size {
                                    this.rotate(array, -blockB.length(), WikiRange(blockA.start, blockB.end), False);

                                    lastB.set(blockA.start, blockA.start + blockB.length());
                                    blockA.start += blockB.length();
                                    blockA.end += blockB.length();
                                    blockB.end = blockB.start;
                                } else {
                                    blockSwap(array, blockA.start, blockB.start, block_size);
                                    lastB.set(blockA.start, blockA.start + block_size);

                                    blockA.start += block_size;
                                    blockA.end += block_size;
                                    blockB.start += block_size;
                                    blockB.end += block_size;

                                    if blockB.end > B.end {
                                        blockB.end = B.end;
                                    }
                                }
                            }
                        }

                        if lastA.length() <= this.cache_size {
                            this.mergeExternal(array, lastA, WikiRange(lastA.end, B.end));
                        } elif buffer2.length() > 0 {
                            this.mergeInternal(array, lastA, WikiRange(lastA.end, B.end), buffer2);
                        } else {
                            this.mergeInPlace(array, lastA, WikiRange(lastA.end, B.end));
                        }
                    }
                }

                this.insertionSort(array, buffer2);

                for pull_index = 0; pull_index < 2; pull_index++ {
                    new int unique = pull[pull_index].count * 2;

                    if pull[pull_index].from_ > pull[pull_index].to {
                        new WikiRange buffer;
                        buffer = WikiRange(pull[pull_index].range.start, pull[pull_index].range.start + pull[pull_index].count);

                        while buffer.length() > 0 {
                            index = this.findFirstForward(array, array[buffer.start].readInt(), WikiRange(buffer.end, pull[pull_index].range.end), unique);
                            new int amount = index - buffer.end;
                            this.rotate(array, buffer.length(), WikiRange(buffer.start, index), True);
                            buffer.start += (amount + 1);
                            buffer.end += amount;
                            unique -= 2;
                        }
                    } elif pull[pull_index].from_ < pull[pull_index].to {
                        new WikiRange buffer;
                        buffer = WikiRange(pull[pull_index].range.end - pull[pull_index].count, pull[pull_index].range.end);

                        while buffer.length() > 0 {
                            index = this.findLastBackward(array, array[buffer.end - 1], WikiRange(pull[pull_index].range.start, buffer.start), unique);
                            new int amount = buffer.start - index;
                            this.rotate(array, amount, WikiRange(index, buffer.end), True);
                            buffer.start -= amount;
                            buffer.end -= (amount + 1);
                            unique -= 2;
                        }
                    }
                }
            }

            if not iterator.nextLevel() {
                break;
            }
        }
    }
}

@Sort(
    "Block Merge Sorts",
    "Wiki Sort",
    "Wiki Sort"
);
new function wikiSortRun(array) {
    new int mode;
    mode = sortingVisualizer.getUserInput("Insert buffer size (0 for in-place)", "0");

    new WikiSort wikiSort = WikiSort(mode);
    wikiSort.sort(array, len(array));
}