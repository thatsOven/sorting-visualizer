new class BWGradientCircle: CircleVisual {
    new method __init__() {
        super().__init__(
            "B/W Gradient Circle",
            (255, 0, 0),
            RefreshMode.NOREFRESH, True
        );
    }

    new method prepare() {
        super.prepare();

        this.colorConstant = 215.0 / sortingVisualizer.arrayMax;
    }

    new method onAuxOn(length) {
        super.onAuxOn(length);

        this.auxColorConstant = 215.0 / sortingVisualizer.auxMax;
    }

    new method draw(array, indices) {
        new dynamic drawn = {}, angle, pos, posEnd;

        for idx in range(len(array)) {
            angle = this.angles[idx];

            if angle in drawn {
                continue;
            } else {
                drawn[angle] = None;
            }

            pos, posEnd = this.points[angle];

            if idx in indices && indices[idx] is not None {
                sortingVisualizer.graphics.polygon([
                    this.circleCenter, pos, posEnd
                ], indices[idx]);
            } else {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.polygon([
                        this.circleCenter, pos, posEnd
                    ], (40, 40, 40));
                } else {
                    sortingVisualizer.graphics.polygon([
                        this.circleCenter, pos, posEnd
                    ], [40 + int(array[idx].value * this.colorConstant)] * 3);
                }
            }
        }

        del drawn;
    }
    
    new method fastDraw(array, indices) {
        new dynamic drawn = {}, angle, pos, posEnd; 

        for idx in indices {
            angle = this.angles[idx];

            if angle in drawn {
                continue;
            } else {
                drawn[angle] = None;
            }

            pos, posEnd = this.points[angle];

            if indices[idx] is None {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.polygon([
                        this.circleCenter, pos, posEnd
                    ], (40, 40, 40));
                } else {
                    sortingVisualizer.graphics.polygon([
                        this.circleCenter, pos, posEnd
                    ], [40 + int(array[idx].value * this.colorConstant)] * 3);
                }
            } else {
                sortingVisualizer.graphics.polygon([
                    this.circleCenter, pos, posEnd
                ], indices[idx]);
            }
        }

        del drawn;
    }

    new method drawAux(array, indices) {
        new dynamic drawn = {}, angle, pos, posEnd;

        for idx in range(len(array)) {
            angle = this.auxAngles[idx];

            if angle in drawn {
                continue;
            } else {
                drawn[angle] = None;
            }

            pos, posEnd = this.auxPoints[angle];

            if idx in indices && indices[idx] is not None {
                sortingVisualizer.graphics.polygon([
                    this.auxCircleCenter, pos, posEnd
                ], indices[idx]);
            } else {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.polygon([
                        this.auxCircleCenter, pos, posEnd
                    ], (40, 40, 40));
                } else {
                    sortingVisualizer.graphics.polygon([
                        this.auxCircleCenter, pos, posEnd
                    ], [40 + int(array[idx].value * this.auxColorConstant)] * 3);
                }
            } 
        }
    }
}