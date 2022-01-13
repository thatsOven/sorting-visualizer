new dynamic uncheckedInsertionSort, MaxHeapSort;

new function staticSort(array, a, b) {
    new int min_, max_;
    dynamic: min_, max_ = findMinMax(array, a, b);

    new int auxLen = b - a;

    new list count  = sortingVisualizer.createValueArray(auxLen + 1),
             offset = sortingVisualizer.createValueArray(auxLen + 1);

    new float CONST = auxLen / (max_ - min_ + 4);

    for i = a; i < b; i++ {
        count[int((array[i].readInt() - min_) * CONST)]++;
    }
    offset[0].write(a);

    for i = 1; i < auxLen; i++ {
        offset[i].write(count[i - 1] + offset[i - 1]);
    }

    for v in range(auxLen) {
        while count[v] > 0 {
            new int origin = offset[v].readInt(),
                    from_  = origin;
            new <Value> num = array[from_].copy();

            array[from_].write(-1);

            do from_ != origin {
                new int dig = int((num.readInt() - min_) * CONST),
                         to = offset[dig].readInt();
                offset[dig]++;
                count[dig]--;

                new <Value> temp = array[to].copy();
                array[to].write(num);
                num = temp.copy();
                from_ = to;
            }
        }
    }

    for i in range(auxLen) {
        new int begin = offset[i - 1].readInt() if i > 0 else a,
                end   = offset[i].readInt();

        if end - begin > 1 {
            if end - begin > 16 {
                MaxHeapSort.sort(array, begin, end);
            } else {
                uncheckedInsertionSort(array, begin, end);
            }
        }
    }
}

@Sort(
    "Distribution Sorts",
    "staticSort [Utils.Iterables.fastSort]",
    "staticSort"
).run;
new function staticSortRun(array) {
    staticSort(array, 0, len(array));
}