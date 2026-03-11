import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import "../services"
import "../data/AppMappings.js" as AppMappings
import "../components"

Item {
    id: root
    implicitWidth: 56
    implicitHeight: trayLayout.implicitHeight

    property var hoveredItem: null
    property var activeMenuModel: null
    property alias bubbleBg: bubbleBackground
    
    property var mainMenu: mainMenuLoader.item
    
    // Remember the geometry of the last hovered item so we can animate from/to its center
    // when transitioning from/to the completely unhovered state
    property var lastHoveredItem: null
    property rect lastHoveredRect: Qt.rect(0, 0, 0, 0)
    
    // Unified hover state
    property bool iconHovered: false
    property int menuHoverCount: 0
    readonly property bool menuHovered: menuHoverCount > 0
    readonly property bool isHovered: iconHovered || menuHovered
    
    // The widgetMouseArea was causing event interference when moving downwards.
    // We now rely purely on the unified 'isHovered', 'Niri.overviewActive',
    // and whether a menu is actively held open.
    readonly property bool expanded: isHovered || Niri.overviewActive || activeMenuModel !== null
    
    width: expanded ? Theme.widgetExpandedWidth : Theme.iconWidth
    Behavior on width { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }

    HoverBackdrop {
        id: backdrop
        anchors.fill: root
        anchors.topMargin: -10
        anchors.bottomMargin: -10
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        z: 1
        opacity: root.expanded ? 1.0 : 0.0
        Behavior on opacity { 
            NumberAnimation { 
                duration: root.expanded ? Theme.animationDuration : Theme.animationDurationOut 
                easing.type: root.expanded ? Easing.OutQuad : Easing.InQuad 
            } 
        }
    }


    // We strictly need this timer to close the Wayland surface when the mouse leaves the
    // entire SysTray + Menu area. The submenu doesn't need this because it closes transparently
    // alongside the main menu.
    Timer {
        id: menuCloseTimer
        // Reduced from 150ms. 50ms is enough to bridge tiny gaps when moving to the menu.
        interval: 50
        running: !root.isHovered
        onTriggered: {
            if (root.activeMenuModel !== null) {
                root.hoveredItem = null;
                root.activeMenuModel = null;
            }
        }
    }
    property rect menuRect: Qt.rect(0, 0, 0, 0)
    
    MenuBlob {
        id: bubbleBackground
        
        property real targetMinY: root.menuRect.width > 0 ? Math.min(0, (root.menuRect.y - root.y) - 12) : 0
        property real targetMaxY: root.menuRect.width > 0 ? Math.max(parent.height, (root.menuRect.y - root.y) + root.menuRect.height + 12) : parent.height
        property real targetWidth: root.menuRect.width > 0 ? root.menuRect.x + root.menuRect.width + 12 : (root.expanded ? Theme.widgetExpandedWidth : 56)
        
        property real cachedMinY: 0
        property real cachedMaxY: 0
        property real cachedWidth: 56
        
        onTargetMinYChanged: if (root.menuRect.width > 0) cachedMinY = targetMinY
        onTargetMaxYChanged: if (root.menuRect.width > 0) cachedMaxY = targetMaxY
        onTargetWidthChanged: if (root.menuRect.width > 0) cachedWidth = targetWidth
        
        property real minY: root.menuRect.width > 0 ? targetMinY : cachedMinY
        property real maxY: root.menuRect.width > 0 ? targetMaxY : cachedMaxY
        
        Behavior on minY { enabled: root.menuRect.width > 0; NumberAnimation { duration: Theme.animationDurationFast; easing.type: Easing.OutQuad } }
        Behavior on maxY { enabled: root.menuRect.width > 0; NumberAnimation { duration: Theme.animationDurationFast; easing.type: Easing.OutQuad } }
        
        x: 0
        y: minY
        width: root.menuRect.width > 0 ? targetWidth : cachedWidth
        Behavior on width { enabled: root.menuRect.width > 0; NumberAnimation { duration: Theme.animationDurationFast; easing.type: Easing.OutQuad } }
        
        
        height: maxY - minY
        z: 2
        
        expanded: root.isHovered && root.menuRect.width > 0
        opacity: root.isHovered ? 1.0 : 0.0
        
        property var activeItem: root.hoveredItem || root.lastHoveredItem

        targetR1X: 6
        targetR1Y: activeItem ? activeItem.y - minY : 0
        targetR1W: activeItem ? (root.expanded ? Theme.widgetExpandedWidth - 12 : activeItem.width + 12) : 0
        targetR1H: activeItem ? activeItem.height : 0

        targetR2X: root.menuRect.width > 0 ? root.menuRect.x : targetR1X
        targetR2Y: root.menuRect.width > 0 ? root.menuRect.y - root.y - minY : targetR1Y
        targetR2W: root.menuRect.width > 0 ? root.menuRect.width : targetR1W
        targetR2H: root.menuRect.width > 0 ? root.menuRect.height : targetR1H
        
        radius1: 10
        radius2: 10
        radius3: 14 // SysTray flat side
        bubbleColor: "#ffffff"
    }

    // The menu Blob has been extracted to TrayMenu.qml!
    // This allows both main menus and submenus to use the exact same fade logic.

    function getDisplayName(item) {
        if (!item) return "";
        if (item.title && item.title.length > 0) return item.title;
        
        // Fallback to ID if title is empty
        var id = item.id || "";
        // Clean up common prefixes and suffixes
        var parts = id.split(".");
        var name = parts[parts.length - 1];
        
        // Remove trailing numbers (e.g. StatusNotifierItem-1234-1)
        name = name.replace(/-\d+-\d+$/, "");
        name = name.replace(/StatusNotifierItem$/, "");
        
        // If it's still generic (like chrome_status_icon_1), try to guess from tooltip or icon
        if (name === "" || name === "SNI" || name.startsWith("chrome_status_icon_")) {
            var tooltip = item.tooltipTitle || "";
            
            var mappedName = AppMappings.getAppNameFromTooltip(tooltip);
            if (mappedName) {
                return mappedName;
            }
            
            // If tooltip is short, it might be the app name
            var firstLine = tooltip.split("\n")[0];
            if (firstLine.length > 0 && firstLine.length <= 15) {
                return firstLine;
            }
            
            // Fallback to generic name to avoid overflowing
            return "App";
        }
        
        // Capitalize first letter
        if (name.length > 0) {
            return name.charAt(0).toUpperCase() + name.slice(1);
        }
        
        return name;
    }

    ColumnLayout {
        id: trayLayout
        anchors.fill: root
        spacing: 0
        z: 3

        Repeater {
            model: SystemTray.items
            delegate: Item {
                id: itemRoot
                required property SystemTrayItem modelData

                Layout.alignment: Qt.AlignLeft
                Layout.fillWidth: true
                height: 28

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.preferredWidth: 56
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignVCenter
                        Image {
                            anchors.centerIn: parent
                            source: itemRoot.modelData.icon
                            sourceSize.width: 22
                            sourceSize.height: 22
                            fillMode: Image.PreserveAspectFit
                            width: 22
                            height: 22
                            smooth: true

                            // Only colorize if the icon is explicitly symbolic
                            property bool isSymbolic: String(itemRoot.modelData.icon).includes("-symbolic")
                            layer.enabled: isSymbolic
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowColor: "black"
                                shadowBlur: 1.0
                                shadowOpacity: 0.5
                                shadowVerticalOffset: 2
                                shadowHorizontalOffset: 2
                                colorization: 1.0
                                colorizationColor: Colors.palette.text
                                brightness: 1.0
                                contrast: 1.0
                            }
                        }
                    }

                    StyledText {
                        text: root.getDisplayName(itemRoot.modelData)
                        Layout.fillWidth: true
                        Layout.rightMargin: 12
                        color: Colors.dark.text
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                        // Only show the text if the widget is globally expanded OR if this specific item is hovered
                        opacity: (root.expanded || root.hoveredItem === itemRoot) ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: Theme.animationDuration } }
                        visible: opacity > 0
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    // We bind the icon's hovered state directly to whether the mouse is inside
                    // the item's MouseArea, rather than relying on imperative entered/exited
                    // signals which can fire out of order when adjacent elements overlap or
                    // when the parent structure shifts.
                    onContainsMouseChanged: {
                        if (containsMouse) {
                            root.iconHovered = true;
                            root.lastHoveredItem = itemRoot;
                            root.lastHoveredRect = Qt.rect(itemRoot.x, itemRoot.y, itemRoot.width, itemRoot.height);
                            root.hoveredItem = itemRoot;
                            root.activeMenuModel = itemRoot.modelData.menu ?? null;
                        } else {
                            // Only un-set if THIS item was the one hovered
                            if (root.hoveredItem === itemRoot) {
                                root.iconHovered = false;
                                root.lastHoveredItem = itemRoot;
                                root.lastHoveredRect = Qt.rect(itemRoot.x, itemRoot.y, itemRoot.width, itemRoot.height);
                            }
                        }
                    }

                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) itemRoot.modelData.activate();
                        else if (mouse.button === Qt.RightButton) itemRoot.modelData.contextMenu();
                        else if (mouse.button === Qt.MiddleButton) itemRoot.modelData.secondaryActivate();
                    }
                }
            }
        }
    }

    Loader {
        id: mainMenuLoader
    }

    property bool mainMenuInstantiated: false
    onActiveMenuModelChanged: {
        if (activeMenuModel !== null) {
            if (!mainMenuInstantiated) {
                mainMenuInstantiated = true;
                // Use relative path for component unification
                mainMenuLoader.setSource("../components/TrayMenu.qml", {
                    "isSubmenu": false,
                    "tray": root,
                    "sourceItem": null,
                    "menuModel": null
                });
            }
            
            Qt.callLater(() => {
                if (mainMenuLoader.item) {
                    mainMenuLoader.item.sourceItem = root.hoveredItem;
                    mainMenuLoader.item.menuModel = root.activeMenuModel;
                }
            });
        } else if (mainMenuLoader.item) {
            mainMenuLoader.item.menuModel = null;
        }
    }

    onHoveredItemChanged: {
        if (mainMenuLoader.item && hoveredItem && activeMenuModel !== null) {
            mainMenuLoader.item.sourceItem = hoveredItem;
        }
    }
}
