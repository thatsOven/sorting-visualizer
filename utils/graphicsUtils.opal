package colorsys: import hsv_to_rgb;

new function hsvToRgb(h, s = 1, v = 1) {
    return tuple(round(i * 255) for i in hsv_to_rgb(h, s, v));
}