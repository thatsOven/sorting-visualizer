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

    new method adaptAux(array) {
        new list result = list(chain.from_iterable(array));

        repeat this.arrayLen - len(result) {
            result.append(Value(0));
        }

        for i in range(len(result)) {
            if result[i].idx is None {
                result[i].idx = i;
                result[i].stabIdx = i;
                result[i].setAux(True);
            }
        }

        return result;
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

    new method auxWrite(aux, dig, array, idx) {
        new dynamic value = array[idx].read();
        new dynamic sTime = default_timer();
        aux[dig].append(value);
        sortingVisualizer.timer(sTime);
        sortingVisualizer.writes++;
        sortingVisualizer.highlight(idx);
    }

    new method LSD(array, a, b) {
        this.arrayLen = b - a;

        new int hPow = this.getHighestPower(array, a, b);

        new list aux = [[] for _ in range(this.base)];

        sortingVisualizer.setAdaptAux(this.adaptAux);
        sortingVisualizer.setAux(aux);

        for p in range(hPow + 1) {
            for i = a; i < b; i++ {
                new int dig = array[i].readDigit(p, this.base);
                this.auxWrite(aux, dig, array, i);
            }

            this.transcribe(array, a, aux);
        }
    }

    new method MSD(array, a, b, p = None) {
        this.arrayLen = b - a;

        if p is None {
            p = this.getHighestPower(array, a, b);
            sortingVisualizer.setAdaptAux(this.adaptAux);
        }

        if a >= b or p < -1 {
            return;
        }

        new list aux = [[] for _ in range(this.base)];
        sortingVisualizer.setAux(aux);

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
);
new function MSDRadixSortRun(array) {
    RadixSort().MSD(array, 0, len(array));
}