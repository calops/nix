import QtQuick
import Quickshell
import "../services"

Item {
    id: root
    width: hovered || Niri.overviewActive ? expandedWidth : iconWidth
    height: 80

    property int iconWidth: Theme.iconWidth
    property int expandedWidth: parent ? parent.width : Theme.widgetExpandedWidth

    Behavior on width { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }
    
    property bool hovered: mouseArea.containsMouse
    
    // Dynamic theme colors (Latte on hover, Catppuccin Macchiato/Dark otherwise)
    property color animTextColor: Colors.dark.text
    property color animSubtextColor: Colors.dark.subtext0
    property color animOverlayColor: Colors.dark.overlay0
    
    MouseArea {
        id: mouseArea
        anchors.fill: backdrop
        hoverEnabled: true
    }
    
    // Shared backdrop component
    HoverBackdrop {
        id: backdrop
        anchors.fill: parent
        anchors.topMargin: -10
        anchors.bottomMargin: -10
        anchors.leftMargin: 6
        anchors.rightMargin: 6
    }
    
    Row {
        id: mainRow
        anchors.left: parent.left
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0
        
        // Clock Column (Always Visible - behaves as the "Icon")
        Item {
            id: clockContainer
            width: 56 // Matches the sidebar standard width
            height: parent.height
            
            Column {
                id: clockColumn
                anchors.centerIn: parent
                spacing: -4
                
                StyledText {
                    text: Datetime.hours
                    color: root.animTextColor
                    font.pixelSize: 20
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                StyledText {
                    text: Datetime.minutes
                    color: root.animSubtextColor
                    font.pixelSize: 20
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                StyledText {
                    text: Datetime.seconds
                    color: root.animOverlayColor
                    font.pixelSize: 20
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
        
        // Date Container (Revealed on hover)
        Item {
            id: dateContainer
            width: root.width - clockContainer.width
            height: parent.height
            clip: true
            
            Column {
                id: dateColumn
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                
                StyledText {
                    text: Datetime.date ? Datetime.date.toLocaleDateString(Qt.locale(), "dddd") : ""
                    color: root.animTextColor
                    font.pixelSize: 14
                    font.bold: true
                }
                StyledText {
                    text: Datetime.date ? Datetime.date.toLocaleDateString(Qt.locale(), "d MMMM") : ""
                    color: root.animSubtextColor
                    font.pixelSize: 13
                }

                Row {
                    id: weatherRow
                    spacing: 12
                    anchors.left: parent.left
                    
                    StyledText {
                        text: Weather.icon
                        color: root.animTextColor
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: Math.round(Weather.temp) + "°"
                        color: root.animSubtextColor
                        font.pixelSize: 14
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: " " + Weather.humidity + "%"
                        color: root.animOverlayColor
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
    
    states: [
        State {
            name: "hovered"
            when: root.hovered || Niri.overviewActive
            PropertyChanges {
                target: backdrop
                opacity: 1.0
            }
            PropertyChanges {
                target: root
                animTextColor: Colors.dark.text
                animSubtextColor: Colors.dark.subtext1
                animOverlayColor: Colors.dark.subtext0
            }
        }
    ]
    
    transitions: [
        Transition {
            from: "*"
            to: "hovered"
            ParallelAnimation {
                NumberAnimation { target: backdrop; property: "opacity"; to: 1.0; duration: Theme.animationDuration; easing.type: Easing.OutQuad }
                ColorAnimation { target: root; property: "animTextColor"; duration: Theme.animationDuration; easing.type: Easing.OutQuad }
                ColorAnimation { target: root; property: "animSubtextColor"; duration: Theme.animationDuration; easing.type: Easing.OutQuad }
                ColorAnimation { target: root; property: "animOverlayColor"; duration: Theme.animationDuration; easing.type: Easing.OutQuad }
            }
        },
        Transition {
            from: "hovered"
            to: "*"
            ParallelAnimation {
                NumberAnimation { target: backdrop; property: "opacity"; to: 0.0; duration: Theme.animationDurationOut; easing.type: Easing.InQuad }
                ColorAnimation { target: root; property: "animTextColor"; duration: Theme.animationDurationOut; easing.type: Easing.InQuad }
                ColorAnimation { target: root; property: "animSubtextColor"; duration: Theme.animationDurationOut; easing.type: Easing.InQuad }
                ColorAnimation { target: root; property: "animOverlayColor"; duration: Theme.animationDurationOut; easing.type: Easing.InQuad }
            }
        }
    ]
}
