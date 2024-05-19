namespace ShellSort {
    new list seq = [8861, 3938, 1750, 701, 301, 132, 57, 23, 10, 4, 1];

    new classmethod sort(array, a, b) {
        for gap in this.seq {
            if gap >= b - a {
                continue;
            }

            for i = a + gap; i < b; i++ {
                new Value tmp;
                new int   idx;

                tmp, idx = array[i].readNoMark();

                for j = i; j >= a + gap and array[j - gap] > tmp; j -= gap {
                    array[j].write(array[j - gap].noMark());
                }
                array[j].writeRestoreIdx(tmp, idx);
            }
        }
    }
	
	new classmethod gappedInsert(array, a, b, gap) {
		for i = a + gap; i < b; i += gap {
			new Value tmp;
			new int   idx;

			tmp, idx = array[i].readNoMark();

			for j = i; j >= a + gap and array[j - gap] > tmp; j -= gap {
				array[j].write(array[j - gap].noMark());
			}
			array[j].writeRestoreIdx(tmp, idx);
		}
	}
	
	new classmethod sortParallel(array, a, b) {
		for gap in this.seq {
			if gap > b-a-1 {
				continue;
			}
			
			new list threads = [];
			
			for i in range(gap) {
				threads.append(sortingVisualizer.createThread(this.gappedInsert, array, a+i, b, gap));
			}
			for t in threads {
				t.start();
			}
			for t in threads {
				t.join();
			}
		}
	}
}

@Sort(
    "Insertion Sorts",
    "Shell Sort",
    "Shell Sort"
);
new function shellSortRun(array) {
    ShellSort.sort(array, 0, len(array));
}

@Sort(
    "Insertion Sorts",
    "Parallel Shell Sort",
    "Shell Sort (Parallel)"
);
new function shellSortRun(array) {
    sortingVisualizer.runParallel(ShellSort.sortParallel, array, 0, len(array));
}