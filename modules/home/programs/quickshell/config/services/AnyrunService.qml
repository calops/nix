pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias resultsModel: resultsModel
    ListModel {
        id: resultsModel
    }

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
                    root.activeConnection = clientSocket;
                    console.log("Anyrun connected");
                } else if (root.activeConnection === clientSocket) {
                    root.activeConnection = null;
                }
            }

            parser: SplitParser {
                onRead: data => {
                    if (!data)
                        return;
                    try {
                        root.handleProviderMessage(JSON.parse(data));
                    } catch (e) {
                        console.error(`Anyrun parse error: ${e}\nData: ${data}`);
                    }
                }
            }
        }
    }

    property var pluginArgs: []

    Process {
        id: configReader
        running: true
        command: ["sh", "-c", "grep -Eo '\"[^\"]*\\.so\"' ~/.config/anyrun/config.ron | tr -d '\"'"]

        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                const plugins = data.trim().split("\n").filter(p => p.length > 0);
                if (plugins.length > 0) {
                    const foundArgs = [];
                    for (const p of plugins) {
                        foundArgs.push("--plugins");
                        foundArgs.push(p);
                    }
                    root.pluginArgs = root.pluginArgs.concat(foundArgs);
                }
            }
        }
        onRunningChanged: {
            if (!running) {
                console.log(`Anyrun: configReader finished. Plugins found: ${root.pluginArgs.length / 2}`);
                providerProcess.running = true;
            }
        }
    }

    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: providerProcess.running = true
    }

    Process {
        id: providerProcess
        command: ["anyrun-provider", ...root.pluginArgs, "connect-to", "/tmp/quickshell-anyrun.sock"]
        onRunningChanged: {
            if (!running && root.pluginArgs.length > 0) {
                restartTimer.restart();
            }
        }

        stdout: SplitParser {
            onRead: data => console.log("anyrun-provider:", data)
        }
        stderr: SplitParser {
            onRead: data => console.error("anyrun-provider error:", data)
        }
    }

    function handleProviderMessage(msg) {
        if (msg.Ready) {
            msg.Ready.info.forEach(info => plugins[info.name] = info);
        } else if (msg.Matches) {
            const {
                plugin,
                matches
            } = msg.Matches;

            // Clear existing results for this plugin
            for (let i = resultsModel.count - 1; i >= 0; i--) {
                if (resultsModel.get(i).pluginName === plugin.name) {
                    resultsModel.remove(i);
                }
            }

            matches.forEach(match => {
                let icon = match.icon || "";
                if (icon && !icon.includes("://") && !icon.startsWith("/") && !icon.startsWith("~")) {
                    icon = `image://icon/${icon}`;
                }

                resultsModel.append({
                    pluginName: plugin.name,
                    title: (match.title || "No Title"),
                    description: (match.description || ""),
                    iconPath: icon,
                    rawMatch: match,
                    rawPlugin: plugin
                });
            });
        }
    }

    function query(text) {
        if (!activeConnection)
            return;

        activeConnection.write(JSON.stringify({
            Query: {
                text
            }
        }) + "\n");
        activeConnection.flush();
    }

    function execute(rawPlugin, rawMatch) {
        if (!activeConnection)
            return;

        activeConnection.write(JSON.stringify({
            Handle: {
                plugin: rawPlugin,
                selection: rawMatch
            }
        }) + "\n");
        activeConnection.flush();
    }

    function reset() {
        if (!activeConnection)
            return;

        resultsModel.clear();
        activeConnection.write(JSON.stringify("Reset") + "\n");
        activeConnection.flush();
    }
}
