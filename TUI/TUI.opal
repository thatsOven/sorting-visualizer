new function adjustTitle(title, sizeX) {
    if len(title) > sizeX - 4 {
        return title[:(sizeX - 7)] + "...";
    }
    return title;
}

new function multilineText(dialog, text, sizeX) {
    if len(text) <= sizeX - 4 {
        dialog.add(1, 2, text);
        return 3;
    }

    for pos = 2; len(text) > sizeX - 4; pos++ {
        new str tmp = text[:sizeX - 4];
        text = text[sizeX - 4:];
        dialog.add(1, pos, tmp);
    }

    if len(text) != 0 {
        dialog.add(1, pos, text);
        pos++;
    }

    return pos + 1;
}

new class UserWarn() {
    new method __init__(title, message, termSize = None) {
        this.title = title;
        this.message = message;

        if termSize is None {
            new auto tmp = os.get_terminal_size();
            this.termSize = Vector(tmp.columns, tmp.lines - 1);
        } else {
            this.termSize = termSize;
        }

        this.dialog = None;
    }

    new method __build() {
        new <Vector> tmp = this.termSize.copy() // 2;

        this.dialog = Dialog(tmp.x - (tmp.x // 2), tmp.y - (tmp.y // 2), tmp.x, tmp.y, title = adjustTitle("thatsOven's Sorting Visualizer - " + this.title, tmp.x));

        multilineText(this.dialog, this.message, tmp.x);

        new auto button = WButton(8, "OK");
        this.dialog.add(tmp.x // 2 - 4, tmp.y - 2, button);
        button.finish_dialog = ACTION_OK;
    }

    new method __screenRedraw(screen, allowCursor = False) {
        screen.attr_color(C_WHITE, C_BLACK);
        screen.cls();
        screen.attr_reset();
        this.dialog.redraw();
    }

    new method __screenResize(screen) {
        this.__build();
        this.__screenRedraw(screen);
    }

    new method run() {
        this.__build();

        with Context() {
            this.__screenRedraw(Screen);
            Screen.set_screen_redraw(this.__screenRedraw);
            Screen.set_screen_resize(this.__screenResize);

            this.dialog.loop();
        }
    }
}

new class userInputData() {
    new method __init__(who, message, type_ = None, default = None, common = None) {
        this.who     = who;
        this.message = message;
        this.type_   = type_;
        this.default = default;
        this.common  = common;
    }
}

enum TUIMode {
    SV, RUN_ALL, DIALOG, SELECTION, SORTSEL
}

enum SVModeIndices {
    ARRAY_SIZE, SPEED, DIST, SHUF, CAT, SORT, VIS
}

enum RunAllModeIndices {
    SPEED, DIST, SHUF, VIS
}

enum SortSelModeIndices {
    CAT, SORT
}

new class TUI() {
    new method __init__() {
        new auto tmp = os.get_terminal_size();

        this.termSize = Vector(tmp.columns, tmp.lines - 1);
        this.dialog   = None;

        this.__mode = 0;
        this.__sv = None;
        this.userInputData = None;
        this.__output = [];

        this.__cats = None;
        this.__chosenCat = None;
        this.__sorts = None;
    }

    new method setSv(sv) {
        this.__sv = sv;
    }

    new method __setShuffles(obj) {
        this.__shuffles = obj;
    }

    new method __getShuffles() {
        return this.__shuffles;
    }

    new method __setDistributions(obj) {
        this.__distributions = obj;
    }

    new method __getDistributions() {
        return this.__distributions;
    }

    new method __setSorts(obj) {
        this.__sorts = obj;
    }

    new method __getSorts() {
        return this.__sorts;
    }

    new method __setVisuals(obj) {
        this.__visuals = obj;
    }

    new method __getVisuals() {
        return this.__visuals;
    }

    new method __handleCategoryChange(key) {
        this.__chosenCat = this.__sv.categories[this.__cats.get()];
        this.__sorts.set_items([sort.listName for sort in this.__sv.sorts[this.__chosenCat]]);
        this.__sorts.redraw();
    }

    new method __buildList(posX, listSize, setFunc, title, content, getFunc) {
        setFunc(WListBox(listSize.x, listSize.y, content));
        this.dialog.add(posX, 5, title);
        new auto prop = getFunc();
        this.dialog.add(posX, 6, prop);
        this.__output.append(prop);
    }

    new method __buildCategoryList(posX, listSize) {
        this.__cats = WListBox(listSize.x, listSize.y, this.__sv.categories);
        this.dialog.add(posX, 5, "Category: ");
        this.dialog.add(posX, 6, this.__cats);
        this.__cats.on("changed", this.__handleCategoryChange);
        this.__output.append(this.__cats);
    }

    new method __buildButton(pos, size, text) {
        new auto tmp = WButton(size, text);
        this.dialog.add(pos.x, pos.y, tmp);
        tmp.finish_dialog = ACTION_OK;
    }

    new method buildSV() {
        this.__mode = TUIMode.SV;
        this.__chosenCat = this.__sv.categories[0];
        this.__output = [];

        this.dialog = Dialog(0, 0, this.termSize.x, this.termSize.y, title = adjustTitle("thatsOven's Sorting Visualizer", this.termSize.x));

        this.__arraySize = WComboBox(8, "1024", [str(2 ** i) for i in range(2, 15)]);
        this.dialog.add(2, 1, "Array size:");
        this.dialog.add(2, 2, this.__arraySize);
        this.__output.append(this.__arraySize);

        this.__speed = WTextEntry(4, "1");
        this.dialog.add(this.termSize.x - 8, 1, "Speed: ");
        this.dialog.add(this.termSize.x - 8, 2, this.__speed);
        this.__output.append(this.__speed);

        new <Vector> listSize;
        listSize = Vector(
            this.termSize.x // 5 - 5,
            this.termSize.y - 7
        );

        new int listSpacing = (2 * ((this.termSize.x - (listSize.x * 2)) // 3 - listSize.x + 1)) // 3;

        this.__buildList(1, listSize, this.__setDistributions, "Distribution: ", [dist.name for dist in this.__sv.distributions], this.__getDistributions);

        this.__buildList(listSize.x + listSpacing, listSize, this.__setShuffles, "Shuffle: ", [shuf.name for shuf in this.__sv.shuffles], this.__getShuffles);

        this.__buildCategoryList(2 * (listSize.x + listSpacing), listSize);

        this.__buildList(3 * (listSize.x + listSpacing), listSize, this.__setSorts, "Sort: ", [sort.listName for sort in this.__sv.sorts[this.__chosenCat]], this.__getSorts);

        this.__buildList(this.termSize.x - listSize.x - 1, listSize, this.__setVisuals, "Visual: ", [vis.name for vis in this.__sv.visuals], this.__getVisuals);

        this.__buildButton(Vector(this.termSize.x // 2 - 4, this.termSize.y - 1), 8, "OK");
    }

    new method buildRunAll() {
        this.__mode = TUIMode.RUN_ALL;

        this.__output = [];

        this.dialog = Dialog(0, 0, this.termSize.x, this.termSize.y, title = adjustTitle("thatsOven's Sorting Visualizer - Run All Sorts", this.termSize.x));

        this.__speed = WTextEntry(4, "1");
        this.dialog.add(2, 1, "Speed: ");
        this.dialog.add(2, 2, this.__speed);
        this.__output.append(this.__speed);

        new <Vector> listSize;
        listSize = Vector(
            this.termSize.x // 3 - 3,
            this.termSize.y - 7
        );

        this.__buildList(1, listSize, this.__setDistributions, "Distribution: ", [dist.name for dist in this.__sv.distributions], this.__getDistributions);

        new int shufPos = this.termSize.x // 2 - listSize.x // 2;
        this.__buildList(shufPos, listSize, this.__setShuffles, "Shuffle: ", [shuf.name for shuf in this.__sv.shuffles], this.__getShuffles);

        this.__buildList(this.termSize.x - listSize.x - 1, listSize, this.__setVisuals, "Visual: ", [vis.name for vis in this.__sv.visuals], this.__getVisuals);

        this.__buildButton(Vector(this.termSize.x // 2 - 4, this.termSize.y - 1), 7, "Run");
    }

    new method __userInputDialogUnwrapped() {
        new <Vector> tmp = this.termSize.copy() // 2;

        this.__output = [];

        this.dialog = Dialog(tmp.x - (tmp.x // 2), tmp.y - (tmp.y // 2), tmp.x, tmp.y, title = adjustTitle("thatsOven's Sorting Visualizer - " + this.userInputData.who, tmp.x));

        multilineText(this.dialog, this.userInputData.message, tmp.x);
        new auto entry = WComboBox(tmp.x - 2, this.userInputData.default, [this.userInputData.default] + this.userInputData.common);
        this.dialog.add(1, 3, entry);
        this.__output.append(entry);

        this.__buildButton(Vector(tmp.x // 2 - 4, tmp.y - 1), 8, "OK");
    }

    new method userInputDialog(who, message, type_, default, common = []) {
        this.__mode = TUIMode.DIALOG;
        this.userInputData = userInputData(who, message, type_, default, common);
        this.__userInputDialogUnwrapped();
    }

    new method __selectionUnwrapped() {
        new <Vector> tmp = this.termSize.copy() // 2;

        this.__output = [];

        this.dialog = Dialog(tmp.x - (tmp.x // 2), tmp.y - (tmp.y // 2), tmp.x, tmp.y, title = adjustTitle("thatsOven's Sorting Visualizer - " + this.userInputData.who, tmp.x));

        new int p;
        p = multilineText(this.dialog, this.userInputData.message, tmp.x);
        new dynamic entry;
        entry = WListBox(tmp.x - 2, tmp.y - p - 1, this.userInputData.type_);
        this.dialog.add(1, p, entry);
        this.__output.append(entry);

        this.__buildButton(Vector(tmp.x // 2 - 4, tmp.y - 1), 8, "OK");
    }

    new method selection(who, message, content) {
        this.__mode = TUIMode.SELECTION;
        this.userInputData = userInputData(who, message, content);
        this.__selectionUnwrapped();
    }

    new method buildSortSelection() {
        this.__mode = TUIMode.SORTSEL;
        this.__chosenCat = this.__sv.categories[0];
        this.__output = [];

        this.dialog = Dialog(0, 0, this.termSize.x, this.termSize.y, title = adjustTitle("thatsOven's Sorting Visualizer - Select sort", this.termSize.x));

        this.dialog.add(1, 2, "Select sort:");

        new <Vector> listSize;
        listSize = Vector(this.termSize.x // 2 - 2, this.termSize.y - 8);

        this.__buildCategoryList(1, listSize);

        this.__buildList(this.termSize.x - listSize.x - 1, listSize, this.__setSorts, "Sort: ", [sort.listName for sort in this.__sv.sorts[this.__chosenCat]], this.__getSorts);

        this.__buildButton(Vector(this.termSize.x // 2 - 4, this.termSize.y - 1), 8, "OK");
    }

    new method __screenRedraw(screen, allowCursor = False) {
        screen.attr_color(C_WHITE, C_BLACK);
        screen.cls();
        screen.attr_reset();
        this.dialog.redraw();
    }

    new method __screenResize(screen) {
        match this.__mode {
            case TUIMode.SV {
                this.buildSV();
            }
            case TUIMode.RUN_ALL {
                this.buildRunAll();
            }
            case TUIMode.DIALOG {
                this.__userInputDialogUnwrapped();
            }
            case TUIMode.SELECTION {
                this.__selectionUnwrapped();
            }
            case TUIMode.SORTSEL {
                this.buildSortSelection();
            }
        }

        this.__screenRedraw(screen);
    }

    new method run() {
        with Context() {
            this.__screenRedraw(Screen);
            Screen.set_screen_redraw(this.__screenRedraw);
            Screen.set_screen_resize(this.__screenResize);

            this.dialog.loop();
        }

        match this.__mode {
            case TUIMode.SV {
                new dynamic size, speed;
                size  = this.__output[SVModeIndices.ARRAY_SIZE].get();
                speed = this.__output[SVModeIndices.SPEED].get();

                if not checkType(size, int) {
                    UserWarn("Error", "Invalid array size. Please retry.", this.termSize).run();
                    return this.run();
                } else {
                    size = int(size);
                }

                if not checkType(speed, float) {
                    UserWarn("Error", "Invalid speed value. Please retry.", this.termSize).run();
                    return this.run();
                } else {
                    speed = float(speed);
                }

                return {
                    "array-size"  : size,
                    "speed"       : speed,
                    "distribution": this.__output[SVModeIndices.DIST].get(),
                    "shuffle"     : this.__output[SVModeIndices.SHUF].get(),
                    "category"    : this.__output[SVModeIndices.CAT].get(),
                    "sort"        : this.__output[SVModeIndices.SORT].get(),
                    "visual"      : this.__output[SVModeIndices.VIS].get()
                };
            }
            case TUIMode.RUN_ALL {
                new dynamic speed;
                speed = this.__output[RunAllModeIndices.SPEED].get();

                if not checkType(speed, float) {
                    UserWarn("Error", "Invalid speed value. Please retry.", this.termSize).run();
                    return this.run();
                } else {
                    speed = float(speed);
                }

                return {
                    "speed"       : speed,
                    "distribution": this.__output[RunAllModeIndices.DIST].get(),
                    "shuffle"     : this.__output[RunAllModeIndices.SHUF].get(),
                    "visual"      : this.__output[RunAllModeIndices.VIS].get()
                };
            }
            case TUIMode.DIALOG {
                new dynamic result = this.__output[0].get();

                if result in ("", None) {
                    result = this.userInputData.default;
                }

                if not checkType(result, this.userInputData.type_) {
                    UserWarn("Error", "Invalid input. Please retry.", this.termSize).run();
                    return this.run();
                } else {
                    return this.userInputData.type_(result);
                }
            }
            case TUIMode.SELECTION {
                return this.__output[0].get();
            }
            case TUIMode.SORTSEL {
                return {
                    "category": this.__output[SortSelModeIndices.CAT].get(),
                    "sort"    : this.__output[SortSelModeIndices.SORT].get()
                };
            }
        }
    }
}