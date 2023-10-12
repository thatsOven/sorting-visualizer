new class _FakeMPNote {
    new method __init__(note) {
        this.degree = note;
    }
}

new class Soundfont: Sound {
    new method __init__() {
        super.__init__("Soundfont");
        this._soundFont  = None;
    }

    new method prepare() {
        sortingVisualizer.setCurrentlyRunning("Soundfont sound system");

        while True {
            new dynamic fileName = os.path.join(SortingVisualizer.SOUND_CONFIG, "Soundfont.json");
            if os.path.exists(fileName) {
                new dynamic config;

                try {
                    with open(fileName, "r") as f {
                        config = json.loads(f.read());
                    }
                } catch Exception as e {
                    sortingVisualizer.userWarn(f"Unable to load soundfont configuration. Exception:\n{formatException(e)}");
                    return;
                }

                try {
                    this._soundFont = sf2_loader(config["file"]);
                } catch Exception as e {
                    sortingVisualizer.userWarn(f"Unable to load soundfont. Exception:\n{formatException(e)}");
                    return;
                }
                
                this._soundFont.change(
                    preset = config["preset"],
                    bank   = config["bank"]
                );

                return;
            } 

            sortingVisualizer.userWarn("Select soundfont file to load");
            new str sf2 = sortingVisualizer.fileDialog({"sf2", "sf3", "SF2", "SF3"}, os.path.join(HOME_DIR, "resources"));

            try {
                this._soundFont = sf2_loader(sf2);
            } catch Exception as e {
                sortingVisualizer.userWarn(f"Unable to load soundfont. Exception:\n{formatException(e)}");
                continue;
            }

            new dynamic tmp   = this._soundFont.all_instruments(),
                        names = [];

            for topKey in tmp {
                for key in tmp[topKey] {
                    names.append((topKey, key, tmp[topKey][key]));
                }
            }

            new dynamic i = sortingVisualizer.getUserSelection(
                [str(x[2]) for x in names], "Select instrument"
            );
            i = names[i];

            new dynamic config = {
                "file":   sf2,
                "bank":   i[0],
                "preset": i[1]
            };

            try {
                with open(fileName, "w") as f {
                    json.dump(config, f);
                }
            } catch Exception as e {
                sortingVisualizer.userWarn(f"Unable to save soundfont configuration. Exception:\n{formatException(e)}");
            }
        }
    }

    new method play(value, max_, sample) {
        if this._soundFont is None {
            return Sounds.SquareWave.play(value, max_, sample);
        } else {
            return numpy.array(
                this._soundFont.export_note(
                    Sounds._FakeMPNote(int(24 + value * 67 / max_)),
                    len(sample) / FREQUENCY_SAMPLE,
                    volume = 127, channels = 1,
                    frame_rate = FREQUENCY_SAMPLE,
                    get_audio = True
                ).get_array_of_samples(),
                float
            );
        }
    }
}

new class Default: Soundfont {
    new method __init__() {
        Sound.__init__(this, "Default");
    }

    new method prepare() {
        sortingVisualizer.setCurrentlyRunning("Default sound system");

        try {
            this._soundFont = sf2_loader(os.path.join(HOME_DIR, "resources", "sfx.sf2"));
        } catch Exception as e {
            sortingVisualizer.userWarn(f"Unable to load soundfont. Exception:\n{formatException(e)}");
            return;
        }

        this._soundFont.change(
            bank   = 0,
            preset = 5
        );
    }
}