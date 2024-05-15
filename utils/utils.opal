new function checkSorted(array, a, b) {
    for i = a; i < b - 1; i++ {
        if array[i] > array[i + 1] {
            return False;
        }
    }
    return True;
}

new function compSwap(array, a, b) {
    if array[a] > array[b] {
        array[a].swap(array[b]);
    }
}

new function partition(array, a, b, p) {
    new int i = a - 1, j = b;

    while True {
        i++;
        while  i < b and array[i] < array[p] { i++;}

        j--;
        while j >= a and array[j] > array[p] { j--;}

        if i < j { array[i].swap(array[j]);}
        else     { return j;}
    }
}

new function medianOfThree(array, a, b) {
    b--;

    new int m = a + (b - a) // 2;

    if array[a] > array[m] {
        array[a].swap(array[m]);
    } 
    if array[m] > array[b] {
        array[m].swap(array[b]);
        
        if array[a] > array[m] { return;}
    }
        
    array[a].swap(array[m]);
}

new function medianOfThreeIndices(array, indices) {
    if len(indices) == 0 {
        return -1;
    }

    if len(indices) < 3 {
        return indices[0];
    }

    if array[indices[1]] > array[indices[0]] {
        if array[indices[2]] > array[indices[1]] {
            return indices[1];
        }

        if array[indices[0]] < array[indices[2]] {
            return indices[2];
        }

        return indices[0];
    }

    if array[indices[2]] < array[indices[1]] {
        return indices[1];
    }
        
    if array[indices[2]] > array[indices[0]] {
        return indices[0];
    }

    return indices[2];
}

new function medianOfThreeIdx(array, a, m, b) {
    return medianOfThreeIndices(array, [a, m, b]);
}

new function medianOf9(array, a, b) {
    new int l = b - a,
		    h = l // 2,
		    q = h // 2,
		    e = q // 2;

    new int m0 = medianOfThreeIndices(array, [        a,         a + e, a + q    ]),
            m1 = medianOfThreeIndices(array, [a + q + e,         a + h, a + h + e]),
            m2 = medianOfThreeIndices(array, [a + h + q, a + h + q + e, b - 1    ]);

    return medianOfThreeIndices(array, [m0, m1, m2]);
}

new function mOMHelper(array, a, len) {
    if len == 1 {
        return a;
    }

    new int t = len // 3;
    return medianOfThreeIndices(array, [
        mOMHelper(array,         a, t),
        mOMHelper(array,     a + t, t),
        mOMHelper(array, a + 2 * t, t)
    ]);
}

new function medianOfMedians(array, a, len) {
    if len == 1 {
        return a;
    }

    new int nearPow = 3 ** round(math.log(len, 3));
    if nearPow == len {
        return mOMHelper(array, a, len);
    }

    nearPow //= 2;
    if 2 * nearPow >= len {
        nearPow //= 3;
    }

    return medianOfThreeIndices(array, [
        mOMHelper(array,                 a, nearPow),
        mOMHelper(array, a + len - nearPow, nearPow),
        medianOfMedians(array, a + nearPow, len - 2 * nearPow)
    ]);
}

new function reverse(array, a, b) {
    for b--; a < b; a++, b-- {
        array[a].swap(array[b]);
    }
}

new function arrayCopy(fromArray, fromIndex, toArray, toIndex, length) {
    for i in range(length) {
        toArray[toIndex + i].write(fromArray[fromIndex + i]);
    }
}

new function reverseArrayCopy(fromArray, fromIndex, toArray, toIndex, length) {
    for i = length - 1; i >= 0; i-- {
        toArray[toIndex + i].write(fromArray[fromIndex + i]);
    }
}

new function bidirArrayCopy(fromArray, fromIndex, toArray, toIndex, length) {
    if fromArray != toArray || toIndex < fromIndex {
        arrayCopy(fromArray, fromIndex, toArray, toIndex, length);
    } else {
        reverseArrayCopy(fromArray, fromIndex, toArray, toIndex, length);
    }
}

new function blockSwap(array, a, b, len) {
    for i = 0; i < len; i++ {
        array[a + i].swap(array[b + i]);
    }
}

new function backwardBlockSwap(array, a, b, len) {
    for i = len - 1; i >= 0; i-- {
        array[a + i].swap(array[b + i]);
    } 
}

new function compareValues(a, b) {
    new int x, y;
    if type(a) is Value {
        x = a.getInt();
    } else {
        x = a;
    }

    if type(b) is Value {
        y = b.getInt();
    } else {
        y = b;
    }

    sortingVisualizer.comparisons++;
    return (x > y) - (x < y);
}

new function compareIntToValue(a, value) {
    new int x = value.readInt();
    return (x < a) - (x > a);
}

new function insertToLeft(array, _from, to) {
    new Value temp;
    new int   idx;

    temp, idx = array[_from].readNoMark();

    for i = _from - 1; i >= to; i-- {
        array[i + 1].write(array[i].noMark());
    }
    array[to].writeRestoreIdx(temp, idx);
}

