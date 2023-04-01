new method __builderEvaluator(title, msg, sel, commands, macros, modes) {
    new list opts;
    opts = [
        "Sort",
        "Shuffle",
        "Distribution",
        "Visual change",
        "Speed change",
        "Autovalue"
    ];
    
    if title == "Thread" {
        opts.append("Macro call");
    }

    this.__tui.selection(title + " builder", "Select the type of command you want to " + msg[sel] + ": ", opts);
    new int mode = this.__tui.run();

    new ThreadCommand command;
    match mode {
        case 0 {
            this.__tui.buildSortSelection();
            new dict sortSel = this.__tui.run();

            command = ThreadCommand(modes[mode], sortSel["sort"], '"' + this.categories[sortSel["category"]] + '"');
        }
        case 1 {
            this.__tui.selection(title + " builder", "Select shuffle:", [shuf.name for shuf in this.shuffles]);
            new int shufSel = this.__tui.run();

            command = ThreadCommand(modes[mode], shufSel);
        }
        case 2 {
            this.__tui.selection(title + " builder", "Select distribution:", [dist.name for dist in this.distributions]);
            new int distSel = this.__tui.run();

            this.__tui.userInputDialog(title + " builder", "Insert array length:", int, "1024", [str(2 ** i) for i in range(2, 15)]);
            new int length = this.__tui.run();

            command = ThreadCommand(modes[mode], distSel, length);
        }
        case 3 {
            this.__tui.selection(title + " builder", "Select visual:", [vis.name for vis in this.visuals]);
            new int visSel = this.__tui.run();

            command = ThreadCommand(modes[mode], visSel);
        }
        case 4 {
            this.__tui.selection(title + " builder", "Select type of speed change: ", [
                "Set",
                "Reset"
            ]);
            new int msel = this.__tui.run();

            match msel {
                case 0 {
                    this.__tui.userInputDialog(title + " builder", "Insert speed:", float, "1");
                    new float speed = this.__tui.run();

                    command = ThreadCommand(modes[mode], speed);
                }
                case 1 {
                    command = ThreadCommand(modes[mode + 2], None);
                }
            }
        }
        case 5 {
            this.__tui.selection(title + " builder", "Select type of autovalue change: ", [
                "Set",
                "Reset"
            ]);
            new int msel = this.__tui.run();

            match msel {
                case 0 {
                    this.__tui.userInputDialog(title + " builder", "Insert value:", int, "");
                    new int value = this.__tui.run();

                    command = ThreadCommand(modes[mode], value);
                }
                case 1 {
                    command = ThreadCommand(modes[mode + 2], None);
                }
            }
        }
        case 6 {
            new list macrosKeys = [key for key in macros];

            if len(macrosKeys) == 0 {
                UserWarn("Error", "No macros have been defined", this.__tui.termSize).run();
                return;
            }
            this.__tui.selection(title + " builder", "Select macro to call: ", macrosKeys);
            new int msel = this.__tui.run();

            match sel {
                case 0 {
                    commands += macros[macrosKeys[msel]];
                }
                case 1 {
                    this.__tui.selection(title + " builder", "Select position to insert to:", [str(com) for com in commands]);
                    new int idx = this.__tui.run(), p = len(commands);

                    commands += macros[macrosKeys[msel]];
                    Utils.Iterables.rotate(commands, idx, p, len(commands));
                }
                case 2 {
                    this.__tui.selection(title + " builder", "Select command to replace:", [str(com) for com in commands]);
                    new int idx = this.__tui.run();

                    commands[idx:idx + 1] = macros[macrosKeys[msel]];
                }
            }

            UserWarn("Success", "Changes applied", this.__tui.termSize).run();
            return;
        }
    }

    match sel {
        case 0 {
            commands.append(command);
        }
        case 1 {
            this.__tui.selection(title + " builder", "Select position to insert to:", [str(com) for com in commands]);
            new int idx = this.__tui.run();

            commands.insert(idx, command);
        }
        case 2 {
            this.__tui.selection(title + " builder", "Select command to replace:", [str(com) for com in commands]);
            new int idx = this.__tui.run();

            commands[idx] = command;
        }
    }

    UserWarn("Success", "Changes applied", this.__tui.termSize).run();
}