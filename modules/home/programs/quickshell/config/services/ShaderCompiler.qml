import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string sourceFile: ""
    property string name: ""

    // The base name of the file without extension
    readonly property string baseName: name !== "" ? name : (sourceFile.split("/").pop().split(".")[0])

    property string compiledPath: ""
    property bool ready: false

    property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/quickshell/shaders"
    property string _outputFile: stateDir + "/" + root.baseName + ".frag.qsb"

    // Cache bust by appending ?v=Date.now() to the URL so UI components reload the file
    property string _urlVersion: ""

    property bool _isLoaded: false

    FileView {
        id: watcher
        path: root.sourceFile
        onTextChanged: {
            if (root._isLoaded) {
                // File changed after initial load
                debounceTimer.restart()
            } else if (watcher.text !== "") {
                // First time the file is fully read
                root._isLoaded = true
                debounceTimer.restart() // Always run check on first load
            }
        }
    }

    Timer {
        id: debounceTimer
        interval: 100
        onTriggered: {
            compiler.running = true
        }
    }

    Process {
        id: compiler

        command: [
            "sh",
            "-c",
			`mkdir -p '${root.stateDir}' && if [ ! -f '${root._outputFile}' ] || [ '${root.sourceFile}' -nt '${root._outputFile}' ]; then echo 'Compiling ${root.name}...'; qsb --qt6 -o '${root._outputFile}' '${root.sourceFile}'; else echo 'Shader ${root.name} is up to date.'; exit 0; fi`
        ]

        onExited: function(exitCode) {
            if (exitCode === 0) {
                // Update the URL version to cache-bust any previous loads in QML
                root._urlVersion = Date.now().toString()
                root.compiledPath = root._outputFile + "?v=" + root._urlVersion
                root.ready = true
            } else {
                console.error("Shader compilation failed for " + root.name + " (code " + exitCode + ")");
            }
        }
    }
}
