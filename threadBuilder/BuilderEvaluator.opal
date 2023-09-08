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

    new int mode = this.__gui.selection(title + " builder", "Select the type of command you want to " + msg[sel] + ": ", opts);

    new ThreadCommand command;
    match mode {
        case 0 {
            new dict sortSel = this.__gui.sortSelection();

            command = ThreadCommand(modes[mode], sortSel["sort"], sortSel["category"]);
        }
        case 1 {
            new int shufSel = this.__gui.selection(title + " builder", "Select shuffle:", [shuf.name for shuf in this.shuffles]);

            command = ThreadCommand(modes[mode], shufSel);
        }
        case 2 {
            new int distSel = this.__gui.selection(title + " builder", "Select distribution:", [dist.name for dist in this.distributions]);
            new int length = this.__gui.userInputDialog(title + " builder", "Insert array length:", int, "1024", [str(2 ** i) for i in range(2, 15)]);
            new int unique = this.__gui.userInputDialog(title + " builder", "Insert unique amount:", int, "512", [str(2 ** i) for i in range(2, 15)]);

            command = ThreadCommand(modes[mode], distSel, length, unique);
        }
        case 3 {
            new int visSel = this.__gui.selection(title + " builder", "Select visual:", [vis.name for vis in this.visuals]);

            command = ThreadCommand(modes[mode], visSel);
        }
        case 4 {
            new int msel = this.__gui.selection(title + " builder", "Select type of speed change: ", [
                "Set",
                "Reset"
            ]);

            match msel {
                case 0 {
                    new float speed = this.__gui.userInputDialog(title + " builder", "Insert speed:", float, "1");

                    command = ThreadCommand(modes[mode], speed);
                }
                case 1 {
                    command = ThreadCommand(modes[mode + 3], None);
                }
            }
        }
        case 5 {
            new int msel = this.__gui.selection(title + " builder", "Select type of autovalue change: ", [
                "Push",
                "Pop",
                "Reset"
            ]);

            match msel {
                case 0 {
                    new int value = this.__gui.userInputDialog(title + " builder", "Insert value:", int, "");

                    command = ThreadCommand(modes[mode], value);
                }
                case 1 {
                    command = ThreadCommand(modes[mode + 1], None);
                }
                case 2 {
                    command = ThreadCommand(modes[mode + 3], None);
                }
            }
        }
        case 6 {
            new list macrosKeys = [key for key in macros];

            if len(macrosKeys) == 0 {
                this.__gui.userWarn("Error", "No macros have been defined");
                return;
            }
        
            new int msel = this.__gui.selection(title + " builder", "Select macro to call: ", macrosKeys);

            match sel {
                case 0 {
                    commands += macros[macrosKeys[msel]];
                }
                case 1 {
                    
                    new int idx = this.__gui.selection(title + " builder", "Select position to insert to:", [str(com) for com in commands]), 
                              p = len(commands);

                    commands += macros[macrosKeys[msel]];
                    Utils.Iterables.rotate(commands, idx, p, len(commands));
                }
                case 2 {
                    new int idx = this.__gui.selection(title + " builder", "Select command to replace:", [str(com) for com in commands]);

                    commands[idx:idx + 1] = macros[macrosKeys[msel]];
                }
            }

            this.__gui.userWarn("Success", "Changes applied");
            return;
        }
    }

    match sel {
        case 0 {
            commands.append(command);
        }
        case 1 {
            
            new int idx = this.__gui.selection(title + " builder", "Select position to insert to:", [str(com) for com in commands]);

            commands.insert(idx, command);
        }
        case 2 {
            new int idx = this.__gui.selection(title + " builder", "Select command to replace:", [str(com) for com in commands]);

            commands[idx] = command;
        }
    }

    this.__gui.userWarn("Success", "Changes applied");
}