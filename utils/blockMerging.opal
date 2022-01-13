new dynamic lrBinarySearch, heliumRotate, insertToLeft;

new function pow2Sqrt(n) {
    for s = 1; s ** 2 < n; s *= 2 {}
    return s;
}

new function checkSortedIdx(array, a, b) {
    for ; a < b - 1; a++ {
        if array[a] > array[a + 1] {
            return a;
        }
    }
    return b;
}

new function findKeysSorted(array, a, b, q) {
    new int n = 1,
            p = a;

    for i = a + 1; i < b and n < q; i++ {
        if array[i] > array[i - 1] {
            heliumRotate(array, p, p + n, i);
            p += i - (p + n);
            n++;
        }
    }

    if n == q {
        heliumRotate(array, a, p, p + n);
    } else {
        heliumRotate(array, p, p + n, b);
    }

    return n;
}

new function findKeysUnsorted(array, a, p, b, q, to) {
    new int n = p - a, l;

    p = a;
    for i = p + n; i < b and n < q; i++ {
        l = lrBinarySearch(array, p, p + n, array[i], True);
        if i == l or array[i] != array[l] {
            heliumRotate(array, p, p + n, i);
            l += i - (p + n);
            p += i - (p + n);
            insertToLeft(array, p + n, l);
            n++;
        }
    }

    heliumRotate(array, to, p, p + n);
    return n;
}

new function findKeys(array, a, b, q, t) {
    new int p = checkSortedIdx(array, a, b);

    if p == b {
        return -1;
    }

    if p - a <= t {
        return findKeysUnsorted(array, a, a, b, q, a);
    } else {
        new int n = findKeysSorted(array, a, p, q);
        if n == q {
            return n;
        }

        return this.findKeysUnsorted(array, p - n, p, b, q, a);
    }
}