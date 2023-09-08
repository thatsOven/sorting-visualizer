package perlin_noise: import PerlinNoise;

@Distribution("Perlin Noise");
new function perlinNoiseDist(array, length, unique) {
    new int seed, OCTAVES = 5;
    seed = sortingVisualizer.getUserInput("Insert seed (negative number for random seed)", "-1");

    new dynamic noise;
    if seed < 0 { 
        noise = PerlinNoise(octaves = OCTAVES, seed = random.randint(0, 1000));
    } else {
        noise = PerlinNoise(octaves = OCTAVES, seed = seed);
    }

    new int t = length // unique;

    for i = 1; i + t < length + 1; i += t {
        for j in range(t) {
            new int val = i // t;
            array[i - 1 + j] = int(noise([(val / 5000) + 0.0001, (val / 5000) - 0.0001]) * length);
        }
    }

    new int val = i // t;
    i -= 1;
    for ; i < length; i++ {
        array[i] = Value(val);
    }

    new int m = min(array);
    for i in range(length) {
        array[i] = Value(array[i] + m);
    }
}