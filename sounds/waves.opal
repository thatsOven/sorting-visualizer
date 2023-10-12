new class SquareWave: Sound {
    new method __init__() {
        super.__init__("Square wave");
    }

    new classmethod play(value, max_, sample) {
        return 200.0 * signal.square(
            2.0 * numpy.pi * ((450.0 + (value * (500.0 / max_)))) 
        * sample); 
    }
}

new class SawtoothWave: Sound {
    new method __init__() {
        super.__init__("Sawtooth wave");
    }

    new method play(value, max_, sample) {
        return 200.0 * signal.sawtooth(
            2.0 * numpy.pi * ((450.0 + (value * (500.0 / max_)))) 
        * sample); 
    }
}