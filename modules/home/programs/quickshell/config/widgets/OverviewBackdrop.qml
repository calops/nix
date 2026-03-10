import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"
import "../components"

PanelWindow {
    id: root
    
    
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
        visible: Shaders.backdropReady
        
        property variant source: null
        property real uTime: 0
        property color baseColor: Colors.palette.base
        property color accentColor: Colors.palette.teal
        property real uWidth: width
        property real uHeight: height
        
        // The shader manages its own compiled state now within Shaders singleton
        fragmentShader: Shaders.backdrop ? "file://" + Shaders.backdrop : ""
        
        // This animation drives the uTime variable in the shader
        NumberAnimation on uTime {
            from: 0
            to: 100000
            duration: 100000000
            loops: Animation.Infinite
            running: true
        }
        
        // Ensure standard opacity behavior
        opacity: root.visible ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.InOutQuad }
        }
    }
}
