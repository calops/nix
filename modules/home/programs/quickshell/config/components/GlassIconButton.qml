import QtQuick
import QtQuick.Layouts
import "../services"

Rectangle {
    id: root
    
    property string icon: ""
    property color iconColor: Colors.dark.text
    property int iconSize: 14
    property bool isActive: false
    property alias hovered: btnMouseArea.containsMouse
    
    signal clicked()

    Layout.fillWidth: true
    Layout.preferredHeight: 36
    radius: 8

    // Glass Neumorphic Base
    color: Colors.alpha("#ffffff", isActive ? 0.2 : (hovered ? 0.22 : 0.08))
    
    // Define the glass edges with a subtle white border
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: 1
        border.color: Colors.alpha("#ffffff", isActive ? 0.15 : (hovered ? 0.45 : 0.25))
    }

    // True Neumorphic Relief
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        opacity: 0.5
        gradient: Gradient {
            GradientStop { 
                position: 0.0
                color: root.isActive ? Colors.alpha("#ffffff", 0.1) : Colors.alpha("#ffffff", 0.8) 
            }
            GradientStop { position: 0.5; color: "transparent" }
            GradientStop { 
                position: 1.0
                color: root.isActive ? Colors.alpha("#ffffff", 0.8) : Colors.alpha("#ffffff", 0.1) 
            }
        }
    }
    
    StyledText {
        anchors.centerIn: parent
        text: root.icon
        font.pixelSize: root.iconSize
        color: root.iconColor
        Behavior on color { ColorAnimation { duration: Theme.animationDuration } }
    }
    
    MouseArea {
        id: btnMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    Behavior on color { ColorAnimation { duration: Theme.animationDurationFast } }
}
