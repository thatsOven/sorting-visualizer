new dynamic binaryInsertionSort;

new class StacklessQuickSort {
    new method __init__(pSel = None) {
        if pSel is None {
            this.pSel = sortingVisualizer.getPivotSelection(
                id = sortingVisualizer.getUserSelection(
                    [p.name for p in sortingVisualizer.pivotSelections],
                    "Select pivot selection: "
                )
            ).getFunc();
        } else {
            this.pSel = pSel;
        }
    }

    new method partition(array, a, b) {
        new int i = a,
                j = b;

        this.pSel(array, a, b, a);

        while True {
            do i < j and array[i] < array[a] {
                i++;
            }

            do j >= i and array[j] >= array[a] {
                j--;
            }

            if i < j {
                array[i].swap(array[j]);
            } else {
                array[a].swap(array[j]);
                return j;
            }
        }
    }

    new method sort(array, a, b) {
        new <Value> max_ = findMaxValue(array, a, b);

        for i = b - 1; i >= 0; i-- {
            if array[i] == max_ {
                b--;
                array[i].swap(array[b]);
            }
        }

        new int b1 = b;
        new bool med = True;

        while True {
            while b1 - a > 16 {
                if med {
                    this.pSel(array, a, b1, a);
                }
                new int p = this.partition(array, a, b1);
                array[p].swap(array[b]);

                b1 = p;
            }
            binaryInsertionSort(array, a, b1);

            a = b1 + 1;

            if a >= b {
                if a - 1 < b {
                    array[a - 1].swap(array[b]);
                }
                return;
            }

            b1 = lrBinarySearch(array, a, b, array[a - 1]);
            array[a - 1].swap(array[b]);

            for med = True; a < b1 and array[a - 1] == array[a]; a++ {
                med = False;
            }
            if a == b1 {
                med = True;
            }
        }
    }
}

@Sort(
    "Quick Sorts",
    "Stackless Quick Sort",
    "Stackless Quick"
);
new function stacklessQuickSortRun(array) {
    StacklessQuickSort().sort(array, 0, len(array));
}