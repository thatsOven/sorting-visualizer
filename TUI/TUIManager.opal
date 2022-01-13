try {
    import termios;
    package picotui.widgets: import *;
    package picotui.menu:    import *;
    package picotui.context: import Context;
} catch {
    $include os.path.join("HOME_DIR", "TUI", "fallbackTUI.opal")
} success {
    $include os.path.join("HOME_DIR", "TUI", "TUI.opal")
}