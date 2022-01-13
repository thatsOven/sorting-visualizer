new function pairwiseSort(array, f, l, g = 1) {
    if f == l - g {
        return;
    }

    for b = f + g; b < l; b += 2 * g {
        compSwap(array, b - g, b);
    }

    if ((l - f) // g) % 2 == 0 {
        pairwiseSort(array,     f,     l, g * 2);
        pairwiseSort(array, f + g, l + g, g * 2);
    } else {
        pairwiseSort(array,     f, l + g, g * 2);
        pairwiseSort(array, f + g,     l, g * 2);
    }

    for a = 1; a < (l - f) // g; a = (a * 2) + 1 {}

    for b = f + g; b + g < l; b += 2 * g {
        new int c = a;
        while c > 1 {
            c //= 2;

            if b + (c * g) < l {
                compSwap(array, b, b + (c * g));
            }
        }
    }
}

@Sort(
    "Concurrent Sorts",
    "Pairwise Sorting Network",
    "Pairwise"
).run;
new function pairwiseSortRun(array) {
    pairwiseSort(array, 0, len(array));
}