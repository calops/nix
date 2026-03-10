pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: niri

    property var workspaces: {}
    property var windows: {}

    property var focusedWorkspace: null
    property var focusedWindow: null

    property bool hasLeftOverflow: false
    property bool hasRightOverflow: false
    property bool overviewActive: false

    Process {
        id: eventStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: message => {
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

    // Full workspace refresh — called on WorkspacesChanged and after monitor events.
    // This is the canonical way to keep workspace state consistent.
    function onNiriWorkspacesChanged(payload) {
        var newWorkspaces = {};
        var newFocused = null;

        for (const workspace of payload.workspaces) {
            workspace.icon = _mapWorkspaceToIcon(workspace);

            if (workspace.is_focused) {
                newFocused = workspace;
            }

            newWorkspaces[workspace.id] = workspace;
        }

        workspaces = newWorkspaces;

        // Always re-derive focusedWorkspace from the fresh payload to avoid
        // stale object references after monitor plug/unplug (workspace IDs can change).
        if (newFocused !== null) {
            focusedWorkspace = newFocused;
        }

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
            // Update is_focused flags on the existing objects
            if (focusedWorkspace && focusedWorkspace.id in workspaces) {
                workspaces[focusedWorkspace.id].is_focused = false;
            }
            if (payload.id in workspaces) {
                workspaces[payload.id].is_focused = true;
                focusedWorkspace = workspaces[payload.id];
            }
        }
        _computeOverflows();
    }

    function onNiriWindowOpenedOrChanged(payload) {
        const win = payload.window;
        windows[win.id] = win;
        if (win.is_focused) {
            focusedWindow = win;
        }
        _computeOverflows();
    }

    function onNiriWindowClosed(payload) {
        if (focusedWindow && focusedWindow.id === payload.id) {
            focusedWindow = null;
        }
        delete windows[payload.id];
        _computeOverflows();
    }

    function onNiriWindowFocusChanged(payload) {
        if (payload.id && payload.id in windows) {
            if (focusedWindow && focusedWindow.is_focused !== undefined) {
                 focusedWindow.is_focused = false;
            }
            windows[payload.id].is_focused = true;
            focusedWindow = windows[payload.id];
        } else if (!payload.id) {
            // Focus moved outside all windows
            if (focusedWindow) focusedWindow.is_focused = false;
            focusedWindow = null;
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

    function onNiriOverviewOpenedOrClosed(payload) {
        overviewActive = payload.is_open;
    }

    function focusWorkspace(workspaceId) {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", workspaceId]);
    }

    // Returns workspaces sorted by id (stable ordering across monitor changes)
    function sortedWorkspaces() {
        if (workspaces) {
            return Object.values(workspaces).sort((w1, w2) => w1.id - w2.id);
        }
        return [];
    }

    // Returns windows in the given workspace, sorted by their x position in the
    // scrolling layout (leftmost first). Falls back to id ordering if no layout data.
    function sortedWorkspaceWindows(workspaceId) {
        if (!windows) return [];
        return Object.values(windows)
            .filter(win => win.workspace_id === workspaceId)
            .sort((a, b) => {
                const ax = a.layout?.pos_in_scrolling_layout?.[0] ?? a.id;
                const bx = b.layout?.pos_in_scrolling_layout?.[0] ?? b.id;
                return ax - bx;
            });
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
            return Object.values(windows).filter(win => win.workspace_id === workspaceId);
        }
        return [];
    }

    function _computeOverflows() {
        var newHasLeftOverflow = false;
        var newHasRightOverflow = false;

        var wins = getWorkspaceWindows(focusedWorkspace?.id);
        if (wins) {
            for (const win of Object.values(wins)) {
                if (win && win.layout && win.layout.tile_pos_in_workspace_view) {
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

        if (focusedWindow && focusedWindow.layout && focusedWindow.layout.tile_pos_in_workspace_view) {
            for (const win of getWorkspaceWindows(focusedWorkspace?.id)) {
                if (win && win.layout && win.layout.tile_pos_in_workspace_view) {
                    if (win.layout.tile_pos_in_workspace_view > focusedWindow.layout.tile_pos_in_workspace_view) {
                        newHasRightOverflow = true;
                        break;
                    }
                }
            }
        }

        if (newHasLeftOverflow !== hasLeftOverflow) {
            hasLeftOverflow = newHasLeftOverflow;
        }

        if (newHasRightOverflow !== hasRightOverflow) {
            hasRightOverflow = newHasRightOverflow;
        }
    }
}
