new <Visual> whiteBarGraph;
whiteBarGraph = Visual("Bar Graph", (255, 0, 0));

@whiteBarGraph.render;
new function whiteBarGraphDraw(sv, array, indices, color) {
    if color == "default" {
        color = (255, 255, 255);
    }

    new dynamic drew = {};

    for idx in indices {
        new dynamic pos = sv.graphics.resolution.copy(), lineEnd;

        pos.x = Utils.translate(idx, 0, len(array), 0, sv.graphics.resolution.x // sv.visualSizes.lineSize) * sv.visualSizes.lineSize + (sv.visualSizes.lineSize // 2);

        if pos.x in drew {
            continue;
        } else {
            drew[pos.x] = None;
        }

        lineEnd = pos - Vector(0, int(array[idx].value * sv.visualSizes.lineLengthConst));
        
        sv.graphics.line(    pos,          lineEnd,     color, sv.visualSizes.lineSize);
        sv.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), sv.visualSizes.lineSize);
    }

    del drew;
}

@whiteBarGraph.aux;
new function whiteBarGraphAux(sv, array, indices, color) {
    sv.getAuxMax();
    new dynamic length     = len(array),
                resolution = sv.graphics.resolution.copy(), lineSize,
                drew       = {};

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
            sv.graphics.line(pos, lineEnd,           color, lineSize);
        } else {
            sv.graphics.line(pos, lineEnd, (255, 255, 255), lineSize);
        }
        sv.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), lineSize);
    }

    del drew;

    sv.graphics.line(Vector(0, resolution.y), resolution, (0, 0, 255), 2);
}

whiteBarGraph.add();