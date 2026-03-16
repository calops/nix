import QtQuick
import QtQuick.Effects
import "../services"

Item {
    id: root

    // Default opacity from widget bindings
    opacity: 0.0
    property string blurGroupId: ""
    property real radius: 10
    property alias baseColor: bgRect.baseColor
    property variant imageSource: null

    Image {
        id: bgImage
        source: root.imageSource || ""
        visible: false
    }

    ShaderEffect {
        id: bgRect
        anchors.fill: parent

        property variant source: null
        property real radius: root.radius
        // Passing baseColor with alpha so the shader can determine transparency
        property color baseColor: Colors.alpha(Theme.backdropTint, Theme.backdropOpacity)
        property real uWidth: width
        property real uHeight: height
        property variant imageSource: bgImage
        property real useImage: root.imageSource && bgImage.status === Image.Ready ? 1.0 : 0.0

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

    function syncBlurRegistration() {
        if (!blurGroupId)
            return;
        // Use 0.05 instead of > 0.0 to prevent floating-point NumberAnimation
        // lingering bugs from permanently keeping the blur region registered.
        if (opacity > 0.05) {
            BlurRegistry.registerItem(blurGroupId, root);
        } else {
            BlurRegistry.unregisterItem(blurGroupId, root);
        }
    }

    onOpacityChanged: syncBlurRegistration()

    Component.onCompleted: {
        var gid = findBlurGroupId(root.parent);
        if (gid) {
            root.blurGroupId = gid;
            syncBlurRegistration();
        }
    }

    Component.onDestruction: {
        if (root.blurGroupId) {
            BlurRegistry.unregisterItem(root.blurGroupId, root);
        }
    }
}
