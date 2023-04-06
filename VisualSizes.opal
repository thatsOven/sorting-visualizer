new class VisualSizes {
    new method __init__(sv) {
        this.sv = sv;

        this.lineSize                 = None;
        this.dotSize                  = None;
        this.lineLengthConst          = None;
        this.circularLineLengthConst  = None;
        this.angleStep                = None;
        this.circleCenter             = None;
        this.circleRadius             = None;
        this.circleStart              = -(math.pi) / 2.0;
        this.circleEnd                = 1.5 * math.pi;
        this.disparityLineLengthConst = None;
        this.top                      = 0;
    }

    new method compute() {
        this.sv.getMax();

        new dynamic length = len(this.sv.array);

        this.lineLengthConst = this.sv.graphics.resolution.y / this.sv.arrayMax;

        if this.sv.graphics.resolution.x >= length {
            if this.sv.graphics.resolution.x == length {
                this.lineSize = 1;
                this.dotSize  = 1;
            } else {
                this.lineSize = math.ceil(this.sv.graphics.resolution.x / float(length));
                this.dotSize = this.sv.graphics.resolution.x // length;
            }
        } else {
            this.lineSize = 1;
            this.dotSize  = 1;
        }

        if 360 == length {
            this.angleStep = 1;
        } else {
            this.angleStep = 360.0 / length;
        }

        this.angleStep = math.radians(this.angleStep);

        this.circleRadius = (this.sv.graphics.resolution.y // 2) - 20;

        this.circleCenter = this.sv.graphics.resolution.copy();
        this.circleCenter.y //= 2;
        this.circleCenter.x = this.sv.graphics.resolution.x - this.circleRadius - 20;

        this.circularLineLengthConst = this.circleRadius / this.sv.arrayMax;
    }

    new method adaptLineLengthAux() {
        this.lineLengthConst = (this.sv.graphics.resolution.y * (3.0 / 4) - 2) / this.sv.arrayMax;
        this.top             = this.sv.graphics.resolution.y // 4;
    }

    new method resetLineLength() {
        this.lineLengthConst = this.sv.graphics.resolution.y / this.sv.arrayMax;
        this.top             = 0;
    }
}