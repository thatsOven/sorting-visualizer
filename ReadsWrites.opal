new class Writes {
    new method __init__() {
        this.writes = 0;
        this.swaps  = 0;
    }

    new method addWrite() {
        this.writes++;
    }

    new method addSwap() {
        this.swaps++;
        this.writes += 2;
    }

    new method reset() {
        this.swaps  = 0;
        this.writes = 0;
    }
}

new class Reads {
    new method __init__() {
        this.reads       = 0;
        this.comparisons = 0;
    }

    new method addRead() {
        this.reads++;
    }

    new method addComparison() {
        this.comparisons++;
        this.reads += 2;
    }

    new method reset() {
        this.reads       = 0;
        this.comparisons = 0;
    }
}