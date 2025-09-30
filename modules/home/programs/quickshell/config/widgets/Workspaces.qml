import Quickshell
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick
import "../services"
import "../widgets"

ColumnLayout {
    id: root
    width: parent.width
    spacing: 0

    Rectangle {
        id: selected

        width: 27
        height: 27
        // anchors.horizontalCenter: parent.horizontalCenter
        Layout.alignment: Qt.AlignCenter
        y: 25 * (Niri.focusedWorkspaceId ? Niri.focusedWorkspaceId : 0) + 1
        color: Colors.palette.peach
        radius: 500

        Behavior on y {
            NumberAnimation {
                target: selected
                property: "y"
                easing.type: Easing.Quad
            }
        }
    }

    Repeater {
        model: Object.values(Niri.workspaces ? Niri.workspaces : {})

        MouseArea {
            required property var modelData
            height: 25
            Layout.alignment: Qt.AlignCenter
            // background: Rectangle {
            //     id: background
            //     color: hovered ? Colors.palette.yellow : "transparent"
            //     radius: 500
            //
            //     Behavior on color {
            //         PropertyAnimation {
            //             target: background
            //             property: "color"
            //             easing.type: Easing.OutQuad
            //         }
            //     }
            // }

            StyledText {
                id: icon
                text: modelData.icon
                color: {
                    if (selected.y == 25 * modelData.id + 1 || parent.hovered)
                        Colors.palette.base;
                    else
                        Colors.palette.subtext0;
                }
            }
        }
    }
}
