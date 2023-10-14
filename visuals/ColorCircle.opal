new class ColorCircle: CircleVisual {
    new method __init__() {
        super().__init__(
            "Color Circle",
            (255, 255, 255),
            RefreshMode.NOREFRESH, True
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

    new method draw(array, indices, color) {
        static: new bint mark;

        new dynamic drawn  = {}, 
                    oldIdx = 0, angle, pos, posEnd;

        for idx in range(len(array)) {
            angle = this.angles[idx];

            if angle in drawn {
                continue;
            } else {
                drawn[angle] = None;
            }

            pos, posEnd = this.points[angle];

            mark = True;
            if color is not None {
                for i in indices {
                    if i in range(oldIdx, idx) {
                        mark = False;
                        sortingVisualizer.graphics.polygon([
                            this.circleCenter, pos, posEnd
                        ], color);
                        break;
                    }
                }
            }

            if mark {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.polygon([
                        this.circleCenter, pos, posEnd
                    ], (255, 0, 0));
                } else {
                    sortingVisualizer.graphics.polygon([
                        this.circleCenter, pos, posEnd
                    ], hsvToRgb(array[idx].value * this.colorConstant));
                }
            }

            oldIdx = idx;
        }

        del drawn;
    }
    
    new method fastDraw(array, indices, color) {
        new dynamic drawn = {}, angle, pos, posEnd; 

        for idx in indices {
            angle = this.angles[idx];

            if angle in drawn {
                continue;
            } else {
                drawn[angle] = None;
            }

            pos, posEnd = this.points[angle];

            if color is None {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.polygon([
                        this.circleCenter, pos, posEnd
                    ], (255, 0, 0));
                } else {
                    sortingVisualizer.graphics.polygon([
                        this.circleCenter, pos, posEnd
                    ], hsvToRgb(array[idx].value * this.colorConstant));
                }
            } else {
                sortingVisualizer.graphics.polygon([
                    this.circleCenter, pos, posEnd
                ], color);
            }
        }

        del drawn;
    }

    new method drawAux(array, indices, color) {
        new dynamic drawn  = {}, 
                    oldIdx = 0, angle, pos, posEnd;

        for idx in range(len(array)) {
            angle = this.auxAngles[idx];

            if angle in drawn {
                continue;
            } else {
                drawn[angle] = None;
            }

            pos, posEnd = this.auxPoints[angle];

            for i in indices {
                if i in range(oldIdx, idx) {
                    sortingVisualizer.graphics.polygon([
                        this.auxCircleCenter, pos, posEnd
                    ], color);
                    break;
                }
            } else {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.polygon([
                        this.auxCircleCenter, pos, posEnd
                    ], (255, 0, 0));
                } else {
                    sortingVisualizer.graphics.polygon([
                        this.auxCircleCenter, pos, posEnd
                    ], hsvToRgb(array[idx].value * this.auxColorConstant));
                }
            } 

            oldIdx = idx;
        }
    }

    new method fastDrawAux(array, indices, color) {
        new dynamic drawn = {}, angle, pos, posEnd;

        for idx in range(len(array)) {
            angle = this.auxAngles[idx];

            if angle in drawn {
                continue;
            } else {
                drawn[angle] = None;
            }

            pos, posEnd = this.auxPoints[angle];

            if idx in indices {
                sortingVisualizer.graphics.polygon([
                    this.auxCircleCenter, pos, posEnd
                ], color);
            } else {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.polygon([
                        this.auxCircleCenter, pos, posEnd
                    ], (255, 0, 0));
                } else {
                    sortingVisualizer.graphics.polygon([
                        this.auxCircleCenter, pos, posEnd
                    ], hsvToRgb(array[idx].value * this.auxColorConstant));
                }
            } 
        }
    }
}