new class RainbowScatterPlot: DotsVisual {
    new Vector UNIT_VECTOR = Vector(1, 1);

    new method __init__() {
        super.__init__(
            "Rainbow Scatter Plot",
            (255, 255, 255)
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

        new dynamic pos = sortingVisualizer.graphics.resolution.copy(), idx;
        pos.x = 0;

        if len(array) > sortingVisualizer.graphics.resolution.x {
            oldIdx = 0;
            unchecked: repeat sortingVisualizer.graphics.resolution.x {
                idx = int(Utils.translate(
                    pos.x, 0, sortingVisualizer.graphics.resolution.x, 
                    0, len(array)
                ));

                pos.y = sortingVisualizer.graphics.resolution.y - int(array[idx].value * this.lineLengthConst);

                for i in indices {
                    if indices[i] is not None && oldIdx <= i < idx {
                        sortingVisualizer.graphics.fastRectangle(pos, RainbowScatterPlot.UNIT_VECTOR, indices[i], fromCenter = True);
                        break;
                    }
                } else {
                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.fastRectangle(pos, RainbowScatterPlot.UNIT_VECTOR, (255, 0, 0), fromCenter = True);
                    } else {
                        sortingVisualizer.graphics.fastRectangle(pos, RainbowScatterPlot.UNIT_VECTOR, hsvToRgb(array[idx].value * this.colorConstant), fromCenter = True);
                    }
                }

                pos.x++;
                oldIdx = idx;
            }
        } else {
            new dynamic vec = Vector(this.lineSize, this.lineSize);

            oldIdx = -1;
            for i = this.lineSize // 2; i < sortingVisualizer.graphics.resolution.x; i += this.lineSize {
                idx = int(Utils.translate(
                    i - this.lineSize // 2, 0, sortingVisualizer.graphics.resolution.x, 
                    0, len(array)
                ));

                pos.x = i;
                pos.y = sortingVisualizer.graphics.resolution.y - int(array[idx].value * this.lineLengthConst);

                for j in indices {
                    if indices[j] is not None && oldIdx <= j - 1 < idx {
                        sortingVisualizer.graphics.fastRectangle(pos, vec, indices[j], fromCenter = True);
                        break;
                    }
                } else {
                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.fastRectangle(pos, vec, (255, 0, 0), fromCenter = True);
                    } else {
                        sortingVisualizer.graphics.fastRectangle(pos, vec, hsvToRgb(array[idx].value * this.colorConstant), fromCenter = True);
                    }
                }

                oldIdx = idx;
            }
        }
    }

    new method fastDraw(array, indices) {
        new dynamic drawn   = {},
                    vec     = Vector(this.lineSize, this.lineSize),
                    delLine = Vector(0, 0);

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

            lineEnd   = pos - Vector(0, int(array[idx].value * this.lineLengthConst));
            delLine.x = pos.x;

            sortingVisualizer.graphics.line(pos, delLine, (0, 0, 0), this.lineSize);
            
            if indices[idx] is None {
                if array[idx].value < 0 {
                    sortingVisualizer.graphics.fastRectangle(lineEnd, vec, (255, 0, 0));
                } else {
                    sortingVisualizer.graphics.fastRectangle(lineEnd, vec, hsvToRgb(array[idx].value * this.colorConstant));
                }
            } else {
                sortingVisualizer.graphics.fastRectangle(lineEnd, vec, indices[idx]);
            }            
        }

        del drawn;
    }
    
    new method drawAux(array, indices) {
        static: new int oldIdx, i, j;
        
        new dynamic pos = this.auxResolution.copy(), idx;

        sortingVisualizer.graphics.fastRectangle(Vector(), pos, (0, 0, 0));

        pos.x = 0;

        if len(array) > this.auxResolution.x {
            oldIdx = 0;
            unchecked: repeat this.auxResolution.x {
                idx = int(Utils.translate(
                    pos.x, 0, this.auxResolution.x, 
                    0, len(array)
                ));

                pos.y = this.auxResolution.y - int(array[idx].value * this.auxLineLengthConst) - this.auxLineSize // 2;

                for i in indices {
                    if oldIdx <= i < idx {
                        sortingVisualizer.graphics.fastRectangle(pos, RainbowScatterPlot.UNIT_VECTOR, indices[i], fromCenter = True);
                        break;
                    }
                } else {
                    if array[idx].value {
                        sortingVisualizer.graphics.fastRectangle(pos, RainbowScatterPlot.UNIT_VECTOR, (255, 0, 0), fromCenter = True);
                    } else {
                        sortingVisualizer.graphics.fastRectangle(pos, RainbowScatterPlot.UNIT_VECTOR, hsvToRgb(array[idx].value * this.auxColorConstant), fromCenter = True);
                    }
                }

                pos.x++;
                oldIdx = idx;
            }
        } else {
            new dynamic vec = Vector(this.auxLineSize, this.auxLineSize);

            oldIdx = -1;
            for i = this.auxLineSize // 2; i < sortingVisualizer.graphics.resolution.x; i += this.auxLineSize {
                idx = int(Utils.translate(
                    i - this.auxLineSize // 2, 0, sortingVisualizer.graphics.resolution.x, 
                    0, len(array)
                ));
                
                pos.x = i;
                pos.y = this.auxResolution.y - int(array[idx].value * this.auxLineLengthConst) - this.auxLineSize // 2;

                for j in indices {
                    if indices[j] is not None && oldIdx <= j - 1 < idx {
                        sortingVisualizer.graphics.fastRectangle(pos, vec, indices[j], fromCenter = True);
                        break;
                    }
                } else {
                    if array[idx].value < 0 {
                        sortingVisualizer.graphics.fastRectangle(pos, vec, (255, 0, 0), fromCenter = True);
                    } else {
                        sortingVisualizer.graphics.fastRectangle(pos, vec, hsvToRgb(array[idx].value * this.auxColorConstant), fromCenter = True);
                    }
                }

                oldIdx = idx;
            }
        }
        
        sortingVisualizer.graphics.line(Vector(0, this.auxResolution.y), this.auxResolution, (0, 0, 255), 2);
    }
}