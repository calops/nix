import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import "../services/"
import "." as Widgets
import "../components"

Scope {
    id: root
    property string time

    Component.onCompleted: {
        Quickshell.iconTheme = "Papirus";
    }

    Variants {
        model: Quickshell.screens

        Scope {
            required property var modelData

            PanelWindow {
                id: leftPanel
                screen: modelData

                anchors {
                    top: true
                    bottom: true
                    left: true
                }
                margins.left: -2

                implicitHeight: screen.height
                // Set a fixed width large enough for expanded tray + menu
                implicitWidth: 650
                color: "transparent"

                exclusionMode: ExclusionMode.Ignore

                Item {
                    id: offscreenAnchorLeft
                    x: -9999
                    y: -9999
                    width: 1
                    height: 1
                    visible: true
                    opacity: 0.0
                }

                // Blur region - only dynamic items
                Region {
                    id: leftBlurRegion
                    items: RegionRegistry.getItemsForGroup("leftBarScopeBlur")
                }

                BackgroundEffect.blurRegion: leftBlurRegion

                // Mask - dynamic items + static items + menuRect
                Region {
                    id: leftMaskRegion
                    items: RegionRegistry.getItemsForGroup("leftBarScope")

                    Region { item: clock || offscreenAnchorLeft }
                    Region { item: workspaces || offscreenAnchorLeft }
                    Region { item: tray || offscreenAnchorLeft }
                    Region {
                        x: Math.round(tray ? tray.menuRect.x : 0)
                        y: Math.round(tray ? tray.menuRect.y : 0)
                        width: Math.round(tray ? tray.menuRect.width : 0)
                        height: Math.round(tray ? tray.menuRect.height : 0)
                    }
                }

                mask: leftMaskRegion

                Item {
                    id: leftBarScope
                    anchors.fill: parent
                    property string blurGroupId: "leftBarScopeBlur"
                    property string maskGroupId: "leftBarScope"

                    Backdrop {
                        enabled: !Niri.overviewActive
                        width: 56
                        anchors.left: parent.left
                        blurGroupId: "leftBarScopeBlur"
                    }

                    SysTray {
                        id: tray
                        anchors.left: parent.left
                        y: 15

                        menuRect: {
                            if (!mainMenu || !mainMenu.shouldShow || !hoveredItem)
                                return Qt.rect(0, 0, 0, 0);
                            var pos = hoveredItem.mapToItem(leftPanel.contentItem, 0, 0);
                            var menuX = tray.expanded ? 248 : 45;
                            return Qt.rect(menuX, pos.y, mainMenu.baseWidth, mainMenu.baseHeight);
                        }
                    }

                    Workspaces {
                        id: workspaces
                        anchors.left: parent.left
                        y: parent.height / 2 - height / 2
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 15
                        spacing: Niri.overviewActive ? 17 : 0

                        Behavior on spacing {
                            NumberAnimation {
                                duration: Theme.animationDuration
                                easing.type: Easing.OutQuad
                            }
                        }

                        Item {
                            id: clockContainer
                            width: Theme.widgetExpandedWidth
                            height: 80

                            Time {
                                id: clock
                                anchors.left: parent.left
                            }
                        }
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: rightPanel
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                right: true
            }
            margins.right: -2

            implicitWidth: 300
            color: "transparent"

            exclusionMode: ExclusionMode.Ignore

            Item {
                id: offscreenAnchorRight
                x: -9999
                y: -9999
                width: 1
                height: 1
                visible: true
                opacity: 0.0
            }

            // Blur region - only dynamic items
            Region {
                id: rightBlurRegion
                items: RegionRegistry.getItemsForGroup("rightBarScopeBlur")
            }

            BackgroundEffect.blurRegion: rightBlurRegion

            // Mask - dynamic items + static widgets
            Region {
                id: rightMaskRegion
                items: RegionRegistry.getItemsForGroup("rightBarScope")

                Region { item: notificationWidget || offscreenAnchorRight }
                Region { item: (batteryLoader.item || null) || offscreenAnchorRight }
                Region { item: brightness || offscreenAnchorRight }
                Region { item: volume || offscreenAnchorRight }
                Region { item: mpris || offscreenAnchorRight }
            }

            mask: rightMaskRegion

            Item {
                id: rightBarScope
                anchors.fill: parent
                property string blurGroupId: "rightBarScopeBlur"
                property string maskGroupId: "rightBarScope"

                Backdrop {
                    id: backdropItem
                    enabled: !Niri.overviewActive
                    width: 56
                    anchors.right: parent.right

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0.0
                            color: Colors.alpha(Colors.palette.crust, 0.0)
                        }
                        GradientStop {
                            position: 0.4
                            color: Colors.alpha(Colors.palette.crust, 0.65)
                        }
                        GradientStop {
                            position: 1.0
                            color: Colors.alpha(Colors.palette.crust, 1.0)
                        }
                    }
                }

                Widgets.NotificationWidget {
                    id: notificationWidget
                    anchors.right: parent.right
                    y: 15
                }

                Widgets.MprisWidget {
                    id: mpris
                    anchors.right: parent.right
                    y: parent.height / 2 - height / 2
                }

                Column {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    anchors.right: parent.right
                    spacing: Niri.overviewActive ? 17 : 0

                    Behavior on spacing {
                        NumberAnimation {
                            duration: Theme.animationDuration
                            easing.type: Easing.OutQuad
                        }
                    }

                    Item {
                        width: Theme.widgetExpandedWidth
                        height: volume.height
                        Widgets.VolumeWidget {
                            id: volume
                            anchors.right: parent.right
                        }
                    }

                    Item {
                        width: Theme.widgetExpandedWidth
                        height: brightness.height
                        Widgets.BrightnessWidget {
                            id: brightness
                            anchors.right: parent.right
                        }
                    }

                    Loader {
                        id: batteryLoader
                        active: UPower.displayDevice != null && UPower.displayDevice.percentage > 0
                        anchors.right: parent.right
                        height: active ? 50 : 0
                        visible: active
                        sourceComponent: Component {
                            Widgets.Battery {
                                anchors.right: parent.right
                            }
                        }
                    }
                }
            }
        }
    }
}
