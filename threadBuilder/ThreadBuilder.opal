this.shuffles.pop();

new tuple msg, modes;
msg   = ("add", "insert", "replace");
modes = ("SORT", "SHUFFLE", "DISTRIBUTION", "VISUAL", "SPEED", "AUTOVALUE", "SPEED_RESET", "AUTOVALUE_RESET");

new list commands = [];
new dict macros   = {};

while True {
    this.__tui.selection("Thread builder", "Select action: ", [
        "Add",
        "Insert",
        "Replace",
        "Remove",
        "View",
        "Create macro",
        "Finish"
    ]);
    new int sel = this.__tui.run();

    match sel {
        case 3 {
            this.__tui.selection("Thread builder", "Select command to remove:", [str(com) for com in commands]);
            sel = this.__tui.run();

            commands.pop(sel);

            UserWarn("Success", "The command has been removed", this.__tui.termSize).run();
            continue; 
        }
        case 4 {
            this.__tui.selection("Thread builder", "Commands list:", [str(com) for com in commands]);
            this.__tui.run();
            continue;
        }
        case 5 {
            do name in macros {
                this.__tui.userInputDialog("Macro builder", "Enter a name for this macro:", str, "");
                new str name = this.__tui.run();

                if name in macros {
                    this.__tui.selection("Macro builder - Warning", "This macro already exists. Overwrite it?", ["Yes", "No"]);
                    new int yn = this.__tui.run();

                    if yn == 0 {
                        break;
                    }
                }
            }

            macros[name] = [];

            while True {
                this.__tui.selection("Macro builder", "Select action: ", [
                    "Add",
                    "Insert",
                    "Replace",
                    "Remove",
                    "View",
                    "Finish"
                ]);
                sel = this.__tui.run();

                match sel {
                    case 3 {
                        this.__tui.selection("Macro builder", "Select command to remove:", [str(com) for com in macros[name]]);
                        sel = this.__tui.run();

                        macros[name].pop(sel);

                        UserWarn("Success", "The command has been removed", this.__tui.termSize).run();
                        continue; 
                    }
                    case 4 {
                        this.__tui.selection("Macro builder", "Commands list:", [str(com) for com in macros[name]]);
                        this.__tui.run();
                        continue;
                    }
                    case 5 {
                        break;
                    }
                }

                this.__builderEvaluator("Macro", msg, sel, macros[name], macros, modes);
            }
            continue;
        }
        case 6 {
            if len(commands) == 0 {
                UserWarn("Error", "No command has been added. Please add a command and retry", this.__tui.termSize).run();
                continue;
            }

            this.__tui.selection("Thread builder", "Select thread type:", [
                "Sorting thread",
                "Shuffle"
            ]);
            sel = this.__tui.run();

            new <ThreadCommand> labelCommand;
            match sel {
                case 0 {
                    labelCommand = ThreadCommand("DEFINE", "THREAD");
                }
                case 1 {
                    labelCommand = ThreadCommand("DEFINE", "SHUFFLE");
                }
            }
            commands.insert(0, labelCommand);

            while True {
                this.__tui.userInputDialog("Thread builder", "Enter a name for this thread:", str, "");
                new str name = this.__tui.run(), fileName;
            
                if len(name.strip().replace(" ", "")) == 0 {
                    UserWarn("Error", "Please insert a name for your file", this.__tui.termSize).run();
                    continue;
                }

                fileName = os.path.join("HOME_DIR", "threads", name + ".py");

                if os.path.isfile(fileName) {
                    this.__tui.selection("Thread builder - Warning", "This file already exists. Overwrite it?", ["Yes", "No"]);
                    new int yn = this.__tui.run();

                    if yn == 0 {
                        os.remove(fileName);
                        break;
                    }
                } else {
                    break;
                }
            }
            this.__compileCommandList(commands, fileName);
            UserWarn("Success", "The thread has been saved", this.__tui.termSize).run();
            break;
        }
    }

    this.__builderEvaluator("Thread", msg, sel, commands, macros, modes);
}
