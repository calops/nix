pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int percentage: 0
    property int maxBrightness: 0
    property int currentBrightness: 0
    property string activeBackend: ""

    function updateFromCsv(csv) {
        // Format: device,class,current,percentage,max
        // example: intel_backlight,backlight,10552,27%,38787
        const parts = csv.split(',');
        if (parts.length >= 5) {
            root.currentBrightness = parseInt(parts[2]);
            root.maxBrightness = parseInt(parts[4]);
            
            let permStr = parts[3];
            if (permStr.endsWith("%")) {
                permStr = permStr.substring(0, permStr.length - 1);
            }
            root.percentage = parseInt(permStr);
        }
    }

    function updateFromDdc(output) {
        // Output format: VCP code 0x10 (Brightness                    ): current value =    60, max value =   100
        const currentMatch = output.match(/current value =\s*(\d+)/);
        const maxMatch = output.match(/max value =\s*(\d+)/);
        
        if (currentMatch && maxMatch) {
            root.currentBrightness = parseInt(currentMatch[1]);
            root.maxBrightness = parseInt(maxMatch[1]);
            if (root.maxBrightness > 0) {
                root.percentage = Math.round((root.currentBrightness / root.maxBrightness) * 100);
            }
        }
    }

    // Startup detection
    Process {
        id: initProcess
        running: true
        command: ["sh", "-c", "brightnessctl -m | grep 'backlight' || echo 'USE_DDC'"]
        
        stdout: SplitParser {
            onRead: data => {
                let text = data.trim();
                if (text === "USE_DDC") {
                    root.activeBackend = "ddcutil";
                    ddcPollTimer.start();
                    // trigger an immediate fetch
                    ddcPollProcess.running = true;
                } else if (text !== "") {
                    root.activeBackend = "brightnessctl";
                    root.updateFromCsv(text);
                    brightnessctlMonitor.running = true;
                }
            }
        }
    }

    // brightnessctl monitor (fast, event-based)
    Process {
        id: brightnessctlMonitor
        running: false
        command: [
            "sh", "-c",
            "udevadm monitor --udev --subsystem-match=backlight | stdbuf -o0 grep --line-buffered 'change' | while read -r _; do brightnessctl -m; done"
        ]
        
        stdout: SplitParser {
            onRead: data => {
                let text = data.trim();
                if (text.includes("monitor will print")) return;
                
                if (text.includes(",")) {
                    root.updateFromCsv(text);
                }
            }
        }
    }

    // ddcutil poll timer (slow, interval-based)
    Timer {
        id: ddcPollTimer
        interval: 3000
        repeat: true
        running: false
        onTriggered: {
            // Prevent launching another if the prior one is hanging
            if (!ddcPollProcess.running) {
                ddcPollProcess.running = true;
            }
        }
    }

    // ddcutil getter
    Process {
        id: ddcPollProcess
        running: false
        command: ["ddcutil", "getvcp", "10", "--terse"]
        
        stdout: SplitParser {
            onRead: data => {
                // with --terse: "VCP 10 C 60 100"
                let parts = data.trim().split(" ");
                if (parts.length >= 5 && parts[0] === "VCP" && parts[1] === "10") {
                    root.currentBrightness = parseInt(parts[3]);
                    root.maxBrightness = parseInt(parts[4]);
                    if (root.maxBrightness > 0) {
                        root.percentage = Math.round((root.currentBrightness / root.maxBrightness) * 100);
                    }
                } else {
                    // Fallback to regex if --terse isn't supported
                    root.updateFromDdc(data);
                }
            }
        }
    }

    property int targetBrightness: 0

    Process {
        id: setBrightnessProcess
        // Re-evaluate command when targetBrightness or activeBackend changes
        command: {
            if (root.activeBackend === "ddcutil") {
                // targetBrightness is expected to be a percentage for the UI
                return ["ddcutil", "setvcp", "10", root.targetBrightness.toString()];
            } else {
                return ["brightnessctl", "s", root.targetBrightness + "%"];
            }
        }
    }

    function setBrightness(value) {
        root.targetBrightness = value;
        setBrightnessProcess.running = true;
        
        // Optimistic UI updates
        root.percentage = value;
        
        if (root.activeBackend === "ddcutil" && root.maxBrightness > 0) {
            root.currentBrightness = Math.round((value / 100) * root.maxBrightness);
        }
    }
}
