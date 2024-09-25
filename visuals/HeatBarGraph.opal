new class HeatBarGraph: LineVisual {
    new method __init__() {
        super.__init__(
            "Heat Bar Graph",
            (255, 255, 255)
        );

        this.colorMap = colormaps["magma"];
    }

    new method __getColorFromIdx(idx, aux = None) {
        return tuple(
            int(x * 255) 
            for x in this.colorMap(sortingVisualizer.getHeatMapNormalizedValue(idx, aux))
        );
    }

    new method draw(array, indices) {
        static: new int oldIdx, i, j;

        indices = {x: indices[x] for x in indices if indices[x] is not None && indices[x] == this.highlightColor};

        new dynamic pos = sortingVisualizer.graphics.resolution.copy(),
                    end = pos.copy(), idx;
        pos.x = 0;
        end.x = 0;

        if len(array) > sortingVisualizer.graphics.resolution.x {
            oldIdx = 0;
            for x in range(sortingVisualizer.graphics.resolution.x) {
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
                    sortingVisualizer.graphics.line(pos, end, this.__getColorFromIdx(idx), 1);
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
                    sortingVisualizer.graphics.line(pos, end, this.__getColorFromIdx(idx), this.lineSize);
                }

                oldIdx = idx;
            }
        }
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
                    sortingVisualizer.graphics.line(pos, end, this.__getColorFromIdx(idx, array), 1);
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
                    sortingVisualizer.graphics.line(pos, end, this.__getColorFromIdx(idx, array), this.auxLineSize);
                }

                oldIdx = idx;
            }
        }
        
        sortingVisualizer.graphics.line(Vector(0, this.auxResolution.y), this.auxResolution, (0, 0, 255), 2);
    }
}