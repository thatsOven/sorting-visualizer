new class WeaveSort {
    new method __init__(end) {
        this.end = end;
    }
    
    new method compSwapCheck(array, a, b) {
        if b < this.end {
            compSwap(array, a, b);
        }
    }
    
    new method circleRec(array, p, n, g) {
        new int h = n // 2;
        
        for i = 0; i < h; i++ {
            this.compSwapCheck(array, p + i*g, p + (n-1-i)*g);
        }
        
        if n >= 2 {
            this.circleRec(array, p,       h, g);
            this.circleRec(array, p + h*g, h, g);
        }
    }
    
    new method weaveSort(array, p, n, g) {
        if n >= 2 {
            new int h = n // 2;
            
            this.weaveSort(array, p,   h, 2*g);
            this.weaveSort(array, p+g, h, 2*g);
        }
        this.circleRec(array, p, n, g);
    }
    
    new method circleRecParallel(array, p, n, g) {
        new int h = n // 2;
        
        for i = 0; i < h; i++ {
            this.compSwapCheck(array, p + i*g, p + (n-1-i)*g);
        }
        
        if n >= 2 {
            new dynamic t0 = sortingVisualizer.createThread(this.circleRecParallel, array, p,       h, g),
                        t1 = sortingVisualizer.createThread(this.circleRecParallel, array, p + h*g, h, g);
                        
            t0.start();
            t1.start();
            
            t0.join();
            t1.join();
        }
    }
    
    new method weaveSortParallel(array, p, n, g) {
        if n >= 2 {
            new int h = n // 2;
            
            new dynamic t0 = sortingVisualizer.createThread(this.weaveSortParallel, array, p,   h, 2*g),
                        t1 = sortingVisualizer.createThread(this.weaveSortParallel, array, p+g, h, 2*g);
                        
            t0.start();
            t1.start();
            
            t0.join();
            t1.join();
        }
        this.circleRecParallel(array, p, n, g);
    }
}

import math;

@Sort(
    "Concurrent Sorts",
    "Weave Sorting Network",
    "Weave"
);
new function weaveSortRun(array) {
    WeaveSort(len(array)).weaveSort(array, 0, 2**math.ceil(math.log2(len(array))), 1);
}

@Sort(
    "Concurrent Sorts",
    "Weave Sorting Network (Parallel)",
    "Weave (Parallel)"
);
new function weaveSortRun(array) {
    sortingVisualizer.runParallel(WeaveSort(len(array)).weaveSortParallel, array, 0, 2**math.ceil(math.log2(len(array))), 1);
}