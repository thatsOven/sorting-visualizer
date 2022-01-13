@Distribution("Quadratic").run;
new function quadraticDist(array, length) {
    for i in range(length) {
        array[i] = Value((i ** 2) // length);
    }
}