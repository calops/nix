import QtQuick
import QtQuick.Effects
import Quickshell
import "../services"

// MenuBlob.qml
// Shared background bubble connecting an item to a menu

ShaderEffect {
    id: root

    property variant source: null

    property bool expanded: false
    property bool allowsAnimation: false
    
    // Visually bound to opacity so animations pause when fully invisible
    visible: opacity > 0
    Behavior on opacity {
        NumberAnimation { 
            duration: root.expanded ? Theme.animationDurationFast : Theme.animationDurationOut
            easing.type: root.expanded ? Easing.OutQuad : Easing.InQuad 
        }
    }
    
    onVisibleChanged: {
        if (visible) Qt.callLater(() => { allowsAnimation = true; });
        else allowsAnimation = false;
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
    onTargetR1XChanged: { if (expanded) { cachedR1X = targetR1X; } else if (!allowsAnimation) { cachedR1X = targetR1X; } }
    onTargetR1YChanged: { if (expanded) { cachedR1Y = targetR1Y; } else if (!allowsAnimation) { cachedR1Y = targetR1Y; } }
    onTargetR1WChanged: { if (expanded) { cachedR1W = targetR1W; } else if (!allowsAnimation) { cachedR1W = targetR1W; } }
    onTargetR1HChanged: { if (expanded) { cachedR1H = targetR1H; } else if (!allowsAnimation) { cachedR1H = targetR1H; } }
    onTargetR2XChanged: { if (expanded) { cachedR2X = targetR2X; } else if (!allowsAnimation) { cachedR2X = targetR2X; } }
    onTargetR2YChanged: { if (expanded) { cachedR2Y = targetR2Y; } else if (!allowsAnimation) { cachedR2Y = targetR2Y; } }
    onTargetR2WChanged: { if (expanded) { cachedR2W = targetR2W; } else if (!allowsAnimation) { cachedR2W = targetR2W; } }
    onTargetR2HChanged: { if (expanded) { cachedR2H = targetR2H; } else if (!allowsAnimation) { cachedR2H = targetR2H; } }

    onExpandedChanged: {
        if (expanded) {
            cachedR1X = targetR1X; cachedR1Y = targetR1Y; cachedR1W = targetR1W; cachedR1H = targetR1H;
            cachedR2X = targetR2X; cachedR2Y = targetR2Y; cachedR2W = targetR2W; cachedR2H = targetR2H;
        }
    }

    // Display coordinates (active inputs when expanded; cached when collapsing/fading)
    property real r1x: expanded ? targetR1X : cachedR1X
    property real r1y: expanded ? targetR1Y : cachedR1Y
    property real r1w: expanded ? targetR1W : cachedR1W
    property real r1h: expanded ? targetR1H : cachedR1H

    // IMPORTANT: On collapse, r2 shrinks back into r1 so the bubble retracts into its source!
    property real r2x: expanded ? targetR2X : r1x
    property real r2y: expanded ? targetR2Y : r1y
    property real r2w: expanded ? targetR2W : r1w
    property real r2h: expanded ? targetR2H : r1h

    property rect rect1: Qt.rect(r1x, r1y, r1w, r1h)
    Behavior on rect1 {
        enabled: root.allowsAnimation
        PropertyAnimation { duration: Theme.animationDurationFast; easing.type: Easing.OutQuad }
    }

    Behavior on r2x { enabled: root.allowsAnimation; PropertyAnimation { duration: Theme.animationDurationFast; easing.type: Easing.OutQuad } }
    Behavior on r2y { enabled: root.allowsAnimation; PropertyAnimation { duration: Theme.animationDurationFast; easing.type: Easing.OutQuad } }
    Behavior on r2w { enabled: root.allowsAnimation; PropertyAnimation { duration: Theme.animationDurationFast; easing.type: Easing.OutQuad } }
    Behavior on r2h { enabled: root.allowsAnimation; PropertyAnimation { duration: Theme.animationDurationFast; easing.type: Easing.OutQuad } }

    property rect rect2: Qt.rect(r2x, r2y, r2w, r2h)
    property rect rect3: Qt.rect(0, 0, 0, 0)
    
    // Bubble styles
    property real radius1: 8
    property real radius2: 10
    property real radius3: 0 // Used by SysTray main background
    property real smoothness: 15.0
    property color bubbleColor: Qt.tint(Colors.light.base, Colors.alpha(Colors.light.text, 0.15))

    property real uWidth: width
    property real uHeight: height

    fragmentShader: Shaders.get("bubble") ? "file://" + Shaders.get("bubble") : ""

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
