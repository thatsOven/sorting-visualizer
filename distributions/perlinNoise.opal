package perlin_noise: import PerlinNoise;

@Distribution("Perlin Noise").run;
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
        array[i] = Value(int(abs(noise([(i / 5000) + 0.0001, (i / 5000) - 0.0001])) * length));
    }
}