new class OddEvenMergeSort {
    new method __init__(end) {
        this.end = end;
    }
    
    new classmethod oddEvenMergeSort(array, length) {
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
    
    new method compSwapCheck(array, a, b) {
        if b < this.end {
            compSwap(array, a, b);
        }
    }
    
    new method oddEvenMergeParallel(array, a, ia, im, ib, bLen, loop) {
        new dynamic t0 = sortingVisualizer.createThread(this.oddEvenMergeParallel, array, a, ia, (ia+im) // 2, im, bLen, False),
                    t1 = sortingVisualizer.createThread(this.oddEvenMergeParallel, array, a, im, (im+ib) // 2, ib, bLen, False);
                    
        if im-ia > 1 {
            t0.start();
            t1.start();
        }
        
        new int p = a + im*bLen*2;
        
        for i in range(bLen) {
            this.compSwapCheck(array, p+i - bLen, p+i);
        }
        
        if im-ia > 1 {
            t0.join();
            t1.join();
        }
        if loop and bLen > 1 {
            this.oddEvenMergeParallel(array, a, ia, im+im, ib+ib, bLen // 2, True);
        }
    }

    new method oddEvenMergeSortParallel(array, a, b) {
        new int h = (b-a) // 2;

        if h > 1 {
            new dynamic t0 = sortingVisualizer.createThread(this.oddEvenMergeSortParallel, array, a, a+h),
                        t1 = sortingVisualizer.createThread(this.oddEvenMergeSortParallel, array, a+h, b);
                        
            t0.start();
            t1.start();
            
            t0.join();
            t1.join();
        }
        for i in range(h) {
            this.compSwapCheck(array, a+i, a+i + h);
        }
        this.oddEvenMergeParallel(array, a, 0, 1, 2, (b-a) // 4, True);
    }
}

@Sort(
    "Concurrent Sorts",
    "Odd Even Merge Sort",
    "Odd Even Merge"
);
new function oddEvenMergeSortRun(array) {
    OddEvenMergeSort(len(array)).oddEvenMergeSort(array, len(array));
}

@Sort(
    "Concurrent Sorts",
    "Parallel Odd Even Merge Sort",
    "Odd Even Merge (Parallel)"
);
new function oddEvenMergeSortRun(array) {
    sortingVisualizer.runParallel(OddEvenMergeSort(len(array)).oddEvenMergeSortParallel, array, 0, 2**math.ceil(math.log2(len(array))));
}