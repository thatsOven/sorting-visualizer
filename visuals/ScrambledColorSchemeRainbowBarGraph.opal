new class ScrambledRainbowBarGraph: LineVisual {
    new method __init__() {
        super.__init__(
            "Scrambled Scheme Rainbow Bar Graph",
            (255, 255, 255)
        );
    }

    new method prepare() {
        super.prepare();

        this.colorConstant = 1.0 / len(sortingVisualizer.array);
    }

    new method onAuxOn(length) {
        super.onAuxOn(length);

        this.auxColorConstant = 1.0 / length;
    }

    new method draw(array, indices, color) {
        static: new bint mark;

        new dynamic pos = sortingVisualizer.graphics.resolution.copy(),
                    end = pos.copy(), idx;
        pos.x = 0;
        end.x = 0;

        if len(array) > sortingVisualizer.graphics.resolution.x {
            new dynamic oldIdx = 0;
            unchecked: repeat sortingVisualizer.graphics.resolution.x {
                idx = int(Utils.translate(
                    pos.x, 0, sortingVisualizer.graphics.resolution.x, 
                    0, len(array)
                ));

                end.y = pos.y - int(array[idx].value * this.lineLengthConst);

                mark = True;
                if color is not None {
                    for i in indices {
                        if i in range(oldIdx, idx) {
                            mark = False;
                            sortingVisualizer.graphics.line(pos, end, color, 1);
                            break;
                        }
                    }
                } 
                
                if mark {
                    sortingVisualizer.graphics.line(pos, end, hsvToRgb(array[idx].stabIdx * colorConstant), 1);
                }
                
                pos.x++;
                end.x++;
                oldIdx = idx;
            }
        } else {
            for idx in range(len(array)) {
                pos.x = int(Utils.translate(
                    idx, 0, len(array), 
                    0, sortingVisualizer.graphics.resolution.x // this.lineSize
                )) * this.lineSize + (this.lineSize // 2);
                end.x = pos.x;

                end.y = pos.y - int(array[idx].value * this.lineLengthConst);

                if idx in indices {
                    sortingVisualizer.graphics.line(pos, end, color, this.lineSize);
                } else {
                    sortingVisualizer.graphics.line(pos, end, hsvToRgb(array[idx].stabIdx * colorConstant), this.lineSize);
                }
            }
        }
    }

    new method fastDraw(array, indices, color) {
        new dynamic drawn = {};

        for idx in indices {
            new dynamic pos = sortingVisualizer.graphics.resolution.copy(), lineEnd;

            pos.x = Utils.translate(
                idx, 0, len(array), 0, 
                sortingVisualizer.graphics.resolution.x // this.lineSize
            ) * this.lineSize + (this.lineSize // 2);

            if pos.x in drawn {
                continue;
            } else {
                drawn[pos.x] = None;
            }

            lineEnd = pos - Vector(0, int(array[idx].value * this.lineLengthConst));

            if color is None {
                sortingVisualizer.graphics.line(pos, lineEnd, hsvToRgb(array[idx].stabIdx * this.colorConstant), this.lineSize);
            } else {
                sortingVisualizer.graphics.line(pos, lineEnd, color, this.lineSize);
            }
            sortingVisualizer.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), this.lineSize);
        }

        del drawn;
    }

    new method drawAux(array, indices, color) {
        new dynamic pos = this.auxResolution.copy(),
                    end = pos.copy(), idx;

        sortingVisualizer.graphics.fastRectangle(Vector(), pos, (0, 0, 0));

        pos.x = 0;
        end.x = 0;

        if len(array) > this.auxResolution.x {
            new dynamic oldIdx = 0;
            unchecked: repeat this.auxResolution.x {
                idx = int(Utils.translate(
                    pos.x, 0, this.auxResolution.x, 
                    0, len(array)
                ));

                end.y = pos.y - int(array[idx].value * this.auxLineLengthConst);

                for i in indices {
                    if i in range(oldIdx, idx) {
                        sortingVisualizer.graphics.line(pos, end, color, 1);
                        break;
                    }
                } else {
                    sortingVisualizer.graphics.line(pos, end, hsvToRgb(array[idx].stabIdx * this.auxColorConstant), 1);
                }

                pos.x++;
                end.x++;
                oldIdx = idx;
            }
        } else {
            for idx in range(len(array)) {
                pos.x = int(Utils.translate(
                    idx, 0, len(array), 
                    0, sortingVisualizer.graphics.resolution.x // this.auxLineSize
                )) * this.auxLineSize + (this.auxLineSize // 2);
                end.x = pos.x;

                end.y = pos.y - int(array[idx].value * this.auxLineLengthConst);

                if idx in indices {
                    sortingVisualizer.graphics.line(pos, end, color, this.auxLineSize);
                } else {
                    sortingVisualizer.graphics.line(pos, end, hsvToRgb(array[idx].stabIdx * this.auxColorConstant), this.auxLineSize);
                }
            }
        }
        
        sortingVisualizer.graphics.line(Vector(0, this.auxResolution.y), this.auxResolution, (0, 0, 255), 2);
    }

    new method fastDrawAux(array, indices, color) {
        new dynamic pos = this.auxResolution.copy(),
                    end = pos.copy(), idx;

        sortingVisualizer.graphics.fastRectangle(Vector(), pos, (0, 0, 0));

        pos.x = 0;
        end.x = 0;

        if len(array) > this.auxResolution.x {
            unchecked: repeat this.auxResolution.x {
                idx = int(Utils.translate(
                    pos.x, 0, this.auxResolution.x, 
                    0, len(array)
                ));

                end.y = pos.y - int(array[idx].value * this.auxLineLengthConst);

                if idx in indices {
                    sortingVisualizer.graphics.line(pos, end, color, 1);
                } else {
                    sortingVisualizer.graphics.line(pos, end, hsvToRgb(array[idx].stabIdx * this.auxColorConstant), 1);
                }
                    
                pos.x++;
                end.x++;
            }
        } else {
            for idx in range(len(array)) {
                pos.x = int(Utils.translate(
                    idx, 0, len(array), 
                    0, sortingVisualizer.graphics.resolution.x // this.auxLineSize
                )) * this.auxLineSize + (this.auxLineSize // 2);
                end.x = pos.x;

                end.y = pos.y - int(array[idx].value * this.auxLineLengthConst);

                if idx in indices {
                    sortingVisualizer.graphics.line(pos, end, color, this.auxLineSize);
                } else {
                    sortingVisualizer.graphics.line(pos, end, hsvToRgb(array[idx].stabIdx * this.auxColorConstant), this.auxLineSize);
                }
            }
        }

        sortingVisualizer.graphics.line(Vector(0, this.auxResolution.y), this.auxResolution, (0, 0, 255), 2);
    }
}