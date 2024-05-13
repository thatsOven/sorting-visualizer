use adaptLow;

new class AmericanFlagSort {
    new method __init__(buckets = None) {
        if buckets is None {
            this.buckets = sortingVisualizer.getUserInput(
                "Insert bucket count: ",
                "128", int);
        } else {
            this.buckets = buckets;
        }

        this.count = None;
    }

    new method __adaptAux(arrays) {
        return adaptLow(arrays, (this.count, ));
    }

    new method sorter(array, a, b, d) {
        sortingVisualizer.setAdaptAux(this.__adaptAux);
        this.count = sortingVisualizer.createValueArray(this.buckets);
        new dynamic offset = sortingVisualizer.createValueArray(this.buckets);
        
        new int digit;
        for i = a; i < b; i++ {
            digit = array[i].readDigit(d, this.buckets);
            this.count[digit]++;
        }

        offset[0].write(a);
        for i = 1; i < this.buckets; i++ {
            offset[i].write(this.count[i - 1] + offset[i - 1]);
        }

        for v in range(this.buckets) {
            while this.count[v] > 0 {
                new int origin = offset[v].readInt(),
                        from_  = origin;
                new Value num = array[from_].copy();

                array[from_].write(-1);

                do from_ != origin {
                    digit = num.readDigit(d, this.buckets);
                    new int to = offset[digit].readInt();
                    offset[digit]++;
                    this.count[digit]--;

                    new Value temp = array[to].copy();
                    array[to].write(num);
                    num = temp.copy();
                    from_ = to;
                }
            }
        }

        this.count = None;

        if d > 0 {
            for i in range(this.buckets) {
                new int begin = offset[i - 1].readInt() if i > 0 else a,
                        end   = offset[i].readInt();

                if end - begin > 1 {
                    this.sorter(array, begin, end, d - 1);
                }
            }
        }
    }

    new method sort(array, a, b) {
        new int m = findHighestPower(array, a, b, this.buckets);
        this.sorter(array, a, b, m);
    }
}

@Sort(
    "Distribution Sorts",
    "American Flag Sort",
    "American Flag Sort",
    usesDynamicAux = True
);
new function americanFlagSortRun(array) {
    AmericanFlagSort().sort(array, 0, len(array));
}