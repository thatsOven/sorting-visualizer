use reverse;

@Rotation("Triple Reversal", RotationMode.INDEXED);
new function tripleReversal(array, a, m, b) {
    reverse(array, a, m);
    reverse(array, m, b);
    reverse(array, a, b);
}