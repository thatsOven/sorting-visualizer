package colorsys: import hsv_to_rgb;

new function hsvToRgb(h, s = 1, v = 1) {
    return tuple(round(i * 255) for i in hsv_to_rgb(h, s, v));
}

new class LineVisual: Visual {
    new method prepare() {
        static: new int length = len(sortingVisualizer.array);

        this.lineLengthConst = sortingVisualizer.graphics.resolution.y / sortingVisualizer.arrayMax;

        if sortingVisualizer.graphics.resolution.x >= length {
            if sortingVisualizer.graphics.resolution.x == length {
                this.lineSize = 1;
                this.dotSize  = 1;
            } else {
                this.lineSize = math.ceil(sortingVisualizer.graphics.resolution.x / float(length));
                this.dotSize  = sortingVisualizer.graphics.resolution.x // length;
            }
        } else {
            this.lineSize = 1;
            this.dotSize  = 1;
        }
    }

    new method onAuxOn(length) {
        this.lineLengthConst = (sortingVisualizer.graphics.resolution.y * (3.0 / 4) - 2) / sortingVisualizer.arrayMax;
        this.top             = sortingVisualizer.graphics.resolution.y // 4;

        this.auxResolution = sortingVisualizer.graphics.resolution.copy();
        this.auxResolution.y //= 4;

        this.auxLineLengthConst = this.auxResolution.y / sortingVisualizer.auxMax;

        if this.auxResolution.x >= length {
            if this.auxResolution.x == length {
                this.auxLineSize = 1;
            } else {
                this.auxLineSize = math.ceil(this.auxResolution.x / length);
            }
        } else {
            this.auxLineSize = 1;
        }
    }

    new method onAuxOff() {
        this.lineLengthConst = sortingVisualizer.graphics.resolution.y / sortingVisualizer.arrayMax;
        this.top             = 0;
    }
}

new class BaseCircleVisual: Visual {
    new method prepare() {
        static: new int length = len(sortingVisualizer.array);

        if sortingVisualizer.graphics.resolution.y < sortingVisualizer.graphics.resolution.x {
            this.circleRadius = (sortingVisualizer.graphics.resolution.y // 2) - 20;

            this.circleCenter = sortingVisualizer.graphics.resolution.copy();
            this.circleCenter.y //= 2;
            this.circleCenter.x = sortingVisualizer.graphics.resolution.x - this.circleRadius - 20;
        } elif sortingVisualizer.graphics.resolution.y == sortingVisualizer.graphics.resolution.x {
            this.circleRadius = (sortingVisualizer.graphics.resolution.x // 7) * 2 - 20;

            this.circleCenter = Vector(
                sortingVisualizer.graphics.resolution.x - this.circleRadius - 20,
                sortingVisualizer.graphics.resolution.y // 2
            );
        } else {
            this.circleRadius = (sortingVisualizer.graphics.resolution.x // 2) - 20;

            this.circleCenter = sortingVisualizer.graphics.resolution.copy();
            this.circleCenter.x //= 2;
            this.circleCenter.y = sortingVisualizer.graphics.resolution.y - this.circleRadius - 20;
        }

        this.circleStart = -(math.pi) / 2.0;
        this.circleEnd   = 1.5 * math.pi;

        if 360 == length {
            this.angleStep = math.radians(1.0);
        } else {
            this.angleStep = math.radians(360.0 / length);
        }
    }

    new method onAuxOn(length) {
        if sortingVisualizer.graphics.resolution.y <= sortingVisualizer.graphics.resolution.x {
            this.auxCircleRadius = (sortingVisualizer.graphics.resolution.y // 6) - 20;
            
            this.auxCircleCenter = sortingVisualizer.graphics.resolution.copy();
            this.auxCircleCenter.y //= 4;
            this.auxCircleCenter.y *= 3;
            this.auxCircleCenter.x = sortingVisualizer.graphics.resolution.x // 4;
        } else {
            this.auxCircleRadius = (sortingVisualizer.graphics.resolution.x // 6) - 20;
            
            this.auxCircleCenter = sortingVisualizer.graphics.resolution.copy();
            this.auxCircleCenter.x //= 5;
            this.auxCircleCenter.x *= 4;
            this.auxCircleCenter.y = sortingVisualizer.graphics.resolution.y // 4;
        }

        if 360 == length {
            this.auxAngleStep = math.radians(1.0);
        } else {
            this.auxAngleStep = math.radians(360.0 / length);
        }
    }
}

new class CircleVisual: BaseCircleVisual {
    new method prepare() {
        super.prepare();

        static: new int length = len(sortingVisualizer.array);

        this.angles = {};
        this.points = {};
        for i in range(length) {
            new dynamic angle = Utils.translate(i, 0, length, this.circleStart, this.circleEnd);

            this.angles[i] = angle;

            new dynamic pos, posEnd;
            
            pos = Vector().fromAngle(angle);
            pos.magnitude(this.circleRadius);
            pos = pos.getIntCoords();
            pos += this.circleCenter;

            posEnd = Vector().fromAngle(angle + this.angleStep);
            posEnd.magnitude(this.circleRadius);
            posEnd = posEnd.getIntCoords();
            posEnd += this.circleCenter;

            this.points[angle] = (pos, posEnd);
        }
    }

    new method onAuxOn(length) {
        super.onAuxOn(length);

        this.auxAngles = {};
        this.auxPoints = {};
        for i in range(length) {
            new dynamic angle = Utils.translate(i, 0, length, this.circleStart, this.circleEnd);

            this.auxAngles[i] = angle;

            new dynamic pos, posEnd;
            
            pos = Vector().fromAngle(angle);
            pos.magnitude(this.auxCircleRadius);
            pos = pos.getIntCoords();
            pos += this.auxCircleCenter;

            posEnd = Vector().fromAngle(angle + this.auxAngleStep);
            posEnd.magnitude(this.auxCircleRadius);
            posEnd = posEnd.getIntCoords();
            posEnd += this.auxCircleCenter;

            this.auxPoints[angle] = (pos, posEnd);
        }
    }
}