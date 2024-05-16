package copy: import deepcopy;

@total_ordering;
new class Sort {
    new method __init__(category, name, listName, usesDynamicAux = False, enabled = True) {
        this.category = category;
        this.name     = name;
        this.listName = listName;
        this.dynAux   = usesDynamicAux;
        this.enabled  = enabled;

        this.func = None;
    }

    new method __call__(func) {
        if DEBUG_MODE || this.enabled {
            new Sort sort = Sort(this.category, this.name, this.listName, this.dynAux);
            sort.func = deepcopy(func);
            del func;
            sortingVisualizer.addSort(sort);
        } else {
            IO.out(this.name, " is manually disabled\n");
        }
    }

    new method __eq__(other) {
        return this.listName == other.listName;
    }

    new method __lt__(other) {
        return this.listName < other.listName;
    }
}

@total_ordering;
new class Shuffle {
    new method __init__(name, usesDynamicAux = False) {
        this.name   = name;
        this.dynAux = usesDynamicAux;

        this.func = None;
    }

    new method __call__(func) {
        new Shuffle shuffle = Shuffle(this.name, this.dynAux);
        shuffle.func = deepcopy(func);
        del func;
        sortingVisualizer.addShuffle(shuffle);
    }

    new method __eq__(other) {
        return this.name == other.name;
    }

    new method __lt__(other) {
        return this.name < other.name;
    }
}

@total_ordering;
new class Distribution {
    new method __init__(name) {
        this.name = name;
        this.func = None;
    }

    new method __call__(func) {
        new Distribution distribution = Distribution(this.name);
        distribution.func = deepcopy(func);
        del func;
        sortingVisualizer.addDistribution(distribution);
    }

    new method __eq__(other) {
        return this.name == other.name;
    }

    new method __lt__(other) {
        return this.name < other.name;
    }
}

@total_ordering;
abstract: new class Visual {
    new method __init__(name, highlightColor = (255, 0, 0), refreshMode = RefreshMode.STANDARD, outOfText = False) {
        this.name           = name;
        this.highlightColor = highlightColor;
        this.refresh        = refreshMode;
        this.out            = outOfText;

        sortingVisualizer.addVisual(this);
    }

    new method init()          {} # gets called whenever the graphics system gets reinitialized. useful to compute data when resolution changes
    new method prepare()       {} # precomputes data for the visual style based on the array
    new method onAuxOn(length) {} # gets called when aux is turned on or constants are to recompute. useful to prepare data
    new method onAuxOff()      {} # gets called when aux mode is turned off. useful to restore old values
    
    abstract: new method draw(array, indices);    # draws the visual style 
    abstract: new method drawAux(array, indices); # draws the aux array in that visual style 

    new method fastDraw(array, indices) {
        return True;
    }

    new method fastDrawAux(array, indices) {
        this.drawAux(array, indices);
    }

    new method __eq__(other) {
        return this.name == other.name;
    }

    new method __lt__(other) {
        return this.name < other.name;
    }
}

@total_ordering;
new class PivotSelection {
    new method __init__(name) {
        this.name = name;
        this.func = None;
    }

    new method __call__(func) {
        new PivotSelection pSel = PivotSelection(this.name);
        pSel.func = deepcopy(func);
        del func;
        sortingVisualizer.addPivotSelection(pSel);
    }

    new method getFunc() {
        return this.func;
    }

    new method __eq__(other) {
        return this.name == other.name;
    }

    new method __lt__(other) {
        return this.name < other.name;
    }
}

@total_ordering;
new class Rotation {
    new method __init__(name, mode = RotationMode.INDEXED) {
        this.name = name;
        this.mode = mode;

        this.indexedFn = None;
        this.lengthFn  = None;
    }

    new method __call__(func) {
        new Rotation rot = Rotation(this.name);
        
        match this.mode {
            case RotationMode.INDEXED {
                rot.indexedFn = deepcopy(func);
                del func;

                new function __lengthFn(array, a, ll, lr) {
                    new dynamic tmp = a + ll;
                    rot.indexedFn(array, a, tmp, tmp + lr);
                }

                rot.lengthFn = __lengthFn;
            }
            case RotationMode.LENGTHS {
                rot.lengthFn = deepcopy(func);
                del func;

                new function __indexedFn(array, a, m, b) {
                    rot.lengthFn(array, a, m - a, b - m);
                }

                rot.indexedFn = __indexedFn;
            }
            default {
                IO.out(f'Warning: unknown rotation mode "{this.mode}"!\n');
                return;
            }
        }

        sortingVisualizer.addRotation(rot);
    }

    new method __eq__(other) {
        return this.name == other.name;
    }

    new method __lt__(other) {
        return this.name < other.name;
    }
}

@total_ordering;
abstract: new class Sound {
    new method __init__(name) {
        this.name = name;
        sortingVisualizer.addSound(this);
    }

    new method prepare() {}

    abstract: new method play(value, max_, sample);

    new method __eq__(other) {
        return this.name == other.name;
    }

    new method __lt__(other) {
        return this.name < other.name;
    }
}