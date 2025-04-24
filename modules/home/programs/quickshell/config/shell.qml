import Quickshell
import QtQuick

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            color: "transparent"

            anchors {
                top: true
                bottom: true
                right: true
            }

            height: 30

            Text {
                color: "white"
                anchors.centerIn: parent
                text: "test"
            }
        }
    }
}
