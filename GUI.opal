new class GUI {
    new Vector OFFS      = RESOLUTION // 80,
               WIN_SIZE  = RESOLUTION // 2,
               TEXT_OFFS = Vector(2, 2);
    new int FPS = 60;

    new method __init__() {
        this.__manager = UIManager(RESOLUTION.toList(2));
        this.__clock   = Clock();
        this.__sv      = None;

        this.__oldCat = None;
    }

    new method setSv(sv) {
        this.__sv = sv;

        this.__buildSV();
        this.__buildRunAll();
        this.__buildSortSel();

        this.__sv.graphics.simpleText(f"thatsOven's Sorting Visualizer v{VERSION}", GUI.TEXT_OFFS);
    }

    new method __loop(fn, fn0 = lambda *a: None) {
        this.__background = this.__sv.graphics.screen.copy();

        while True {
            new dynamic delta = this.__clock.tick(GUI.FPS) / 1000.0;

            for event in this.__sv.graphics.getEvents() {
                if event.type in this.__sv.graphics.eventActions {
                    this.__sv.graphics.eventActions[event.type](event);
                }

                if event.type == pygame_gui.UI_BUTTON_PRESSED {
                    new dynamic res = fn(event);
                    if res is not None {
                        return res;
                    }
                }

                this.__manager.process_events(event);
            }

            fn0();

            this.__manager.update(delta);

            this.__sv.graphics.blitSurf(this.__background, Vector());
            this.__manager.draw_ui(this.__sv.graphics.screen);

            this.__sv.graphics.rawUpdate();
        }
    }

    new method __genericDialog(who, message, type_, default, textInput) {
        new dynamic win = elements.UIWindow(
            Rect(
                RESOLUTION.x - GUI.WIN_SIZE.x // 2, 
                RESOLUTION.y - GUI.WIN_SIZE.y // 2, 
                GUI.WIN_SIZE.x, GUI.WIN_SIZE.y
            ),
            this.__manager, window_display_title = who
        );
        win.set_blocking(True);
        win.on_close_window_button_pressed = lambda *a: None;
        win.set_position((RESOLUTION // 2 - GUI.WIN_SIZE // 2).toList(2));

        elements.UITextBox(
            message, Rect(
                GUI.TEXT_OFFS.x, GUI.TEXT_OFFS.y, 
                GUI.WIN_SIZE.x - GUI.TEXT_OFFS.x, 
                80
            ),
            this.__manager, container = win
        );

        new dynamic entry;
        if textInput {
            entry = elements.UITextEntryLine(
                Rect(
                    GUI.TEXT_OFFS.x, GUI.TEXT_OFFS.y + 80, 
                    GUI.WIN_SIZE.x - GUI.TEXT_OFFS.x, 
                    20
                ),
                this.__manager, container = win,
                initial_text = default,
            );
        } else {
            entry = None;
        }

        new dynamic button = elements.UIButton(
            Rect(
                GUI.WIN_SIZE.x // 2 - 60, 
                GUI.WIN_SIZE.y - 100 - GUI.TEXT_OFFS.y, 
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
                RESOLUTION.x - GUI.WIN_SIZE.x // 2, 
                RESOLUTION.y - GUI.WIN_SIZE.y // 2, 
                GUI.WIN_SIZE.x, GUI.WIN_SIZE.y
            ),
            this.__manager, window_display_title = who
        );
        win.set_blocking(True);
        win.on_close_window_button_pressed = lambda *a: None;
        win.set_position((RESOLUTION // 2 - GUI.WIN_SIZE // 2).toList(2));

        elements.UITextBox(
            message, Rect(
                GUI.TEXT_OFFS.x, GUI.TEXT_OFFS.y, 
                GUI.WIN_SIZE.x - GUI.TEXT_OFFS.x - 40, 
                80
            ),
            this.__manager, container = win
        );

        new dynamic lst = elements.UISelectionList(
            Rect(
                GUI.TEXT_OFFS.x, GUI.TEXT_OFFS.y + 80, 
                GUI.WIN_SIZE.x - GUI.TEXT_OFFS.x - 40, 
                GUI.WIN_SIZE.y - GUI.TEXT_OFFS.y - 200
            ),
            content, this.__manager, 
            container = win
        );

        new dynamic button = elements.UIButton(
            Rect(
                GUI.WIN_SIZE.x // 2 - 60, 
                GUI.WIN_SIZE.y - 100 - GUI.TEXT_OFFS.y, 
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
                GUI.OFFS.x, GUI.OFFS.y, RESOLUTION.x - GUI.OFFS.x * 2, RESOLUTION.y - GUI.OFFS.y * 2
            ), manager = this.__manager
        );
        this.__sortSelPanel.hide();

        new int listOffs = (RESOLUTION.x - GUI.OFFS.x) // 2,
                listSize = listOffs - (RESOLUTION.x - GUI.OFFS.x) // 25;

        elements.UILabel(
            Rect(GUI.OFFS.x, GUI.OFFS.y + 80, listSize, 20), 
            "Category", this.__manager, this.__sortSelPanel
        );
        this.__chosenCat  = this.__sv.categories[0];
        this.__sortSelCategories = elements.UISelectionList(
            Rect(GUI.OFFS.x, GUI.OFFS.y + 100, listSize, RESOLUTION.y - GUI.OFFS.y * 2 - 180),
            this.__sv.categories, this.__manager, 
            container = this.__sortSelPanel
        );

        elements.UILabel(
            Rect(GUI.OFFS.x + listOffs, GUI.OFFS.y + 80, listSize, 20), 
            "Sort", this.__manager, this.__sortSelPanel
        );
        this.__sorts = [sort.listName for sort in this.__sv.sorts[this.__chosenCat]];
        this.__sortSelSorts = elements.UISelectionList(
            Rect(GUI.OFFS.x + listOffs, GUI.OFFS.y + 100, listSize, RESOLUTION.y - GUI.OFFS.y * 2 - 180),
            this.__sorts, this.__manager, container = this.__sortSelPanel
        );

        elements.UILabel(
            Rect(GUI.OFFS.x + listOffs, GUI.OFFS.y, listSize, 20),
            "Select sort", this.__manager, this.__sortSelPanel
        );

        this.__sortSelButton = elements.UIButton(
            Rect(GUI.OFFS.x + listOffs, RESOLUTION.y - GUI.OFFS.y * 2 - 60, listSize, 40),
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
                GUI.OFFS.x, GUI.OFFS.y, RESOLUTION.x - GUI.OFFS.x * 2, RESOLUTION.y - GUI.OFFS.y * 2
            ), manager = this.__manager
        );
        this.__svPanel.hide();

        elements.UILabel(
            Rect(GUI.OFFS.x, GUI.OFFS.y + 20, 100, 20), 
            "Array length", this.__manager, this.__svPanel
        );
        this.__svArrayLength = elements.UITextEntryLine(
            Rect(GUI.OFFS.x, GUI.OFFS.y + 40, 100, 20), 
            this.__manager, this.__svPanel, 
            initial_text = '1024'
        );

        elements.UILabel(
            Rect(RESOLUTION.x - GUI.OFFS.x * 2 - 120, GUI.OFFS.y + 20, 100, 20), 
            "Speed", this.__manager, this.__svPanel
        );
        this.__svSpeed = elements.UITextEntryLine(
            Rect(RESOLUTION.x - GUI.OFFS.x * 2 - 120, GUI.OFFS.y + 40, 100, 20), 
            this.__manager, this.__svPanel, 
            initial_text = '1'
        );

        new int listOffs = (RESOLUTION.x - GUI.OFFS.x) // 5,
                listSize = listOffs - (RESOLUTION.x - GUI.OFFS.x) // 25;

        elements.UILabel(
            Rect(GUI.OFFS.x, GUI.OFFS.y + 80, listSize, 20), 
            "Distribution", this.__manager, this.__svPanel
        );
        this.__distributions = [dist.name for dist in this.__sv.distributions];
        this.__svDistributions = elements.UISelectionList(
            Rect(GUI.OFFS.x, GUI.OFFS.y + 100, listSize, RESOLUTION.y - GUI.OFFS.y * 2 - 180),
            this.__distributions, this.__manager, container = this.__svPanel
        );

        elements.UILabel(
            Rect(GUI.OFFS.x + listOffs, GUI.OFFS.y + 80, listSize, 20), 
            "Shuffle", this.__manager, this.__svPanel
        );
        this.__shuffles = [shuf.name for shuf in this.__sv.shuffles];
        this.__svShuffles = elements.UISelectionList(
            Rect(GUI.OFFS.x + listOffs, GUI.OFFS.y + 100, listSize, RESOLUTION.y - GUI.OFFS.y * 2 - 180),
            this.__shuffles, this.__manager, container = this.__svPanel
        );

        elements.UILabel(
            Rect(GUI.OFFS.x + listOffs * 2, GUI.OFFS.y + 80, listSize, 20), 
            "Category", this.__manager, this.__svPanel
        );
        this.__svCategories = elements.UISelectionList(
            Rect(GUI.OFFS.x + listOffs * 2, GUI.OFFS.y + 100, listSize, RESOLUTION.y - GUI.OFFS.y * 2 - 180),
            this.__sv.categories, this.__manager, 
            container = this.__svPanel
        );

        elements.UILabel(
            Rect(GUI.OFFS.x + listOffs * 3, GUI.OFFS.y + 80, listSize, 20), 
            "Sort", this.__manager, this.__svPanel
        );
        this.__sorts = [sort.listName for sort in this.__sv.sorts[this.__sv.categories[0]]];
        this.__svSorts = elements.UISelectionList(
            Rect(GUI.OFFS.x + listOffs * 3, GUI.OFFS.y + 100, listSize, RESOLUTION.y - GUI.OFFS.y * 2 - 180),
            this.__sorts, this.__manager, container = this.__svPanel
        );

        elements.UILabel(
            Rect(GUI.OFFS.x + listOffs * 4, GUI.OFFS.y + 80, listSize, 20), 
            "Visual", this.__manager, this.__svPanel
        );
        this.__visuals = [vis.name for vis in this.__sv.visuals];
        this.__svVisuals = elements.UISelectionList(
            Rect(GUI.OFFS.x + listOffs * 4, GUI.OFFS.y + 100, listSize, RESOLUTION.y - GUI.OFFS.y * 2 - 180),
            this.__visuals, this.__manager, container = this.__svPanel
        );

        elements.UILabel(
            Rect(GUI.OFFS.x + listOffs * 2, GUI.OFFS.y, listSize, 20),
            "Run Sort", this.__manager, this.__svPanel
        );

        this.__svRunButton = elements.UIButton(
            Rect(GUI.OFFS.x + listOffs * 2, RESOLUTION.y - GUI.OFFS.y * 2 - 60, listSize, 40),            
            "Run", this.__manager, this.__svPanel, 
            tool_tip_text = "Runs the selected sort with the given settings"
        );
    }

    new method runSort() {
        this.__svPanel.show();

        new function __internal(event) {
            if event.ui_element == this.__svRunButton {
                new dynamic size, speed;
                size  = this.__svArrayLength.get_text();
                speed = this.__svSpeed.get_text();

                if checkType(size, int) {
                    int <- size;
                } else {
                    this.userWarn("Error", "Invalid array size. Please retry.");
                    return;
                }

                if checkType(speed, float) {
                    float <- speed;
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
                    "speed"       : speed,
                    "distribution": dist,
                    "shuffle"     : shuf,
                    "category"    : cat,
                    "sort"        : sort,
                    "visual"      : vis
                };
            }
        }

        new dict result = this.__loop(__internal, this.__updateSortCat(this.__svCategories, this.__svSorts));
        this.__svPanel.hide();
        return result;
    }

    new method __buildRunAll() {
        this.__runAllPanel = elements.UIPanel(
            Rect(
                GUI.OFFS.x, GUI.OFFS.y, RESOLUTION.x - GUI.OFFS.x * 2, RESOLUTION.y - GUI.OFFS.y * 2
            ), manager = this.__manager
        );
        this.__runAllPanel.hide();

        elements.UILabel(
            Rect(GUI.OFFS.x, GUI.OFFS.y + 20, 100, 20), 
            "Speed", this.__manager, this.__runAllPanel
        );
        this.__runAllSpeed = elements.UITextEntryLine(
            Rect(GUI.OFFS.x, GUI.OFFS.y + 40, 100, 20), 
            this.__manager, this.__runAllPanel, 
            initial_text = '1'
        );

        new int listOffs = (RESOLUTION.x - GUI.OFFS.x) // 3,
                listSize = listOffs - (RESOLUTION.x - GUI.OFFS.x) // 25;

        elements.UILabel(
            Rect(GUI.OFFS.x, GUI.OFFS.y + 80, listSize, 20), 
            "Distribution", this.__manager, this.__runAllPanel
        );
        this.__runAllDistributions = elements.UISelectionList(
            Rect(GUI.OFFS.x, GUI.OFFS.y + 100, listSize, RESOLUTION.y - GUI.OFFS.y * 2 - 180),
            [dist.name for dist in this.__sv.distributions],
            this.__manager, container = this.__runAllPanel
        );

        elements.UILabel(
            Rect(GUI.OFFS.x + listOffs, GUI.OFFS.y + 80, listSize, 20), 
            "Shuffle", this.__manager, this.__runAllPanel
        );
        this.__runAllShuffles = elements.UISelectionList(
            Rect(GUI.OFFS.x + listOffs, GUI.OFFS.y + 100, listSize, RESOLUTION.y - GUI.OFFS.y * 2 - 180),
            [shuf.name for shuf in this.__sv.shuffles],
            this.__manager, container = this.__runAllPanel
        );

        elements.UILabel(
            Rect(GUI.OFFS.x + listOffs * 2, GUI.OFFS.y + 80, listSize, 20), 
            "Visual", this.__manager, this.__runAllPanel
        );
        this.__runAllVisuals = elements.UISelectionList(
           Rect(GUI.OFFS.x + listOffs * 2, GUI.OFFS.y + 100, listSize, RESOLUTION.y - GUI.OFFS.y * 2 - 180),
            [vis.name for vis in this.__sv.visuals],
            this.__manager, container = this.__runAllPanel
        );

        elements.UILabel(
            Rect(GUI.OFFS.x + listOffs, GUI.OFFS.y, listSize, 20),
            "Run all sorts", this.__manager, this.__runAllPanel
        );

        this.__runAllButton = elements.UIButton(
            Rect(GUI.OFFS.x + listOffs, RESOLUTION.y - GUI.OFFS.y * 2 - 60, listSize, 40),
            "Run", this.__manager, this.__runAllPanel, 
            tool_tip_text = "Runs all sorts with the given settings"
        );
    }

    new method runAll() {
        this.__runAllPanel.show();

        new function __internal(event) {
            if event.ui_element == this.__runAllButton {
                new dynamic speed = this.__runAllSpeed.get_text();

                if checkType(speed, float) {
                    float <- speed;
                } else {
                    this.userWarn("Error", "Invalid speed value. Please retry.");
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
}