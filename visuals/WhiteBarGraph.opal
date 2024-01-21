new class WhiteBarGraph: LineVisual {
    new method __init__() {
        super().__init__(
            "Bar Graph",
            (255, 0, 0)
        );
    }

    new method draw(array, indices) {
        static: new int i;

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

                for i in indices {
                    if indices[i] is not None && i in range(oldIdx, idx) {
                        sortingVisualizer.graphics.line(pos, end, indices[i], 1);
                        break;
                    }
                } else {
                    sortingVisualizer.graphics.line(pos, end, (255, 255, 255), 1);
                }

                pos.x++;
                end.x++;
                oldIdx = idx;
            }
        } else {
            for i = this.lineSize // 2; i < sortingVisualizer.graphics.resolution.x; i += this.lineSize {
                idx = int(Utils.translate(
                    i - this.lineSize // 2, 0, sortingVisualizer.graphics.resolution.x, 
                    0, len(array)
                ));

                pos.x = i;
                end.x = i;
                end.y = pos.y - int(array[idx].value * this.lineLengthConst);

                if idx in indices {
                    sortingVisualizer.graphics.line(pos, end, indices[idx], this.lineSize);
                } else {
                    sortingVisualizer.graphics.line(pos, end, (255, 255, 255), this.lineSize);
                }
            }
        }
    }

    new method fastDraw(array, indices) {
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
                sortingVisualizer.graphics.line(pos, lineEnd, (255, 255, 255), this.lineSize);
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
                    sortingVisualizer.graphics.line(pos, end, (255, 255, 255), 1);
                }

                pos.x++;
                end.x++;
                oldIdx = idx;
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
                    sortingVisualizer.graphics.line(pos, end, (255, 255, 255), this.auxLineSize);
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
                    sortingVisualizer.graphics.line(pos, end, (255, 255, 255), 1);
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
                    sortingVisualizer.graphics.line(pos, end, (255, 255, 255), this.auxLineSize);
                }
            }
        }

        sortingVisualizer.graphics.line(Vector(0, this.auxResolution.y), this.auxResolution, (0, 0, 255), 2);
    }
}