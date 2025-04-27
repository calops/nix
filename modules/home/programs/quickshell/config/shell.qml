import Quickshell
import QtQuick

ShellRoot {
    ReloadPopup {}
    Scope {
        Variants {
            model: Quickshell.screens

            PanelWindow {
                id: bar
                color: "transparent"

                property var modelData
                screen: modelData

                height: modelData.height
                width: 56

                anchors {
                    top: true
                    right: true
                }

                Rectangle {
                    width: parent.width
                    height: parent.height

                    gradient: Gradient {
                        orientation: Gradient.Horizontal

                        GradientStop {
                            position: 0.0
                            color: Palette.yolo("red", 0.5)
                        }

                        GradientStop {
                            position: 1.0
                            color: Palette.alpha("base", 0.5)
                        }
                    }
                }

                Text {
                    color: "white"
                    anchors.centerIn: parent
                    text: "test"
                }
            }
        }
    }
}
