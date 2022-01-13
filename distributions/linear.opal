@Distribution("Linear").run;
new function linear(array, length) {
    new int uniqueAmount;
    uniqueAmount = length // sortingVisualizer.getUserInput("Insert amount of unique items (default = " + str(length) + ")", str(length), [str(2 ** i) for i in range(1, int(math.log2(length)))]);

    for i = 1; i + uniqueAmount < length + 1; i += uniqueAmount {
        for j in range(uniqueAmount) {
            array[i - 1 + j] = Value(i // uniqueAmount);
        }
    }

    new int val = i // uniqueAmount;
    i -= 1;
    for ; i < length; i++ {
        array[i] = Value(val);
    }
}