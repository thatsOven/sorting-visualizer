new class _CustomImageChunk: sprite.Sprite {
    new method __init__(image, rect) {
        sprite.Sprite.__init__(this);

        this.image = image;
        this.rect  = rect;
    }
}

new class CustomImage: LineVisual {
    # https://www.pygame.org/docs/ref/image.html
    new set SUPPORTED_IMAGE_FORMATS = {
        "bmp", "gif", "jpg", "jpeg", "lbm", 
        "pbm", "pgm", "ppm", "webp", "pcx", 
        "pnm", "svg", "tga", "tiff", "png", 
        "xpm"
    };
    SUPPORTED_IMAGE_FORMATS |= set(x.upper() for x in SUPPORTED_IMAGE_FORMATS);

    new method __init__() {
        super.__init__(
            "Custom Image",
            (255, 255, 255)
        );

        this.image  = None;

        this.defaultChunks = [];

        this.chunks = [];
        this.group  = sprite.Group();

        this.auxChunks = [];
        this.auxGroup  = sprite.Group();
    }

    new method init() {
        sortingVisualizer.setCurrentlyRunning("Custom Image visual style");

        while True {
            new dynamic fileName = os.path.join(SortingVisualizer.CONFIG, "CustomImage.json");
            if os.path.exists(fileName) {
                new dynamic config;

                try {
                    with open(fileName, "r") as f {
                        config = json.loads(f.read());
                    }
                } catch Exception as e {
                    sortingVisualizer.userWarn(f"Unable to load custom image configuration. Exception:\n{formatException(e)}");
                    return;
                }

                if config["file"] is None {
                    return;
                }

                try {
                    this.image = sortingVisualizer.graphics.loadImage(config["file"], sortingVisualizer.graphics.resolution);
                } catch Exception as e {
                    sortingVisualizer.userWarn(f"Unable to load image. Exception:\n{formatException(e)}");
                    return;
                }

                return;
            } 

            new dynamic config;
            if (
                sortingVisualizer.getUserSelection(
                    ["Yes", "No"], 
                    "Do you want to set an image for the Custom Image visual style? " +
                    "If you say no, this will not be asked again, " +
                    'but you can change this setting later by resetting the "CustomImage.json" ' +
                    "configuration through the visualizer's settings."
                ) == 0
            ) {
                new dynamic file = sortingVisualizer.fileDialog(Visuals.CustomImage.SUPPORTED_IMAGE_FORMATS);

                try {
                    this.image = sortingVisualizer.graphics.loadImage(file, sortingVisualizer.graphics.resolution);
                } catch Exception as e {
                    sortingVisualizer.userWarn(f"Unable to load image. Exception:\n{formatException(e)}");
                    return;
                }

                config = {
                    "file": file
                };
            } else {
                config = {
                    "file": None
                };
            }

            try {
                with open(fileName, "w") as f {
                    json.dump(config, f);
                }
            } catch Exception as e {
                sortingVisualizer.userWarn(f"Unable to save custom image configuration. Exception:\n{formatException(e)}");
            }
        }
    }

    new method prepare() {
        if this.image is None {
            throw VisualizerException("No image was set for Custom Image visual style");
        }

        super.prepare();

        this.chunks.clear();

        for x = 0; x + this.lineSize < sortingVisualizer.graphics.resolution.x; x += this.lineSize {            
            this.chunks.append(this.image.subsurface((x, 0, this.lineSize, sortingVisualizer.graphics.resolution.y)));
        }

        this.defaultChunks = this.chunks.copy();

        this.mapFactor = len(this.chunks) / sortingVisualizer.arrayMax;
    }

    new method onAuxOn(length) {
        super.onAuxOn(length);

        this.chunks.clear();
        this.auxChunks.clear();

        new dynamic ySize  = sortingVisualizer.graphics.resolution.y - this.top, 
                    yStart = sortingVisualizer.graphics.resolution.y // 2 - ySize // 2;

        for x = 0; x + this.lineSize < sortingVisualizer.graphics.resolution.x; x += this.lineSize {
            this.chunks.append(this.image.subsurface((x, yStart, this.lineSize, ySize)));
        }

        yStart = sortingVisualizer.graphics.resolution.y // 2 - this.top // 2;

        for x = 0; x + this.auxLineSize < sortingVisualizer.graphics.resolution.x; x += this.auxLineSize {
            this.auxChunks.append(this.image.subsurface((x, yStart, this.auxLineSize, this.top)));
        }

        this.auxMapFactor = len(this.auxChunks) / sortingVisualizer.auxMax;
    }

    new method onAuxOff() {
        super.onAuxOff();
        
        this.chunks = this.defaultChunks.copy();
    }

    new method draw(array, indices) {
        this.group.empty();

        new dynamic ySize = sortingVisualizer.graphics.resolution.y - this.top, idx;

        if len(array) > sortingVisualizer.graphics.resolution.x {
            for x in range(sortingVisualizer.graphics.resolution.x) {
                idx = int(Utils.translate(
                    x, 0, sortingVisualizer.graphics.resolution.x, 
                    0, len(array)
                ));

                new dynamic item = array[idx], chunk;

                if item.value < 0 {
                    chunk = this.chunks[0].copy();
                } else {
                    chunk = this.chunks[int(item.value * this.mapFactor)].copy();
                }

                this.group.add(Visuals._CustomImageChunk(chunk, (x, this.top, this.lineSize, ySize)));
            }
        } else {
            for x = 0; x < sortingVisualizer.graphics.resolution.x; x += this.lineSize {
                idx = int(Utils.translate(
                    x, 0, sortingVisualizer.graphics.resolution.x, 
                    0, len(array)
                ));
                    
                new dynamic item = array[idx], chunk;

                if item.value < 0 {
                    chunk = this.chunks[0].copy();
                } else {
                    chunk = this.chunks[int(item.value * this.mapFactor)].copy();
                }

                this.group.add(Visuals._CustomImageChunk(chunk, (x, this.top, this.lineSize, ySize)));
            }
        }

        this.group.draw(sortingVisualizer.graphics.screen);

        new dynamic drawn = {};
        new dynamic vec = Vector(this.lineSize, sortingVisualizer.graphics.resolution.y - this.top),
                    pos = Vector(0, this.top);

        for idx in indices {
            if indices[idx] is None {
                continue;
            }

            pos.x = Utils.translate(
                idx, 0, len(array), 0, 
                sortingVisualizer.graphics.resolution.x // this.lineSize
            ) * this.lineSize + (this.lineSize // 2);

            if pos.x in drawn {
                continue;
            } else {
                drawn[pos.x] = None;
            }

            sortingVisualizer.graphics.fastRectangle(pos, vec, indices[idx], 0);
        }

        del drawn;
    }

    new method drawAux(array, indices) {
        this.auxGroup.empty();

        new dynamic idx;

        if len(array) > sortingVisualizer.graphics.resolution.x {
            for x in range(sortingVisualizer.graphics.resolution.x) {
                idx = int(Utils.translate(
                    x, 0, sortingVisualizer.graphics.resolution.x, 
                    0, len(array)
                ));

                new dynamic item = array[idx], chunk;

                if item.value < 0 {
                    chunk = this.auxChunks[0].copy();
                } else {
                    chunk = this.auxChunks[int(item.value * this.auxMapFactor)].copy();
                }

                this.auxGroup.add(Visuals._CustomImageChunk(chunk, (x, 0, this.auxLineSize, this.top)));
            }
        } else {
            for x = 0; x < sortingVisualizer.graphics.resolution.x; x += this.auxLineSize {
                idx = int(Utils.translate(
                    x, 0, sortingVisualizer.graphics.resolution.x, 
                    0, len(array)
                ));
                    
                new dynamic item = array[idx], chunk;

                if item.value < 0 {
                    chunk = this.auxChunks[0].copy();
                } else {
                    chunk = this.auxChunks[int(item.value * this.auxMapFactor)].copy();
                }

                this.auxGroup.add(Visuals._CustomImageChunk(chunk, (x, 0, this.auxLineSize, this.top)));
            }
        }

        this.auxGroup.draw(sortingVisualizer.graphics.screen);

        new dynamic drawn = {};
        new dynamic vec = Vector(this.auxLineSize, this.top),
                    pos = Vector();

        for idx in indices {
            if indices[idx] is None {
                continue;
            }

            pos.x = Utils.translate(
                idx, 0, len(array), 0, 
                sortingVisualizer.graphics.resolution.x // this.auxLineSize
            ) * this.auxLineSize + (this.auxLineSize // 2);

            if pos.x in drawn {
                continue;
            } else {
                drawn[pos.x] = None;
            }

            sortingVisualizer.graphics.fastRectangle(pos, vec, indices[idx], 0);
        }

        del drawn;

        sortingVisualizer.graphics.line(Vector(0, this.auxResolution.y), this.auxResolution, (0, 0, 255), 2);
    }
}