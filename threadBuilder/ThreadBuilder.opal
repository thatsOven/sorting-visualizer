this.shuffles.pop();

new tuple msg, modes;
msg   = ("add", "insert", "replace");
modes = ("SORT", "SHUFFLE", "DISTRIBUTION", "VISUAL", "SPEED", "AUTOVALUE", "SPEED_RESET", "AUTOVALUE_RESET");

new list commands = [];
new dict macros   = {};

while True {
    new int sel = this.__gui.selection("Thread builder", "Select action: ", [
        "Add",
        "Insert",
        "Replace",
        "Remove",
        "View",
        "Create macro",
        "Finish"
    ]);

    match sel {
        case 3 {
            sel = this.__gui.selection("Thread builder", "Select command to remove:", [str(com) for com in commands]);

            commands.pop(sel);

            this.__gui.userWarn("Success", "The command has been removed");
            continue; 
        }
        case 4 {
            this.__gui.selection("Thread builder", "Commands list:", [str(com) for com in commands]);
            continue;
        }
        case 5 {
            do name in macros {
                new str name = this.__gui.userInputDialog("Macro builder", "Enter a name for this macro:", str, "");

                if name in macros {
                    new int yn = this.__gui.selection("Macro builder - Warning", "This macro already exists. Overwrite it?", ["Yes", "No"]);

                    if yn == 0 {
                        break;
                    }
                }
            }

            macros[name] = [];

            while True {
                sel = this.__gui.selection("Macro builder", "Select action: ", [
                    "Add",
                    "Insert",
                    "Replace",
                    "Remove",
                    "View",
                    "Finish"
                ]);

                match sel {
                    case 3 {
                        sel = this.__gui.selection("Macro builder", "Select command to remove:", [str(com) for com in macros[name]]);

                        macros[name].pop(sel);

                        this.__gui.userWarn("Success", "The command has been removed");
                        continue; 
                    }
                    case 4 {
                        this.__gui.selection("Macro builder", "Commands list:", [str(com) for com in macros[name]]);
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
                this.__gui.userWarn("Error", "No command has been added. Please add a command and retry");
                continue;
            }

            sel = this.__gui.selection("Thread builder", "Select thread type:", [
                "Sorting thread",
                "Shuffle"
            ]);

            new ThreadCommand labelCommand;
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
                new str name = this.__gui.userInputDialog("Thread builder", "Enter a name for this thread:", str, ""), 
                        fileName;
            
                if len(name.strip().replace(" ", "")) == 0 {
                    this.__gui.userWarn("Error", "Please insert a name for your file");
                    continue;
                }

                fileName = os.path.join(HOME_DIR, "threads", name + ".py");

                if os.path.isfile(fileName) {
                    new int yn = this.__gui.selection("Thread builder - Warning", "This file already exists. Overwrite it?", ["Yes", "No"]);

                    if yn == 0 {
                        os.remove(fileName);
                        break;
                    }
                } else {
                    break;
                }
            }
            this.__compileCommandList(commands, fileName);
            this.__gui.userWarn("Success", "The thread has been saved");
            break;
        }
    }

    this.__builderEvaluator("Thread", msg, sel, commands, macros, modes);
}
