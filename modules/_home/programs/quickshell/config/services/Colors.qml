pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: colors

    property var dark: new Object({
        base: "#1e1e2e",
        mantle: "#181825",
        crust: "#11111b",
        text: "#cdd6f4",
        subtext1: "#bac2de",
        subtext0: "#a6adc8",
        overlay2: "#9399b2",
        overlay1: "#7f849c",
        overlay0: "#6c7086",
        surface2: "#585b70",
        surface1: "#45475a",
        surface0: "#313244",
        peach: "#fab387",
        yellow: "#f9e2af",
        red: "#f38ba8",
        maroon: "#eba0ac",
        pink: "#f5c2e7",
        mauve: "#cba6f7",
        rosewater: "#f5e0dc",
        flamingo: "#f2cdcd",
        sky: "#89dceb",
        sapphire: "#74c7ec",
        blue: "#89b4fa",
        lavender: "#b4befe",
        green: "#a6e3a1",
        teal: "#94e2d5"
    })

    property var light: new Object({
        base: "#eff1f5",
        mantle: "#e6e9ef",
        crust: "#dce0e8",
        text: "#1c1f39",
        subtext1: "#2c2f47",
        subtext0: "#3c3f55",
        overlay2: "#4c4f63",
        overlay1: "#5c5f71",
        overlay0: "#6c6f80",
        surface2: "#acb0be",
        surface1: "#bcc0cc",
        surface0: "#ccd0da",
        peach: "#fe640b",
        yellow: "#df8e1d",
        red: "#d20f39",
        maroon: "#e64553",
        pink: "#ea76cb",
        mauve: "#8839ef",
        rosewater: "#dc8a78",
        flamingo: "#dd7878",
        sky: "#04a5e5",
        sapphire: "#209fb5",
        blue: "#1e66f5",
        lavender: "#7287fd",
        green: "#40a02b",
        teal: "#179299"
    })

    property var palette: dark

    function alpha(color, aValue) {
        if (typeof color === 'string') {
            var r = color.slice(1, 3);
            var g = color.slice(3, 5);
            var b = color.slice(5, 7);
            var a = Math.round(aValue * 255).toString(16).padStart(2, '0');
            return "#" + a + r + g + b;
        } else {
            return Qt.rgba(color.r, color.g, color.b, aValue);
        }
    }
}
