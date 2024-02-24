new class CombSort {
    new method __init__(shrink = None) {
        if shrink is None {
            new float tmp = sortingVisualizer.getUserInput(
                "Insert shrink factor:",
                "1.3",
                float
            );

            if tmp < 1 {
                this.shrink = 1.3;
            } else {
                this.shrink = tmp;
            }
        } else {
            this.shrink = shrink;
        }
    }

    new method sort(array, a, b) {
        new bool swapped = False;
        new  int     gap = b - a;

        while (gap > 1) or swapped {
            if gap > 1 {
                gap /= this.shrink;
                gap = int(gap);
            }

            swapped = False;

            for i = a; gap + i < b; i++ {
                if array[i] > array[i + gap] {
                    array[i].swap(array[i + gap]);
                    swapped = True;
                }
            }
        }
    }
}

@Sort(
    "Exchange Sorts",
    "Comb Sort",
    "Comb Sort"
);
new function combSortRun(array) {
    CombSort().sort(array, 0, len(array));
}