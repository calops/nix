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

                // mask is set dynamically in updateBlurRegion

                property var registeredBlurItems: BlurRegistry.getItemsForGroup("leftBarScope")
                onRegisteredBlurItemsChanged: updateBlurRegion()

                Item {
                    id: offscreenAnchorLeft
                    x: -9999; y: -9999; width: 1; height: 1
                    visible: true; opacity: 0.0
                }

                function updateBlurRegion() {
                    var items = registeredBlurItems || [];
                    
                    // Blur Region
                    var blurStr = "import Quickshell; import Quickshell.Wayland; Region {\n";
                    if (items.length === 0) {
                        blurStr += "    Region { item: offscreenAnchorLeft }\n";
                    } else {
                        for (var i = 0; i < items.length; i++) {
                            blurStr += "    property var item" + i + ": leftPanel.registeredBlurItems[" + i + "];\n";
                            blurStr += "    Region { item: item" + i + " || offscreenAnchorLeft; radius: typeof item" + i + " !== 'undefined' && item" + i + " ? (item" + i + ".radius || 0) : 0 }\n";
                        }
                    }
                    blurStr += "}";
                    if (leftPanel.BackgroundEffect.blurRegion) leftPanel.BackgroundEffect.blurRegion.destroy();
                    leftPanel.BackgroundEffect.blurRegion = Qt.createQmlObject(blurStr, leftPanel, "dynamicBlurRegionLeft");
                    
                    // Window Mask (includes static widgets + registered items)
                    var maskStr = "import Quickshell; import Quickshell.Wayland; Region {\n";
                    maskStr += "    Region { item: clock || offscreenAnchorLeft }\n";
                    maskStr += "    Region { item: workspaces || offscreenAnchorLeft }\n";
                    maskStr += "    Region { item: tray || offscreenAnchorLeft }\n";
                    maskStr += "    Region {\n";
                    // Need to use integer bindings for Region custom rects
                    maskStr += "        x: Math.round(tray ? tray.menuRect.x : 0)\n";
                    maskStr += "        y: Math.round(tray ? tray.menuRect.y : 0)\n";
                    maskStr += "        width: Math.round(tray ? tray.menuRect.width : 0)\n";
                    maskStr += "        height: Math.round(tray ? tray.menuRect.height : 0)\n";
                    maskStr += "    }\n";
                    for (var j = 0; j < items.length; j++) {
                        maskStr += "    property var item" + j + ": leftPanel.registeredBlurItems[" + j + "];\n";
                        maskStr += "    Region { item: item" + j + " || offscreenAnchorLeft; radius: typeof item" + j + " !== 'undefined' && item" + j + " ? (item" + j + ".radius || 0) : 0 }\n";
                    }
                    maskStr += "}";
                    if (leftPanel.mask) leftPanel.mask.destroy();
                    leftPanel.mask = Qt.createQmlObject(maskStr, leftPanel, "dynamicMaskLeft");
                }

                Item {
                    id: leftBarScope
                    anchors.fill: parent
                    property string blurGroupId: "leftBarScope"

                    Backdrop {
                        enabled: !Niri.overviewActive
                        width: 56
                        anchors.left: parent.left
                    }

                    SysTray {
                        id: tray
                        anchors.left: parent.left
                        y: 10
                        
                        menuRect: {
                            if (!mainTrayMenu.shouldShow || !hoveredItem) return Qt.rect(0, 0, 0, 0);
                            var pos = hoveredItem.mapToItem(leftPanel.contentItem, 0, 0);
                            // Increase overlap (248 < 260) for a smoother bridge transition
                            var menuX = tray.expanded ? 248 : 45;
                            // Align perfectly with the tray item top (pos.y) instead of offseting by -2
                            return Qt.rect(menuX, pos.y, mainTrayMenu.baseWidth, mainTrayMenu.baseHeight);
                        }
                    }

                    Workspaces {
                        id: workspaces
                        width: 56
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        y: parent.height / 2 - height / 2
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 15
                        spacing: Niri.overviewActive ? 17 : 0

                        Behavior on spacing { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }

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

            // Replaced manual hardcoded menuWin & subMenuWin with reusable unified TrayMenu
            TrayMenu {
                id: mainTrayMenu
                isSubmenu: false
                tray: tray
                sourceItem: tray.hoveredItem
                menuModel: tray.activeMenuModel
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
            // Force window to extend slightly past screen edge to cover potential gap
            margins.right: -2 

            implicitWidth: 300 // Fixed width to prevent resize flicker
            color: "transparent"
            
            // Try to set exclusion mode to ignore to fix reservation issue.
            // Based on common Quickshell/Wayland patterns, exclusionMode: ExclusionMode.Ignore might work.
            // But I should check if I can confirm this property exists.
            // For now, I will just fix the visibility issue in this step.
            exclusionMode: ExclusionMode.Ignore

            // static mask removed; handled dynamically in updateBlurRegion

            property var registeredBlurItems: BlurRegistry.getItemsForGroup("rightBarScope")
            onRegisteredBlurItemsChanged: updateBlurRegion()

            Item {
                id: offscreenAnchorRight
                x: -9999; y: -9999; width: 1; height: 1
                visible: true; opacity: 0.0
            }

            function updateBlurRegion() {
                var items = registeredBlurItems || [];
                
                // Blur Region
                var blurStr = "import Quickshell; import Quickshell.Wayland; Region {\n";
                if (items.length === 0) {
                    blurStr += "    Region { item: offscreenAnchorRight }\n";
                } else {
                    for (var i = 0; i < items.length; i++) {
                        blurStr += "    property var item" + i + ": rightPanel.registeredBlurItems[" + i + "];\n";
                        blurStr += "    Region { item: item" + i + " || offscreenAnchorRight; radius: typeof item" + i + " !== 'undefined' && item" + i + " ? (item" + i + ".radius || 0) : 0 }\n";
                    }
                }
                blurStr += "}";
                if (rightPanel.BackgroundEffect.blurRegion) rightPanel.BackgroundEffect.blurRegion.destroy();
                rightPanel.BackgroundEffect.blurRegion = Qt.createQmlObject(blurStr, rightPanel, "dynamicBlurRegionRight");

                // Window Mask (static base items + dynamic bounds)
                var maskStr = "import Quickshell; import Quickshell.Wayland; Region {\n";
                maskStr += "    Region { item: batteryLoader.item || offscreenAnchorRight }\n";
                maskStr += "    Region { item: brightness || offscreenAnchorRight }\n";
                maskStr += "    Region { item: volume || offscreenAnchorRight }\n";
                for (var i = 0; i < items.length; i++) {
                    maskStr += "    property var item" + i + ": rightPanel.registeredBlurItems[" + i + "];\n";
                    maskStr += "    Region { item: item" + i + " || offscreenAnchorRight; radius: typeof item" + i + " !== 'undefined' && item" + i + " ? (item" + i + ".radius || 0) : 0 }\n";
                }
                maskStr += "}";
                if (rightPanel.mask) rightPanel.mask.destroy();
                rightPanel.mask = Qt.createQmlObject(maskStr, rightPanel, "dynamicMaskRight");
            }

            Item {
                id: rightBarScope
                anchors.fill: parent
                property string blurGroupId: "rightBarScope"

                Backdrop {
                    // enabled: Niri.hasRightOverflow
                    enabled: !Niri.overviewActive
                    width: 56
                    anchors.right: parent.right
                    
                    // Override gradient to fade from Right (Opaque) to Left (Transparent)
                    // This avoids using rotation: 180 which causes pixel alignment issues
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Colors.alpha(Colors.palette.crust, 0.0) }
                        GradientStop { position: 0.4; color: Colors.alpha(Colors.palette.crust, 0.65) }
                        GradientStop { position: 1.0; color: Colors.alpha(Colors.palette.crust, 1.0) }
                    }
                }

                Column {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    anchors.right: parent.right
                    spacing: Niri.overviewActive ? 17 : 0

                    Behavior on spacing { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }

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
                        width: Theme.widgetExpandedWidth
                        sourceComponent: Component {
                            Battery {
                                anchors.right: parent.right
                            }
                        }
                    }
                }
            }
        }
    }
}
