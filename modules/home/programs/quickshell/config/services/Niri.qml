pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: niri

    property var workspaces: {}
    property var workspaceWindows: {}
    property var windows: {}

    property var focusedWorkspace: {}
    property var focusedWindow: {}

    property bool hasLeftOverflow: false
    property bool hasRightOverflow: false

    Process {
        id: eventStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: message => {
                console.log("Niri: ", message);

                const messageObject = JSON.parse(message);
                const event = Object.keys(messageObject)[0];
                const payload = Object.values(messageObject)[0];

                var handler = niri["on" + event];
                if (typeof handler === "function") {
                    handler(payload);
                }
            }
        }
    }

    function onWorkspacesChanged(payload) {
        workspaces = {};
        for (const workspace of payload.workspaces) {
            workspace.icon = _mapWorkspaceNameToIcon(workspace.name);
            workspaces[workspace.id] = workspace;

            if (workspace.is_focused) {
                focusedWorkspace = workspace;
            }
        }
    }

    function onWindowsChanged(payload) {
        workspaceWindows = {};

        for (const win of payload.windows) {
            workspaceWindows[win.workspace_id] = {};
            workspaceWindows[win.workspace_id][win.id] = win;

            if (win.is_focused) {
                focusedWindow = win;
            }
        }
    }

    function onWorkspaceActivated(payload) {
        if (payload.focused) {
            focusedWorkspace = workspaces[payload.id];
        }
    }

    function onWindowOpenedOrChanged(payload) {
        workspaceWindows[payload.window.workspace_id][payload.window.id] = payload.window;
    }

    function onWindowFocusChanged(payload) {
        focusedWindow = workspaceWindows[focusedWorkspace.id][payload.id];
    }

    onFocusedWindowChanged: {
        _computeOverflows();
    }

    onFocusedWorkspaceChanged: {
        _computeOverflows();
    }

    onWorkspaceWindowsChanged: {
        _computeOverflows();
    }

    onWorkspacesChanged: {
        _computeOverflows();
    }

    function _mapWorkspaceNameToIcon(name) {
        switch (name) {
        case "work":
            return "";
        case "dev":
            return "";
        case "misc":
            return "";
        case "chat":
            return "";
        case "games":
            return "󰊗";
        case "web":
            return "󰖟";
        default:
            return name;
        }
    }

    function _computeOverflows() {
        var newHasLeftOverflow = false;
        var newHasRightOverflow = false;

        for (const win of Object.values(workspaceWindows[focusedWorkspace.id])) {
            if (win.layout.tile_pos_in_workspace_view) {
                if (win.layout.tile_pos_in_workspace_view[0] < 56) {
                    newHasLeftOverflow = true;
                } else if (win.layout.tile_pos_in_workspace_view[0] > (3440 - 56)) {
                    newHasRightOverflow = true;
                }
            }
        }

        if (focusedWindow?.layout?.pos_in_scrolling_layout?.[0] > 0) {
            newHasLeftOverflow = true;
        }

        hasLeftOverflow = newHasLeftOverflow;
        hasRightOverflow = newHasRightOverflow;
    }
}
