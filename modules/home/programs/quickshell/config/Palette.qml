pragma Singleton

import Quickshell

Singleton {
    property var colors: {
        base: "#1E1E2E";
        text: "#cdd6f4";
        red: "#f38ba8";
    }

    property var yolo: function (colorSlug, alpha) {
        var color = colors[colorSlug];
        var r = parseInt(color.slice(1, 3), 16);
        var g = parseInt(color.slice(3, 5), 16);
        var b = parseInt(color.slice(5, 7), 16);
        var a = Math.round(alpha * 255).toString(16).padStart(2, '0');
        console.log("alpha", color, alpha, r, g, b, a);
        return "#" + r.toString(16) + g.toString(16) + b.toString(16) + a;
    }
}
