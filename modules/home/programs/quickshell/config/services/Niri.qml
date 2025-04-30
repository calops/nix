pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: niri
    property string workspaces: "TODO"

    Process {
        id: dateProc
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: event => {
                console.log("Niri: ", event);
            }
        }
    }
}
