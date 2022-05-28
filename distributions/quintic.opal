@Distribution("Quintic");
new function quinticDist(array, length) {
    new float mid = (length - 1) / 2;

    for i in range(length) {
        array[i] = Value(int((((i - mid) ** 5) / (mid ** (4))) + mid));
    }
}