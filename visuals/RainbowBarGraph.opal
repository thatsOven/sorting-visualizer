new class RainbowBarGraph: LineVisual {
    new method __init__() {
        super().__init__(
            "Rainbow Bar Graph",
            (255, 255, 255),
            RefreshMode.LINES
        );
    }

    new method prepare() {
        super.prepare();

        this.colorConstant = 1.0 / sortingVisualizer.arrayMax;
    }

    new method onAuxOn(length) {
        super.onAuxOn(length);

        this.auxColorConstant = 1.0 / sortingVisualizer.auxMax;
    }

    new method draw(array, indices) {
        static: new int oldIdx, i, j;

        new dynamic pos = sortingVisualizer.graphics.resolution.copy(),
                    end = pos.copy(), idx;
        pos.x = 0;
        end.x = 0;

        if len(array) > sortingVisualizer.graphics.resolution.x {
            oldIdx = 0;
            unchecked: repeat sortingVisualizer.graphics.resolution.x {
                idx = int(Utils.translate(
                    pos.x, 0, sortingVisualizer.graphics.resolution.x, 
                    0, len(array)
                ));

                end.y = pos.y - int(array[idx].value * this.lineLengthConst);

                for i in indices {
                    if indices[i] is not None && oldIdx <= i < idx {
                        sortingVisualizer.graphics.line(pos, end, indices[i], 1);
                        break;
                    }
                } else {
                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.line(pos, end, (255, 0, 0), 1);
                    } else {
                        sortingVisualizer.graphics.line(pos, end, hsvToRgb(array[idx].value * this.colorConstant), 1);
                    }
                }

                pos.x++;
                end.x++;
                oldIdx = idx;
            }
        } else {
            oldIdx = -1;
            for i = this.lineSize // 2; i < sortingVisualizer.graphics.resolution.x; i += this.lineSize {
                idx = int(Utils.translate(
                    i - this.lineSize // 2, 0, sortingVisualizer.graphics.resolution.x, 
                    0, len(array)
                ));
                
                pos.x = i;
                end.x = i;
                end.y = pos.y - int(array[idx].value * this.lineLengthConst);

                for j in indices {
                    if indices[j] is not None && oldIdx <= j - 1 < idx {
                        sortingVisualizer.graphics.line(pos, end, indices[j], this.lineSize);
                        break;
                    }
                } else {
                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.line(pos, end, (255, 0, 0), this.lineSize);
                    } else {
                        sortingVisualizer.graphics.line(pos, end, hsvToRgb(array[idx].value * this.colorConstant), this.lineSize);
                    }
                }

                oldIdx = idx;
            }
        }
    }

    new method selectiveDraw(array, indices) {
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

            if indices[idx] is None {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.line(pos, lineEnd, (255, 0, 0), this.lineSize);
                } else {
                    sortingVisualizer.graphics.line(pos, lineEnd, hsvToRgb(array[idx].value * this.colorConstant), this.lineSize);
                }   
            } else {
                sortingVisualizer.graphics.line(pos, lineEnd, indices[idx], this.lineSize);
            }

            sortingVisualizer.graphics.line(lineEnd, Vector(pos.x, 0), (0, 0, 0), this.lineSize);
        }

        del drawn;
    }

    new method drawAux(array, indices) {
        static: new int oldIdx, i, j;

        new dynamic pos = this.auxResolution.copy(),
                    end = pos.copy(), idx;

        sortingVisualizer.graphics.fastRectangle(Vector(), pos, (0, 0, 0));

        pos.x = 0;
        end.x = 0;

        if len(array) > this.auxResolution.x {
            oldIdx = 0;
            unchecked: repeat this.auxResolution.x {
                idx = int(Utils.translate(
                    pos.x, 0, this.auxResolution.x, 
                    0, len(array)
                ));

                end.y = pos.y - int(array[idx].value * this.auxLineLengthConst);

                for i in indices {
                    if oldIdx <= i < idx {
                        sortingVisualizer.graphics.line(pos, end, indices[i], 1);
                        break;
                    }
                } else {
                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.line(pos, end, (255, 0, 0), 1);
                    } else {
                        sortingVisualizer.graphics.line(pos, end, hsvToRgb(array[idx].value * this.auxColorConstant), 1);
                    }
                }

                pos.x++;
                end.x++;
                oldIdx = idx;
            }
        } else {
            oldIdx = -1;
            for i = this.auxLineSize // 2; i < sortingVisualizer.graphics.resolution.x; i += this.auxLineSize {
                idx = int(Utils.translate(
                    i - this.auxLineSize // 2, 0, sortingVisualizer.graphics.resolution.x, 
                    0, len(array)
                ));
                
                pos.x = i;
                end.x = i;
                end.y = pos.y - int(array[idx].value * this.auxLineLengthConst);

                for j in indices {
                    if indices[j] is not None && oldIdx <= j - 1 < idx {
                        sortingVisualizer.graphics.line(pos, end, indices[j], this.auxLineSize);
                        break;
                    }
                } else {
                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.line(pos, end, (255, 0, 0), 1);
                    } else {
                        sortingVisualizer.graphics.line(pos, end, hsvToRgb(array[idx].value * this.auxColorConstant), this.auxLineSize);
                    }
                }

                oldIdx = idx;
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
                        sortingVisualizer.graphics.line(pos, end, (255, 0, 0), 1);
                    } else {
                        sortingVisualizer.graphics.line(pos, end, hsvToRgb(array[idx].value * this.auxColorConstant), 1);
                    }
                }
                    
                pos.x++;
                end.x++;
            }
        } else {
            for i = this.auxLineSize // 2; i < sortingVisualizer.graphics.resolution.x; i += this.auxLineSize {
                idx = int(Utils.translate(
                    i - this.auxLineSize // 2, 0, sortingVisualizer.graphics.resolution.x, 
                    0, len(array)
                ));
                
                pos.x = i;
                end.x = i;
                end.y = pos.y - int(array[idx].value * this.auxLineLengthConst);

                if idx in indices {
                    sortingVisualizer.graphics.line(pos, end, indices[idx], this.auxLineSize);
                } else {
                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.line(pos, end, (255, 0, 0), 1);
                    } else {
                        sortingVisualizer.graphics.line(pos, end, hsvToRgb(array[idx].value * this.auxColorConstant), this.auxLineSize);
                    }
                }
            }
        }

        sortingVisualizer.graphics.line(Vector(0, this.auxResolution.y), this.auxResolution, (0, 0, 255), 2);
    }
}