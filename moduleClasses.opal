package copy: import deepcopy;

@total_ordering;
new class Sort {
    new method __init__(category, name, listName) {
        this.category = category;
        this.name     = name;
        this.listName = listName;
        this.func     = None;
    }

    new method __call__(func) {
        new Sort sort = Sort(this.category, this.name, this.listName);
        sort.func = deepcopy(func);
        del func;
        sortingVisualizer.addSort(sort);
    }

    new method __eq__(other) {
        if this.listName == other.listName {
            return True;
        }
        return False;
    }

    new method __lt__(other) {
        if this.listName < other.listName {
            return True;
        }
        return False;
    }
}

@total_ordering;
new class Shuffle {
    new method __init__(name) {
        this.name     = name;
        this.func     = None;
    }

    new method __call__(func) {
        new Shuffle shuffle = Shuffle(this.name);
        shuffle.func = deepcopy(func);
        del func;
        sortingVisualizer.addShuffle(shuffle);
    }

    new method __eq__(other) {
        if this.name == other.name {
            return True;
        }
        return False;
    }

    new method __lt__(other) {
        if this.name < other.name {
            return True;
        }
        return False;
    }
}

@total_ordering;
new class Distribution {
    new method __init__(name) {
        this.name     = name;
        this.func     = None;
    }

    new method __call__(func) {
        new Distribution distribution = Distribution(this.name);
        distribution.func = deepcopy(func);
        del func;
        sortingVisualizer.addDistribution(distribution);
    }

    new method __eq__(other) {
        if this.name == other.name {
            return True;
        }
        return False;
    }

    new method __lt__(other) {
        if this.name < other.name {
            return True;
        }
        return False;
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

    abstract: new method draw(array, indices, color);
    abstract: new method drawAux(array, indices, color);

    new method __eq__(other) {
        if this.name == other.name {
            return True;
        }
        return False;
    }

    new method __lt__(other) {
        if this.name < other.name {
            return True;
        }
        return False;
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
        if this.name == other.name {
            return True;
        }
        return False;
    }

    new method __lt__(other) {
        if this.name < other.name {
            return True;
        }
        return False;
    }
}