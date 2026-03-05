pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool runnerVisible: false

    function toggleRunner(requestedState) {
        if (arguments.length === 0 || requestedState === undefined) {
            runnerVisible = !runnerVisible;
        } else {
            runnerVisible = !!requestedState;
        }

        if (!runnerVisible) {
            root.reset();
        }
    }

    property alias resultsModel: resultsModel
    ListModel { id: resultsModel }
    property var activeConnection: null
    property var plugins: ({})

    SocketServer {
        id: server
        path: "/tmp/quickshell-anyrun.sock"
        active: true

        handler: Socket {
            id: clientSocket

            onConnectedChanged: {
                if (connected) {
                    root.activeConnection = clientSocket
                    console.log("Anyrun provider connected")
                } else {
                    if (root.activeConnection === clientSocket) {
                        root.activeConnection = null
                    }
                    console.log("Anyrun provider disconnected")
                }
            }

            parser: SplitParser {
                onRead: data => {
                    if (!data) return;
                    try {
                        const message = JSON.parse(data);
                        root.handleProviderMessage(message);
                    } catch (e) {
                        console.error("Failed to parse Anyrun message ERROR: " + e + " DATA: " + data);
                    }
                }
            }
        }
    }

    Process {
        id: providerProcess
        running: true
        // Delay connection slightly to ensure the socket is listening
        command: [
            "sh", "-c",
            "sleep 0.1 && " +
            "PLUGINS=$(grep -Eo '\"[^\"]*\\.so\"' ~/.config/anyrun/config.ron | tr -d '\"')\n" +
            "ARGS=\"\"\n" +
            "for p in $PLUGINS; do\n" +
            "  ARGS=\"$ARGS --plugins $p\"\n" +
            "done\n" +
            "exec anyrun-provider $ARGS connect-to /tmp/quickshell-anyrun.sock"
        ]
        
        stdout: SplitParser {
            onRead: data => console.log("anyrun-provider stdout:", data)
        }
        stderr: SplitParser {
            onRead: data => console.log("anyrun-provider stderr:", data)
        }
    }

    function handleProviderMessage(msg) {
        if (msg.Ready) {
            console.log("Anyrun Ready with plugins:", msg.Ready.info.length);
            for (let i = 0; i < msg.Ready.info.length; i++) {
                const info = msg.Ready.info[i];
                plugins[info.name] = info;
            }
        } else if (msg.Matches) {
            const plugin = msg.Matches.plugin;
            const matches = msg.Matches.matches;
            
            for (let i = resultsModel.count - 1; i >= 0; i--) {
                if (resultsModel.get(i).pluginName === plugin.name) {
                    resultsModel.remove(i, 1);
                }
            }
            
            for (let i = 0; i < matches.length; i++) {
                const match = matches[i];
                let icon = match.icon || "";
                if (icon && !icon.includes("://")) {
                    if (icon.startsWith("/") || icon.startsWith("~")) {
                        // Keep absolute paths
                    } else {
                        icon = "image://icon/" + icon;
                    }
                }
                
                resultsModel.append({
                    "pluginName": plugin.name,
                    "title": match.title || "No Title",
                    "description": match.description || "",
                    "iconPath": icon,
                    "rawMatch": match,
                    "rawPlugin": plugin
                });
            }
        } else if (msg.Handled) {
            console.log("Anyrun handled selection");
            // Closed by UI to allow for validation animations
        }
    }

    function query(text) {
        if (!activeConnection) {
            console.warn("Anyrun query: no active connection");
            return;
        }
        
        console.log("Anyrun query: " + text);
        // We don't clear the model here to prevent jitter.
        // The provider-driven update in handleProviderMessage will clear 
        // stale results per-plugin as they arrive.
        
        const req = { "Query": { "text": text } };
        activeConnection.write(JSON.stringify(req) + "\n");
        activeConnection.flush();
    }

    function execute(rawPlugin, rawMatch) {
        if (!activeConnection) return;
        
        const req = {
            "Handle": {
                "plugin": rawPlugin,
                "selection": rawMatch
            }
        };
        activeConnection.write(JSON.stringify(req) + "\n");
        activeConnection.flush();
    }

    function reset() {
        if (!activeConnection) return;
        
        resultsModel.clear();
        const req = "Reset";
        activeConnection.write(JSON.stringify(req) + "\n");
        activeConnection.flush();
    }
}
