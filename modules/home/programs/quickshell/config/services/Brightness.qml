pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int percentage: 0
    property int maxBrightness: 0
    property int currentBrightness: 0

    // Parsing helper
    function updateFromCsv(csv) {
        // Format: device,class,current,percentage,max
        // example: intel_backlight,backlight,10552,27%,38787
        const parts = csv.split(',');
        if (parts.length >= 5) {
            root.currentBrightness = parseInt(parts[2]);
            root.maxBrightness = parseInt(parts[4]);
            
            // Extract percentage string "27%" -> 27
            let permStr = parts[3];
            if (permStr.endsWith("%")) {
                permStr = permStr.substring(0, permStr.length - 1);
            }
            root.percentage = parseInt(permStr);
        }
    }

    // Monitor process
    Process {
        id: monitorProcess
        running: true
        // Monitor for backlight changes using udev, and print current status on change.
        // Initial status is printed by the first `brightnessctl -m`.
        // Then we pipe udevadm monitor to a loop. 
        // stdbuf -o0 ensures immediate output.
        // We filter for "change" events to avoid noise.
        command: [
            "sh", "-c",
            "brightnessctl -m; udevadm monitor --udev --subsystem-match=backlight | stdbuf -o0 grep --line-buffered 'change' | while read -r _; do brightnessctl -m; done"
        ]
        
        stdout: SplitParser {
            onRead: data => {
                // brightnessctl -m output might be cleaner than reading the udev event line
                // The logical flow is: event -> triggers `brightnessctl -m` -> outputs line
                // We just parse that line.
                // We might get the udev line "monitor will print..." header, ignore it.
                if (data.includes("monitor will print")) return;
                
                // brightnessctl output starts with device name composed of alphanumeric or underscores
                // e.g. "intel_backlight,backlight..."
                if (data.includes(",")) {
                    root.updateFromCsv(data.trim());
                }
            }
        }
    }

    Process {
        id: setBrightnessProcess
        command: ["brightnessctl", "s", root.targetBrightness + "%"]
    }

    property int targetBrightness: 0

    function setBrightness(value) {
        root.targetBrightness = value;
        setBrightnessProcess.running = true;
    }
}
