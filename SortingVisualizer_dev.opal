# this file generates a pycompiled version of the visualizer
# inside the release version for external module development purposes.
# when this file is not compiled in release mode, or ran directly,
# it operates exactly like SortingVisualizer.opal

$args ["--require", "2024.8.4"]

$comptime
    if RELEASE_MODE {
        new dynamic opalDir = OPAL_DIR,
                    homeDir = HOME_DIR;

        new dynamic compiler = Compiler();
        compiler.preConsts["RELEASE_MODE"] = "False";
        compiler.preConsts["OPAL_DIR"] = f"r'{opalDir}'";
        compiler.preConsts["HOME_DIR"] = f"r'{homeDir}'";
        compiler.initMain();

        compiler.compileToPY(
            os.path.join(HOME_DIR, "SortingVisualizer.opal"),
            os.path.join(HOME_DIR, "SortingVisualizer.py"),
            'package pathlib:import Path;new dynamic HOME_DIR=str(Path(__file__).parent.absolute());del Path;'
        );
    }
$end

$include os.path.join(HOME_DIR, "SortingVisualizer.opal")