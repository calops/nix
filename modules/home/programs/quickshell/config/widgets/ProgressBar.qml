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
    
    // Transition point: center of the handle
    readonly property real centerPos: (width - handleSize) * root.value + handleSize / 2
    
    implicitHeight: Math.max(trackHeight, handleSize)
    implicitWidth: 100
    
    // Inactive Part (Track) - starts from the center of the handle to avoid overlap
    Rectangle {
        id: track
        x: root.centerPos
        width: Math.max(0, parent.width - x)
        height: root.trackHeight
        radius: height / 2
        color: root.trackColor
        opacity: root.trackOpacity
        anchors.verticalCenter: parent.verticalCenter
    }
    
    // Active Part (Fill + Handle) - flattened to allow unified transparency
    Item {
        id: progressLayer
        anchors.fill: parent
        opacity: root.contentOpacity
        layer.enabled: true
        
        // Fill portion - ends at the center of the handle
        Rectangle {
            id: fill
            width: root.centerPos
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
            x: (parent.width - width) * root.value
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
