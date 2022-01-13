new <Visual> rainbowBarGraph;
rainbowBarGraph = Visual("Rainbow Bar Graph", (255, 255, 255));

@rainbowBarGraph.render;
new function rainbowBarGraphDraw(sv, array, indices, color) {
    new dynamic colorConstant = 1 / sv.arrayMax, drew = {};

    for idx in indices {
        new dynamic pos = sv.graphics.resolution.copy(), lineEnd;

        pos.x = Utils.translate(idx, 0, len(array), 0, sv.graphics.resolution.x // sv.visualSizes.lineSize) * sv.visualSizes.lineSize + (sv.visualSizes.lineSize // 2);

        if pos.x in drew {
            continue;
        } else {
            drew[pos.x] = None;
        }

        lineEnd = pos - Vector(0, int(array[idx].value * sv.visualSizes.lineLengthConst));

        if color == "default" {
            if array[idx].value < 0 {
                sv.graphics.line(pos, lineEnd, hsvToRgb(0), sv.visualSizes.lineSize);
            } else {
                sv.graphics.line(pos, lineEnd, hsvToRgb(array[idx].value * colorConstant), sv.visualSizes.lineSize);
            }   
        } else {
            sv.graphics.line(pos, lineEnd, color, sv.visualSizes.lineSize);
        }
        sv.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), sv.visualSizes.lineSize);
    }

    del drew;
}

@rainbowBarGraph.aux;
new function rainbowBarGraphAux(sv, array, indices, color) {
    sv.getAuxMax();
    new dynamic length        = len(array),
                resolution    = sv.graphics.resolution.copy(), lineSize,
                drew          = {},
                colorConstant = 1 / sv.auxMax;

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

        if pos.x in drew {
            continue;
        } else {
            drew[pos.x] = None;
        }

        lineEnd = pos - Vector(0, int(array[idx].value * lineLengthConst));
        
        if idx in indices {
            sv.graphics.line(pos, lineEnd, color, lineSize);
        } else {
            if array[idx].value < 0 {
                sv.graphics.line(pos, lineEnd, hsvToRgb(0), lineSize);
            } else {
                sv.graphics.line(pos, lineEnd, hsvToRgb(array[idx].value * colorConstant), lineSize);
            }   
        }
        sv.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), lineSize);
    }

    del drew;

    sv.graphics.line(Vector(0, resolution.y), resolution, (0, 0, 255), 2);
}

rainbowBarGraph.add();