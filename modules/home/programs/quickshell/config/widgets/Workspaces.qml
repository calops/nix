import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "."
import "../services"
import "../components"

Item {
    id: root

    // --- Layout ---
    property int iconColumnWidth: Theme.iconWidth       // 56px — always visible
    property int expandedWidth: 260
    property bool expanded: hovered || Niri.overviewActive

    width: expanded ? expandedWidth : iconColumnWidth
    // Height is driven by the repeater content
    height: workspaceColumn.height

    Behavior on width {
        NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad }
    }

    // --- Hover detection ---
    // HoverHandler is the correct choice here: unlike MouseArea it doesn't
    // compete with or block child input handlers (WrapperMouseArea etc).
    property bool hovered: hoverHandler.hovered

    HoverHandler {
        id: hoverHandler
    }

    // --- Teal glass backdrop (like other widgets) ---
    HoverBackdrop {
        id: backdrop
        anchors.fill: parent
        anchors.topMargin: -5
        anchors.bottomMargin: -5
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        radius: 14
    }

    // --- States / Transitions ---
    states: [
        State {
            name: "expanded"
            when: root.expanded
            PropertyChanges { target: backdrop; opacity: 1.0 }
        }
    ]

    transitions: [
        Transition {
            from: "*"; to: "expanded"
            NumberAnimation { target: backdrop; property: "opacity"; to: 1.0; duration: Theme.animationDuration; easing.type: Easing.OutQuad }
        },
        Transition {
            from: "expanded"; to: "*"
            NumberAnimation { target: backdrop; property: "opacity"; to: 0.0; duration: Theme.animationDurationOut; easing.type: Easing.InQuad }
        }
    ]

    // --- Main layout: icon column (left, fixed) + expanded panel (right) ---
    Row {
        id: mainRow
        anchors.left: parent.left
        height: parent.height

        // Icon column (always 56px wide, stays on the left)
        Item {
            id: iconColumn
            width: root.iconColumnWidth
            height: workspaceColumn.height

            // --- Peach glassmorphic active-workspace cursor ---
            // This Item wraps the ShaderEffect and handles BlurRegistry registration
            // so the window blur pass includes the area beneath the cursor.
            Item {
                id: cursorContainer
                width: 32
                height: 32
                anchors.horizontalCenter: parent.horizontalCenter

                // Mirror cursor y with the same animation as the ShaderEffect
                property real targetY: {
                    var sorted = Niri.sortedWorkspaces();
                    if (!sorted || sorted.length === 0 || !Niri.focusedWorkspace) return 0;
                    var idx = sorted.findIndex(w => w.id === Niri.focusedWorkspace.id);
                    if (idx < 0) idx = 0;
                    return idx * 32;
                }

                y: targetY

                Behavior on y {
                    NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
                }

                // Radius property required by BlurRegistry/Region
                property real radius: 16.0

                // --- BlurRegistry registration ---
                // Walk up to find the blurGroupId (same as HoverBackdrop does)
                property string blurGroupId: ""

                function findBlurGroupId(node) {
                    if (!node) return "";
                    if (node.blurGroupId) return node.blurGroupId;
                    return findBlurGroupId(node.parent);
                }

                Component.onCompleted: {
                    var gid = findBlurGroupId(cursorContainer.parent);
                    if (gid) {
                        blurGroupId = gid;
                        BlurRegistry.registerItem(gid, cursorContainer);
                    }
                }

                Component.onDestruction: {
                    if (blurGroupId) {
                        BlurRegistry.unregisterItem(blurGroupId, cursorContainer);
                    }
                }

                // Peach glass shader
                ShaderEffect {
                    id: cursorShader
                    anchors.fill: parent

                    property real radius: 16.0

                    // Alpha: subtle when collapsed, fully opaque when expanded
                    property real cursorAlpha: root.expanded ? 0.75 : 0.45
                    Behavior on cursorAlpha {
                        NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad }
                    }

                    property color baseColor: Colors.alpha(Colors.palette.peach, cursorAlpha)
                    property real uWidth: width
                    property real uHeight: height

                    fragmentShader: Qt.resolvedUrl("../components/shaders/glass.frag.qsb")
                }
            }

            // Workspace icon slots
            Column {
                id: workspaceColumn
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 0

                Repeater {
                    id: workspaceRepeater
                    model: Niri.sortedWorkspaces()

                    Item {
                        id: wsItem
                        required property var modelData
                        width: root.iconColumnWidth
                        height: 32

                        readonly property bool isActive: Niri.focusedWorkspace && Niri.focusedWorkspace.id === modelData.id

                        WrapperMouseArea {
                            id: wma
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Niri.focusWorkspace(modelData.id)
                        }

                        StyledText {
                            id: wsIcon
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.family: "Symbols Nerd Font Mono"
                            font.pixelSize: 16

                            color: {
                                if (wsItem.isActive)       return Colors.palette.base;
                                if (wma.containsMouse)     return Colors.palette.teal;
                                return Colors.palette.subtext0;
                            }

                            Behavior on color { ColorAnimation { duration: Theme.animationDurationFast } }
                        }
                    }
                }
            }
        }

        // Expanded window-list panel (appears to the right of the icon column)
        Item {
            id: expandPanel
            width: Math.max(0, root.width - root.iconColumnWidth)
            height: parent.height
            clip: true

            opacity: root.expanded ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad }
            }

            // One row per workspace, vertically aligned with its icon
            Column {
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Repeater {
                    id: windowListRepeater
                    model: Niri.sortedWorkspaces()

                    // WorkspaceWindowRow: explicitly captures the workspace via property
                    WorkspaceWindowRow {
                        required property var modelData
                        workspace: modelData
                        width: expandPanel.width - 6
                        height: 32
                    }
                }
            }
        }
    }
}
