new class Spiral: BaseCircleVisual {
    new method __init__() {
        super().__init__(
            "Spiral",
            (255, 0, 0), 
            RefreshMode.FULL, True
        );
    }

    new method prepare() {
        super.prepare();

        static: new int length = len(sortingVisualizer.array);

        this.lineLengthConst = this.circleRadius / sortingVisualizer.arrayMax;

        this.points = {};
        for i in range(length) {
            new dynamic angle = Utils.translate(i, 0, length, this.circleStart, this.circleEnd);
            new dynamic pos, posEnd, end, endStep;
            
            pos = Vector().fromAngle(angle);
            posEnd = Vector().fromAngle(angle + this.angleStep);

            end = pos.copy();
            end.magnitude(this.circleRadius);
            end = end.getIntCoords();
            end += this.circleCenter;

            endStep = posEnd.copy();
            endStep.magnitude(this.circleRadius);
            endStep = endStep.getIntCoords();
            endStep += this.circleCenter;

            this.points[i] = (pos, posEnd, end, endStep);
        }
    }

    new method onAuxOn(length) {
        super.onAuxOn(length);

        this.auxLineLengthConst = this.circleRadius / max(sortingVisualizer.auxMax, sortingVisualizer.arrayMax);

        this.auxPoints = {};
        for i in range(length) {
            new dynamic angle = Utils.translate(i, 0, length, this.circleStart, this.circleEnd);
            new dynamic pos, posEnd;
            
            pos = Vector().fromAngle(angle);
            posEnd = Vector().fromAngle(angle + this.auxAngleStep);

            this.points[i] = (pos, posEnd);
        }
    }

    new method draw(array, indices, color) {
        if color is None {
            color = (255, 255, 255);
        }

        new dynamic drawn = {}, pos, posEnd, angle, l, end, endStep;
        
        for idx in indices {
            l = array[idx].value * this.lineLengthConst;
            pos, posEnd, end, endStep = this.points[idx];

            pos.magnitude(l);
            pos = pos.getIntCoords();
            pos += this.circleCenter;

            posEnd.magnitude(l);
            posEnd = posEnd.getIntCoords();
            posEnd += this.circleCenter;

            sortingVisualizer.graphics.polygon([
                this.circleCenter, end, endStep
            ], (0, 0, 0));

            sortingVisualizer.graphics.polygon([
                this.circleCenter, pos, posEnd
            ], color);
        }

        del drawn;
    }

    new method drawAux(array, indices, color) {
        new dynamic drawn = {}, pos, posEnd, angle, l;

        sortingVisualizer.graphics.fastCircle(this.auxCircleCenter, this.auxCircleRadius, (0, 0, 0));

        for idx in range(len(array)) {
            l = array[idx].value * this.auxLineLengthConst;
            pos, posEnd = this.auxPoints[i];
            
            pos.magnitude(l);
            pos = pos.getIntCoords();
            pos += this.auxCircleCenter;

            posEnd.magnitude(l);
            posEnd = posEnd.getIntCoords();
            posEnd += this.auxCircleCenter;

            if idx in indices {
                sortingVisualizer.graphics.polygon([
                    this.circleCenter, pos, posEnd
                ], color);
            } else {
                sortingVisualizer.graphics.polygon([
                    this.circleCenter, pos, posEnd
                ], (255, 255, 255));
            }
        }

        del drawn;
    }
}

new class RainbowSpiral: Spiral {
    new method __init__() {
        Visual.__init__(
            this,
            "Rainbow Spiral",
            (255, 255, 255), 
            RefreshMode.FULL, True
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
        new dynamic drawn = {}, pos, posEnd, angle, l, end, endStep;
        
        for idx in indices {
            l = array[idx].value * this.lineLengthConst;
            pos, posEnd, end, endStep = this.points[idx];

            pos.magnitude(l);
            pos = pos.getIntCoords();
            pos += this.circleCenter;

            posEnd.magnitude(l);
            posEnd = posEnd.getIntCoords();
            posEnd += this.circleCenter;

            sortingVisualizer.graphics.polygon([
                this.circleCenter, end, endStep
            ], (0, 0, 0));

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
        new dynamic drawn = {}, pos, posEnd, angle, l;

        sortingVisualizer.graphics.fastCircle(this.auxCircleCenter, this.auxCircleRadius, (0, 0, 0));

        for idx in range(len(array)) {
            l = array[idx].value * this.auxLineLengthConst;
            pos, posEnd = this.auxPoint[idx];
            
            pos.magnitude(l);
            pos = pos.getIntCoords();
            pos += this.auxCircleCenter;

            posEnd.magnitude(l);
            posEnd = posEnd.getIntCoords();
            posEnd += this.auxCircleCenter;

            if idx in indices {
                sortingVisualizer.graphics.polygon([
                    this.circleCenter, pos, posEnd
                ], color);
            } else {
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
        }

        del drawn;
    }
}