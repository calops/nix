import Quickshell
import Quickshell.Widgets
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
        Layout.alignment: Qt.AlignCenter
        y: 25 * (Niri.focusedWorkspaceId ? Niri.focusedWorkspaceId : 0) + 1
        color: Colors.palette.peach
        radius: 500

        Behavior on y {
            NumberAnimation {
                target: selected
                property: "y"
                easing.type: Easing.OutQuad
            }
        }
    }

    Repeater {
        model: Object.values(Niri.workspaces ? Niri.workspaces : {})

        WrapperMouseArea {
            id: mouseArea

            required property var modelData
            hoverEnabled: true
            Layout.alignment: Qt.AlignCenter

            onClicked: {
                Niri.focusWorkspace(modelData.id);
            }

            onHoveredChanged: {
                icon.hovered = !icon.hovered;
            }

            StyledText {
                id: icon
                text: modelData.icon
                property bool hovered: false
                color: {
                    if (selected.y == 25 * modelData.id + 1 || parent.hovered)
                        Colors.palette.base;
                    else if (hovered)
                        Colors.palette.red;
                    else
                        Colors.palette.subtext0;
                }
            }
        }
    }
}
