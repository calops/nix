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

    // Track if blurItem has been registered to avoid double-registration
    property bool _blurRegistered: false

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
    // When hidden, dimensions are 0 to exclude from blur region.
    Item {
        id: blurItem
        anchors.fill: parent
        visible: false

        // Direct binding - no animation to avoid lag
        width: root.opacity > 0.05 ? root.width : 0
        height: root.opacity > 0.05 ? root.height : 0
    }

    // Register blurItem once when blurGroupId is found
    function setupBlurItem(gid) {
        console.log("[HoverBackdrop] setupBlurItem called with gid='" + gid + "'");
        // Only register once, using the group ID passed in
        if (gid && !root._blurRegistered) {
            root._blurRegistered = true;
            console.log("[HoverBackdrop] Registering blurItem for group '" + gid + "'");
            RegionRegistry.registerItem(gid, blurItem);
        }
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

    function syncBlurRegistration() {
        // No-op - blurItem dimensions are bound directly to opacity
    }

    function syncMaskRegistration() {
        if (!maskGroupId)
            return;
        if (opacity > 0.05) {
            RegionRegistry.registerItem(maskGroupId, root);
        } else {
            RegionRegistry.unregisterItem(maskGroupId, root);
        }
    }

    onOpacityChanged: {
        console.log("[HoverBackdrop] onOpacityChanged: " + opacity.toFixed(2));
        syncBlurRegistration();
        syncMaskRegistration();
    }

    Component.onCompleted: {
        console.log("[HoverBackdrop] Component.onCompleted - root.width=" + root.width + " root.height=" + root.height);
        var gid = findBlurGroupId(root.parent);
        console.log("[HoverBackdrop] findBlurGroupId returned: '" + gid + "'");
        if (gid) {
            root.blurGroupId = gid;
            setupBlurItem(gid);
        }
        var mid = findMaskGroupId(root.parent);
        if (mid) {
            root.maskGroupId = mid;
            syncMaskRegistration();
        }
        if (root.imageSource) {
            root._pendingImageSource = root.imageSource;
            bgImage.source = root.imageSource;
        }
    }

    Component.onDestruction: {
        console.log("[HoverBackdrop] Component.onDestruction");
        if (root.blurGroupId && root._blurRegistered) {
            console.log("[HoverBackdrop] Unregistering blurItem for group '" + root.blurGroupId + "'");
            RegionRegistry.unregisterItem(root.blurGroupId, blurItem);
        }
        if (root.maskGroupId) {
            console.log("[HoverBackdrop] Unregistering maskItem for group '" + root.maskGroupId + "'");
            RegionRegistry.unregisterItem(root.maskGroupId, root);
        }
    }
}
