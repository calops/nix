import QtQuick
import QtQuick.Effects
import "../services"

Item {
    id: root
    
    // Default opacity from widget bindings
    opacity: 0.0
    property string blurGroupId: ""
    property real radius: 10

    ShaderEffect {
        id: bgRect
        anchors.fill: parent
        
        property real radius: root.radius
        // Passing baseColor with alpha so the shader can determine transparency
        property color baseColor: Colors.alpha(Theme.backdropTint, Theme.backdropOpacity)
        property real uWidth: width
        property real uHeight: height
        
        // This opacity determines the overall visible alpha of the entire effect over the background
        opacity: 1.0

        fragmentShader: Qt.resolvedUrl("shaders/glass.frag.qsb")

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
        if (!node) return "";
        if (node.blurGroupId) return node.blurGroupId;
        return findBlurGroupId(node.parent);
    }

    function syncBlurRegistration() {
        if (!blurGroupId) return;
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
