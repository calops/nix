pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: niri

    property var workspaces: {}
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
            workspace.icon = _mapWorkspaceToIcon(workspace);

            if (workspace.is_focused) {
                focusedWorkspace = workspace;
            }

            newWorkspaces[workspace.id] = workspace;
        }

        workspaces = newWorkspaces;

        _computeOverflows();
    }

    function onNiriWindowsChanged(payload) {
        var newWindows = {};

        for (const win of payload.windows) {
            newWindows[win.id] = win;
            if (win.is_focused) {
                focusedWindow = win;
            }
        }

        windows = newWindows;

        _computeOverflows();
    }

    function onNiriWorkspaceActivated(payload) {
        if (payload.focused) {
            focusedWorkspace.is_focused = false;
            workspaces[payload.id].is_focused = true;
            focusedWorkspace = workspaces[payload.id];
        }
        _computeOverflows();
    }

    function onNiriWindowOpenedOrChanged(payload) {
        const win = payload.window;
        windows[win.id] = win;
        _computeOverflows();
    }

    function onNiriWindowClosed(payload) {
        delete windows[payload.id];
        _computeOverflows();
    }

    function onNiriWindowFocusChanged(payload) {
        if (payload.id && payload.id in windows) {
            focusedWindow.is_focused = false;
            windows[payload.id].is_focused = true;
            focusedWindow = windows[payload.id];
        }
        _computeOverflows();
    }

    function onNiriWindowLayoutsChanged(payload) {
        for (const change of payload.changes) {
            const [window_id, layout] = change;
            if (window_id in windows) {
                windows[window_id].layout = layout;
            }
        }
        _computeOverflows();
    }

    function focusWorkspace(workspaceId) {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", workspaceId]);
    }

    function sortedWorkspaces() {
        if (workspaces) {
            return Object.values(workspaces).sort((w1, w2) => w1.id - w2.id);
        }
        return [];
    }

    function _mapWorkspaceToIcon(workspace) {
        switch (workspace.name) {
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
            return workspace.id;
        }
    }

    function getWorkspaceWindows(workspaceId) {
        if (windows) {
            return Object.values(windows).filter(win => win.workspace_id == workspaceId);
        }
        return [];
    }

    function _computeOverflows() {
        var newHasLeftOverflow = false;
        var newHasRightOverflow = false;

        var wins = getWorkspaceWindows(focusedWorkspace?.id);
        if (wins) {
            for (const win of Object.values(wins)) {
                if (win.layout.tile_pos_in_workspace_view) {
                    if (win.layout.tile_pos_in_workspace_view[0] < 56) {
                        newHasLeftOverflow = true;
                    } else if (win.layout.tile_pos_in_workspace_view[0] > (3440 - 56)) {
                        newHasRightOverflow = true;
                    }
                }
            }
        }

        if (focusedWindow?.layout?.pos_in_scrolling_layout?.[0] > 1) {
            newHasLeftOverflow = true;
        }

        for (const win of getWorkspaceWindows(focusedWorkspace?.id)) {
            if (win.layout.tile_pos_in_workspace_view > focusedWindow.layout.tile_pos_in_workspace_view) {
                newHasRightOverflow = true;
                break;
            }
        }

        if (newHasLeftOverflow != hasLeftOverflow) {
            hasLeftOverflow = newHasLeftOverflow;
        }

        if (newHasRightOverflow != hasRightOverflow) {
            hasRightOverflow = newHasRightOverflow;
        }
    }
}