new function insertToRight(array, _from, to) {
    new Value temp;
    new int   idx;

    temp, idx = array[_from].readNoMark();

    for i = _from; i < to; i++ {
        array[i].write(array[i + 1].noMark());
    }
    array[to].writeRestoreIdx(temp, idx);
}

new function checkMergeBounds(array, a, m, b, rotate = None) {
    if rotate is None {
        rotate = sortingVisualizer.getRotation(
            name = "Helium"
        ).indexedFn;
    }

    if   array[m - 1] <= array[m] {
        return True;
    } elif array[a] > array[b - 1] {
        rotate(array, a, m, b);
        return True;
    }
    return False;
}

new function lrBinarySearch(array, a, b, val, left = True) {
    while a < b {
        new int m = a + ((b - a) // 2), cmp;

        cmp = compareValues(array[m], val);
        if (cmp >= 0 if left else cmp > 0) {
            b = m;
        } else {
            a = m + 1;
        }
    }

    return a;
}

new function dualPivotPartition(array, a, b) {
    new int l, g, k;

    l = a + 1;
    g = b - 1;
    k = l;

    for ; k <= g; k++ {
        if array[k] < array[a] {
            array[k].swap(array[l]);
            l++;
        } elif array[k] >= array[b] {
            while array[g] > array[b] and k < g {
                g--;
            }

            array[k].swap(array[g]);
            g--;

            if array[k] < array[a] {
                array[k].swap(array[l]);
                l++;
            }
        }
    }

    l--;
    g++;

    array[a].swap(array[l]);
    array[b].swap(array[g]);

    return l, g;
}

new function LLPartition(array, a, b) {
    b--;

    new Value pivot = array[b].copy();

    for i = a, j = a; j <= b; j++ {
        if array[j] < pivot {
            array[i].swap(array[j]);
            i++;
        }
    }
    array[i].swap(array[b]);
    return i;
}

new function findMinMaxIndices(array, a, b) {
    new int currMin = a,
            currMax = a;

    for i = a + 1; i < b; i++ {
        if array[i] < array[currMin] {
            currMin = i;
        } elif array[i] > array[currMax] {
            currMax = i;
        }
    }

    return currMin, currMax;
}

new function findMinMaxValue(array, a, b) {
    new int min_, max_;
    min_, max_ = findMinMaxIndices(array, a, b);
    return array[min_].copy(), array[max_].copy();
}

new function findMinMax(array, a, b) {
    new Value currMin, currMax;
    currMin, currMax = findMinMaxValue(array, a, b);
    return currMin.readInt(), currMax.readInt();
}

new function findMaxValue(array, a, b) {
    new Value currMax = array[a].copy();

    for i = a + 1; i < b; i++ {
        if array[i] > currMax {
            currMax = array[i].copy();
        }
    }
    return currMax;
}

new function findMax(array, a, b) {
    return findMaxValue(array, a, b).readInt();
}

new function findMaxIndex(array, a, b) {
    static: new int idx = 0;
    new Value max_ = array[0].copy();

    for i = a; i < b; i++ {
        if array[i] > max_ {
            max_ = array[i].copy();
            idx = i;
        }
    }

    return idx;
}

new function findMinValue(array, a, b) {
    new Value currMin = array[a].copy();

    for i = a + 1; i < b; i++ {
        if array[i] < currMin {
            currMin = array[i].copy();
        }
    }
    return currMin;
}

new function findMin(array, a, b) {
    return findMinValue(array, a, b).readInt();
}

new function findHighestPower(array, a, b, base) {
    return int(math.log(findMax(array, a, b), base));
}

new function log2(n) {
    new int target = 0;
    for ; n != 0; n >>= 1, target++ {}
    return target;
}

new function javaNumberOfLeadingZeros(i) {
    if i <= 0 {
        return 32 if i == 0 else 0;
    }

    new int n = 31;

    if i >= 1 << 16 {
        n  -= 16;
        i >>= 16;
    }

    if i >= 1 << 8 {
        n  -= 8;
        i >>= 8;
    }

    if i >= 1 << 4 {
        n  -= 4;
        i >>= 4;
    }

    if i >= 1 << 2 {
        n  -= 2;
        i >>= 2;
    }

    return n - (i >> 1);
}

new function javaNumberOfTrailingZeros(i) {
    i = ~i & (i - 1);
    if i <= 0 {
        return i & 32;
    }

    new int n = 1;
    if i > 1 << 16 {
        n  += 16;
        i >>= 16;
    }

    if i > 1 << 8 {
        n  += 8;
        i >>= 8;
    }

    if i > 1 << 4 {
        n  += 4;
        i >>= 4;
    }

    if i > 1 << 2 {
        n  += 2;
        i >>= 2;
    }

    return n + (i >> 1);
}