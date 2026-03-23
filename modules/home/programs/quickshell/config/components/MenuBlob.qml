import QtQuick
import QtQuick.Effects
import Quickshell
import "../services"

// MenuBlob.qml
// Shared background bubble connecting an item to a menu

ShaderEffect {
    id: root

    property bool expanded: false
    property bool allowsAnimation: false

    property string blurGroupId: ""

    // Visually bound to opacity so animations pause when fully invisible
    visible: opacity > 0
    Behavior on opacity {
        NumberAnimation {
            duration: root.expanded ? Theme.animationDurationFast : Theme.animationDurationOut
            easing.type: root.expanded ? Easing.OutQuad : Easing.InQuad
        }
    }

    onVisibleChanged: {
        if (visible)
            Qt.callLater(() => {
                allowsAnimation = true;
            });
        else
            allowsAnimation = false;
        syncBlurRegistration();
    }

    // Input coordinates from parent
    property real targetR1X: 0
    property real targetR1Y: 0
    property real targetR1W: 0
    property real targetR1H: 0

    property real targetR2X: 0
    property real targetR2Y: 0
    property real targetR2W: 0
    property real targetR2H: 0

    // Local cached coordinates for smooth fade outs
    property real cachedR1X: 0
    property real cachedR1Y: 0
    property real cachedR1W: 0
    property real cachedR1H: 0

    property real cachedR2X: 0
    property real cachedR2Y: 0
    property real cachedR2W: 0
    property real cachedR2H: 0

    // Keep cache updated while expanded
    onTargetR1XChanged: {
        if (expanded) {
            cachedR1X = targetR1X;
        } else if (!allowsAnimation) {
            cachedR1X = targetR1X;
        }
    }
    onTargetR1YChanged: {
        if (expanded) {
            cachedR1Y = targetR1Y;
        } else if (!allowsAnimation) {
            cachedR1Y = targetR1Y;
        }
    }
    onTargetR1WChanged: {
        if (expanded) {
            cachedR1W = targetR1W;
        } else if (!allowsAnimation) {
            cachedR1W = targetR1W;
        }
    }
    onTargetR1HChanged: {
        if (expanded) {
            cachedR1H = targetR1H;
        } else if (!allowsAnimation) {
            cachedR1H = targetR1H;
        }
    }
    onTargetR2XChanged: {
        if (expanded) {
            cachedR2X = targetR2X;
        } else if (!allowsAnimation) {
            cachedR2X = targetR2X;
        }
    }
    onTargetR2YChanged: {
        if (expanded) {
            cachedR2Y = targetR2Y;
        } else if (!allowsAnimation) {
            cachedR2Y = targetR2Y;
        }
    }
    onTargetR2WChanged: {
        if (expanded) {
            cachedR2W = targetR2W;
        } else if (!allowsAnimation) {
            cachedR2W = targetR2W;
        }
    }
    onTargetR2HChanged: {
        if (expanded) {
            cachedR2H = targetR2H;
        } else if (!allowsAnimation) {
            cachedR2H = targetR2H;
        }
    }

    onExpandedChanged: {
        if (expanded) {
            cachedR1X = targetR1X;
            cachedR1Y = targetR1Y;
            cachedR1W = targetR1W;
            cachedR1H = targetR1H;
            cachedR2X = targetR2X;
            cachedR2Y = targetR2Y;
            cachedR2W = targetR2W;
            cachedR2H = targetR2H;
        }
    }

    // Display coordinates (active inputs when expanded; cached when collapsing/fading)
    property real r1x: expanded ? targetR1X : cachedR1X
    property real r1y: expanded ? targetR1Y : cachedR1Y
    property real r1w: expanded ? targetR1W : cachedR1W
    property real r1h: expanded ? targetR1H : cachedR1H

    // On collapse, r2 simply uses its cached position so the bubble stays full size while fading out
    property real r2x: expanded ? targetR2X : cachedR2X
    property real r2y: expanded ? targetR2Y : cachedR2Y
    property real r2w: expanded ? targetR2W : cachedR2W
    property real r2h: expanded ? targetR2H : cachedR2H

    property rect rect1: Qt.rect(r1x, r1y, r1w, r1h)
    Behavior on rect1 {
        enabled: root.allowsAnimation
        PropertyAnimation {
            duration: Theme.animationDurationFast
            easing.type: Easing.OutQuad
        }
    }

    Behavior on r2x {
        enabled: root.allowsAnimation
        PropertyAnimation {
            duration: Theme.animationDurationFast
            easing.type: Easing.OutQuad
        }
    }
    Behavior on r2y {
        enabled: root.allowsAnimation
        PropertyAnimation {
            duration: Theme.animationDurationFast
            easing.type: Easing.OutQuad
        }
    }
    Behavior on r2w {
        enabled: root.allowsAnimation
        PropertyAnimation {
            duration: Theme.animationDurationFast
            easing.type: Easing.OutQuad
        }
    }
    Behavior on r2h {
        enabled: root.allowsAnimation
        PropertyAnimation {
            duration: Theme.animationDurationFast
            easing.type: Easing.OutQuad
        }
    }

    property rect rect2: Qt.rect(r2x, r2y, r2w, r2h)
    property rect rect3: Qt.rect(0, 0, 0, 0)

    // Bubble styles
    property real radius1: 8
    property real radius2: 10
    property real radius3: 0 // Used by SysTray main background
    property real radius: 0 // Unused in bubble mode
    property real smoothness: 15.0
    property real useImage: 0.0
    property real recessed: 0
    property variant imageSource: null
    property color baseColor: Colors.alpha(Qt.tint(Colors.light.base, Colors.alpha(Colors.light.text, 0.15)), 0.8)

    property real uWidth: width
    property real uHeight: height

    fragmentShader: Shaders.get("glass")

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "black"
        shadowBlur: 1.0
        shadowOpacity: 0.5
        shadowVerticalOffset: 2
        shadowHorizontalOffset: 2
    }

    property alias r1item: _r1item
    property alias r2item: _r2item
    property alias r3item: _r3item

    // --- Blur Registration ---
    // Extract individual rectangles into items for BlurRegistry
    Item {
        id: _r1item
        x: root.r1x
        y: root.r1y
        width: root.r1w
        height: root.r1h
        visible: width > 0 && height > 0
        property real radius: root.radius1
    }
    Item {
        id: _r2item
        x: root.r2x
        y: root.r2y
        width: root.r2w
        height: root.r2h
        visible: width > 0 && height > 0
        property real radius: root.radius2
    }
    Item {
        id: _r3item
        x: root.rect3.x
        y: root.rect3.y
        width: root.rect3.width
        height: root.rect3.height
        visible: width > 0 && height > 0
        property real radius: root.radius3
    }

    function syncBlurRegistration() {
        if (!blurGroupId)
            return;
        if (opacity > 0.05 && root.visible) {
            RegionRegistry.registerItem(blurGroupId, _r1item);
            RegionRegistry.registerItem(blurGroupId, _r2item);
            RegionRegistry.registerItem(blurGroupId, _r3item);
        } else {
            RegionRegistry.unregisterItem(blurGroupId, _r1item);
            RegionRegistry.unregisterItem(blurGroupId, _r2item);
            RegionRegistry.unregisterItem(blurGroupId, _r3item);
        }
    }

    onOpacityChanged: syncBlurRegistration()
    onBlurGroupIdChanged: syncBlurRegistration()

    Component.onCompleted: syncBlurRegistration()
    Component.onDestruction: {
        if (blurGroupId) {
            RegionRegistry.unregisterItem(blurGroupId, _r1item);
            RegionRegistry.unregisterItem(blurGroupId, _r2item);
            RegionRegistry.unregisterItem(blurGroupId, _r3item);
        }
    }
}
