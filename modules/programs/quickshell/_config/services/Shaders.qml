pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string dir: "/home/calops/.config/quickshell/assets/shaders"

    // Explicit list of shaders to manage
    // This is still much cleaner than duplicating ShaderCompiler blocks
    readonly property var shaderList: ["backdrop", "glass", "curves", "fractal"]

    // A map of shader names to their results
    property var all: ({})
    property var readyStates: ({})

    function get(name) {
        return all[name] ? ("file://" + all[name]) : "";
    }

    function isReady(name) {
        return !!readyStates[name];
    }

    Instantiator {
        model: root.shaderList
        delegate: ShaderCompiler {
            required property string modelData
            name: modelData
            sourceFile: root.dir + "/" + modelData + ".frag"

            onCompiledPathChanged: {
                if (compiledPath !== "") {
                    root.all = Object.assign({}, root.all, {
                        [name]: compiledPath
                    });
                }
            }

            onReadyChanged: {
                root.readyStates = Object.assign({}, root.readyStates, {
                    [name]: ready
                });
            }
        }
    }
}
