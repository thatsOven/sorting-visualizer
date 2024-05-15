new class KWayMerge {
    new classmethod keyLessThan(src, pa, a, b) bool {
        new int cmp = compareValues(src[pa[a].readInt()], src[pa[b].readInt()]);
        return cmp < 0 || (cmp == 0 && a < b);
    }

    new classmethod siftDown(src, heap, pa, t, r, size) {
        while 2 * r + 2 < size {
            new int nxt  = 2 * r + 1,
                    min_ = nxt + int(!this.keyLessThan(src, pa, heap[nxt].readInt(), heap[nxt + 1].readInt()));

            if this.keyLessThan(src, pa, heap[min_].readInt(), t) {
                heap[r].write(heap[min_]);
                r = min_;
            } else {
                break;
            }
        }

        new int min_ = 2 * r + 1;

        if min_ < size && this.keyLessThan(src, pa, heap[min_].readInt(), t) {
            heap[r].write(heap[min_]);
            r = min_;
        } 

        heap[r].write(t);
    }

    new classmethod kWayMerge(src, dest, heap, pa, pb, size) {
        for i = 0; i < size; i++ {
            heap[i].write(i);
        }

        for i = (size - 1) // 2; i >= 0; i-- {
            this.siftDown(src, heap, pa, heap[i].readInt(), i, size);
        }

        for i = 0; size > 0; i++ {
            new int min_ = heap[0].readInt();

            dest[i].write(src[pa[min_].readInt()]);
            pa[min_]++;

            if pa[min_] == pb[min_] {
                size--;
                this.siftDown(src, heap, pa, heap[size].readInt(), 0, size);
            } else {
                this.siftDown(src, heap, pa, heap[0].readInt(), 0, size);
            }
        }
    }
}