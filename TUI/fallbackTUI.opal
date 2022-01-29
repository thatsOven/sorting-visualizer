new class UserWarn() {
    new method __init__(stPlaceHolder, message, ndPlaceHolder = None) {
        this.message = message;
    }

    new method run() {
        IO.out(this.message, IO.endl);
    }
}

new function getType(message, type_) {
    while True {
        IO.out(message, IO.endl);
        new dynamic in_ = IO.read("> ");

        if checkType(in_, type_) {
            return type_(in_);
        } else {
            IO.out("Invalid input. Please retry.\n");
        }
    }
}

new function selection(message, content) {
    while True {
        IO.out(message, IO.endl);
        for i, line in enumerate(content) {
            IO.out(i + 1, ") ", line, IO.endl);
        }
        new dynamic sel = IO.read("> ");

        if checkType(sel, int) {
            sel = int(sel);

            if sel in range(1, len(content) + 1) {
                return sel - 1;
            } else {
                IO.out("Invalid input. Please retry.\n");
            }
        } else {
            IO.out("Invalid input. Please retry.\n");
        }
    }
}

new class TUI() {
    new method __init__() {
        this.__sv = None;

        this.__toCall = None;
        this.__args   = None;
    }

    new method setSv(sv) {
        this.__sv = sv;
    }

    new method userInputDialog(stPlaceHolder, message, type_, ndPlaceHolder, rdPlaceHolder = None) {
        this.__toCall = getType;
        this.__args   = (message, type_);
    }

    new method selection(stPlaceHolder, message, content) {
        this.__toCall = selection;
        this.__args   = (message, content);
    }

    new method __SVRun() {
        new int size, dist, shuf, cat, sort, vis;
        new float speed;
        size  = getType("Insert array size:", int);
        dist  = selection("Select distribution:", [dist.name for dist in this.__sv.distributions]);
        shuf  = selection("Select shuffle:", [shuf.name for shuf in this.__sv.shuffles]);
        cat   = selection("Select sort category:", this.__sv.categories);
        sort  = selection("Select sort:", [sort.listName for sort in this.__sv.sorts[this.__sv.categories[cat]]]);
        vis   = selection("Select visual style:", [vis.name for vis in this.__sv.visuals]);
        speed = getType("Insert speed:", float);

        return {
            "array-size"  : size,
            "speed"       : speed,
            "distribution": dist,
            "shuffle"     : shuf,
            "category"    : cat,
            "sort"        : sort,
            "visual"      : vis 
        };
    }

    new method buildSV() {
        this.__toCall = this.__SVRun;
        this.__args   = None;
    }

    new method __runAll() {
        new int dist, shuf, vis;
        new float speed;

        speed = getType("Insert speed multiplier: ", float);
        dist  = selection("Select distribution:", [dist.name for dist in this.__sv.distributions]);
        shuf  = selection("Select shuffle:", [shuf.name for shuf in this.__sv.shuffles]);
        vis   = selection("Select visual style:", [vis.name for vis in this.__sv.visuals]);

        return {
            "speed"       : speed,
            "distribution": dist,
            "shuffle"     : shuf,
            "visual"      : vis 
        };
    }

    new method buildRunAll() {
        this.__toCall = this.__runAll;
        this.__args   = None;
    }

    new method __sortSel() {
        new int cat, sort;
        cat  = selection("Select sort category:", this.__sv.categories);
        sort = selection("Select sort:", [sort.listName for sort in this.__sv.sorts[this.__sv.categories[cat]]]);
    
        return {
            "category": cat,
            "sort"    : sort
        };  
    }

    new method buildSortSelection() {
        this.__toCall = this.__sortSel;
        this.__args   = None;
    }

    new method run() {
        if this.__args == None {
            return this.__toCall();
        } else {
            return this.__toCall(*this.__args);
        }
    }
}