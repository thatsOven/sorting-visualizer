use reverse;

@Rotation("Cycle Reverse", RotationMode.INDEXED);
new function cycleReverseRotate(array, a, m, e) {
    static: new int lenA = m - a,
                    lenB = e - m;

    if lenA < 1 || lenB < 1 {
        return;
    }

    static: new int b = m - 1,
                    c = m,
                    d = e - 1;

    new Value swap;

    while a < b && c < d {
        swap = array[b].read();
        array[b].write(array[a]);
        b--;
        array[a].write(array[c]);
        a++;
        array[c].write(array[d]);
        c++;
        array[d].write(swap);
        d--;
    }

    while a < b {
        swap = array[b].read();
        array[b].write(array[a]);
        b--;
        array[a].write(array[d]);
        a++;
        array[d].write(swap);
        d--;
    }

    while c < d {
        swap = array[c].read();
        array[c].write(array[d]);
        c++;
        array[d].write(array[a]);
        d--;
        array[a].write(swap);
        a++;
    }

    if a < d {
        reverse(array, a, d + 1);
    }
}