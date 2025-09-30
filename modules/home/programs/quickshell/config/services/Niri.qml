pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: niri

    property var workspaces: {}
    property var workspaceWindows: {}
    property var windows: {}

    property int focusedWorkspaceId: 0
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

                var handler = niri["onNiri" + event];
                if (typeof handler === "function") {
                    handler(payload);
                }
            }
        }
    }

    function onNiriWorkspacesChanged(payload) {
        var newWorkspaces = {};

        for (const workspace of payload.workspaces) {
            workspace.icon = _mapWorkspaceNameToIcon(workspace.name);
            newWorkspaces[workspace.id] = workspace;

            if (workspace.is_focused) {
                focusedWorkspaceId = workspace.id;
            }
        }

        workspaces = newWorkspaces;
    }

    function onNiriWindowsChanged(payload) {
        workspaceWindows = {};

        for (const win of payload.windows) {
            workspaceWindows[win.workspace_id] = {};
            workspaceWindows[win.workspace_id][win.id] = win;

            if (win.is_focused) {
                focusedWindow = win;
            }
        }
    }

    function onNiriWorkspaceActivated(payload) {
        if (payload.focused) {
            workspaces[focusedWorkspaceId].is_focused = false;
            focusedWorkspaceId = payload.id;
            workspaces[focusedWorkspaceId].is_focused = true;
        }
    }

    function onNiriWindowOpenedOrChanged(payload) {
        workspaceWindows[payload.window.workspace_id][payload.window.id] = payload.window;
    }

    function onNiriWindowFocusChanged(payload) {
        focusedWindow = workspaceWindows?.get(focusedWorkspaceId)?.get(payload.id);
    }

    onFocusedWindowChanged: {
        _computeOverflows();
    }

    onFocusedWorkspaceIdChanged: {
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
        var windows = workspaceWindows?.get(focusedWorkspaceId);

        if (windows) {
            for (const win of Object.values(windows)) {
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
}
