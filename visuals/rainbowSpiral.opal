new <Visual> rainbowSpiral;
rainbowSpiral = Visual("Rainbow Spiral", (255, 255, 255), RefreshMode.FULL, True);

@rainbowSpiral.render;
new function rainbowSpiralDraw(sv, array, indices, color) {
    new dynamic drawn = {}, pos, posEnd, angle, colorConstant = 1 / sv.arrayMax, l, end, endStep;
    
    for idx in indices {
        angle = Utils.translate(idx, 0, len(array), sv.visualSizes.circleStart, sv.visualSizes.circleEnd);

        if angle in drawn {
            continue;
        } else {
            drawn[angle] = None;
        }

        l = array[idx].value * sv.visualSizes.circularLineLengthConst;
        pos = Vector().fromAngle(angle);

        end = pos.copy();
        end.magnitude(sv.visualSizes.circleRadius);
        end = end.getIntCoords();
        end += sv.visualSizes.circleCenter;

        pos.magnitude(l);
        pos = pos.getIntCoords();
        pos += sv.visualSizes.circleCenter;

        posEnd = Vector().fromAngle(angle + sv.visualSizes.angleStep);

        endStep = posEnd.copy();
        endStep.magnitude(sv.visualSizes.circleRadius);
        endStep = endStep.getIntCoords();
        endStep += sv.visualSizes.circleCenter;

        posEnd.magnitude(l);
        posEnd = posEnd.getIntCoords();
        posEnd += sv.visualSizes.circleCenter;

        sv.graphics.polygon([
            sv.visualSizes.circleCenter,
            end, endStep
            ], (0, 0, 0));

        if color == "default" {
            if array[idx].value < 0 {
                sv.graphics.polygon([
                sv.visualSizes.circleCenter,
                pos, posEnd
                ], hsvToRgb(0));
            } else {
                sv.graphics.polygon([
                sv.visualSizes.circleCenter,
                pos, posEnd
                ], hsvToRgb(array[idx].value * colorConstant));
            }
        } else {
            sv.graphics.polygon([
            sv.visualSizes.circleCenter,
            pos, posEnd
            ], color);
        }
    }

    del drawn;
}

@rainbowSpiral.aux;
new function rainbowSpiralAux(sv, array, indices, color) {
    sv.getAuxMax();
    new dynamic length        = len(array),
                resolution    = sv.graphics.resolution.copy(), lineSize,
                drawn          = {},
                colorConstant = 1 / sv.auxMax, angleStep, circleCenter, circleRadius, 
                                               circularLineLengthConst, pos, posEnd, angle,
                                               l;

    if 360 == length {
        angleStep = 1;
    } else {
        angleStep = 360 / length;
    }

    angleStep = math.radians(angleStep);

    circleRadius = (resolution.y // 6) - 20;
        
    circleCenter = resolution.copy();
    circleCenter.y //= 4;
    circleCenter.y *= 3;
    circleCenter.x = resolution.x // 4;

    circularLineLengthConst = circleRadius / sv.auxMax;

    sv.graphics.fastCircle(circleCenter, circleRadius, (0, 0, 0));

    for idx in range(len(array)) {
        angle = Utils.translate(idx, 0, len(array), sv.visualSizes.circleStart, sv.visualSizes.circleEnd);

        if angle in drawn {
            continue;
        } else {
            drawn[angle] = None;
        }

        l = array[idx].value * circularLineLengthConst;
        pos = Vector().fromAngle(angle);
        pos.magnitude(l);
        pos = pos.getIntCoords();
        pos += circleCenter;

        posEnd = Vector().fromAngle(angle + angleStep);
        posEnd.magnitude(l);
        posEnd = posEnd.getIntCoords();
        posEnd += circleCenter;

        if idx in indices {
            sv.graphics.polygon([
            circleCenter,
            pos, posEnd
            ], color);
        } else {
            if array[idx].value < 0 {
                sv.graphics.polygon([
                circleCenter,
                pos, posEnd
                ], hsvToRgb(0));
            } else {
                sv.graphics.polygon([
                circleCenter,
                pos, posEnd
                ], hsvToRgb(array[idx].value * colorConstant));
            }
        }
    }

    del drawn;
}

rainbowSpiral.add();