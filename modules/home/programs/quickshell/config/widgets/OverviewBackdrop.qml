import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"
import "../components"

PanelWindow {
    id: root
    visible: true
    WlrLayershell.namespace: "niri-backdrop"
    WlrLayershell.layer: WlrLayershell.Background
    // Cover the whole screen
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    // Don't reserve space
    exclusionMode: ExclusionMode.Ignore
    
    color: "transparent"
    

    ShaderEffect {
        id: bgEffect
        anchors.fill: parent
        // Only render when the backdrop is compiled AND we are either in overview or fading out
        visible: Shaders.backdropReady && (Niri.overviewActive || opacity > 0.01)
        
        property variant source: null
        property real uTime: 0
        property color baseColor: Colors.palette.base
        property color accentColor: Colors.palette.teal
        property real uWidth: width
        property real uHeight: height
        
        // The shader manages its own compiled state now within Shaders singleton
        fragmentShader: Shaders.backdrop ? "file://" + Shaders.backdrop : ""
        
        // Disable animation when not visible to save resources
        NumberAnimation on uTime {
            from: 0
            to: 100000
            duration: 100000000
            loops: Animation.Infinite
            running: bgEffect.visible
        }
        
        // Ensure standard opacity behavior
        // Fade in when overview is active
        opacity: Niri.overviewActive ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.InOutQuad }
        }
    }
}
