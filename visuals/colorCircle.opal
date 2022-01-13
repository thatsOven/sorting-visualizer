new <Visual> colorCircle;
colorCircle = Visual("Color Circle", (255, 255, 255), RefreshMode.NOREFRESH, True);

@colorCircle.render;
new function colorCircleDraw(sv, array, indices, color) {
    new dynamic drawn = {}, pos, posEnd, angle, colorConstant = 1 / sv.arrayMax;

    for idx in indices {
        angle = Utils.translate(idx, 0, len(array), sv.visualSizes.circleStart, sv.visualSizes.circleEnd);

        if angle in drawn {
            continue;
        } else {
            drawn[angle] = None;
        }

        pos = Vector().fromAngle(angle);
        pos.magnitude(sv.visualSizes.circleRadius);
        pos = pos.getIntCoords();
        pos += sv.visualSizes.circleCenter;

        posEnd = Vector().fromAngle(angle + sv.visualSizes.angleStep);
        posEnd.magnitude(sv.visualSizes.circleRadius);
        posEnd = posEnd.getIntCoords();
        posEnd += sv.visualSizes.circleCenter;

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

@colorCircle.aux;
new function colorCircleAux(sv, array, indices, color) {
    sv.getAuxMax();
    new dynamic length        = len(array),
                resolution    = sv.graphics.resolution.copy(), lineSize,
                drawn          = {},
                colorConstant = 1 / sv.auxMax, angleStep, circleCenter, circleRadius, 
                                               pos, posEnd, angle;

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

    for idx in range(len(array)) {
        angle = Utils.translate(idx, 0, len(array), sv.visualSizes.circleStart, sv.visualSizes.circleEnd);

        if angle in drawn {
            continue;
        } else {
            drawn[angle] = None;
        }

        pos = Vector().fromAngle(angle);
        pos.magnitude(circleRadius);
        pos = pos.getIntCoords();
        pos += circleCenter;

        posEnd = Vector().fromAngle(angle + angleStep);
        posEnd.magnitude(circleRadius);
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

colorCircle.add();