package perlin_noise: import PerlinNoise;

@Distribution("Perlin Noise");
new function perlinNoiseDist(array, length) {
    new int seed, OCTAVES = 5;
    seed = sortingVisualizer.getUserInput("Insert seed (negative number for random seed)", "-1");

    new dynamic noise;
    if seed < 0 { 
        noise = PerlinNoise(octaves = OCTAVES, seed = random.randint(0, 1000));
    } else {
        noise = PerlinNoise(octaves = OCTAVES, seed = seed);
    }

    for i in range(length) {
        array[i] = int(noise([(i / 500) + 0.0001, (i / 500) - 0.0001]) * length);
    }

    new int m = min(array);
    if m < 0 {
        m = -m;
    } else {
        m = 0;
    }

    for i in range(length) {
        array[i] += m;
    }
}