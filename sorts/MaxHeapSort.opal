new class MaxHeapSort {
    new classmethod siftDown(array, root, dist, start) {
        while root <= dist // 2 {
            new int leaf = 2 * root;

            if leaf < dist and array[start + leaf - 1] < array[start + leaf] {
                leaf++;
            }

            if array[start + root - 1] < array[start + leaf - 1] {
                array[start + root - 1].swap(array[start + leaf - 1]);
                root = leaf;
            } else { break;}
        }
    }

    new classmethod heapify(array, a, b) {
        new int length = b - a;

        for i = length // 2; i >= 1; i-- {
            this.siftDown(array, i, length, a);
        }
    }

    new classmethod sort(array, a, b) {
        this.heapify(array, a, b);

        for i = b - a; i > 1; i-- {
            array[a].swap(array[a + i - 1]);
            this.siftDown(array, 1, i - 1, a);
        }
    }
}


@Sort(
    "Selection Sorts",
    "Max Heap Sort",
    "Max Heap Sort"
);
new function maxHeapSortRun(array) {
    MaxHeapSort.sort(array, 0, len(array));
}