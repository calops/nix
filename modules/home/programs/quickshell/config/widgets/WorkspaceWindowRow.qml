import QtQuick
import Quickshell
import "../services"
import "../components"

// A single row of app icons for all windows in one workspace.
Item {
    id: root

    property var workspace: null

    readonly property bool workspaceIsActive: {
        if (!workspace || !Niri.focusedWorkspace) return false;
        return Niri.focusedWorkspace.id === workspace.id;
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: root.workspace ? Niri.sortedWorkspaceWindows(root.workspace.id) : []

            Item {
                required property var modelData

                width: 18
                height: 18

                // Niri app_ids can be capitalized (e.g. "Slack") while icon names are lowercase.
                readonly property string iconId: (modelData.app_id || "").toLowerCase()

                // Quickshell.iconPath(name, check: true) returns "" when the icon doesn't
                // exist in the current theme — preventing Qt from loading a placeholder pixmap.
                // When empty, the Image has no source and renders nothing (showing only the fallback).
                readonly property string resolvedIcon: Quickshell.iconPath(iconId, true)

                // Fallback: always underneath, shown when resolvedIcon is empty
                Image {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    sourceSize: Qt.size(14, 14)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    // Use iconPath with a known-good fallback icon name
                    source: Quickshell.iconPath("application-default-icon")
                    visible: parent.resolvedIcon === ""
                    opacity: root.workspaceIsActive ? 0.6 : 0.35
                    Behavior on opacity { NumberAnimation { duration: Theme.animationDuration } }
                }

                // Specific app icon, only rendered when confirmed to exist in the theme
                Image {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    sourceSize: Qt.size(16, 16)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    source: parent.resolvedIcon
                    visible: parent.resolvedIcon !== ""
                    opacity: root.workspaceIsActive ? 1.0 : 0.65
                    Behavior on opacity { NumberAnimation { duration: Theme.animationDuration } }
                }
            }
        }
    }
}
