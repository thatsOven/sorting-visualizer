new class RadixSort {
    new method __init__(base = None) {
        if base is None {
            this.base = sortingVisualizer.getUserInput(
                "Insert base: ",
                "4", int
            );
        } else {
            this.base = base;
        }
        this.arrayLen = None;
        this.offs = 0;
    }

    new method getHighestPower(array, a, b) {
        return findHighestPower(array, a, b, this.base);
    }

    new method adaptAuxLSD(arrays) {
        new list result = list(chain.from_iterable(arrays[0]));

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

    new method transcribe(array, a, aux, empty = True) {
        new int k = 0;
        for j in range(len(aux)) {
            for i in range(len(aux[j])) {
                aux[j][i].idx = k;
                k++;
            }
        }

        new int i = a;
        for j in range(len(aux)) {
            for element in aux[j] {
                array[i].write(element);
                i++;
            }
        }

        if empty {
            for j in range(len(aux)) {
                sortingVisualizer.writes += len(aux[j]);
                aux[j].clear();
            }
        }
    }

    new method auxWrite(aux, dig, array, i) {
        new Value val = array[i].copy();
        val.setAux(aux);

        new dynamic sTime = default_timer();
        aux[dig].append(val);
        sortingVisualizer.timer(sTime);
        sortingVisualizer.writes++;
    }

    new method LSD(array, a, b) {
        this.arrayLen = b - a;

        new int hPow = this.getHighestPower(array, a, b);

        new list aux = [[] for _ in range(this.base)];

        sortingVisualizer.setAdaptAux(this.adaptAuxLSD);
        sortingVisualizer.addAux(aux);

        for p in range(hPow + 1) {
            for i = a; i < b; i++ {
                new int dig = array[i].readDigit(p, this.base);
                this.auxWrite(aux, dig, array, i);
            }

            this.transcribe(array, a, aux);
        }
    }

    new method adaptAuxMSD(arrays) {
        new list result = list(chain.from_iterable(list(chain.from_iterable(arrays))));

        if len(result) == 0 {
            result = [Value(0)];
            result[0].idx = 0;
            result[0].stabIdx = 0;
            result[0].setAux(result);
            return result;
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
        return this.offs + idx;
    }

    new method MSD(array, a, b, p = None) {
        if p is None {
            p = this.getHighestPower(array, a, b);
            sortingVisualizer.setAdaptAux(this.adaptAuxMSD, this.adaptIdx);
        }

        if a >= b or p < -1 {
            return;
        }

        new list aux = [[] for _ in range(this.base)];
        sortingVisualizer.addAux(aux);

        for i = a; i < b; i++ {
            new int dig = array[i].readDigit(p, this.base);
            this.auxWrite(aux, dig, array, i);
        }

        this.transcribe(array, a, aux, False);
        this.offs += b - a;

        new int sum_ = 0;
        for i in range(len(aux)) {
            this.MSD(array, a + sum_, a + sum_ + len(aux[i]), p - 1);

            sum_ += len(aux[i]);
            sortingVisualizer.writes += len(aux[i]);
            this.offs -= len(aux[i]);
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