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
    property int trackHeight: 4
    property int handleSize: 12
    
    signal moved(real newValue)
    
    readonly property alias pressed: mouseArea.pressed
    readonly property alias containsMouse: mouseArea.containsMouse
    
    implicitHeight: Math.max(trackHeight, handleSize)
    implicitWidth: 100
    
    // Background Track
    Rectangle {
        id: track
        width: parent.width
        height: root.trackHeight
        radius: height / 2
        color: root.trackColor
        opacity: root.trackOpacity
        anchors.verticalCenter: parent.verticalCenter
    }
    
    // Fill and Handle (Layered to merge transparency)
    Item {
        id: progressLayer
        anchors.fill: parent
        opacity: root.contentOpacity
        layer.enabled: true
        
        // Fill portion
        Rectangle {
            id: fill
            width: parent.width * Math.min(1.0, Math.max(0.0, root.value))
            height: root.trackHeight
            radius: height / 2
            color: root.color
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // Handle (Dot)
        Rectangle {
            id: handle
            width: root.handleSize
            height: root.handleSize
            radius: width / 2
            color: root.color
            anchors.verticalCenter: parent.verticalCenter
            x: (parent.width - width) * Math.min(1.0, Math.max(0.0, root.value))
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
