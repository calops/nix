import Quickshell
import "../services/"

Scope {
    id: root
    property string time

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
            }

            implicitHeight: screen.height
            implicitWidth: 56
            color: "transparent"

            mask: Region {
                item: clock
            }

            Backdrop {
                enabled: Niri.hasLeftOverflow
            }

            Workspaces {
                id: workspaces
                x: parent.width / 2 - width / 2
                y: parent.height / 2 - height / 2
            }

            Time {
                id: clock
                x: parent.width / 2 - width / 2
                y: parent.height - height - 10
            }
        }
    }
}
