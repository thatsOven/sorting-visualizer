# Sorting Visualizer
 A sorting algorithms visualizer written in opal

to run, open or compile `SortingVisualizer.opal` using the opal compiler.

here you can find a video about the program: https://youtu.be/9ZuYW9bnCGw

# Installation
To properly run the visualizer, you will need to install these Python modules:
```
pygame_gui
scipy
perlin_noise
```

# The API
## Array operations
The array provided to the algorithms is filled with instances of the `Value` class. A `Value` contains a numeric value that actually gets sorted; an index, which is used for visualization and tracking of the value inside the array; a stability index, which is used for stability checking; an `aux` flag, that marks whether the `Value` is contained in the main array, or an `aux`iliary one. An instance of `Value` acts as any sortable data type, but it will automatically track elapsed time and display highlights for the current operation. The `Value` class provides the following methods:
- `copy() -> Value`: creates a copy of the `Value` without tracking time, statistics or highlighting;
- `read() -> Value`: like `copy` but it tracks time and statistics and highlights the `Value`'s index;
- `noMark() -> Value`: creates a copy of the `Value` without the index field, causing it not to get highlighted;
- `getInt() -> int`: returns the integer value of the `Value` without tracking time, statistics or highlighting;
- `readInt() -> int`: like `getInt` but it tracks time and statistics and highlights the `Value`'s index;
- `readDigit(digitIdx: int, base: int) -> int`: returns the given `Value`'s digit in the given base;
- `readNoMark() -> Value, int`: like `read`, but the returned value becomes "invisible" (that is, it doesn't get highlighted anymore). The `Value`'s index is returned so it can be restored later;
- `write(other: Value | int)`: writes a `Value` to that `Value`'s position;
- `writeRestoreIdx(other: Value | int, idx: int)`: like `write`, but it allows to restore an index. Used in conjunction with `readNoMark`;
- `swap(other: Value)`: swaps with another `Value`.
## Manually working with statistics
To manually increment, decrement, or edit statistics, you can access:
- `sortingVisualizer.reads`;
- `sortingVisualizer.comparisons`;
- `sortingVisualizer.writes`;
- `sortingVisualizer.swaps`.

Comparisons and reads are tied together, like swaps and writes. That is, if you add one swap, two writes will be added. 
The visualizer also provides a method to time operations manually:
- `sortingVisualizer.timer(sTime: float)`

It's used in conjuction with `default_timer()` like this:
```
new float sTime = default_timer();
# perform an operation here
sortingVisualizer.timer(sTime);
```
## Manual writes
For array operations that don't work properly with the `Value` class, the visualizer provides two methods that automatically keep track of statistics and time:
- `sortingVisualizer.write(array: list, i: int, val)`;
- `sortingVisualizer.swap(array: list, a: int, b: int)`.
## Manual highlights
The visualizer provides two methods for manual highlighting:
- `sortingVisualizer.highlight(index: int, aux: bool = False)`: highlights the given index;
- `sortingVisualizer.multiHighlight(indices: list[int], aux: bool = False)`: highlights a list of indices.
## Working with auxiliary arrays
To create a new array, the visualizer provides  `sortingVisualizer.createValueArray(length: int) -> list[Value]`, which is pre-filled with already configured `Value`s. To select an auxiliary array for visualization, `sortingVisualizer.setAux(array: list)` can be used, and `sortingVisualizer.resetAux()` can be used to remove it. The visualizer though, can only display one auxiliary array at a time. For this reason, it provides other two methods:
- `sortingVisualizer.setInvisibleArray(array: list[Value])`: disables all highlights from the given array. Basically, sets all the `Value`'s indices to `None`;
- `sortingVisualizer.setAdaptAux(fn)`: sets a function to "adapt" the aux array for visualization. It can merge more arrays together, effectively providing multiple-aux visualization, or visualization of multidimensional lists. The visualizer also provides `sortingVisualizer.resetAdaptAux()` to reset the adaptation to default. It's not mandatory to call, but it can be useful.
## Other utilities
The visualization speed can be changed through `sortingVisualizer.setSpeed(value: float)` and reset to 1 via `sortingVisualizer.resetSpeed()`. The speed can be fetched through `sortingVisualizer.speed` for temporary speed editing.

Delays can be set by using `sortingVisualizer.delay(timeMs: float)` before any highlighted operation.

The visualizer also provides methods for user input, namely:
- `sortingVisualizer.getUserInput(message: str = "", default: str = "", type_: int)`: asks the user a text input that gets converted to `type_`. `default` sets the default value;
- `sortingVisualizer.getUserSelection(content: list[str], message: str = "")`: asks the user to select between a list of items and returns the selection index.

And a method for warnings and errors, often used for invalid inputs:
- `sortingVisualizer.userWarn(message: str)`.

When the process of asking the user needs to be skipped, like in a custom thread, an "autoValue" can be set through the `sortingVisualizer.setAutoValue(value)` method. The value isn't changed until a new autoValue is set, or `sortingVisualizer.resetAutoValue()` is called.
## Adding new shuffles
Adding a new shuffle is extremely simple! You just need to add your `.opal` or `.py` file inside the `shuffles` folder, and provide a run function, composed like this:
```
@Shuffle("Shuffle Name");
new function myShuffle(array) {
    # your code here
}
```
or, in Python:
```py
@Shuffle("Shuffle Name")
def myShuffle(array):
    ... # your code here
```
## Adding new sorts
Like shuffles, adding sorts is very simple.  `.opal` or `.py` files need to be added to the `sorts` folder, and they have to provide a run function:
```
@Sort(
    "Sort Category",
    "Sort Name",
    "Sort Name in menu selection"
);
new function mySort(array) {
    # your code here
}
```
## Adding new pivot selections
Pivot selections are algorithms used to select a pivot in partitioning sorts that require one. The visualizer provides a set of pivot selections for those algorithms to use, and the user can pick the one they prefer to experiment with. The process to adding one is very similar to adding a shuffle. The file needs to be added in the `pivotSelection` folder, and provide a run function:
```
@PivotSelection("Pivot Selection Name");
new function myPivotSelection(array, start, end, pivotDestination) {
	 # [start, end) is the interval in which the selection should pick a pivot
	 # pivotDestination should be the destination index the pivot should be swapped to
     # your code here
}
```
## Adding new distributions
Adding distributions is similar to adding shuffles and pivot selections. Files need to be added to the `distributions` folder. Creating arrays doesn't use the `Value` API, since the `Value`s aren't placed in the array at that time yet.
```
@Distribution("Distribution Name");
new function myDistribution(array, length) {
     # your code here
}
```
## Adding visual styles
To add a visual style, a class needs to be created an inherit from the `Visual` class. That way, visuals are automatically added. Said file needs to be added in the `visuals` folder.  Example:
```
new class MyVisual: Visual {
	new method __init__() {
		super.__init__(
			"Visual Name",
			highlightColor,
			refreshMode,
			outOfText
		);
	}
}
```
- `highlightColor`: a tuple containing 3 values (0, 255) in the RGB format;
- `refreshMode`: can either be `RefreshMode.STANDARD` for line-like visuals that intersect with the text, `RefreshMode.NOREFRESH` for visuals that don't need forced indices reloading, and `RefreshMode.FULL` for visuals that need the whole array to be refreshed at all times.
- `outOfText`: a boolean that indicates whether the visual draws over text. If it doesn't (True), the visualizer will draw a black rectangle under the text, to refresh it.

The `Visual` class contains two abstract methods: 
- `draw(array: list[Value], indices: list[int], color: Optional[tuple[int, int, int]])`: draws the main array. `indices` contains the list of highlighted indices. `color` contains either a color, or `None`, in which case the visual should draw those indices like they're not highlighted;
- `drawAux(array: list[Value], indices: list[int], color: Optional[tuple[int, int, int]])`: like `draw`, but draws the aux array.

The class also provides three methods that get called in specific scenarios and can be overrided. By default, they do nothing:
- `prepare()`: precomputes data for the visual style;
- `onAuxOn(length)`: gets called when aux is turned on or constants are to recompute. Useful to prepare data;
- `onAuxOff()`: gets called when aux mode is turned off. Useful to restore old values.

The `graphicsUtils.opal` file contains some presets for common visual styles.

