import QtQuick
import QtQuick.Effects
import "../services"

Item {
    id: root

    // Default opacity from widget bindings
    opacity: 0.0
    property string blurGroupId: ""
    property string maskGroupId: ""
    property real radius: 10
    property alias baseColor: bgRect.baseColor
    property variant imageSource: null

    property string _pendingImageSource: ""

    // Displayed image — drives the shader texture
    Image {
        id: bgImage
        source: ""
        visible: false
        // Fade in once the new source is decoded and ready
        onStatusChanged: {
            if (status === Image.Ready && source !== "")
                bgRect.useImage = 1.0;
        }
    }

    // Cache warmer: pre-fetches the next image so the swap timer hits cache
    Image {
        id: bgImagePreload
        source: ""
        visible: false
        cache: true
    }

    // Mid-crossfade swap: replaces bgImage source after the fade-out has started.
    // Because bgImagePreload already fetched the URL, this is a cache hit.
    Timer {
        id: imageSwapTimer
        interval: Theme.animationDuration / 2
        onTriggered: bgImage.source = root._pendingImageSource
    }

    onImageSourceChanged: {
        root._pendingImageSource = root.imageSource || "";
        if (!root._pendingImageSource) {
            bgRect.useImage = 0.0;
            bgImage.source = "";
            bgImagePreload.source = "";
            return;
        }
        // Warm the cache before the timer fires
        bgImagePreload.source = root._pendingImageSource;
        // Start the crossfade immediately
        if (bgRect.useImage > 0.0) {
            bgRect.useImage = 0.0;
            imageSwapTimer.restart();
        } else {
            bgImage.source = root._pendingImageSource;
        }
    }

    // Blur tracking item - registered ONCE, never unregisters.
    // When hidden, moved offscreen while keeping full dimensions.
    // This keeps it in the region QML (avoiding rebuilds) but excludes from visible blur.
    Item {
        id: blurItem
        visible: false

        property real radius: root.radius

        // Always full dimensions (no rebuild on expand)
        width: root.width
        height: root.height

        // Position: offscreen when hidden, at origin when visible
        x: root.opacity > 0.05 ? 0 : -99999
        y: root.opacity > 0.05 ? 0 : -99999
    }

    ShaderEffect {
        id: bgRect
        anchors.fill: parent

        property real radius: root.radius
        // Passing baseColor with alpha so the shader can determine transparency
        property color baseColor: Colors.alpha(Theme.backdropTint, Theme.backdropOpacity)
        property real uWidth: width
        property real uHeight: height
        property variant imageSource: bgImage
        property real useImage: 0.0

        Behavior on useImage {
            NumberAnimation {
                duration: Theme.animationDuration
                easing.type: Easing.InOutQuad
            }
        }

        // Multi-shape defaults (silence warnings)
        property rect rect1: Qt.rect(0, 0, 0, 0)
        property rect rect2: Qt.rect(0, 0, 0, 0)
        property rect rect3: Qt.rect(0, 0, 0, 0)
        property real radius1: 0
        property real radius2: 0
        property real radius3: 0
        property real smoothness: 0
        property real recessed: 0

        // This opacity determines the overall visible alpha of the entire effect over the background
        opacity: 1.0

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
    }

    function findBlurGroupId(node) {
        if (!node)
            return "";
        if (node.blurGroupId)
            return node.blurGroupId;
        return findBlurGroupId(node.parent);
    }

    function findMaskGroupId(node) {
        if (!node)
            return "";
        if (node.maskGroupId)
            return node.maskGroupId;
        return findMaskGroupId(node.parent);
    }

    Component.onCompleted: {
        // Only auto-discover blurGroupId if not already set externally
        // (e.g., NotificationCard passes "" when blurEnabled is false)
        if (!root.blurGroupId) {
            var gid = findBlurGroupId(root.parent);
            if (gid) {
                root.blurGroupId = gid;
            }
        }
        // Only register if we have a blurGroupId (not empty string)
        if (root.blurGroupId) {
            RegionRegistry.registerItem(root.blurGroupId, blurItem);
        }

        // Only auto-discover maskGroupId if not already set externally
        if (!root.maskGroupId) {
            var mid = findMaskGroupId(root.parent);
            if (mid) {
                root.maskGroupId = mid;
            }
        }
        if (root.maskGroupId) {
            RegionRegistry.registerItem(root.maskGroupId, root);
        }

        if (root.imageSource) {
            root._pendingImageSource = root.imageSource;
            bgImage.source = root.imageSource;
        }
    }

    Component.onDestruction: {
        if (root.blurGroupId) {
            RegionRegistry.unregisterItem(root.blurGroupId, blurItem);
        }
        if (root.maskGroupId) {
            RegionRegistry.unregisterItem(root.maskGroupId, root);
        }
    }
}
