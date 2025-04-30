import Quickshell
import QtQuick

import "widgets"

ShellRoot {
    ReloadPopup {}
    Scope {
        Variants {
            model: Quickshell.screens

            PanelWindow {
                id: bar

                property var modelData
                screen: modelData

                color: "transparent"
                height: screen.height
                width: 56

                anchors {
                    top: true
                    right: true
                }

                Backdrop {}

                Workspaces {
                    x: parent.width / 2 - width / 2
                    y: parent.height / 2 - height / 2
                }

                Time {
                    x: parent.width / 2 - width / 2
                    y: parent.height - height - 10
                }
            }
        }
    }
}
