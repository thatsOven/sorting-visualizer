new class BWGradientBarGraph: LineVisual {
    new method __init__() {
        super().__init__(
            "B/W Gradient Bar Graph",
            (255, 0, 0)
        );
    }

    new method prepare() {
        super.prepare();

        this.colorConstant = 215.0 / sortingVisualizer.arrayMax;
    }

    new method onAuxOn(length) {
        super.onAuxOn(length);

        this.auxColorConstant = 215.0 / sortingVisualizer.auxMax;
    }

    new method draw(array, indices) {
        new dynamic pos = this.resolution.copy(),
                    end = pos.copy(), idx;
        pos.x = 0;
        end.x = 0;

        if len(array) > this.resolution.x {
            new dynamic oldIdx = 0;
            unchecked: repeat this.resolution.x {
                idx = int(Utils.translate(
                    pos.x, 0, this.resolution.x, 
                    0, len(array)
                ));

                end.y = pos.y - int(array[idx].value * this.lineLengthConst);

                for i in indices {
                    if indices[i] is not None && i in range(oldIdx, idx) {
                        sortingVisualizer.graphics.line(pos, end, indices[i], 1);
                        break;
                    }
                } else {
                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.line(pos, end, (40, 40, 40), 1);
                    } else {
                        sortingVisualizer.graphics.line(pos, end, [40 + int(array[idx].value * this.colorConstant)] * 3, 1);
                    }
                }

                pos.x++;
                end.x++;
                oldIdx = idx;
            }
        } else {
            for idx in range(len(array)) {
                pos.x = int(Utils.translate(
                    idx, 0, len(array), 
                    0, this.resolution.x // this.lineSize
                )) * this.lineSize + (this.lineSize // 2);
                end.x = pos.x;

                end.y = pos.y - int(array[idx].value * this.lineLengthConst);

                if idx in indices {
                    sortingVisualizer.graphics.line(pos, end, indices[idx], this.lineSize);
                } else {
                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.line(pos, end, (40, 40, 40), this.lineSize);
                    } else {
                        sortingVisualizer.graphics.line(pos, end, [40 + int(array[idx].value * this.colorConstant)] * 3, this.lineSize);
                    }
                }
            }
        }
    }

    new method fastDraw(array, indices) {
        new dynamic drawn = {};

        for idx in indices {
            new dynamic pos = this.resolution.copy(), lineEnd;

            pos.x = Utils.translate(
                    idx, 0, len(array), 0, 
                    this.resolution.x // this.lineSize
                ) * this.lineSize + (this.lineSize // 2);

            if pos.x in drawn {
                continue;
            } else {
                drawn[pos.x] = None;
            }

            lineEnd = pos - Vector(0, int(array[idx].value * this.lineLengthConst));

            if indices[idx] is None {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.line(pos, lineEnd, (40, 40, 40), this.lineSize);
                } else {
                    sortingVisualizer.graphics.line(pos, lineEnd, [40 + int(array[idx].value * this.colorConstant)] * 3, this.lineSize);
                }
            } else {
                sortingVisualizer.graphics.line(pos, lineEnd, indices[idx], this.lineSize);
            }

            sortingVisualizer.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), this.lineSize);
        }

        del drawn;
    }

    new method drawAux(array, indices) {
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
                        sortingVisualizer.graphics.line(pos, end, indices[i], 1);
                        break;
                    }
                } else {
                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.line(pos, end, (40, 40, 40), 1);
                    } else {
                        sortingVisualizer.graphics.line(pos, end, [40 + int(array[idx].value * this.auxColorConstant)] * 3, 1);
                    }
                }

                pos.x++;
                end.x++;
                oldIdx = idx;
            }
        } else {
            for idx in range(len(array)) {
                pos.x = int(Utils.translate(
                    idx, 0, len(array), 
                    0, this.resolution.x // this.auxLineSize
                )) * this.auxLineSize + (this.auxLineSize // 2);
                end.x = pos.x;
                end.y = pos.y - int(array[idx].value * this.auxLineLengthConst);

                if idx in indices {
                    sortingVisualizer.graphics.line(pos, end, indices[idx], this.auxLineSize);
                } else {
                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.line(pos, end, (40, 40, 40), this.auxLineSize);
                    } else {
                        sortingVisualizer.graphics.line(pos, end, [40 + int(array[idx].value * this.auxColorConstant)] * 3, this.auxLineSize);
                    }
                }
            }
        }

        sortingVisualizer.graphics.line(Vector(0, this.auxResolution.y), this.auxResolution, (0, 0, 255), 2);
    }

    new method fastDrawAux(array, indices) {
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
                    sortingVisualizer.graphics.line(pos, end, indices[idx], 1);
                } else {
                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.line(pos, end, (40, 40, 40), 1);
                    } else {
                        sortingVisualizer.graphics.line(pos, end, [40 + int(array[idx].value * this.auxColorConstant)] * 3, 1);
                    }
                }
                    
                pos.x++;
                end.x++;
            }
        } else {
            for idx in range(len(array)) {
                pos.x = int(Utils.translate(
                    idx, 0, len(array), 
                    0, this.resolution.x // this.auxLineSize
                )) * this.auxLineSize + (this.auxLineSize // 2);
                end.x = pos.x;

                end.y = pos.y - int(array[idx].value * this.auxLineLengthConst);

                if idx in indices {
                    sortingVisualizer.graphics.line(pos, end, indices[idx], this.auxLineSize);
                } else {
                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.line(pos, end, (40, 40, 40), this.auxLineSize);
                    } else {
                        sortingVisualizer.graphics.line(pos, end, [40 + int(array[idx].value * this.auxColorConstant)] * 3, this.auxLineSize);
                    }
                }
            }
        }

        sortingVisualizer.graphics.line(Vector(0, this.auxResolution.y), this.auxResolution, (0, 0, 255), 2);
    }
}