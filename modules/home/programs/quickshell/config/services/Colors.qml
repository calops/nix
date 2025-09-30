pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: colors

    property var palette: new Object({
        base: "#1e1e2e",
        text: "#cdd6f4",
        subtext1: "#bac2de",
        subtext0: "#a6adc8",
        overlay2: "#9399b2",
        overlay1: "#7f849c",
        overlay0: "#6c7086",
        crust: "#11111b",
        mantle: "#1e1e2e",
        peach: "#f2b48b",
        yellow: "#f9e2af"
    })

    function alpha(color, alpha) {
        var r = parseInt(color.slice(1, 3), 16);
        var g = parseInt(color.slice(3, 5), 16);
        var b = parseInt(color.slice(5, 7), 16);
        var a = Math.round(alpha * 255).toString(16).padStart(2, '0');
        var ret = "#" + a + r + g + b;
        return ret;
    }
}
