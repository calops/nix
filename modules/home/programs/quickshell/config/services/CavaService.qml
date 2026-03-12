pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int barCount: 40
    property var frequencies: []

    // Initialize and Start
    Component.onCompleted: {
        // Initialize with zeros
        let arr = [];
        for (let i = 0; i < barCount; i++) arr.push(0);
        frequencies = arr;
        
        cavaProcess.running = true;
    }

    readonly property string configPath: "/tmp/quickshell-cava.conf"

    Process {
        id: cavaProcess
        
        // We write the config and exec cava in a single shell command to avoid race conditions and QML API guesswork
        command: [
            "sh", "-c", 
            `printf "[general]\\nbars=${root.barCount}\\nframerate=60\\nsensitivity=100\\n\\n[input]\\nmethod=pipewire\\nsource=auto\\n\\n[output]\\nmethod=raw\\nraw_target=/dev/stdout\\ndata_format=ascii\\nascii_max_range=100\\n" > ${root.configPath} && exec cava -p ${root.configPath}`
        ]
        
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                
                const parts = data.split(';');
                for (const part of parts) {
                    const trimmed = part.trim();
                    if (trimmed === "") continue;
                    
                    const val = parseInt(trimmed);
                    if (!isNaN(val)) {
                        root.handleValue(val);
                    }
                }
            }
        }

        onRunningChanged: {
            if (!running) {
                console.warn("CavaService: cava stopped, restarting in 2s...");
                restartTimer.start();
            }
        }
        
        stderr: SplitParser {
            onRead: data => console.error("CavaService (stderr):", data)
        }
    }

    Timer {
        id: restartTimer
        interval: 2000
        repeat: false
        onTriggered: cavaProcess.running = true
    }

    property var _buffer: []
    function handleValue(v) {
        _buffer.push(v / 100.0); // Normalize to 0.0 - 1.0
        if (_buffer.length >= root.barCount) {
            root.frequencies = _buffer;
            _buffer = [];
        }
    }
}
