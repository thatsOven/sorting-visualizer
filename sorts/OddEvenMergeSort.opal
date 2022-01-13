new function oddEvenMergeSort(array, length) {
    for p = 1; p < length; p *= 2 {
        for k = p; k > 0; k //= 2 {
            for j = k % p; j + k < length; j += k * 2 {
                for i = 0; i < k; i++ {
                    if (i + j) // (p * 2) == (i + j + k) // (p * 2) {
                        if i + j + k < length {
                            compSwap(array, i + j, i + j + k);
                        }
                    }
                }
            }
        }
    }
}

@Sort(
    "Concurrent Sorts",
    "Odd Even Merge Sort",
    "Odd Even Merge"
).run;
new function oddEvenMergeSortRun(array) {
    oddEvenMergeSort(array, len(array));
}