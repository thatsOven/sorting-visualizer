new class DataTrace: BaseDataTrace {
    new Vector UNIT_VECTOR = Vector(1, 1),
               ZERO_VEC    = Vector();

    new int HIGHLIGHT_HEIGHT = 4;

    new method __init__() {
        super.__init__(
            "Data Trace",
            (255, 255, 255),
            RefreshMode.NOREFRESH
        );
    }

    new method prepare() {
        super.prepare();

        this.colorConstant = 1.0 / sortingVisualizer.arrayMax;
    }

    new method onAuxOn(length) {
        super.onAuxOn(length);

        this.auxColorConstant = 1.0 / sortingVisualizer.auxMax;
    }

    new method draw(array, indices) {
        static: new int oldIdx, i, j;

        static: new list arrayValues = [x.value for x in array];
        if arrayValues != this.oldArray {
            this.oldArray = arrayValues;
            this.mainSurf.scroll(dy = -1);

            new dynamic pos = sortingVisualizer.graphics.resolution.copy(), idx;
            pos.y--;
            pos.x = 0;

            if len(array) > sortingVisualizer.graphics.resolution.x {
                oldIdx = 0;
                unchecked: repeat sortingVisualizer.graphics.resolution.x {
                    idx = int(Utils.translate(
                        pos.x, 0, sortingVisualizer.graphics.resolution.x, 
                        0, len(array)
                    ));

                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.fastRectangle(pos, this.UNIT_VECTOR, (255, 0, 0), 0, True, this.mainSurf);
                    } else {
                        sortingVisualizer.graphics.fastRectangle(pos, this.UNIT_VECTOR, hsvToRgb(array[idx].value * this.colorConstant), 0, True, this.mainSurf);
                    }

                    pos.x++;
                    oldIdx = idx;
                }
            } else {
                new dynamic vec = Vector(this.lineSize, 1);

                oldIdx = -1;
                for i = this.lineSize // 2; i < sortingVisualizer.graphics.resolution.x; i += this.lineSize {
                    idx = int(Utils.translate(
                        i - this.lineSize // 2, 0, sortingVisualizer.graphics.resolution.x, 
                        0, len(array)
                    ));
                    
                    pos.x = i;

                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.fastRectangle(pos, vec, (255, 0, 0), 0, True, this.mainSurf);
                    } else {
                        sortingVisualizer.graphics.fastRectangle(pos, vec, hsvToRgb(array[idx].value * this.colorConstant), 0, True, this.mainSurf);
                    }

                    oldIdx = idx;
                }
            }
        }

        sortingVisualizer.graphics.blitSurf(this.mainSurf, this.ZERO_VEC);

        new dynamic drawn = {};
        new dynamic vec = Vector(this.lineSize, this.HIGHLIGHT_HEIGHT);
        new dynamic pos = sortingVisualizer.graphics.resolution.copy();
        pos.y -= this.HIGHLIGHT_HEIGHT // 2;

        for idx in indices {
            if indices[idx] is None {
                continue;
            }

            pos.x = Utils.translate(
                idx, 0, len(array), 0, 
                sortingVisualizer.graphics.resolution.x // this.lineSize
            ) * this.lineSize + (this.lineSize // 2);

            if pos.x in drawn {
                continue;
            } else {
                drawn[pos.x] = None;
            }

            sortingVisualizer.graphics.fastRectangle(pos, vec, indices[idx], 0, True);
        }

        del drawn;
    }

    new method drawAux(array, indices) {
        static: new int oldIdx, i, j;

        static: new list arrayValues = [x.value for x in array];
        if arrayValues != this.oldAux {
            this.oldAux = arrayValues;
            this.auxSurf.scroll(dy = -1);

            new dynamic pos = this.auxResolution.copy(), idx;
            pos.y--;
            pos.x = 0;

            if len(array) > this.auxResolution.x {
                oldIdx = 0;
                unchecked: repeat this.auxResolution.x {
                    idx = int(Utils.translate(
                        pos.x, 0, this.auxResolution.x, 
                        0, len(array)
                    ));

                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.fastRectangle(pos, this.UNIT_VECTOR, (255, 0, 0), 0, True, this.auxSurf);
                    } else {
                        sortingVisualizer.graphics.fastRectangle(pos, this.UNIT_VECTOR, hsvToRgb(array[idx].value * this.auxColorConstant), 0, True, this.auxSurf);
                    }

                    pos.x++;
                    oldIdx = idx;
                }
            } else {
                new dynamic vec = Vector(this.auxLineSize, 1);

                oldIdx = -1;
                for i = this.auxLineSize // 2; i < this.auxResolution.x; i += this.auxLineSize {
                    idx = int(Utils.translate(
                        i - this.auxLineSize // 2, 0, this.auxResolution.x, 
                        0, len(array)
                    ));
                    
                    pos.x = i;

                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.fastRectangle(pos, vec, (255, 0, 0), 0, True, this.auxSurf);
                    } else {
                        sortingVisualizer.graphics.fastRectangle(pos, vec, hsvToRgb(array[idx].value * this.auxColorConstant), 0, True, this.auxSurf);
                    }

                    oldIdx = idx;
                }
            }
        }

        sortingVisualizer.graphics.blitSurf(this.auxSurf, this.ZERO_VEC);

        new dynamic drawn = {};
        new dynamic vec = Vector(this.auxLineSize, this.HIGHLIGHT_HEIGHT);
        new dynamic pos = this.auxResolution.copy();
        pos.y -= this.HIGHLIGHT_HEIGHT // 2;

        for idx in indices {
            if indices[idx] is None {
                continue;
            }

            pos.x = Utils.translate(
                idx, 0, len(array), 0, 
                this.auxResolution.x // this.auxLineSize
            ) * this.auxLineSize + (this.auxLineSize // 2);

            if pos.x in drawn {
                continue;
            } else {
                drawn[pos.x] = None;
            }

            sortingVisualizer.graphics.fastRectangle(pos, vec, indices[idx], 0, True);
        }

        del drawn;

        sortingVisualizer.graphics.line(Vector(0, this.auxResolution.y), this.auxResolution, (0, 0, 255), 2);
    }
}