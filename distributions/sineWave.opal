@Distribution("Sine Wave");
new function sineWaveDist(array, length, unique) {
    new int n = length - 1,
            t = length // unique;
    new float c = 2 * math.pi / n;

    for i in range(length) {
        
    }

    for i = 1; i + t < length + 1; i += t {
        for j in range(t) {
            array[i - 1 + j] = Value(int(n * (math.sin(c * (i // t)) + 1) / 2));
        }
    }

    new int val = i // t;
    i -= 1;
    for ; i < length; i++ {
        array[i] = Value(val);
    }
}