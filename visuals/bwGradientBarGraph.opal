new <Visual> bwGradientBarGraph;
bwGradientBarGraph = Visual("B/W Gradient Bar Graph", (255, 0, 0));

@bwGradientBarGraph.render;
new function bwGradientBarGraphDraw(sv, array, indices, color) {
    new dynamic colorConstant = 215 / sv.arrayMax, drawn = {};

    for idx in indices {
        new dynamic pos = sv.graphics.resolution.copy(), lineEnd;

        pos.x = Utils.translate(idx, 0, len(array), 0, sv.graphics.resolution.x // sv.visualSizes.lineSize) * sv.visualSizes.lineSize + (sv.visualSizes.lineSize // 2);

        if pos.x in drawn {
            continue;
        } else {
            drawn[pos.x] = None;
        }

        lineEnd = pos - Vector(0, int(array[idx].value * sv.visualSizes.lineLengthConst));

        if color == "default" {
            if array[idx].value < 0 {
                sv.graphics.line(pos, lineEnd, (40, 40, 40), sv.visualSizes.lineSize);
            } else {
                sv.graphics.line(pos, lineEnd, [40 + int(array[idx].value * colorConstant)] * 3, sv.visualSizes.lineSize);
            }
        } else {
            sv.graphics.line(pos, lineEnd, color, sv.visualSizes.lineSize);
        }
        sv.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), sv.visualSizes.lineSize);
    }

    del drawn;
}

@bwGradientBarGraph.aux;
new function bwGradientBarGraphAux(sv, array, indices, color) {
    sv.getAuxMax();
    new dynamic length        = len(array),
                resolution    = sv.graphics.resolution.copy(), lineSize,
                drawn          = {},
                colorConstant = 215 / sv.auxMax;

    resolution.y //= 4;

    new dynamic lineLengthConst = resolution.y / sv.auxMax;

    if resolution.x >= length {
        if resolution.x == length {
            lineSize = 1;
        } else {
            lineSize = math.ceil(resolution.x / length);
        }
    } else {
        lineSize = 1;
    }

    for idx in range(len(array)) {
        new dynamic pos = resolution.copy(), lineEnd;

        pos.x = Utils.translate(idx, 0, len(array), 0, resolution.x // lineSize) * lineSize + (lineSize // 2);

        if pos.x in drawn {
            continue;
        } else {
            drawn[pos.x] = None;
        }

        lineEnd = pos - Vector(0, int(array[idx].value * lineLengthConst));
        
        if idx in indices {
            sv.graphics.line(pos, lineEnd, color, lineSize);
        } else {
            if array[idx].value < 0 {
                sv.graphics.line(pos, lineEnd, (40, 40, 40), lineSize);
            } else {
                sv.graphics.line(pos, lineEnd, [40 + int(array[idx].value * colorConstant)] * 3, lineSize);
            }
        }
        sv.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), lineSize);
    }

    del drawn;

    sv.graphics.line(Vector(0, resolution.y), resolution, (0, 0, 255), 2);
}

bwGradientBarGraph.add();