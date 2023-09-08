@Distribution("Sine Wave");
new function sineWaveDist(array, length) {
    new int n = length - 1;
    new float c = 2 * math.pi / n;

    for i in range(length) {
        array[i] = int(n * (math.sin(c * i) + 1) / 2);
    }
}