new function checkType(value, type_) {
    try {
        new dynamic tmp = type_(value);
    } catch ValueError {
        return False;
    }
    return True;
}

new class GUI {
    new Vector TEXT_OFFS = Vector(2, 2);
    new int FPS = 60;

    new method __init__() {
        this.__clock   = Clock();
        this.__manager = None;
        this.__sv      = None;

        this.__oldCat    = None;
        this.__oldLength = None;
    }

    new method setSv(sv) {
        this.__sv = sv;
        this.__manager = UIManager(this.__sv.graphics.resolution.toList(2));

        this.OFFS              = this.__sv.graphics.resolution // 80;
        this.WIN_SIZE          = this.__sv.graphics.resolution // 2;
        this.SMALL_WIN_SIZE    = Vector(this.__sv.graphics.resolution.x // 4, this.__sv.graphics.resolution.y // 6);
        this.SETTINGS_WIN_SIZE = Vector(this.__sv.graphics.resolution.x // 2, this.__sv.graphics.resolution.y * 0.8).getIntCoords();

        this.__buildSV();
        this.__buildRunAll();
        this.__buildSortSel();

        this.__sv.graphics.simpleText(f"opal Sorting Visualizer v{VERSION}", GUI.TEXT_OFFS);
        this.saveBackground();
    }

    new method saveBackground() {
        this.__background = this.__sv.graphics.screen.copy();
    }

    new method __loop(fn, fn0 = lambda *a: None) {
        while True {
            new dynamic delta = this.__clock.tick(GUI.FPS) / 1000.0;

            for event in this.__sv.graphics.getEvents() {
                if event.type in this.__sv.graphics.eventActions {
                    this.__sv.graphics.eventActions[event.type](event);
                }

                if event.type in (
                    pygame_gui.UI_BUTTON_PRESSED,
                    pygame_gui.UI_DROP_DOWN_MENU_CHANGED,
                    pygame_gui.UI_FILE_DIALOG_PATH_PICKED
                ) {
                    new dynamic res = fn(event);
                    if res is not None {
                        return res;
                    }
                }

                this.__manager.process_events(event);
            }

            if fn0() {
                return;
            }

            this.__manager.update(delta);

            this.__sv.graphics.blitSurf(this.__background, Vector());
            this.__manager.draw_ui(this.__sv.graphics.screen);

            this.__sv.graphics.rawUpdate();
        }
    }

    new method __genericDialog(who, message, type_, default, textInput) {
        new dynamic win = elements.UIWindow(
            Rect(
                this.__sv.graphics.resolution.x - this.WIN_SIZE.x // 2,
                this.__sv.graphics.resolution.y - this.WIN_SIZE.y // 2,
                this.WIN_SIZE.x, this.WIN_SIZE.y
            ),
            this.__manager, window_display_title = who
        );
        win.set_blocking(True);
        win.on_close_window_button_pressed = lambda *a: None;
        win.set_position((this.__sv.graphics.resolution // 2 - this.WIN_SIZE // 2).toList(2));

        new dynamic entry;
        if textInput {
            elements.UITextBox(
                message, Rect(
                    GUI.TEXT_OFFS.x, GUI.TEXT_OFFS.y,
                    this.WIN_SIZE.x - GUI.TEXT_OFFS.x - 40,
                    80
                ),
                this.__manager, container = win
            );

            entry = elements.UITextEntryLine(
                Rect(
                    GUI.TEXT_OFFS.x, GUI.TEXT_OFFS.y + 80,
                    this.WIN_SIZE.x - GUI.TEXT_OFFS.x,
                    20
                ),
                this.__manager, container = win,
                initial_text = default,
            );
        } else {
            elements.UITextBox(
                message, Rect(
                    GUI.TEXT_OFFS.x, GUI.TEXT_OFFS.y,
                    this.WIN_SIZE.x - GUI.TEXT_OFFS.x - 40,
                    this.WIN_SIZE.y - GUI.TEXT_OFFS.y - 120
                ),
                this.__manager, container = win
            );

            entry = None;
        }

        new dynamic button = elements.UIButton(
            Rect(
                this.WIN_SIZE.x // 2 - 60,
                this.WIN_SIZE.y - 100 - GUI.TEXT_OFFS.y,
                100, 40
            ),
            "OK", this.__manager, win
        );

        new function __internal(event) {
            if event.ui_element == button {
                if entry is None {
                    return 1;
                } else {
                    new dynamic out = entry.get_text();
                    if checkType(out, type_) {
                        return type_(out);
                    } else {
                        this.userWarn("Error", "Invalid input. Please retry.");
                    }
                }
            }
        }

        new dynamic res = this.__loop(__internal);
        win.kill();
        return res;
    }

    new method userWarn(title, message) {
        this.__genericDialog(title, message, None, None, False);
    }

    new method userInputDialog(who, message, type_, default = None) {
        return this.__genericDialog(who, message, type_, default, True);
    }

    new method selection(who, message, content) {
        new dynamic win = elements.UIWindow(
            Rect(
                this.__sv.graphics.resolution.x - this.WIN_SIZE.x // 2,
                this.__sv.graphics.resolution.y - this.WIN_SIZE.y // 2,
                this.WIN_SIZE.x, this.WIN_SIZE.y
            ),
            this.__manager, window_display_title = who
        );
        win.set_blocking(True);
        win.on_close_window_button_pressed = lambda *a: None;
        win.set_position((this.__sv.graphics.resolution // 2 - this.WIN_SIZE // 2).toList(2));

        elements.UITextBox(
            message, Rect(
                GUI.TEXT_OFFS.x, GUI.TEXT_OFFS.y,
                this.WIN_SIZE.x - GUI.TEXT_OFFS.x - 40,
                80
            ),
            this.__manager, container = win
        );

        new dynamic lst = elements.UISelectionList(
            Rect(
                GUI.TEXT_OFFS.x, GUI.TEXT_OFFS.y + 80,
                this.WIN_SIZE.x - GUI.TEXT_OFFS.x - 40,
                this.WIN_SIZE.y - GUI.TEXT_OFFS.y - 200
            ),
            content, this.__manager,
            container = win
        );

        new dynamic button = elements.UIButton(
            Rect(
                this.WIN_SIZE.x // 2 - 60,
                this.WIN_SIZE.y - 100 - GUI.TEXT_OFFS.y,
                100, 40
            ),
            "OK", this.__manager, win
        );

        new function __internal(event) {
            if event.ui_element == button {
                new dynamic res = lst.get_single_selection();
                if res is not None {
                    return content.index(res);
                }
            }
        }

        new dynamic res = this.__loop(__internal);
        win.kill();
        return res;
    }

    new method __buildSortSel() {
        this.__sortSelPanel = elements.UIPanel(
            Rect(
                this.OFFS.x, this.OFFS.y, this.__sv.graphics.resolution.x - this.OFFS.x * 2, this.__sv.graphics.resolution.y - this.OFFS.y * 2
            ), manager = this.__manager
        );
        this.__sortSelPanel.hide();

        new int listOffs = (this.__sv.graphics.resolution.x - this.OFFS.x) // 2,
                listSize = listOffs - (this.__sv.graphics.resolution.x - this.OFFS.x) // 25;

        elements.UILabel(
            Rect(this.OFFS.x, this.OFFS.y + 80, listSize, 20),
            "Category", this.__manager, this.__sortSelPanel
        );
        this.__chosenCat  = this.__sv.categories[0];
        this.__sortSelCategories = elements.UISelectionList(
            Rect(this.OFFS.x, this.OFFS.y + 100, listSize, this.__sv.graphics.resolution.y - this.OFFS.y * 2 - 180),
            this.__sv.categories, this.__manager,
            container = this.__sortSelPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x + listOffs, this.OFFS.y + 80, listSize, 20),
            "Sort", this.__manager, this.__sortSelPanel
        );
        this.__sorts = [sort.listName for sort in this.__sv.sorts[this.__chosenCat]];
        this.__sortSelSorts = elements.UISelectionList(
            Rect(this.OFFS.x + listOffs, this.OFFS.y + 100, listSize, this.__sv.graphics.resolution.y - this.OFFS.y * 2 - 180),
            this.__sorts, this.__manager, container = this.__sortSelPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x + listOffs, this.OFFS.y, listSize, 20),
            "Select sort", this.__manager, this.__sortSelPanel
        );

        this.__sortSelButton = elements.UIButton(
            Rect(this.OFFS.x + listOffs, this.__sv.graphics.resolution.y - this.OFFS.y * 2 - 60, listSize, 40),
            "OK", this.__manager, this.__sortSelPanel,
        );
    }

    new method __updateSortCat(categories, sorts) {
        new function __fn() {
            new dynamic cat = categories.get_single_selection();
            if cat {
                cat = this.__sv.categories.index(cat);

                if cat != this.__oldCat {
                    sorts.remove_items(this.__sorts);
                    this.__sorts = [sort.listName for sort in this.__sv.sorts[this.__sv.categories[cat]]];
                    sorts.add_items(this.__sorts);
                    this.__oldCat = cat;
                }
            }
        }

        return __fn;
    }

    new method sortSelection() {
        this.__sortSelPanel.show();

        new function __internal(event) {
            if event.ui_element == this.__sortSelButton {
                new dynamic cat, sort;

                cat = this.__sortSelCategories.get_single_selection();
                if cat  {
                    cat = this.__sv.categories.index(cat);
                } else {
                    this.userWarn("Error", "Select a category first");
                    return;
                }

                sort = this.__sortSelSorts.get_single_selection();
                if sort {
                    sort = this.__sorts.index(sort);
                } else {
                    this.userWarn("Error", "Select a sort first");
                    return;
                }

                return {
                    "category": cat,
                    "sort"    : sort
                };
            }
        }

        new dict result = this.__loop(__internal, this.__updateSortCat(this.__sortSelCategories, this.__sortSelSorts));
        this.__sortSelPanel.hide();
        return result;
    }

    new method __buildSV() {
        this.__svPanel = elements.UIPanel(
            Rect(
                this.OFFS.x, this.OFFS.y, this.__sv.graphics.resolution.x - this.OFFS.x * 2, this.__sv.graphics.resolution.y - this.OFFS.y * 2
            ), manager = this.__manager
        );
        this.__svPanel.hide();

        elements.UILabel(
            Rect(this.OFFS.x, this.OFFS.y + 20, 100, 20),
            "Array length", this.__manager, this.__svPanel
        );
        this.__svArrayLength = elements.UITextEntryLine(
            Rect(this.OFFS.x, this.OFFS.y + 40, 100, 20),
            this.__manager, this.__svPanel,
            initial_text = '1024'
        );

        elements.UILabel(
            Rect(this.OFFS.x + 120, this.OFFS.y + 20, 120, 20),
            "Unique amount", this.__manager, this.__svPanel
        );
        this.__svUnique = elements.UITextEntryLine(
            Rect(this.OFFS.x + 120, this.OFFS.y + 40, 120, 20),
            this.__manager, this.__svPanel,
            initial_text = '512'
        );

        elements.UILabel(
            Rect(this.__sv.graphics.resolution.x - this.OFFS.x * 2 - 120, this.OFFS.y + 20, 100, 20),
            "Speed", this.__manager, this.__svPanel
        );
        this.__svSpeed = elements.UITextEntryLine(
            Rect(this.__sv.graphics.resolution.x - this.OFFS.x * 2 - 120, this.OFFS.y + 40, 100, 20),
            this.__manager, this.__svPanel,
            initial_text = '1'
        );

        new int listOffs = (this.__sv.graphics.resolution.x - this.OFFS.x) // 5,
                listSize = listOffs - (this.__sv.graphics.resolution.x - this.OFFS.x) // 25;

        elements.UILabel(
            Rect(this.OFFS.x, this.OFFS.y + 80, listSize, 20),
            "Distribution", this.__manager, this.__svPanel
        );
        this.__distributions = [dist.name for dist in this.__sv.distributions];
        this.__svDistributions = elements.UISelectionList(
            Rect(this.OFFS.x, this.OFFS.y + 100, listSize, this.__sv.graphics.resolution.y - this.OFFS.y * 2 - 180),
            this.__distributions, this.__manager, container = this.__svPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x + listOffs, this.OFFS.y + 80, listSize, 20),
            "Shuffle", this.__manager, this.__svPanel
        );
        this.__shuffles = [shuf.name for shuf in this.__sv.shuffles];
        this.__svShuffles = elements.UISelectionList(
            Rect(this.OFFS.x + listOffs, this.OFFS.y + 100, listSize, this.__sv.graphics.resolution.y - this.OFFS.y * 2 - 180),
            this.__shuffles, this.__manager, container = this.__svPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x + listOffs * 2, this.OFFS.y + 80, listSize, 20),
            "Category", this.__manager, this.__svPanel
        );
        this.__svCategories = elements.UISelectionList(
            Rect(this.OFFS.x + listOffs * 2, this.OFFS.y + 100, listSize, this.__sv.graphics.resolution.y - this.OFFS.y * 2 - 180),
            this.__sv.categories, this.__manager,
            container = this.__svPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x + listOffs * 3, this.OFFS.y + 80, listSize, 20),
            "Sort", this.__manager, this.__svPanel
        );
        this.__sorts = [sort.listName for sort in this.__sv.sorts[this.__sv.categories[0]]];
        this.__svSorts = elements.UISelectionList(
            Rect(this.OFFS.x + listOffs * 3, this.OFFS.y + 100, listSize, this.__sv.graphics.resolution.y - this.OFFS.y * 2 - 180),
            this.__sorts, this.__manager, container = this.__svPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x + listOffs * 4, this.OFFS.y + 80, listSize, 20),
            "Visual", this.__manager, this.__svPanel
        );
        this.__visuals = [vis.name for vis in this.__sv.visuals];
        this.__svVisuals = elements.UISelectionList(
            Rect(this.OFFS.x + listOffs * 4, this.OFFS.y + 100, listSize, this.__sv.graphics.resolution.y - this.OFFS.y * 2 - 180),
            this.__visuals, this.__manager, container = this.__svPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x + listOffs * 2, this.OFFS.y, listSize, 20),
            "Run Sort", this.__manager, this.__svPanel
        );

        this.__svRunButton = elements.UIButton(
            Rect(this.OFFS.x + listOffs * 2, this.__sv.graphics.resolution.y - this.OFFS.y * 2 - 60, listSize, 40),
            "Run", this.__manager, this.__svPanel,
            tool_tip_text = "Runs the selected sort with the given settings"
        );
    }

    new method runSort() {
        this.__svPanel.show();

        new function __internal(event) {
            if event.ui_element == this.__svRunButton {
                new dynamic size, unique, speed;
                size   = this.__svArrayLength.get_text();
                unique = this.__svUnique.get_text();
                speed  = this.__svSpeed.get_text();

                if checkType(size, int) {
                    int <- size;

                    if size < 0 {
                        this.userWarn("Error", "Invalid array size. Please retry.");
                        return;
                    }
                } else {
                    this.userWarn("Error", "Invalid array size. Please retry.");
                    return;
                }

                if checkType(unique, int) {
                    int <- unique;

                    if unique < 0 || unique > size {
                        this.userWarn("Error", "Invalid unique amount. Please retry.");
                        return;
                    }
                } else {
                    this.userWarn("Error", "Invalid unique amount. Please retry.");
                    return;
                }

                if checkType(speed, float) {
                    float <- speed;

                    if speed < 0 {
                        this.userWarn("Error", "Invalid speed value. Please retry.");
                        return;
                    }
                } else {
                    this.userWarn("Error", "Invalid speed value. Please retry.");
                    return;
                }

                new dynamic dist, shuf, cat, sort, vis;

                dist = this.__svDistributions.get_single_selection();
                if dist {
                    dist = this.__distributions.index(dist);
                } else {
                    this.userWarn("Error", "Select a distribution first");
                    return;
                }

                shuf = this.__svShuffles.get_single_selection();
                if shuf {
                    shuf = this.__shuffles.index(shuf);
                } else {
                    this.userWarn("Error", "Select a shuffle first");
                    return;
                }

                cat = this.__svCategories.get_single_selection();
                if cat {
                    cat = this.__sv.categories.index(cat);
                } else {
                    this.userWarn("Error", "Select a category first");
                    return;
                }

                sort = this.__svSorts.get_single_selection();
                if sort {
                    sort = this.__sorts.index(sort);
                } else {
                    this.userWarn("Error", "Select a sort first");
                    return;
                }

                vis = this.__svVisuals.get_single_selection();
                if vis {
                    vis = this.__visuals.index(vis);
                } else {
                    this.userWarn("Error", "Select a visual style first");
                    return;
                }

                return {
                    "array-size"  : size,
                    "unique"      : unique,
                    "speed"       : speed,
                    "distribution": dist,
                    "shuffle"     : shuf,
                    "category"    : cat,
                    "sort"        : sort,
                    "visual"      : vis
                };
            }
        }

        new dynamic updateSortCat = this.__updateSortCat(this.__svCategories, this.__svSorts);
        new function __update() {
            updateSortCat();

            new dynamic length = this.__svArrayLength.get_text();
            if length != this.__oldLength {
                if checkType(length, int) {
                    this.__oldLength = length;
                    int <- length;
                    this.__svUnique.set_text(str(length // 2));
                }
            }
        }

        new dict result = this.__loop(__internal, __update);
        this.__svPanel.hide();
        return result;
    }

    new method __buildRunAll() {
        this.__runAllPanel = elements.UIPanel(
            Rect(
                this.OFFS.x, this.OFFS.y, this.__sv.graphics.resolution.x - this.OFFS.x * 2, this.__sv.graphics.resolution.y - this.OFFS.y * 2
            ), manager = this.__manager
        );
        this.__runAllPanel.hide();

        elements.UILabel(
            Rect(this.OFFS.x, this.OFFS.y + 20, 200, 20),
            "Array length multiplier", this.__manager, this.__runAllPanel
        );
        this.__runAllSizeMlt = elements.UITextEntryLine(
            Rect(this.OFFS.x, this.OFFS.y + 40, 200, 20),
            this.__manager, this.__runAllPanel,
            initial_text = '1'
        );

        elements.UILabel(
            Rect(this.OFFS.x + 220, this.OFFS.y + 20, 120, 20),
            "Unique divisor", this.__manager, this.__runAllPanel
        );
        this.__runAllUniqueDiv = elements.UITextEntryLine(
            Rect(this.OFFS.x + 220, this.OFFS.y + 40, 120, 20),
            this.__manager, this.__runAllPanel,
            initial_text = '2'
        );

        elements.UILabel(
            Rect(this.__sv.graphics.resolution.x - this.OFFS.x * 2 - 120, this.OFFS.y + 20, 100, 20),
            "Speed", this.__manager, this.__runAllPanel
        );
        this.__runAllSpeed = elements.UITextEntryLine(
            Rect(this.__sv.graphics.resolution.x - this.OFFS.x * 2 - 120, this.OFFS.y + 40, 100, 20),
            this.__manager, this.__runAllPanel,
            initial_text = '1'
        );

        new int listOffs = (this.__sv.graphics.resolution.x - this.OFFS.x) // 3,
                listSize = listOffs - (this.__sv.graphics.resolution.x - this.OFFS.x) // 25;

        elements.UILabel(
            Rect(this.OFFS.x, this.OFFS.y + 80, listSize, 20),
            "Distribution", this.__manager, this.__runAllPanel
        );
        this.__runAllDistributions = elements.UISelectionList(
            Rect(this.OFFS.x, this.OFFS.y + 100, listSize, this.__sv.graphics.resolution.y - this.OFFS.y * 2 - 180),
            [dist.name for dist in this.__sv.distributions],
            this.__manager, container = this.__runAllPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x + listOffs, this.OFFS.y + 80, listSize, 20),
            "Shuffle", this.__manager, this.__runAllPanel
        );
        this.__runAllShuffles = elements.UISelectionList(
            Rect(this.OFFS.x + listOffs, this.OFFS.y + 100, listSize, this.__sv.graphics.resolution.y - this.OFFS.y * 2 - 180),
            [shuf.name for shuf in this.__sv.shuffles],
            this.__manager, container = this.__runAllPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x + listOffs * 2, this.OFFS.y + 80, listSize, 20),
            "Visual", this.__manager, this.__runAllPanel
        );
        this.__runAllVisuals = elements.UISelectionList(
           Rect(this.OFFS.x + listOffs * 2, this.OFFS.y + 100, listSize, this.__sv.graphics.resolution.y - this.OFFS.y * 2 - 180),
            [vis.name for vis in this.__sv.visuals],
            this.__manager, container = this.__runAllPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x + listOffs, this.OFFS.y, listSize, 20),
            "Run all sorts", this.__manager, this.__runAllPanel
        );

        this.__runAllButton = elements.UIButton(
            Rect(this.OFFS.x + listOffs, this.__sv.graphics.resolution.y - this.OFFS.y * 2 - 60, listSize, 40),
            "Run", this.__manager, this.__runAllPanel,
            tool_tip_text = "Runs all sorts with the given settings"
        );
    }

    new method runAll() {
        this.__runAllPanel.show();

        new function __internal(event) {
            if event.ui_element == this.__runAllButton {
                new dynamic speed     = this.__runAllSpeed.get_text(),
                            sizeMlt   = this.__runAllSizeMlt.get_text(),
                            uniqueDiv = this.__runAllUniqueDiv.get_text();

                if checkType(speed, float) {
                    float <- speed;
                } else {
                    this.userWarn("Error", "Invalid speed value. Please retry.");
                    return;
                }

                if checkType(sizeMlt, float) {
                    float <- sizeMlt;
                } else {
                    this.userWarn("Error", "Invalid size multiplier value. Please retry.");
                    return;
                }

                if checkType(uniqueDiv, float) {
                    float <- uniqueDiv;

                    if uniqueDiv < 1 {
                        this.userWarn("Error", "Minimum unique divisor is 1.");
                        return;
                    }
                } else {
                    this.userWarn("Error", "Invalid unique divisor value. Please retry.");
                    return;
                }

                new dynamic dist, shuf, vis;

                dist = this.__runAllDistributions.get_single_selection();
                if dist {
                    dist = this.__distributions.index(dist);
                } else {
                    this.userWarn("Error", "Select a distribution first");
                    return;
                }

                shuf = this.__runAllShuffles.get_single_selection();
                if shuf {
                    shuf = this.__shuffles.index(shuf);
                } else {
                    this.userWarn("Error", "Select a shuffle first");
                    return;
                }

                vis = this.__runAllVisuals.get_single_selection();
                if vis {
                    vis = this.__visuals.index(vis);
                } else {
                    this.userWarn("Error", "Select a visual style first");
                    return;
                }

                return {
                    "speed"       : speed,
                    "size-mlt"    : sizeMlt,
                    "unique-div"  : uniqueDiv,
                    "distribution": dist,
                    "shuffle"     : shuf,
                    "visual"      : vis
                };
            }
        }

        new dict result = this.__loop(__internal);
        this.__runAllPanel.hide();
        return result;
    }

    new method settings() {
        new dynamic showTextSettingValue     = this.__sv.settings["show-text"],
                    renderSettingValue       = this.__sv.settings["render"],
                    internalInfoSettingValue = this.__sv.settings["internal-info"],
                    showAuxSettingValue      = this.__sv.settings["show-aux"],
                    lazyAuxSettingValue      = this.__sv.settings["lazy-aux"],
                    lazyRenderSettingValue   = this.__sv.settings["lazy-render"],
                    profileSettingValue      = this.__sv.settings["profile"],
                    soundSettingValue        = this.__sv.settings["sound"];

        new dynamic settingsPanel = elements.UIPanel(
            Rect(
                this.__sv.graphics.resolution.x // 2 - this.SETTINGS_WIN_SIZE.x // 2,
                this.__sv.graphics.resolution.y // 2 - this.SETTINGS_WIN_SIZE.y // 2,
                this.SETTINGS_WIN_SIZE.x, this.SETTINGS_WIN_SIZE.y
            ), manager = this.__manager
        );

        elements.UILabel(
            Rect(this.SETTINGS_WIN_SIZE.x // 2 - 50, this.OFFS.y + 10, 100, 20),
            "Settings", this.__manager, settingsPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x, this.OFFS.y + 40, 250, 20),
            "Show text", this.__manager, settingsPanel
        );
        new dynamic showTextSetting = elements.ui_drop_down_menu.UIDropDownMenu(
            ["True", "False"], str(showTextSettingValue),
            Rect(this.SETTINGS_WIN_SIZE.x - this.OFFS.x - 100, this.OFFS.y + 40, 100, 20),
            this.__manager, settingsPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x, this.OFFS.y + 70, 250, 20),
            "Show auxiliary array", this.__manager, settingsPanel
        );
        new dynamic showAuxSetting = elements.ui_drop_down_menu.UIDropDownMenu(
            ["True", "False"], str(showAuxSettingValue),
            Rect(this.SETTINGS_WIN_SIZE.x - this.OFFS.x - 100, this.OFFS.y + 70, 100, 20),
            this.__manager, settingsPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x, this.OFFS.y + 100, 250, 20),
            "Show internal information", this.__manager, settingsPanel
        );
        new dynamic internalInfoSetting = elements.ui_drop_down_menu.UIDropDownMenu(
            ["True", "False"], str(internalInfoSettingValue),
            Rect(this.SETTINGS_WIN_SIZE.x - this.OFFS.x - 100, this.OFFS.y + 100, 100, 20),
            this.__manager, settingsPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x, this.OFFS.y + 130, 250, 20),
            "Render mode", this.__manager, settingsPanel
        );
        new dynamic renderSetting = elements.ui_drop_down_menu.UIDropDownMenu(
            ["True", "False"], str(renderSettingValue),
            Rect(this.SETTINGS_WIN_SIZE.x - this.OFFS.x - 100, this.OFFS.y + 130, 100, 20),
            this.__manager, settingsPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x, this.OFFS.y + 160, 250, 20),
            "Lazy auxiliary visualization", this.__manager, settingsPanel
        );
        new dynamic lazyAuxSetting = elements.ui_drop_down_menu.UIDropDownMenu(
            ["True", "False"], str(lazyAuxSettingValue),
            Rect(this.SETTINGS_WIN_SIZE.x - this.OFFS.x - 100, this.OFFS.y + 160, 100, 20),
            this.__manager, settingsPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x, this.OFFS.y + 190, 250, 20),
            "Lazy rendering", this.__manager, settingsPanel
        );
        new dynamic lazyRenderSetting = elements.ui_drop_down_menu.UIDropDownMenu(
            ["True", "False"], str(lazyRenderSettingValue),
            Rect(this.SETTINGS_WIN_SIZE.x - this.OFFS.x - 100, this.OFFS.y + 190, 100, 20),
            this.__manager, settingsPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x, this.OFFS.y + 220, 250, 20),
            "Window resolution", this.__manager, settingsPanel
        );
        new dynamic resolutionXSetting = elements.UITextEntryLine(
            Rect(this.SETTINGS_WIN_SIZE.x - this.OFFS.x - 220, this.OFFS.y + 220, 100, 20),
            this.__manager, settingsPanel, initial_text = str(this.__sv.graphics.resolution.x)
        );
        elements.UILabel(
            Rect(this.SETTINGS_WIN_SIZE.x - this.OFFS.x - 120, this.OFFS.y + 220, 20, 20),
            "x", this.__manager, settingsPanel
        );
        new dynamic resolutionYSetting = elements.UITextEntryLine(
            Rect(this.SETTINGS_WIN_SIZE.x - this.OFFS.x - 100, this.OFFS.y + 220, 100, 20),
            this.__manager, settingsPanel, initial_text = str(this.__sv.graphics.resolution.y)
        );

        elements.UILabel(
            Rect(this.OFFS.x, this.OFFS.y + 250, 250, 20),
            "Render bitrate (kbps)", this.__manager, settingsPanel
        );
        new dynamic bitrateSetting = elements.UITextEntryLine(
            Rect(this.SETTINGS_WIN_SIZE.x - this.OFFS.x - 100, this.OFFS.y + 250, 100, 20),
            this.__manager, settingsPanel, initial_text = str(this.__sv.settings["bitrate"])
        );

        elements.UILabel(
            Rect(this.OFFS.x, this.OFFS.y + 280, 250, 20),
            "Render profile", this.__manager, settingsPanel
        );
        new dynamic profileSetting = elements.ui_drop_down_menu.UIDropDownMenu(
            [os.path.splitext(os.path.basename(x))[0] for x in os.listdir(SortingVisualizer.PROFILES)], str(profileSettingValue),
            Rect(this.SETTINGS_WIN_SIZE.x - this.OFFS.x - 200, this.OFFS.y + 280, 200, 20),
            this.__manager, settingsPanel
        );

        elements.UILabel(
            Rect(this.OFFS.x, this.SETTINGS_WIN_SIZE.y - 150, 250, 20),
            "Sounds", this.__manager, settingsPanel
        );
        new dynamic soundSetting = elements.ui_drop_down_menu.UIDropDownMenu(
            [x.name for x in this.__sv.sounds], str(soundSettingValue),
            Rect(this.SETTINGS_WIN_SIZE.x - this.OFFS.x - 250, this.SETTINGS_WIN_SIZE.y - 150, 250, 20),
            this.__manager, settingsPanel
        );

        new dynamic soundRefreshButton = elements.UIButton(
            Rect(this.OFFS.x, this.SETTINGS_WIN_SIZE.y - 120, 250, 30),
            "Refresh sound config", this.__manager, settingsPanel,
            tool_tip_text = "Performs the sound initialization process. Used to change sound specific settings"
        );

        new dynamic resetConf = elements.UIButton(
            Rect(this.SETTINGS_WIN_SIZE.x - this.OFFS.x - 250, this.SETTINGS_WIN_SIZE.y - 120, 250, 30),
            "Reset configuration", this.__manager, settingsPanel,
            tool_tip_text = "Resets the selected configuration file"
        );

        new dynamic settingsBackButton = elements.UIButton(
            Rect(20, this.SETTINGS_WIN_SIZE.y - 60, 100, 40),
            "Back", this.__manager, settingsPanel,
            tool_tip_text = "Goes back to the main menu without saving"
        );

        new dynamic settingsSaveButton = elements.UIButton(
            Rect(this.SETTINGS_WIN_SIZE.x - 130, this.SETTINGS_WIN_SIZE.y - 60, 100, 40),
            "Save", this.__manager, settingsPanel,
            tool_tip_text = "Saves given settings"
        );

        new function __internal(event) {
            external showTextSettingValue, showAuxSettingValue,
                     internalInfoSettingValue, renderSettingValue,
                     lazyAuxSettingValue, lazyRenderSettingValue,
                     soundSettingValue, profileSettingValue;

            if event.type == pygame_gui.UI_DROP_DOWN_MENU_CHANGED {
                new bool val = event.text == "True";

                match:() event.ui_element {
                    case showTextSetting {
                        showTextSettingValue = val;
                    }
                    case showAuxSetting {
                        showAuxSettingValue = val;
                    }
                    case internalInfoSetting {
                        internalInfoSettingValue = val;
                    }
                    case renderSetting {
                        renderSettingValue = val;
                    }
                    case lazyAuxSetting {
                        lazyAuxSettingValue = val;
                    }
                    case lazyRenderSetting {
                        lazyRenderSettingValue = val;
                    }
                    case profileSetting {
                        profileSettingValue = event.text;
                    }
                    case soundSetting {
                        soundSettingValue = event.text;
                    }
                }
            } elif event.type == pygame_gui.UI_BUTTON_PRESSED {
                match:() event.ui_element {
                    case settingsBackButton {
                        return 1;
                    }
                    case soundRefreshButton {
                        this.__sv._refreshSoundConf();
                        this.userWarn("Success", "Sound configuration was reset");
                    }
                    case resetConf {
                        this.userWarn("Settings", "Select configuration to reset");
                        new dynamic file = this.fileDialog({"json"}, SortingVisualizer.CONFIG),
                                    name = os.path.basename(file);

                        if name == "SortingVisualizer.json" {
                            this.userWarn("Error", "Cannot delete SortingVisualizer configuration.");
                            return;
                        }

                        if (
                            this.selection(
                                "Settings",
                                f'Are you sure you want to delete "{name}"?',
                                ["Yes", "No"]
                            ) == 0
                        ) {
                            try {
                                os.remove(file);
                            } catch Exception as e {
                                this.userWarn("Error", f"Unable to delete configuration. Exception:\n{formatException(e)}");
                            } success {
                                this.userWarn("Success", "Configuration deleted");
                            }
                        }
                    }
                    case settingsSaveButton {
                        new dynamic oldSound   = this.__sv.settings["sound"],
                                    oldProfile = this.__sv.settings["profile"],
                                    resX       = resolutionXSetting.get_text(),
                                    resY       = resolutionYSetting.get_text(),
                                    bitrate    = bitrateSetting.get_text();

                        if checkType(resX, int) {
                            int <- resX;

                            if resX < 1080 {
                                this.userWarn("Error", "Minimum X resolution is 1080.");
                                return;
                            }
                        } else {
                            this.userWarn("Error", "Invalid X resolution.");
                            return;
                        }

                        if checkType(resY, int) {
                            int <- resY;

                            if resY < 640 {
                                this.userWarn("Error", "Minimum Y resolution is 640.");
                                return;
                            }
                        } else {
                            this.userWarn("Error", "Invalid Y resolution.");
                            return;
                        }

                        if checkType(bitrate, int) {
                            int <- bitrate;
                        } else {
                            this.userWarn("Error", "Invalid bitrate.");
                            return;
                        }

                        this.__sv.settings = {
                            "show-text":     showTextSettingValue,
                            "show-aux":      showAuxSettingValue,
                            "internal-info": internalInfoSettingValue,
                            "render":        renderSettingValue,
                            "lazy-aux":      lazyAuxSettingValue,
                            "lazy-render":   lazyRenderSettingValue,
                            "bitrate":       bitrate,
                            "profile":       profileSettingValue,
                            "sound":         soundSettingValue,
                            "resolution":    [resX, resY]
                        };

                        try {
                            this.__sv._writeSettings();

                            if oldProfile != profileSettingValue {
                                this.__sv._loadProfile();
                            }

                            if oldSound != soundSettingValue {
                                this.__sv._setSound(name = soundSettingValue);
                            }
                        } catch Exception as e {
                            this.userWarn("Error", f"An error occurred while saving your settings:\n{formatException(e)}");
                            return;
                        } success {
                            this.userWarn("Success", "Settings saved successfully.");
                            return 1;
                        }
                    }
                }
            }
        }

        this.__loop(__internal);
        settingsPanel.kill();
    }

    new method renderScreen(process, message) {
        new dynamic panel = elements.UIPanel(
            Rect(
                this.__sv.graphics.resolution.x // 2 - this.SMALL_WIN_SIZE.x // 2,
                this.__sv.graphics.resolution.y // 2 - this.SMALL_WIN_SIZE.y // 2,
                this.SMALL_WIN_SIZE.x, this.SMALL_WIN_SIZE.y
            ), manager = this.__manager
        );

        elements.UILabel(
            Rect(0, this.SMALL_WIN_SIZE.y // 2 - 15, this.SMALL_WIN_SIZE.x, 20),
            message, this.__manager, panel
        ).set_text_scale(2);

        new function __internal() {
            if process.poll() is not None {
                return True;
            }
        }

        this.__loop(lambda _: None, __internal);
        panel.kill();
        this.__sv.graphics.blitSurf(this.__background, Vector());

        if process.returncode != 0 {
            throw VisualizerException("ffmpeg exited with a non-zero return code");
        }
    }

    new method fileDialog(allowed = None, initPath = None) {
        if allowed is None {
            allowed = {""};
        }

        new dynamic win = windows.ui_file_dialog.UIFileDialog(
            Rect(
                this.__sv.graphics.resolution.x // 2 - this.WIN_SIZE.x // 2,
                this.__sv.graphics.resolution.y // 2 - this.WIN_SIZE.y // 2,
                this.WIN_SIZE.x, this.WIN_SIZE.y
            ), this.__manager, "Select file",
            allowed, initPath
        );
        win.set_blocking(True);
        win.on_close_window_button_pressed = lambda *a: None;
        win.set_position((this.__sv.graphics.resolution // 2 - this.WIN_SIZE // 2).toList(2));

        new function __internal(event) {
            if event.type == pygame_gui.UI_FILE_DIALOG_PATH_PICKED {
                return event.text;
            }
        }

        new dynamic tmp = this.__loop(__internal);
        win.kill();
        return tmp;
    }
}