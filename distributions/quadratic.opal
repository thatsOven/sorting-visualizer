@Distribution("Quadratic");
new function quadraticDist(array, length, unique) {
    new int t = length // unique;

    for i = 1; i + t < length + 1; i += t {
        for j in range(t) {
            array[i - 1 + j] = Value(((i // t) ** 2) // length);
        }
    }

    new int val = i // t;
    i -= 1;
    for ; i < length; i++ {
        array[i] = Value(val);
    }
}