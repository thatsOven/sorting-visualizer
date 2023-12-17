@PivotSelection("First");
new function firstPivot(array, a, b) {
    return a;
}

@PivotSelection("Last");
new function lastPivot(array, a, b) {
    return b - 1;
}

@PivotSelection("Middle");
new function middlePivot(array, a, b) {
    return a + ((b - a) // 2);
}

@PivotSelection("Median of three (unstable)");
new function medianOfThreeUnstablePivot(array, a, b) {
    medianOfThree(array, a, b);
    return a + ((b - a) // 2);
}

@PivotSelection("Median of three");
new function medianOfThreePivot(array, a, b) {
    return medianOfThreeIdx(array, a, a + (b - a) // 2, b - 1);
}

@PivotSelection("Random");
new function randomPivot(array, a, b) {
    return random.randint(a, b - 1);
}