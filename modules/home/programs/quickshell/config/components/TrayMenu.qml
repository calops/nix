import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
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
    property var parentWindow: null // The PanelWindow this menu anchors to

    property string blurGroupId: "trayMenu_" + root

    // Directional anchoring: Main menus grow right from the tray, submenus grow right from the item
    anchor.window: isSubmenu ? parentMenu : parentWindow

    property rect cachedAnchorRect: Qt.rect(0, 0, 0, 0)

    Connections {
        target: root.sourceItem
        function onXChanged() {
            if (root.shouldShow)
                root.updateAnchorCache();
        }
        function onYChanged() {
            if (root.shouldShow)
                root.updateAnchorCache();
        }
        function onWidthChanged() {
            if (root.shouldShow)
                root.updateAnchorCache();
        }
        function onHeightChanged() {
            if (root.shouldShow)
                root.updateAnchorCache();
        }
    }

    function updateAnchorCache() {
        if (!sourceItem || !parentWindow || !tray)
            return;

        if (isSubmenu) {
            cachedAnchorRect = Qt.rect(sourceItem.x + 8 + sourceItem.width, sourceItem.y + 2, 0, 0);
        } else {
            var pos = sourceItem.mapToItem(parentWindow.contentItem, 0, 0);
            cachedAnchorRect = Qt.rect(tray.expanded ? 248 : 45, pos.y, menuContent.implicitWidth + 16, menuContent.implicitHeight);
        }
    }

    anchor.rect: {
        if (!sourceItem || !shouldShow)
            return cachedAnchorRect;

        if (isSubmenu) {
            // Anchor to the RIGHT edge of the active item!
            return Qt.rect(sourceItem.x + 8 + sourceItem.width, sourceItem.y + 2, 0, 0);
        } else {
            // Main menu anchors to the tray item
            var pos = sourceItem.mapToItem(parentWindow.contentItem, 0, 0);

            // Adjust the x offset dynamically to bridge the gap properly!
            // When not expanded, it anchors near the left edge
            return Qt.rect(tray.expanded ? 248 : 45, pos.y, menuContent.implicitWidth + 16, menuContent.implicitHeight);
        }
    }

    anchor.gravity: Edges.Right | Edges.Bottom
    anchor.edges: Edges.Left | Edges.Top
    color: "transparent"

    // Decouple visibility from opacity to allow fade-out
    property bool shouldShow: menuModel !== null && sourceItem !== null

    // Simplified visibility logic:
    // Window is mapped if we have a model OR if we are still fading out.
    visible: shouldShow || menuContentWrapper.opacity > 0

    // Calculate the base size required just for this menu's immediate content
    // We cache this because when menuModel becomes null, implicit sizes drop to 0 instantly,
    // which breaks the fade-out geometry!
    property real cachedBaseWidth: 0
    property real cachedBaseHeight: 0

    // Update caches while the menu is active
    onShouldShowChanged: {
        if (shouldShow) {
            updateAnchorCache();
            updateSizeCache();
        }
    }

    Connections {
        target: menuContentWrapper
        function onImplicitWidthChanged() {
            if (root.shouldShow)
                root.updateSizeCache();
        }
        function onImplicitHeightChanged() {
            if (root.shouldShow)
                root.updateSizeCache();
        }
    }

    function updateSizeCache() {
        if (!root.shouldShow)
            return;
        cachedBaseWidth = Math.min(isSubmenu ? 250 : 300, menuContentWrapper.implicitWidth + 16);
        cachedBaseHeight = menuContentWrapper.implicitHeight + 8;
    }

    property real baseWidth: shouldShow ? Math.min(isSubmenu ? 250 : 300, menuContentWrapper.implicitWidth + 16) : cachedBaseWidth
    property real baseHeight: shouldShow ? (menuContentWrapper.implicitHeight + 8) : cachedBaseHeight

    // Expand the bounding Wayland surface to a fixed maximum size.
    // This provides a massive invisible canvas so the popup doesn't have to dynamically resize (and jitter)
    // when a submenu opens. The background wrapper uses `baseWidth`, leaving this extra padded space purely transparent!
    implicitWidth: 1000
    implicitHeight: Math.max(baseHeight, 800)

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

    // Track child menu hover state safely to fix the hover collapse!
    property bool isChildMenuHovered: childMenu !== null && childMenu.isHovered
    property bool isHovered: menuBgMouseArea.containsMouse || isChildMenuHovered

    Timer {
        id: closeSubmenuTimer
        // Reduced from 100ms. 40ms is just enough to catch diagonal mouse movements into the submenu
        // without causing the text to artificially hang around when actually leaving.
        interval: 40
        onTriggered: {
            if (root.activeSubMenuData !== null) {
                let itemHovered = root.activeSubMenuItem !== null && root.activeSubMenuItem.itemHovered;
                if (!root.isChildMenuHovered && !itemHovered) {
                    root.activeSubMenuData = null;
                    root.activeSubMenuItem = null;
                }
            }
        }
    }

    onIsChildMenuHoveredChanged: {
        if (!isChildMenuHovered)
            closeSubmenuTimer.restart();
    }

    Item {
        id: menuContentWrapper
        // Force concrete sizes so the Wayland layout isn't a circular dependency that clips the bubble!
        width: root.implicitWidth
        height: root.implicitHeight
        implicitWidth: menuContent.implicitWidth
        implicitHeight: menuContent.implicitHeight

        opacity: root.shouldShow ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                id: menuFadeOut
                // Fade in slightly slower than the bubble (150ms) to let it stretch,
                // but fade out extremely fast (50ms) so text disappears before the bubble collapses.
                duration: root.shouldShow ? 220 : 50
                easing.type: root.shouldShow ? Easing.InOutQuad : Easing.OutQuad
            }
        }

        // Background Blob connecting exactly this menu's active item to its child submenu
        MenuBlob {
            id: submenuBlob
            width: root.implicitWidth
            height: root.implicitHeight
            z: -1

            expanded: root.activeSubMenuData !== null && root.childMenu && root.childMenu.shouldShow
            opacity: expanded ? 1.0 : 0.0

            targetR1X: root.activeSubMenuItem ? root.activeSubMenuItem.x + 8 : 0
            targetR1Y: root.activeSubMenuItem ? root.activeSubMenuItem.y + 2 : 0
            targetR1W: root.activeSubMenuItem ? root.activeSubMenuItem.width : 0
            targetR1H: root.activeSubMenuItem ? root.activeSubMenuItem.height : 0

            targetR2X: (root.activeSubMenuItem && root.childMenu) ? root.activeSubMenuItem.x + 8 + root.activeSubMenuItem.width : targetR1X
            targetR2Y: targetR1Y
            // Ensure childMenu base dimensions are mapped securely
            targetR2W: (root.childMenu && root.childMenu.baseWidth) ? root.childMenu.baseWidth : 0
            targetR2H: (root.childMenu && root.childMenu.baseHeight) ? root.childMenu.baseHeight : 0

            radius3: 0
            blurGroupId: "toto"
        }

        MouseArea {
            id: menuBgMouseArea
            width: root.baseWidth
            height: root.baseHeight
            hoverEnabled: true

            property real radius: 10

            Component.onDestruction: {
                if (containsMouse && tray) {
                    tray.menuHoverCount--;
                }
            }
            // Extremely critical: if the parent tray's expanded state collapses, the Wayland anchor X coordinate
            // recalculates instantly. If this shifts the fading surface under the user's cursor again, it creates an infinite feedback loop!
            enabled: tray ? tray.expanded : true

            onContainsMouseChanged: {
                if (tray) {
                    if (containsMouse)
                        tray.menuHoverCount++;
                    else
                        tray.menuHoverCount--;
                }
            }

            acceptedButtons: Qt.NoButton

            ColumnLayout {
                id: menuContent
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: 8
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
                        if (root.menuModel && root.shouldShow) {
                            menuContent.opacity = 0.0;
                            menuContentFadeIn.restart();
                        }
                    }
                }

                Repeater {
                    model: menuOpener.children

                    delegate: Item {
                        id: menuItem
                        required property var modelData

                        property bool itemHovered: itemMouse.containsMouse

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
                                    property variant source: parent
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
                                if (containsMouse) {
                                    if (modelData.hasChildren) {
                                        root.activeSubMenuData = modelData;
                                        root.activeSubMenuItem = menuItem;
                                    } else {
                                        closeSubmenuTimer.restart();
                                    }
                                } else {
                                    closeSubmenuTimer.restart();
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
                    "parentWindow": root.parentWindow,
                    "sourceItem": null,
                    "menuModel": null,
                    "blurGroupId": root.blurGroupId
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
}
