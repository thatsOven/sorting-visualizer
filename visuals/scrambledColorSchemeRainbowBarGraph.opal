new <Visual> scrambledRainbowBarGraph;
scrambledRainbowBarGraph = Visual("Scrambled Scheme Rainbow Bar Graph", (255, 255, 255));

@scrambledRainbowBarGraph.render;
new function scrambledRainbowBarGraphDraw(sv, array, indices, color) {
    new dynamic colorConstant = 1 / len(array), drawn = {};

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
            sv.graphics.line(pos, lineEnd, hsvToRgb(array[idx].stabIdx * colorConstant), sv.visualSizes.lineSize);
        } else {
            sv.graphics.line(pos, lineEnd, color, sv.visualSizes.lineSize);
        }
        sv.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), sv.visualSizes.lineSize);
    }

    del drawn;
}

@scrambledRainbowBarGraph.aux;
new function scrambledRainbowBarGraphAux(sv, array, indices, color) {
    sv.getAuxMax();
    new dynamic length        = len(array),
                resolution    = sv.graphics.resolution.copy(), lineSize,
                drawn          = {},
                colorConstant = 1 / len(array);

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
            sv.graphics.line(pos, lineEnd,                                        color, lineSize);
        } else {
            sv.graphics.line(pos, lineEnd, hsvToRgb(array[idx].stabIdx * colorConstant), lineSize);
        }
        sv.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), lineSize);
    }

    del drawn;

    sv.graphics.line(Vector(0, resolution.y), resolution, (0, 0, 255), 2);
}

scrambledRainbowBarGraph.add();