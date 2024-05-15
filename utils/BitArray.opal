new class BitArray {
    new method __init__(array, pa, pb, size, w) {
        this.array = array;
        this.pa = pa;
        this.pb = pb;
        this.size = size;
        this.w = w;
        this.length = size * w;
    }

    new method flipBit(a, b) {
        this.array[a].swap(this.array[b]);
    }

    new method getBit(a, b) {
        return this.array[a] > this.array[b];
    }

    new method setBit(a, b, bit) {
        if this.getBit(a, b) ^ bit {
            this.flipBit(a, b);
        }
    }

    new method free() {
        new int i1 = this.pa + this.length;
        for i = this.pa, j = this.pb; i < i1; i++, j++ {
            this.setBit(i, j, False);
        }
    }

    new method set(idx, uInt) {
        assert idx >= 0 && idx < this.size;

        new int s  = idx * this.w,
                i1 = this.pa + s + this.w;

        for i = this.pa + s, j = this.pb + s; i < i1; i++, j++, uInt >>= 1 {
            this.setBit(i, j, (uInt & 1) == 1);
        } 

        if uInt > 0 {
            IO.out("Warning: Word too large\n");
        }
    }

    new method setXor(idx, val) {
        assert idx >= 0 && idx < this.size;

        new int s  = idx * this.w,
                i1 = this.pa + s + this.w;
        for i = this.pa + s, j = this.pb + s; i < i1; i++, j++, val >>= 1 {
            if (val & 1) == 1 {
                this.flipBit(i, j);
            }
        }

        if val > 0 {
            IO.out("Warning: Word too large\n");
        }
    }   

    new method get(idx) {
        assert idx >= 0 && idx < this.size;

        new int r = 0,
                s = idx * this.w;

        for k = 0, i = this.pa + s, j = this.pb + s; k < this.w; k++, i++, j++ {
            r |= int(this.getBit(i, j)) << k;
        }

        return r;
    }

    new method incr(idx) {
        assert idx >= 0 && idx < this.size;

        new int s  = idx * this.w, 
                i1 = this.pa + s + this.w;

        for i = this.pa + s, j = this.pb + s; i < i1; i++, j++ {
            this.flipBit(i, j);
            if this.getBit(i, j) {
                return;
            }
        } 

        IO.out("Warning: Integer overflow\n");
    }

    new method decr(idx) {
        assert idx >= 0 && idx < this.size;

        new int s  = idx * this.w, 
                i1 = this.pa + s + this.w;

        for i = this.pa + s, j = this.pb + s; i < i1; i++, j++ {
            this.flipBit(i, j);
            if !this.getBit(i, j) {
                return;
            }
        } 

        IO.out("Warning: Integer underflow\n");
    }

    new method swap(a, b) {
        assert a >= 0 && a < this.size;
        assert b >= 0 && b < this.size;

        new int tmp = this.get(a);
        this.set(a, this.get(b));
        this.set(b, tmp);
    }
}