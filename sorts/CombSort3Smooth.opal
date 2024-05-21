new class CombSort3Smooth {
    
    new classmethod powOfThree(array, a, b, g) {
        if 3*g < b-a {
            this.powOfThree(array, a,     b, 3*g);
            this.powOfThree(array, a+g,   b, 3*g);
            this.powOfThree(array, a+g+g, b, 3*g);
        }
        for i in range(a+g, b, g) {
            compSwap(array, i-g, i);
        }
    }
    
    new classmethod combSort(array, a, b, g) {
        if 2*g < b-a {
            this.combSort(array, a,   b, 2*g);
            this.combSort(array, a+g, b, 2*g);
        }
        this.powOfThree(array, a, b, g);
    }
    
    new classmethod powOfThreeParallel(array, a, b, g) {
        if 3*g < b-a {
            new dynamic t0 = sortingVisualizer.createThread(this.powOfThreeParallel, array, a,     b, 3*g),
                        t1 = sortingVisualizer.createThread(this.powOfThreeParallel, array, a+g,   b, 3*g),
                        t2 = sortingVisualizer.createThread(this.powOfThreeParallel, array, a+g+g, b, 3*g);
                        
            t0.start();
            t1.start();
            t2.start();
            
            t0.join();
            t1.join();
            t2.join();
        }
        for i in range(a+g, b, g) {
            compSwap(array, i-g, i);
        }
    }
    
    new classmethod combSortParallel(array, a, b, g) {
        if 2*g < b-a {
            new dynamic t0 = sortingVisualizer.createThread(this.combSortParallel, array, a,   b, 2*g),
                        t1 = sortingVisualizer.createThread(this.combSortParallel, array, a+g, b, 2*g);
                        
            t0.start();
            t1.start();
            
            t0.join();
            t1.join();
        }
        this.powOfThreeParallel(array, a, b, g);
    }
}

@Sort(
    "Concurrent Sorts",
    "Combsort with 3-Smooth Gaps",
    "3-Smooth Comb"
);
new function combSort3SmoothRun(array) {
    CombSort3Smooth.combSort(array, 0, len(array), 1);
}

@Sort(
    "Concurrent Sorts",
    "3-Smooth Combsort (Parallel)",
    "3-Smooth Comb (Parallel)"
);
new function weaveSortRun(array) {
    sortingVisualizer.runParallel(CombSort3Smooth.combSortParallel, array, 0, len(array), 1);
}