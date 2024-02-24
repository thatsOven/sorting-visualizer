new class RadixSort {
    new method __init__(base = None) {
        if base is None {
            this.base = sortingVisualizer.getUserInput(
                "Insert base: ",
                "4", int);
        } else {
            this.base = base;
        }
        this.arrayLen = None;
    }

    new method getHighestPower(array, a, b) {
        return findHighestPower(array, a, b, this.base);
    }

    new method adaptAux(_) {
        new list result = list(chain.from_iterable(this.aux));

        repeat this.arrayLen - len(result) {
            result.append(Value(0));
        }

        for i in range(len(result)) {
            if result[i].idx is None {
                result[i].idx = i;
                result[i].stabIdx = i;
                result[i].setAux(result);
            }
        }

        return result;
    }

    new method adaptIdx(idx, aux) {
        static: new int out;
        for out = 0; idx >= 0; idx-- {
            out += len(this.aux[idx]);
        }
    
        return out - 1;
    }

    new method transcribe(array, a, aux, empty = True) {
        new int i = a;
        for j in range(len(aux)) {
            for element in aux[j] {
                array[i].write(element);
                i++;
            }
            if empty {
                sortingVisualizer.writes += len(aux[j]);
                aux[j].clear();
            }
        }
    }

    new method auxWrite(aux, dig, array, i) {
        new Value val = array[i].copy();
        val.idx = dig;
        val.setAux(this.aux);

        new dynamic sTime = default_timer();
        aux[dig].append(val);
        sortingVisualizer.timer(sTime);
        sortingVisualizer.writes++;
        sortingVisualizer.highlight(dig, aux);
    }

    new method LSD(array, a, b) {
        this.arrayLen = b - a;

        new int hPow = this.getHighestPower(array, a, b);

        this.aux = [[] for _ in range(this.base)];

        sortingVisualizer.setAdaptAux(this.adaptAux, this.adaptIdx);
        sortingVisualizer.addAux(this.aux);

        for p in range(hPow + 1) {
            for i = a; i < b; i++ {
                new int dig = array[i].readDigit(p, this.base);
                this.auxWrite(this.aux, dig, array, i);
            }

            this.transcribe(array, a, this.aux);
        }
    }

    new method MSD(array, a, b, p = None) {
        this.arrayLen = b - a;

        if p is None {
            p = this.getHighestPower(array, a, b);
            sortingVisualizer.setAdaptAux(this.adaptAux, this.adaptIdx);
        }

        if a >= b or p < -1 {
            return;
        }

        new list aux = [[] for _ in range(this.base)];
        this.aux = aux;
        sortingVisualizer.addAux(aux);

        for i = a; i < b; i++ {
            new int dig = array[i].readDigit(p, this.base);
            this.auxWrite(aux, dig, array, i);
        }

        this.transcribe(array, a, aux, False);

        new int sum_ = 0;
        for i in range(len(aux)) {
            this.MSD(array, a + sum_, a + sum_ + len(aux[i]), p - 1);

            sum_ += len(aux[i]);
            sortingVisualizer.writes += len(aux[i]);
            aux[i].clear();
        }
    }
}

@Sort(
    "Distribution Sorts",
    "Least Significant Digit Radix Sort",
    "LSD Radix Sort"
);
new function LSDRadixSortRun(array) {
    RadixSort().LSD(array, 0, len(array));
}

@Sort(
    "Distribution Sorts",
    "Most Significant Digit Radix Sort",
    "MSD Radix Sort",
    usesDynamicAux = True
);
new function MSDRadixSortRun(array) {
    RadixSort().MSD(array, 0, len(array));
}