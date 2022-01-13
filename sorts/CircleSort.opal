new class CircleSort() {
    new classmethod converge(array, a, b) {
        new bool s = False;
        for ; a <= b; a++, b-- {
            if array[a] > array[b] {
                array[a].swap(array[b]);
                s = True;
            }
        }
        return s;
    }

    new classmethod sorter(array, a, b) {
        if b - a == 1 {
            if array[a] > array[b] {
                array[a].swap(array[b]);
                return True;
            }
            return False;
        } elif b - a < 1 {
            return False;
        }

        new bool l, r, s; 
        s = this.converge(array, a, b);

        new int m = a + ((b - a) // 2);
        
        l = this.sorter(array, a, m);
        r = this.sorter(array, m, b);

        return s or l or r;
    }

    new classmethod sort(array, a, b) {
        while this.sorter(array, a, b - 1) {}
    }
}

@Sort(
    "Exchange Sorts",
    "Circle Sort",
    "Circle Sort"
).run;
new function circleSortRun(array) {
    CircleSort.sort(array, 0, len(array));
}