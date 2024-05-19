new class BoseNelsonSort {
	
    new method __init__(end) {
        this.end = end;
    }
	
	new method compSwapCheck(array, a, b) {
		if b < this.end {
			compSwap(array, a, b);
		}
	}
	
	new method boseNelsonMerge(array, a1, a2, n, f) {
		if f {
			for i = 0; i < n; i++ {
				this.compSwapCheck(array, a1+i, a2+i);
			}
		}
		
		new int h = n // 2;
		
		if h > 1 {
			this.boseNelsonMerge(array, a1,   a2,   h, False),
			this.boseNelsonMerge(array, a1+h, a2+h, h, False);
		}
		if h > 0 {
			this.boseNelsonMerge(array, a1+h, a2, h, True);
		}
	}
	
	new method boseNelsonSort(array, a, n) {
		new int h = n // 2;
		
		if h > 1 {
			this.boseNelsonSort(array, a,   h),
			this.boseNelsonSort(array, a+h, h);
		}
		this.boseNelsonMerge(array, a, a+h, h, True);
	}
	
	new method boseNelsonMergeParallel(array, a1, a2, n, f) {
		if f {
			for i = 0; i < n; i++ {
				if a2+i < this.end {
					this.compSwapCheck(array, a1+i, a2+i);
				}
			}
		}
		
		new int h = n // 2;
		
		if h > 1 {
			new dynamic t0 = sortingVisualizer.createThread(this.boseNelsonMergeParallel, array, a1,   a2,   h, False),
						t1 = sortingVisualizer.createThread(this.boseNelsonMergeParallel, array, a1+h, a2+h, h, False);
						
			t0.start();
			t1.start();
			
			t0.join();
			t1.join();
		}
		if h > 0 {
			this.boseNelsonMergeParallel(array, a1+h, a2, h, True);
		}
	}
	
	new method boseNelsonSortParallel(array, a, n) {
		new int h = n // 2;
		
		if h > 1 {
			new dynamic t0 = sortingVisualizer.createThread(this.boseNelsonSortParallel, array, a,   h),
						t1 = sortingVisualizer.createThread(this.boseNelsonSortParallel, array, a+h, h);
						
			t0.start();
			t1.start();
			
			t0.join();
			t1.join();
		}
		this.boseNelsonMergeParallel(array, a, a+h, h, True);
	}
}

import math;

@Sort(
    "Concurrent Sorts",
    "Bose Nelson Sort",
    "Bose Nelson"
);
new function boseNelsonSortRun(array) {
    BoseNelsonSort(len(array)).boseNelsonSort(array, 0, 2**math.ceil(math.log2(len(array))));
}

@Sort(
    "Concurrent Sorts",
    "Bose Nelson Sort (Parallel)",
    "Bose Nelson (Parallel)"
);
new function boseNelsonSortRun(array) {
    sortingVisualizer.runParallel(BoseNelsonSort(len(array)).boseNelsonSortParallel, array, 0, 2**math.ceil(math.log2(len(array))));
}