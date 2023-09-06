new class ThreadCommand {
    new method __init__(mode, id, lengthC = None) {
        this.__mode    = mode;
        this.__id      = id;
        this.__lengthC = lengthC;
    }

    new method compile() {
        match this.__mode {
            case "DISTRIBUTION" {
                return "this.runDistribution(" + str(this.__lengthC) + ", " + str(this.__id) + ")\n";
            }
            case "VISUAL" {
                return "this.setVisual(" + str(this.__id) + ")\n";
            }
            case "SHUFFLE" {
                return "this.runShuffle(" + str(this.__id) + ")\n";
            }
            case "SORT" {
                return "this.runSort(" + str(this.__lengthC) + ", " + str(this.__id) + ")\n";
            }
            case "SPEED" {
                return "this.setSpeed(" + str(this.__id) + ")\n";
            }
            case "AUTOVALUE_PUSH" {
                return "this.pushAutoValue(" + str(this.__id) + ")\n";
            }
            case "AUTOVALUE_POP" {
                return "this.popAutoValue()\n";
            }
            case "SPEED_RESET" {
                return "this.resetSpeed()\n";
            }
            case "AUTOVALUES_RESET" {
                return "this.resetAutoValues()\n";
            }
            case "DEFINE" {
                return "#" + str(this.__id) + "\n";
            }
        }
    }

    new method __str__() {
        new str name;

        match this.__mode {
            case "DISTRIBUTION" {
                name = sortingVisualizer.distributions[this.__id].name + " | " + str(this.__lengthC) + " elements";
            }
            case "VISUAL" {
                name = sortingVisualizer.visuals[this.__id].name;
            }
            case "SHUFFLE" {
                name = sortingVisualizer.shuffles[this.__id].name;
            }
            case "SORT" {
                name = sortingVisualizer.sorts[sortingVisualizer.categories[this.__lengthC]][this.__id].listName;
            }
            case "SPEED" {
                name = "SET | " + str(this.__id);
            }
            case "AUTOVALUE_PUSH" {
                name = "PUSH | " + str(this.__id);
            }
            case "AUTOVALUE_POP" {
                name = "POP";
            }
            case "SPEED_RESET" {
                name = "RESET";
            }
            case "AUTOVALUES_RESET" {
                name = "RESET";
            }
            case "DEFINE" {
                name = str(this.__id);
            }
        }

        return this.__mode + ": " + name;
    }
}
