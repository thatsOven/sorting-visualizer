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

new function medianOfThreeIdx(array, a, m, b) {
    if array[m] > array[a] {
        if array[m] < array[b] {
            return m;
        }

        if array[a] > array[b] {
            return a;
        }

        return b;
    }

    if array[m] > array[b] {
        return m;
    }
        
    if array[a] < array[b] {
        return a;
    }

    return b;
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
    return (a > b) - (a < b);
}

new function compareIntToValue(a, value) {
    return (value < a) - (value > a);
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

new function findMinMaxValue(array, a, b) {
    new Value currMin = array[a].copy(),
              currMax = currMin;

    for i = a + 1; i < b; i++ {
        if array[i] < currMin {
            currMin = array[i].copy();
        } elif array[i] > currMax {
            currMax = array[i].copy();
        }
    }
    return currMin, currMax;
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
    return math.log(findMax(array, a, b), base);
}