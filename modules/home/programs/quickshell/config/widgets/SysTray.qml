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
        interval: 150
        running: !root.isHovered
        onTriggered: {
            if (root.activeMenuModel !== null) {
                root.hoveredItem = null;
                root.activeMenuModel = null;
            }
        }
    }
    property rect menuRect: Qt.rect(0, 0, 0, 0)





    ShaderEffect {
        id: bubbleBackground
        
        // Dynamically expand the shader bounds to cover both the tray icons and the menu
        // We must subtract root.y from menuRect.y to bring it into the tray's local coordinate system!
        property real minY: root.menuRect.width > 0 ? Math.min(0, (root.menuRect.y - root.y) - 12) : 0
        property real maxY: root.menuRect.width > 0 ? Math.max(parent.height, (root.menuRect.y - root.y) + root.menuRect.height + 12) : parent.height
        
        Behavior on minY { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }
        Behavior on maxY { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }
        
        x: 0
        y: minY
        width: root.menuRect.width > 0 ? root.menuRect.x + root.menuRect.width + 12 : (root.expanded ? root.width : 56)
        Behavior on width { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }
        
        height: maxY - minY
        z: 2
        visible: opacity > 0
        property bool allowsAnimation: false
        onVisibleChanged: {
            if (visible) {
                Qt.callLater(() => { allowsAnimation = true; });
            } else {
                allowsAnimation = false;
            }
        }

        // Active item is only the currently hovered item, or the last one if we are fading out
        property var activeItem: root.hoveredItem || root.lastHoveredItem
        property rect rect1: {
            if (!activeItem) return Qt.rect(0, 0, 0, 0);
            
            // If actively hovered, map perfectly to its bounds
            if (root.hoveredItem !== null) {
                return Qt.rect(6, activeItem.y - minY, 
                              (root.expanded ? root.width - 12 : activeItem.width + 12), 
                              activeItem.height);
            }
            
            // If fading out or in transition gap, use the cached rectangle so it doesn't jump
            // if the layout shifts or active item parameters become unstable
            if (bubbleBackground.opacity > 0) {
               return Qt.rect(6, root.lastHoveredRect.y - minY,
                              (root.expanded ? root.width - 12 : root.lastHoveredRect.width + 12),
                              root.lastHoveredRect.height);
            }
            
            // Closed/Collapsed center dot state
            return Qt.rect(root.lastHoveredRect.x + root.lastHoveredRect.width / 2,
                           root.lastHoveredRect.y + root.lastHoveredRect.height / 2 - minY, 
                           0, 0);
        }
            
        Behavior on rect1 {
            enabled: bubbleBackground.allowsAnimation
            PropertyAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad }
        }
            
        // When menu is closed, rect2 = rect1 so it smoothly grows out of/into the icon
        property real targetR1X: {
            if (!activeItem) return 0;
            if (root.hoveredItem !== null) return 6;
            if (bubbleBackground.opacity > 0) return 6;
            return root.lastHoveredRect.x + root.lastHoveredRect.width / 2;
        }
        
        property real targetR1W: {
            if (!activeItem) return 0;
            if (root.hoveredItem !== null) return (root.expanded ? root.width - 12 : activeItem.width + 12);
            if (bubbleBackground.opacity > 0) return (root.expanded ? root.width - 12 : root.lastHoveredRect.width + 12);
            return 0;
        }
        
        property real targetR1H: {
            if (!activeItem) return 0;
            if (root.hoveredItem !== null) return activeItem.height;
            if (bubbleBackground.opacity > 0) return root.lastHoveredRect.height;
            return 0;
        }

        property real r2x: (root.menuRect.width > 0 && bubbleBackground.allowsAnimation) ? root.menuRect.x : targetR1X
        property real r2w: (root.menuRect.width > 0 && bubbleBackground.allowsAnimation) ? root.menuRect.width : targetR1W
        property real r2h: (root.menuRect.width > 0 && bubbleBackground.allowsAnimation) ? root.menuRect.height : targetR1H

        Behavior on r2x { enabled: bubbleBackground.allowsAnimation; PropertyAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }
        Behavior on r2w { enabled: bubbleBackground.allowsAnimation; PropertyAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }
        Behavior on r2h { enabled: bubbleBackground.allowsAnimation; PropertyAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }

        property rect rect2: Qt.rect(r2x, rect1.y, r2w, r2h)
        property rect rect3: Qt.rect(0, 0, 0, 0)
        property real radius1: 10
        property real radius2: 10
        property real radius3: 14
        property real smoothness: 15.0
        property color bubbleColor: "#ffffff"
        property real uWidth: bubbleBackground.width
        property real uHeight: bubbleBackground.height

        // Entire visibility tied directly to isHovered to match subMenuBlob pattern
        opacity: root.isHovered ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: root.isHovered ? Theme.animationDuration : Theme.animationDurationOut; easing.type: root.isHovered ? Easing.OutQuad : Easing.InQuad }
        }

        fragmentShader: Qt.resolvedUrl("../components/shaders/bubble.frag.qsb")

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
                            if (bubbleBackground.opacity === 0) {
                                root.lastHoveredItem = itemRoot;
                                root.lastHoveredRect = Qt.rect(itemRoot.x, itemRoot.y, itemRoot.width, itemRoot.height);
                            }
                            root.hoveredItem = itemRoot;
                            root.lastHoveredRect = Qt.rect(itemRoot.x, itemRoot.y, itemRoot.width, itemRoot.height);
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

}
