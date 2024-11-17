package colorsys: import hsv_to_rgb;

# https://www.pygame.org/docs/ref/image.html
new set SUPPORTED_IMAGE_FORMATS = {
    "bmp", "gif", "jpg", "jpeg", "lbm", 
    "pbm", "pgm", "ppm", "webp", "pcx", 
    "pnm", "svg", "tga", "tiff", "png", 
    "xpm"
};
SUPPORTED_IMAGE_FORMATS |= set(x.upper() for x in SUPPORTED_IMAGE_FORMATS);

namespace HeatMap {
    new int MAX_HEAT   = 10_000,
            BASE_HEAT  =  3_000,
            SWEEP_HEAT = int(MAX_HEAT * 1);
    
    new float HEAT_RATE      = 1.2,
              COOLING_MLT    = 0.9925,
              MIN_OUTPUT_VAL = 0.1;
}

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
            } else {
                this.lineSize = math.ceil(sortingVisualizer.graphics.resolution.x / float(length));
            }
        } else {
            this.lineSize = 1;
        }

        this.top = 0;
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
    new float ANGLE_TOL = math.radians(0.2);

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
            this.angleStep = max(BaseCircleVisual.ANGLE_TOL, math.radians(360.0 / length));
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
            this.auxAngleStep = max(BaseCircleVisual.ANGLE_TOL, math.radians(360.0 / length));
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
            new dynamic angle = (
                Utils.translate(
                    i, 0, length, this.circleStart, 
                    this.circleEnd
                )
            );

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
            new dynamic angle = (
                Utils.translate(
                    i, 0, length, this.circleStart, 
                    this.circleEnd
                )
            );

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

new class DotsVisual: LineVisual {
    new method prepare() {
        LineVisual.prepare(this);
        this.lineLengthConst = (sortingVisualizer.graphics.resolution.y - this.lineSize) / sortingVisualizer.arrayMax;
    }

    new method onAuxOn(length) {
        LineVisual.onAuxOn(this, length);

        this.lineLengthConst = (sortingVisualizer.graphics.resolution.y * (3.0 / 4) - 2 - this.lineSize) / sortingVisualizer.arrayMax;

        this.auxResolution = sortingVisualizer.graphics.resolution.copy();
        this.auxResolution.y //= 4;

        this.auxLineLengthConst = (this.auxResolution.y - this.auxLineSize) / sortingVisualizer.auxMax;
    }

    new method onAuxOff() {
        LineVisual.onAuxOff(this);

        this.lineLengthConst = (sortingVisualizer.graphics.resolution.y - this.lineSize) / sortingVisualizer.arrayMax;
        this.top             = 0;
    }
}

new class BaseDataTrace: LineVisual {
    new method init() {
        this.oldArray = None;
        this.mainSurf = Surface(sortingVisualizer.graphics.resolution.toList(2));

        this.oldAux  = None;
        this.auxSurf = Surface((
            sortingVisualizer.graphics.resolution.x, 
            sortingVisualizer.graphics.resolution.y // 4
        ));
    }
}

new class HeatVisual: LineVisual {
    new method __init__(*args, **kwargs) {
        if "minOutput" in kwargs {
            this.minOutput = kwargs["minOutput"];
            del kwargs["minOutput"];
        } else {
            this.minOutput = HeatMap.MIN_OUTPUT_VAL;
        }

        Visual.__init__(this, *args, **kwargs);
        this.colorMap = colormaps["magma"];
    }

    new method _getColorFromIdx(idx, aux = None) {
        return tuple(
            int(x * 255) 
            for x in this.colorMap(sortingVisualizer.getHeatMapNormalizedValue(idx, this.minOutput, aux))
        );
    }
}