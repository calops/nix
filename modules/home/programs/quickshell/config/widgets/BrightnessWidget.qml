import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import "../services"
import "../services" as Services
import "."

Item {
    id: root
    width: hovered || Niri.overviewActive || (reactive && reactive.active) ? expandedWidth : iconWidth
    height: 50

    property int iconWidth: Theme.iconWidth
    property int expandedWidth: parent ? parent.width : Theme.widgetExpandedWidth

    Behavior on width { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }

    // Theme colors
    property color animIconColor: Colors.dark.text
    property color animBarColor: Colors.dark.yellow // Using yellow/gold for brightness
    property color animBgColor: Colors.dark.surface0

    readonly property int percentage: Services.Brightness.percentage
    property real localPercentage: percentage
    property bool isInteracting: false
    property bool isDragging: false

    Binding {
        target: root
        property: "localPercentage"
        value: percentage
        when: !root.isInteracting
    }

    Behavior on localPercentage {
        id: sliderBehavior
        enabled: !root.isDragging
        NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad }
    }

    Timer {
        id: syncTimer
        interval: 1000
        onTriggered: {
            isInteracting = false;
        }
    }

    ReactiveExpansion {
        id: reactive
        watchValue: percentage
        ignore: hovered || isInteracting
    }

    // Combine hover states to prevent widget collapsing when interacting with slider
    property bool hovered: mouseArea.containsMouse || sliderMouseArea.containsMouse

    MouseArea {
        id: mouseArea
        anchors.fill: background
        hoverEnabled: true
        // Removed imperative onEntered/onExited, using binding above
        
        // Scroll to change brightness
        onWheel: (wheel) => {
            isInteracting = true;
            syncTimer.restart();
            let step = 5;
            let val = localPercentage;
            if (wheel.angleDelta.y < 0) {
                val = Math.max(0, val - step);
            } else {
                val = Math.min(100, val + step);
            }
            localPercentage = val;
            Services.Brightness.setBrightness(val);
        }
    }

    // Shared backdrop component
    HoverBackdrop {
        id: background
        anchors.fill: parent
        anchors.topMargin: -5
        anchors.bottomMargin: -5
        anchors.rightMargin: 6
        anchors.leftMargin: 6
    }

    Row {
        id: row
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0
        height: parent.height

        // Text and Slider Container
        Item {
            id: textContainer
            width: root.width - iconContainer.width
            height: parent.height
            clip: false
            
            RowLayout {
                id: expandedContent
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                opacity: root.hovered || Niri.overviewActive || (reactive && reactive.active) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }

                // Brightness Slider
                Item {
                    id: sliderContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: 26
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    
                    // Track
                    Rectangle {
                        id: track
                        height: 4
                        radius: 2
                        color: Colors.alpha(Colors.dark.subtext1, 0.3)
                        opacity: 1.0
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        
                        // Fill
                        Rectangle {
                            width: parent.width * (root.localPercentage / 100.0)
                            height: parent.height
                            radius: 2
                            color: root.animBarColor
                        }
                    }
                    
                    // Handle
                    Rectangle {
                        id: handle
                        width: 12
                        height: 12
                        radius: 6
                        color: root.animBarColor
                        anchors.verticalCenter: parent.verticalCenter
                        x: (parent.width - width) * (root.localPercentage / 100.0)
                    }

                    MouseArea {
                        id: sliderMouseArea
                        anchors.fill: parent
                        hoverEnabled: true // Enable to keep widget open
                        onPressed: (mouse) => {
                            isInteracting = true;
                            isDragging = true;
                            syncTimer.stop();
                            updateBrightness(mouse);
                        }
                        onPositionChanged: (mouse) => {
                            if (pressed) updateBrightness(mouse);
                        }
                        onReleased: {
                            isDragging = false;
                            syncTimer.restart();
                        }
                        
                        function updateBrightness(mouse) {
                            let val = mouse.x / width * 100;
                            val = Math.max(0, Math.min(100, val));
                            root.localPercentage = val;
                            Services.Brightness.setBrightness(Math.round(val));
                        }
                    }
                }


                // Text Column
                Column {
                    id: textColumn
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.preferredWidth: 45
                    
                    StyledText {
                        text: Math.round(root.localPercentage) + "%"
                        font.pixelSize: 20
                        color: Colors.dark.text
                        anchors.right: parent.right
                    }
                }
            }
        }

        // Icon Container
        Item {
            id: iconContainer
            width: 56
            height: parent.height

            Item {
                id: icon
                width: 22 
                height: 22
                anchors.centerIn: parent
                
                // Sun Body (Outline)
                Rectangle {
                    id: sunBody
                    width: 14
                    height: 14
                    radius: 7
                    color: "transparent"
                    border.width: 2
                    border.color: root.animIconColor
                    anchors.centerIn: parent
                    
                    // Sun Fill (Dynamic Opacity)
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2 // Inside the border
                        radius: width / 2
                        color: root.animIconColor
                        opacity: root.localPercentage / 100.0
                    }
                }

                // Sun Rays
                Repeater {
                    model: 8
                    Item {
                        width: 22
                        height: 2
                        anchors.centerIn: parent
                        rotation: index * 45
                        
                        Rectangle {
                            width: 3
                            height: 2
                            radius: 1
                            color: root.animIconColor
                            anchors.right: parent.right
                        }
                        
                        Rectangle {
                            width: 3
                            height: 2
                            radius: 1
                            color: root.animIconColor
                            anchors.left: parent.left
                        }
                    }
                }
            }
             
             // Overlay to show "fill" level on the icon? 
             // Maybe a circular progress bar around the sun?
             // For simplicity and matching style, let's just use the text percentage and a static icon that matches the theme.
        }
    }
    
    // States for hover
    states: [
        State {
            name: "hovered"
            when: root.hovered || Niri.overviewActive || (reactive && reactive.active)
            PropertyChanges {
                target: background
                opacity: 1.0
            }
            PropertyChanges {
                target: root
                animIconColor: Colors.dark.text
                animBarColor: Colors.light.yellow
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "hovered"
            ParallelAnimation {
                NumberAnimation { target: background; property: "opacity"; to: 1.0; duration: Theme.animationDuration; easing.type: Easing.OutQuad }
                ColorAnimation { target: root; property: "animIconColor"; duration: Theme.animationDuration; easing.type: Easing.OutQuad }
                ColorAnimation { target: root; property: "animBarColor"; duration: Theme.animationDuration; easing.type: Easing.OutQuad }
            }
        },
        Transition {
            from: "hovered"
            to: "*"
            ParallelAnimation {
                NumberAnimation { target: background; property: "opacity"; to: 0.0; duration: Theme.animationDurationOut; easing.type: Easing.InQuad }
                ColorAnimation { target: root; property: "animIconColor"; duration: Theme.animationDurationOut; easing.type: Easing.InQuad }
                ColorAnimation { target: root; property: "animBarColor"; duration: Theme.animationDurationOut; easing.type: Easing.InQuad }
            }
        }
    ]
}
