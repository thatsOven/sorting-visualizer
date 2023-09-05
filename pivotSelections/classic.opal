@PivotSelection("First");
new function firstPivot(array, a, b, p) {
    if p != a {
        array[p].swap(array[a]);
    }
}

@PivotSelection("Last");
new function lastPivot(array, a, b, p) {
    if p != b - 1 {
        array[p].swap(array[b - 1]);
    }
}

@PivotSelection("Middle");
new function middlePivot(array, a, b, p) {
    new int mid = a + ((b - a) // 2);

    if p != mid {
        array[p].swap(array[mid]);
    }
}

@PivotSelection("Median of three");
new function medianOfThreePivot(array, a, b, p) {
    new int p0 = medianOfThreeIdx(array, a, a + (b - a) // 2, b - 1);

    if p != p0 {
        array[p].swap(array[p0]);
    }
}

@PivotSelection("Random");
new function randomPivot(array, a, b, p) {
    new int rnd = random.randint(a, b - 1);

    if rnd != p {
        array[p].swap(array[rnd]);
    }
}