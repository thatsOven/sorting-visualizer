@Distribution("Quintic");
new function quinticDist(array, length, unique) {
    new float mid = (length - 1) / 2;
    new int t = length // unique;

    for i = 1; i + t < length + 1; i += t {
        for j in range(t) {
            array[i - 1 + j] = Value(int((((i // t - mid) ** 5) / (mid ** 4)) + mid));
        }
    }

    new int val = i // t;
    i -= 1;
    for ; i < length; i++ {
        array[i] = Value(val);
    }
}