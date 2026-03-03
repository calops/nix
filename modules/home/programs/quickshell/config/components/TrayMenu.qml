import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../services"

// TrayMenu.qml
// A recursive popup menu component for system tray items.
PopupWindow {
    id: root
    
    // Properties to define how this menu is anchored and what data it shows
    property var sourceItem: null // The visual QML Item this menu sprouts from
    property var menuModel: null  // The QsMenu data model
    property bool isSubmenu: false
    property var tray: null       // Reference to the main SysTray for state tracking
    property var parentMenu: null // The parent TrayMenu Window
    
    // Directional anchoring: Main menus grow right from the tray, submenus grow right from the item
    anchor.window: isSubmenu ? parentMenu : leftPanel // leftPanel is assumed to be in scope from Bars.qml
    // We attach a dynamic property to sourceItem to track the active submenu if needed
    
    // Position logic
    property real targetX: 0
    property real targetY: 0
    property real targetWidth: 0
    property real targetHeight: 0
    
    anchor.rect: {
        if (!sourceItem) return Qt.rect(0, 0, 0, 0);
        
        if (isSubmenu) {
            // Anchor to the RIGHT edge of the active item!
            return Qt.rect(sourceItem.x + 8 + sourceItem.width, sourceItem.y + 2, 0, 0);
        } else {
            // Main menu anchors to the tray item
            var pos = sourceItem.mapToItem(leftPanel.contentItem, 0, 0);
            return Qt.rect(tray.expanded ? 248 : 45, pos.y, menuContent.implicitWidth + 16, menuContent.implicitHeight);
        }
    }
    
    anchor.gravity: Edges.Right | Edges.Bottom
    anchor.edges: Edges.Left | Edges.Top
    color: "transparent"

    // Decouple visibility from opacity to allow fade-out
    property bool shouldShow: menuModel !== null && sourceItem !== null
    visible: shouldShow || menuFadeOut.running

    // Calculate the base size required just for this menu's immediate content
    property real baseWidth: Math.min(isSubmenu ? 250 : 300, menuContentWrapper.implicitWidth + 16)
    property real baseHeight: menuContentWrapper.implicitHeight + 8

    // Expand the bounding Wayland surface to a fixed maximum size.
    // This provides a massive invisible canvas so the popup doesn't have to dynamically resize (and jitter)
    // when a submenu opens. The background wrapper uses `baseWidth`, leaving this extra padded space purely transparent!
    implicitWidth: baseWidth + 260
    implicitHeight: Math.max(baseHeight, 600)

    // Track which submenu parent is active
    property var activeSubMenuData: null
    property Item activeSubMenuItem: null

    property var lastMenuModel: null
    onMenuModelChanged: {
        if (root.menuModel) {
            root.lastMenuModel = root.menuModel;
        }
    }

    QsMenuOpener {
        id: menuOpener
        // Fallback to the cached model when menuModel becomes null during fade-out
        // so the text items persist on the screen while the container's opacity goes to 0!
        menu: root.menuModel || root.lastMenuModel
    }

    Item {
        id: menuContentWrapper
        anchors.fill: parent
        opacity: root.shouldShow ? 1.0 : 0.0
        implicitWidth: menuContent.implicitWidth
        implicitHeight: menuContent.implicitHeight

        Behavior on opacity {
            NumberAnimation {
                id: menuFadeOut
                duration: root.shouldShow ? Theme.animationDuration : Theme.animationDurationOut
                easing.type: root.shouldShow ? Easing.OutQuad : Easing.InQuad
            }
        }

        // Background Blob
        ShaderEffect {
            id: menuBlob
            anchors.fill: parent
            z: -1
            visible: opacity > 0
            opacity: root.activeSubMenuData !== null ? 1.0 : 0.0
            
            Behavior on opacity {
                NumberAnimation { 
                    duration: root.activeSubMenuData !== null ? Theme.animationDuration : Theme.animationDurationOut
                    easing.type: root.activeSubMenuData !== null ? Easing.OutQuad : Easing.InQuad 
                }
            }
            
            property bool allowsAnimation: false
            onVisibleChanged: {
                if (visible) Qt.callLater(() => { allowsAnimation = true; });
                else allowsAnimation = false;
            }
            
            property rect rect1: {
                if (!root.activeSubMenuItem) return Qt.rect(0,0,0,0);
                return Qt.rect(root.activeSubMenuItem.x + 8, root.activeSubMenuItem.y + 2, 
                             root.activeSubMenuItem.width, root.activeSubMenuItem.height);
            }
                
            Behavior on rect1 {
                enabled: menuBlob.allowsAnimation
                PropertyAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad }
            }
                
            property real targetR1X: {
                if (!root.activeSubMenuItem) return 0;
                return root.activeSubMenuItem.x + 8;
            }
            property real targetR1W: {
                if (!root.activeSubMenuItem) return 0;
                return root.activeSubMenuItem.width;
            }
            property real targetR1H: {
                if (!root.activeSubMenuItem) return 0;
                return root.activeSubMenuItem.height;
            }

            property real r2x: (root.activeSubMenuItem && root.childMenu && root.childMenu.shouldShow && menuBlob.allowsAnimation)
                ? root.activeSubMenuItem.x + 8 + root.activeSubMenuItem.width : targetR1X
            property real r2w: (root.activeSubMenuItem && root.childMenu && root.childMenu.shouldShow && menuBlob.allowsAnimation)
                ? root.childMenu.baseWidth : targetR1W
            property real r2h: (root.activeSubMenuItem && root.childMenu && root.childMenu.shouldShow && menuBlob.allowsAnimation)
                ? root.childMenu.baseHeight : targetR1H

            Behavior on r2x { enabled: menuBlob.allowsAnimation; PropertyAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }
            Behavior on r2w { enabled: menuBlob.allowsAnimation; PropertyAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }
            Behavior on r2h { enabled: menuBlob.allowsAnimation; PropertyAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }

            property rect rect2: Qt.rect(r2x, rect1.y, r2w, r2h)

            property rect rect3: Qt.rect(0, 0, 0, 0)
            property real radius1: 8
            property real radius2: 10
            property real radius3: 0
            property real smoothness: 15.0
            property color bubbleColor: Qt.tint(Colors.light.base, Colors.alpha(Colors.light.text, 0.15))
            property real uWidth: width
            property real uHeight: height
            
            fragmentShader: Qt.resolvedUrl("shaders/bubble.frag.qsb")

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "black"
                shadowBlur: 1.0
                shadowOpacity: 0.5
                shadowVerticalOffset: 2
                shadowHorizontalOffset: 2
            }
        }

        MouseArea {
            width: root.baseWidth
            height: root.baseHeight
            hoverEnabled: true
            // Extremely critical: if the parent tray's expanded state collapses, the Wayland anchor X coordinate 
            // recalculates instantly. If this shifts the fading surface under the user's cursor again, it creates an infinite feedback loop!
            enabled: tray ? tray.expanded : true
            
            onContainsMouseChanged: {
                if (tray) {
                    if (containsMouse) tray.menuHoverCount++;
                    else tray.menuHoverCount--;
                }
            }

            Component.onDestruction: {
                if (containsMouse && tray) {
                    tray.menuHoverCount--;
                }
            }
            
            acceptedButtons: Qt.NoButton

            ColumnLayout {
                id: menuContent
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: 8
                anchors.topMargin: 0
                spacing: isSubmenu ? 2 : 0
                
                opacity: 1.0
                NumberAnimation {
                    id: menuContentFadeIn
                    target: menuContent
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: Theme.animationDurationFast
                    easing.type: Easing.OutQuad
                }
                
                Connections {
                    target: root
                    function onMenuModelChanged() {
                        if (root.menuModel) {
                            menuContentFadeIn.restart();
                        }
                    }
                }
                
                Repeater {
                    model: menuOpener.children

                    delegate: Item {
                        id: menuItem
                        required property var modelData
                        
                        Layout.fillWidth: true
                        implicitHeight: modelData.isSeparator ? 9 : Math.max(isSubmenu ? 24 : 32, menuLabel.implicitHeight + 8)
                        implicitWidth: Math.max(180, menuLabel.implicitWidth + 56)
                        Layout.maximumWidth: isSubmenu ? 250 : 280
                        visible: modelData.visible !== false

                        Rectangle {
                            visible: modelData.isSeparator
                            anchors.centerIn: parent
                            width: parent.width - 16
                            height: 1
                            color: Colors.light.surface1
                        }

                        Rectangle {
                            id: hoverBg
                            visible: !modelData.isSeparator && (itemMouse.containsMouse || root.activeSubMenuData === modelData)
                            anchors.fill: parent
                            anchors.margins: 3
                            radius: 8
                            color: Colors.light.surface0
                        }

                        RowLayout {
                            visible: !modelData.isSeparator
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            Image {
                                id: menuIcon
                                source: modelData.icon || ""
                                sourceSize: Qt.size(16, 16)
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                Layout.maximumWidth: 16
                                Layout.maximumHeight: 16
                                fillMode: Image.PreserveAspectFit
                                visible: source != ""
                                Layout.alignment: Qt.AlignVCenter

                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    colorization: 1.0
                                    colorizationColor: modelData.enabled ? Colors.light.text : Colors.light.overlay0
                                    brightness: 1.0
                                    contrast: 1.0
                                }
                            }

                            StyledText {
                                id: menuLabel
                                text: (modelData.text || "").replace(/&/g, "")
                                font.pixelSize: 13
                                color: modelData.enabled ? Colors.light.text : Colors.light.overlay0
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                            }
                            
                            StyledText {
                                text: "›"
                                font.pixelSize: 13
                                color: Colors.light.overlay1
                                visible: modelData.hasChildren
                            }
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: !modelData.isSeparator && modelData.enabled && (tray ? tray.expanded : true)
                            onContainsMouseChanged: {
                                if (containsMouse && modelData.hasChildren) {
                                    root.activeSubMenuData = modelData;
                                    root.activeSubMenuItem = menuItem;
                                } else if (containsMouse && !modelData.hasChildren) {
                                    root.activeSubMenuData = null;
                                    root.activeSubMenuItem = null;
                                }
                            }
                            onClicked: {
                                if (!modelData.hasChildren) {
                                    modelData.triggered();
                                    if (tray) {
                                        tray.activeMenuModel = null;
                                        tray.hoveredItem = null;
                                    }
                                    root.activeSubMenuData = null;
                                    root.activeSubMenuItem = null;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Load the submenu dynamically via a URL string to bypass QML's strict cyclic dependency static analyzer.
    Loader {
        id: childMenuLoader
    }
    
    // Provide a proxy property to reference the active child menu for anchors/sizing
    // MUST be var, because TrayMenu is a PopupWindow (Wayland Window), not a QQuickItem!
    property var childMenu: childMenuLoader.item

    property bool childMenuInstantiated: false
    onActiveSubMenuDataChanged: {
        if (activeSubMenuData !== null) {
            if (!childMenuInstantiated) {
                childMenuInstantiated = true;
                // Instantiate without a source item / model first so it initializes with shouldShow=false and opacity=0
                childMenuLoader.setSource("TrayMenu.qml", {
                    "isSubmenu": true,
                    "tray": root.tray,
                    "parentMenu": root,
                    "sourceItem": null,
                    "menuModel": null
                });
            }
            
            // Apply the properties on the next frame so it naturally triggers the fade IN animation!
            Qt.callLater(() => {
                if (childMenuLoader.item) {
                    childMenuLoader.item.sourceItem = root.activeSubMenuItem;
                    childMenuLoader.item.menuModel = root.activeSubMenuData;
                }
            });
        } else if (childMenuLoader.item) {
            // Unlink the model so 'shouldShow' evaluates to false, triggering the fade OUT animation!
            // Do NOT wipe 'source' instantly, or the child component will be destroyed instantly instead of fading!
            childMenuLoader.item.menuModel = null;
        }
    }

    onActiveSubMenuItemChanged: {
        if (childMenuLoader.item && activeSubMenuItem && activeSubMenuData !== null) {
            childMenuLoader.item.sourceItem = activeSubMenuItem;
        }
    }
}
