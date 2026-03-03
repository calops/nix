import QtQuick
import QtQuick.Layouts
import "../services"

Item {
    id: root
    
    property real value: 0.0 // 0.0 to 1.0
    property color color: Colors.dark.mauve
    property real contentOpacity: 1.0
    property color trackColor: Colors.dark.subtext1
    property real trackOpacity: 0.3
    property int trackHeight: 8
    property int handleSize: 14
    
    signal moved(real newValue)
    
    readonly property alias pressed: mouseArea.pressed
    readonly property alias containsMouse: mouseArea.containsMouse
    
    // Flatten the entire component into a single layer.
    // This allows children to occlude each other (if they are opaque) 
    // before the entire combined result is rendered with the specified opacity.
    layer.enabled: true
    opacity: contentOpacity
    
    implicitHeight: Math.max(trackHeight, handleSize)
    implicitWidth: 100
    
    // 1. Inactive Part (Track) - full width
    Rectangle {
        id: track
        width: parent.width
        height: root.trackHeight
        radius: height / 2
        color: Colors.alpha("#ffffff", root.containsMouse ? 0.14 : 0.08)
        anchors.verticalCenter: parent.verticalCenter
        
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: Colors.alpha("#ffffff", root.containsMouse ? 0.35 : 0.25)
        }
        Behavior on color { ColorAnimation { duration: 150 } }
    }
    
    // 2. Active Part (Fill) - opaque to occlude the track underneath
    Rectangle {
        id: fill
        width: (parent.width - root.handleSize) * root.value + root.handleSize / 2
        height: root.trackHeight
        radius: height / 2
        color: root.color
        anchors.verticalCenter: parent.verticalCenter
        
        // Inner Gloss Gradient
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Colors.alpha("#ffffff", 0.3) }
                GradientStop { position: 0.5; color: "transparent" }
                GradientStop { position: 1.0; color: Colors.alpha("#000000", 0.2) }
            }
        }
    }
    
    // 3. Handle (Dot) - opaque to occlude both track and fill
    Rectangle {
        id: handle
        width: root.handleSize
        height: root.handleSize
        radius: width / 2
        color: root.color
        anchors.verticalCenter: parent.verticalCenter
        x: (parent.width - width) * root.value
        
        // Inner Gloss Gradient
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Colors.alpha("#ffffff", 0.45) }
                GradientStop { position: 0.5; color: "transparent" }
                GradientStop { position: 1.0; color: Colors.alpha("#000000", 0.3) }
            }
        }
        
        // Add a subtle glass border to the handle
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: Colors.alpha("#ffffff", 0.4)
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        function updateFromMouse(mouse) {
            let newValue = mouse.x / width;
            newValue = Math.max(0, Math.min(1, newValue));
            root.moved(newValue);
        }
        
        onPressed: (mouse) => updateFromMouse(mouse)
        onPositionChanged: (mouse) => {
            if (pressed) updateFromMouse(mouse)
        }
    }
}
