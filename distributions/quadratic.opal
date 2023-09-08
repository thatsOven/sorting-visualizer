@Distribution("Quadratic");
new function quadraticDist(array, length) {
    for i in range(length) {
        array[i] = (i ** 2) // length;
    }
}