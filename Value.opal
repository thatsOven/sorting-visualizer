new class HighlightInfo {
    new method __init__(idx, aux = None, color = None, silent = False) {
        this.idx    = idx;
        this.aux    = aux;
        this.color  = color;
        this.silent = silent;
    }

    new method __eq__(other) {
        return this.idx == other.idx && this.aux is other.aux;
    }

    new method __hash__() {
        return hash((this.idx, id(this.aux)));
    }
}

@total_ordering;
new class VerifyValue {
    new method __init__(value, stabIdx) {
        this.value   = value;
        this.stabIdx = stabIdx;
    }

    new method __eq__(other) {
        return this.value == other.value;
    }

    new method __lt__(other) {
        return this.value < other.value;
    }
}

new class Value {
    new method __init__(value) {
        this.value   = value;
        this.idx     = None;
        this.stabIdx = None;
        this.aux     = None;
    }

    new method copy() {
        new Value val = Value(this.value);
        val.idx     = this.idx;
        val.stabIdx = this.stabIdx;
        val.aux     = this.aux;

        return val;
    }

    new method noMark() {
        new Value val = Value(this.value);
        val.stabIdx = this.stabIdx;

        return val;
    }

    new method getInt() {
        return this.value;
    }

    new method setAux(val) {
        this.aux = val;
    }

    new method getHighlightInfo() {
        return HighlightInfo(this.idx, this.aux, None);
    }

    new method readDigit(d, base) {
        sortingVisualizer.reads++;

        new dynamic sTime = default_timer(),
                    temp  = (this.value // (base ** d)) % base;
        sortingVisualizer.timer(sTime);

        sortingVisualizer.highlightAdvanced(this.getHighlightInfo());

        return int(temp);
    }

    new method readInt() {
        sortingVisualizer.reads++;

        new dynamic sTime = default_timer(),
                    temp  = this.value;
        sortingVisualizer.timer(sTime);

        sortingVisualizer.highlightAdvanced(this.getHighlightInfo());

        return temp;
    }

    new method read() {
        sortingVisualizer.reads++;

        new dynamic sTime = default_timer(),
                    temp  = this.value, val;
        sortingVisualizer.timer(sTime);

        sortingVisualizer.highlightAdvanced(this.getHighlightInfo());

        val         = Value(temp);
        val.idx     = this.idx;
        val.stabIdx = this.stabIdx;

        return val;
    }

    new method readNoMark() {
        sortingVisualizer.reads++;

        new dynamic sTime = default_timer(),
                    temp  = this.value, val;
        sortingVisualizer.timer(sTime);

        sortingVisualizer.highlightAdvanced(this.getHighlightInfo());

        val = Value(temp);
        val.stabIdx = this.stabIdx;

        return val, this.idx;
    }

    new method __eq__(other) {
        sortingVisualizer.comparisons++;

        new dynamic compResult;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            compResult = this.value == other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            compResult = this.value == other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        } else {
            return False;
        }

        return compResult;
    }

    new method __ne__(other) {
        sortingVisualizer.comparisons++;

        new dynamic compResult;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            compResult = this.value != other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            compResult = this.value != other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        } else {
            return False;
        }

        return compResult;
    }

    new method __lt__(other) {
        sortingVisualizer.comparisons++;

        new dynamic compResult;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            compResult = this.value < other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            compResult = this.value < other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        } else {
            return False;
        }

        return compResult;
    }

    new method __gt__(other) {
        sortingVisualizer.comparisons++;

        new dynamic compResult;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            compResult = this.value > other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            compResult = this.value > other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        } else {
            return False;
        }

        return compResult;
    }

    new method __le__(other) {
        sortingVisualizer.comparisons++;

        new dynamic compResult;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            compResult = this.value <= other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            compResult = this.value <= other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        } else {
            return False;
        }

        return compResult;
    }

    new method __ge__(other) {
        sortingVisualizer.comparisons++;

        new dynamic compResult;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            compResult = this.value >= other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            compResult = this.value >= other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        } else {
            return False;
        }

        return compResult;
    }

    new method write(other) {
        sortingVisualizer.writes++;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            this.value = other.value;
            sortingVisualizer.timer(sTime);

            this.stabIdx = other.stabIdx;
            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            this.value = other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        }
    }

    new method writeRestoreIdx(other, idx) {
        sortingVisualizer.writes++;

        if type(this) == type(other) {
            other.idx = idx;

            new dynamic sTime = default_timer();
            this.value = other.value;
            sortingVisualizer.timer(sTime);

            this.stabIdx = other.stabIdx;
            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            this.value = other;
            sortingVisualizer.timer(sTime);

            this.idx = idx;

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        }
    }

    new method swap(other) {
        sortingVisualizer.swaps++;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            unchecked: this.value, other.value = other.value, this.value;
            sortingVisualizer.timer(sTime);

            unchecked: this.stabIdx, other.stabIdx = other.stabIdx, this.stabIdx;
            unchecked:     this.aux,     other.aux =     other.aux,     this.aux;

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        }
    }

    new method __repr__() {
        return "Value(" + str(this.value) + ", " + str(this.idx) + ", " + str(this.stabIdx) + ")";
    }

    new method __add__(other) {
        if type(this) == type(other) {
            new dynamic sTime = default_timer(),
                        temp  = this.value + other.value;
            sortingVisualizer.timer(sTime);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer(),
                        temp  = this.value + other;
            sortingVisualizer.timer(sTime);
        }

        return temp;
    }

    new method __sub__(other) {
        if type(this) == type(other) {
            new dynamic sTime = default_timer(),
                        temp  = this.value - other.value;
            sortingVisualizer.timer(sTime);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer(),
                        temp  = this.value - other;
            sortingVisualizer.timer(sTime);
        }

        return temp;
    }

    new method __mul__(other) {
        if type(this) == type(other) {
            new dynamic sTime = default_timer(),
                        temp  = this.value * other.value;
            sortingVisualizer.timer(sTime);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer(),
                        temp  = this.value * other;
            sortingVisualizer.timer(sTime);
        }

        return temp;
    }

    new method __truediv__(other) {
        if type(this) == type(other) {
            new dynamic sTime = default_timer(),
                        temp  = this.value / other.value;
            sortingVisualizer.timer(sTime);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer(),
                        temp  = this.value / other;
            sortingVisualizer.timer(sTime);
        }

        return temp;
    }

    new method __floordiv__(other) {
        if type(this) == type(other) {
            new dynamic sTime = default_timer(),
                        temp  = this.value // other.value;
            sortingVisualizer.timer(sTime);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer(),
                        temp  = this.value // other;
            sortingVisualizer.timer(sTime);
        }

        return temp;
    }

    new method __mod__(other) {
        if type(this) == type(other) {
            new dynamic sTime = default_timer(),
                        temp  = this.value % other.value;
            sortingVisualizer.timer(sTime);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer(),
                        temp  = this.value & other;
            sortingVisualizer.timer(sTime);
        }

        return temp;
    }

    new method __pow__(other) {
        if type(this) == type(other) {
            new dynamic sTime = default_timer(),
                        temp  = this.value ** other.value;
            sortingVisualizer.timer(sTime);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer(),
                        temp  = this.value ** other;
            sortingVisualizer.timer(sTime);
        }

        return temp;
    }

    new method __lshift__(other) {
        if type(this) == type(other) {
            new dynamic sTime = default_timer(),
                        temp  = this.value << other.value;
            sortingVisualizer.timer(sTime);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer(),
                        temp  = this.value << other;
            sortingVisualizer.timer(sTime);
        }

        return temp;
    }

    new method __rshift__(other) {
        if type(this) == type(other) {
            new dynamic sTime = default_timer(),
                        temp  = this.value >> other.value;
            sortingVisualizer.timer(sTime);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer(),
                        temp  = this.value >> other;
            sortingVisualizer.timer(sTime);
        }

        return temp;
    }

    new method __and__(other) {
        if type(this) == type(other) {
            new dynamic sTime = default_timer(),
                        temp  = this.value & other.value;
            sortingVisualizer.timer(sTime);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer(),
                        temp  = this.value & other;
            sortingVisualizer.timer(sTime);
        }

        return temp;
    }

    new method __xor__(other) {
        if type(this) == type(other) {
            new dynamic sTime = default_timer(),
                        temp  = this.value ^ other.value;
            sortingVisualizer.timer(sTime);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer(),
                        temp  = this.value ^ other;
            sortingVisualizer.timer(sTime);
        }

        return temp;
    }

    new method __or__(other) {
        if type(this) == type(other) {
            new dynamic sTime = default_timer(),
                        temp  = this.value | other.value;
            sortingVisualizer.timer(sTime);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer(),
                        temp  = this.value | other;
            sortingVisualizer.timer(sTime);
        }

        return temp;
    }

    new method __iadd__(other) {
        sortingVisualizer.writes++;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            this.value += other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            this.value += other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        }

        return this;
    }

    new method __isub__(other) {
        sortingVisualizer.writes++;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            this.value -= other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            this.value -= other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        }

        return this;
    }

    new method __imul__(other) {
        sortingVisualizer.writes++;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            this.value *= other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            this.value *= other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        }

        return this;
    }

    new method __itruediv__(other) {
        sortingVisualizer.writes++;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            this.value /= other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            this.value /= other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        }

        return this;
    }

    new method __ifloordiv__(other) {
        sortingVisualizer.writes++;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            this.value //= other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            this.value //= other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        }

        return this;
    }

    new method __imod__(other) {
        sortingVisualizer.writes++;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            this.value %= other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            this.value %= other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        }

        return this;
    }

    new method __ipow__(other) {
        sortingVisualizer.writes++;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            this.value **= other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            this.value **= other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        }

        return this;
    }

    new method __ilshift__(other) {
        sortingVisualizer.writes++;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            this.value <<= other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            this.value <<= other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        }

        return this;
    }

    new method __irshift__(other) {
        sortingVisualizer.writes++;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            this.value >>= other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            this.value >>= other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        }

        return this;
    }

    new method __iand__(other) {
        sortingVisualizer.writes++;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            this.value &= other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            this.value &= other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        }

        return this;
    }

    new method __ixor__(other) {
        sortingVisualizer.writes++;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            this.value ^= other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            this.value ^= other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        }

        return this;
    }

    new method __ior__(other) {
        sortingVisualizer.writes++;

        if type(this) == type(other) {
            new dynamic sTime = default_timer();
            this.value |= other.value;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.multiHighlightAdvanced([this.getHighlightInfo(), other.getHighlightInfo()]);
        } elif type(other) in [int, float] {
            new dynamic sTime = default_timer();
            this.value |= other;
            sortingVisualizer.timer(sTime);

            sortingVisualizer.highlightAdvanced(this.getHighlightInfo());
        }

        return this;
    }
}