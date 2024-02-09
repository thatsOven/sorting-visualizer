use javaNumberOfLeadingZeros;

namespace SmoothSort {
    new list LP = [
        1, 1, 3, 5, 9, 15, 25, 41, 67, 109, 177, 287, 465, 
        753, 1219, 1973, 3193, 5167, 8361, 13529, 21891
    ];

    new classmethod sift(array, pshift, head) {
        new Value val = array[head].copy();

        while pshift > 1 {
            new int rt = head - 1,
                    lf = rt - SmoothSort.LP[pshift - 2];

            if val >= array[lf] && val >= array[rt] {
                break;
            }

            if array[lf] >= array[rt] {
                array[head].write(array[lf]);
                head = lf;
                pshift--;
            } else {
                array[head].write(array[rt]);
                head = rt;
                pshift -= 2;
            }
        }

        array[head].write(val);
    }

    new classmethod trinkle(array, p, pshift, head, isTrusty) {
        new Value val = array[head].copy();

        while p != 1 {
            new int stepson = head - SmoothSort.LP[pshift];

            if array[stepson] <= val {
                break;
            }

            if (!isTrusty) && pshift > 1 {
                new int rt = head - 1,
                        lf = rt - SmoothSort.LP[pshift - 2];

                if array[rt] >= array[stepson] || array[lf] >= array[stepson] {
                    break;
                }
            }

            array[head].write(array[stepson]);

            head = stepson;
            new int trail = javaNumberOfLeadingZeros((p >> 1) << 1);
            p >>= trail;
            pshift += trail;
            isTrusty = False;
        }

        if !isTrusty {
            array[head].write(val);
            this.sift(array, pshift, head);
        }
    }

    new classmethod sort(array, lo, hi) {
        new int head   = lo,
                p      = 1,
                pshift = 1;

        for ; head < hi; p |= 1, head++ {
            if (p & 3) == 3 {
                this.sift(array, pshift, head);
                p >>= 2;
                pshift += 2;
            } else {
                if SmoothSort.LP[pshift] - 1 >= hi - head {
                    this.trinkle(array, p, pshift, head, False);
                } else {
                    this.sift(array, pshift, head);
                }

                if pshift == 1{
                    p <<= 1;
                    pshift--;
                } else {
                    p <<= (pshift - 1);
                    pshift = 1;
                }
            }
        }

        this.trinkle(array, p, pshift, head, False);

        for ; pshift != 1 || p != 1; head-- {
            if pshift <= 1 {
                new int trail = javaNumberOfLeadingZeros((p >> 1) << 1);
                p >>= trail;
                pshift += trail;
            } else {
                p <<= 2;
                p ^= 7;
                pshift -= 2;

                this.trinkle(array, p >> 1, pshift + 1, head - SmoothSort.LP[pshift] - 1, True);
                this.trinkle(array, p, pshift, head - 1, True);
            }
        }
    }
}

@Sort(
    "Tree Sorts",
    "Smooth Sort",
    "Smooth Sort",
    enabled = False
);
new function smoothSortRun(array) {
    SmoothSort.sort(array, 0, len(array));
}