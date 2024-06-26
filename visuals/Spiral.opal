new class Spiral: BaseCircleVisual {
    new method __init__() {
        super().__init__(
            "Spiral",
            (255, 0, 0), 
            outOfText = True
        );
    }

    new method prepare() {
        super.prepare();

        static: new int length = len(sortingVisualizer.array);

        this.lineLengthConst = this.circleRadius / sortingVisualizer.arrayMax;

        this.points = {};
        for i in range(length) {
            new dynamic angle = (
                Utils.translate(
                    i, 0, length, this.circleStart, 
                    this.circleEnd
                )
            );

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

        this.auxLineLengthConst = this.circleRadius / sortingVisualizer.auxMax;

        this.auxPoints = {};
        for i in range(length) {
            new dynamic angle = (
                Utils.translate(
                    i, 0, length, this.circleStart, 
                    this.circleEnd
                )
            );

            new dynamic pos, posEnd;
            
            pos = Vector().fromAngle(angle);
            posEnd = Vector().fromAngle(angle + this.auxAngleStep);

            this.points[i] = (pos, posEnd);
        }
    }

    new method draw(array, indices) {        
        new dynamic drawn = {}, pos, posEnd, angle, l, end, endStep;
        
        for idx in range(len(array)) {
            l = array[idx].value * this.lineLengthConst;
            pos, posEnd, end, endStep = this.points[idx];

            if (pos.x, pos.y) in drawn {
                continue;
            } else {
                drawn[(pos.x, pos.y)] = None;
            }

            pos.magnitude(l);
            pos = pos.getIntCoords();
            pos += this.circleCenter;

            posEnd.magnitude(l);
            posEnd = posEnd.getIntCoords();
            posEnd += this.circleCenter;

            if idx in indices && indices[idx] is not None {
                sortingVisualizer.graphics.polygon([
                    this.circleCenter, pos, posEnd
                ], indices[idx]);
            } else {
                sortingVisualizer.graphics.polygon([
                    this.circleCenter, pos, posEnd
                ], (255, 255, 255));
            }
        }

        del drawn;
    }

    new method drawAux(array, indices) {
        new dynamic drawn = {}, pos, posEnd, angle, l, end, endStep;
        
        for idx in range(len(array)) {
            l = array[idx].value * this.auxLineLengthConst;
            pos, posEnd, end, endStep = this.auxPoints[idx];

            if (pos.x, pos.y) in drawn {
                continue;
            } else {
                drawn[(pos.x, pos.y)] = None;
            }

            pos.magnitude(l);
            pos = pos.getIntCoords();
            pos += this.auxCircleCenter;

            posEnd.magnitude(l);
            posEnd = posEnd.getIntCoords();
            posEnd += this.auxCircleCenter;

            if idx in indices && indices[idx] is not None {
                sortingVisualizer.graphics.polygon([
                    this.auxCircleCenter, pos, posEnd
                ], indices[idx]);
            } else {
                sortingVisualizer.graphics.polygon([
                    this.auxCircleCenter, pos, posEnd
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
            outOfText = True
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
        new dynamic drawn = {}, pos, posEnd, angle, l, end, endStep;
        
        for idx in range(len(array)) {
            l = array[idx].value * this.lineLengthConst;
            pos, posEnd, end, endStep = this.points[idx];

            if (pos.x, pos.y) in drawn {
                continue;
            } else {
                drawn[(pos.x, pos.y)] = None;
            }

            pos.magnitude(l);
            pos = pos.getIntCoords();
            pos += this.circleCenter;

            posEnd.magnitude(l);
            posEnd = posEnd.getIntCoords();
            posEnd += this.circleCenter;

            if idx in indices && indices[idx] is not None {
                sortingVisualizer.graphics.polygon([
                    this.circleCenter, pos, posEnd
                ], indices[idx]);
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

    new method drawAux(array, indices) {
        new dynamic drawn = {}, pos, posEnd, angle, l;

        sortingVisualizer.graphics.fastCircle(this.auxCircleCenter, this.auxCircleRadius, (0, 0, 0));

        for idx in range(len(array)) {
            l = array[idx].value * this.auxLineLengthConst;
            pos, posEnd = this.auxPoint[idx];

            if (pos.x, pos.y) in drawn {
                continue;
            } else {
                drawn[(pos.x, pos.y)] = None;
            }
            
            pos.magnitude(l);
            pos = pos.getIntCoords();
            pos += this.auxCircleCenter;

            posEnd.magnitude(l);
            posEnd = posEnd.getIntCoords();
            posEnd += this.auxCircleCenter;

            if idx in indices && indices[idx] is not None {
                sortingVisualizer.graphics.polygon([
                    this.auxCircleCenter, pos, posEnd
                ], indices[idx]);
            } else {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.polygon([
                        this.auxCircleCenter, pos, posEnd
                    ], (255, 0, 0));
                } else {
                    sortingVisualizer.graphics.polygon([
                        this.auxCircleCenter, pos, posEnd
                    ], hsvToRgb(array[idx].value * this.colorConstant));
                }
            }
        }

        del drawn;
    }
}