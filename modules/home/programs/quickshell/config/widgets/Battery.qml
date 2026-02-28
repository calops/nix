import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "../services"

Item {
    id: root
    width: hovered || Niri.overviewActive ? expandedWidth : iconWidth
    height: 50

    property int iconWidth: Theme.iconWidth
    property int expandedWidth: parent ? parent.width : Theme.widgetExpandedWidth

    Behavior on width { NumberAnimation { id: widthAnim; duration: Theme.animationDuration; easing.type: Easing.OutQuad } }

    // Dynamic theme switching: Animated colors
    property color animIconColor: Colors.dark.text
    property color animRedColor: Colors.dark.red
    property color animChargingColor: Colors.dark.base
    // animBoltColor is no longer used for a separate icon, but we keep it if needed or remove it.
    // The user requested monochrome inversion, so we'll strictly use iconColor and chargingColor (background).


    // Hover state handling
    property bool hovered: false

    // UPower integration: Mapping built-in service to UI variables
    readonly property real batteryPercentage: (UPower.displayDevice?.percentage ?? 0) * 100
    readonly property bool isCharging: {
        const state = UPower.displayDevice?.state;
        return state === UPowerDeviceState.Charging || state === UPowerDeviceState.FullyCharged;
    }

    onIsChargingChanged: {
        if (isCharging) {
            PowerProfiles.profile = PowerProfile.Balanced;
        } else {
            PowerProfiles.profile = PowerProfile.PowerSaver;
        }
    }
    
    readonly property string timeEstimate: {
        const device = UPower.displayDevice;
        if (!device) return "";
        if (device.state === UPowerDeviceState.FullyCharged) return "Full";
        
        // Use timeToFull if charging, otherwise fallback to timeToEmpty for discharge/pending
        let seconds = (device.state === UPowerDeviceState.Charging) ? device.timeToFull : device.timeToEmpty;
        
        if (seconds <= 0) return "";
        return durationToText(seconds);
    }

    function durationToText(seconds) {
        const h = Math.floor(seconds / 3600);
        const m = Math.floor((seconds % 3600) / 60);
        return h + "h " + m + "m";
    }

    readonly property string powerProfileText: {
        const p = PowerProfiles.profile;
        if (p === PowerProfile.PowerSaver) return "Power Saver";
        if (p === PowerProfile.Balanced) return "Balanced";
        if (p === PowerProfile.Performance) return "Performance";
        return "";
    }

    readonly property int profileStepIndex: {
        const p = PowerProfiles.profile;
        if (p === PowerProfile.PowerSaver) return 0;
        if (p === PowerProfile.Balanced) return 1;
        if (p === PowerProfile.Performance) return 2;
        return 1;
    }

    readonly property color activeProfileColor: {
        const p = PowerProfiles.profile;
        if (p === PowerProfile.PowerSaver) return Colors.light.green;
        if (p === PowerProfile.Balanced) return Colors.light.blue;
        if (p === PowerProfile.Performance) return Colors.light.red;
        return Colors.dark.subtext0;
    }

    MouseArea {
        id: mouseArea
        anchors.fill: background // Constrain hover area to the visual backdrop
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited: root.hovered = false
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
        anchors.rightMargin: 0
        
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0 // Spacing handled by text container margin
        
        // Stabilize height to parent
        height: parent.height

        // Percentage, Time, and Profile Selector Container
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
                opacity: root.hovered || Niri.overviewActive ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }
                
                // Power Profile Slider Selector
                Item {
                    id: profileSelector
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.fillWidth: true
                    height: parent.height
                    clip: false

                    Column {
                        anchors.centerIn: parent
                        width: parent.width
                        spacing: 0 // Reduced from 2 for tighter layout

                        Item {
                            width: parent.width
                            height: 14 // Reduced from 16
                            
                            Repeater {
                                model: [
                                    { icon: "", profile: PowerProfile.PowerSaver },
                                    { icon: "⚖", profile: PowerProfile.Balanced },
                                    { icon: "", profile: PowerProfile.Performance }
                                ]
                                Item {
                                    width: 30
                                    height: parent.height
                                    // Center precisely on the dot positions (dots are 8px wide)
                                    x: (index * (parent.width - 8) / 2 + 4) - width/2
                                    
                                    StyledText {
                                        text: modelData.icon
                                        font.pixelSize: 14
                                        anchors.centerIn: parent
                                        color: root.profileStepIndex === index ? root.activeProfileColor : Colors.dark.subtext0
                                        opacity: 1.0
                                        Behavior on color { ColorAnimation { duration: Theme.animationDuration } }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: PowerProfiles.profile = modelData.profile
                                    }
                                }
                            }
                        }

                        // Row 2: Slider Line (Track, Dots, Handle)
                        Item {
                            width: parent.width
                            height: 12

                            // Line and Dots (Background Layer)
                            Item {
                                anchors.fill: parent
                                opacity: 0.2
                                layer.enabled: true
                                
                                Rectangle {
                                    id: sliderTrack
                                    width: parent.width
                                    height: 4
                                    radius: 2
                                    color: Colors.dark.subtext1
                                    anchors.centerIn: parent
                                }

                                Repeater {
                                    model: 3
                                    Rectangle {
                                        width: 8; height: 8; radius: 4
                                        color: Colors.dark.subtext1
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: index * (parent.width - width) / 2
                                    }
                                }
                            }

                            // Moving Handle (Foreground Layer)
                            Rectangle {
                                id: sliderCursor
                                width: 12; height: 12; radius: 6
                                color: root.activeProfileColor
                                anchors.verticalCenter: parent.verticalCenter
                                // Center precisely on the dot positions
                                x: (root.profileStepIndex * (parent.width - 8) / 2 + 4) - width/2
                                
                                Behavior on x { 
                                    enabled: !widthAnim.running
                                    NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutBack } 
                                }
                                Behavior on color { ColorAnimation { duration: Theme.animationDuration } }
                            }
                        }

                        // Row 3: Mode Text
                        StyledText {
                            text: root.powerProfileText + " Mode"
                            font.pixelSize: 10
                            color: Colors.dark.subtext1
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }


                Column {
                    id: textColumn
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.preferredWidth: 45
                    spacing: 0
                    
                    StyledText {
                        id: percentageText
                        text: Math.round(root.batteryPercentage) + "%"
                        font.pixelSize: 20
                        color: Colors.dark.text
                        anchors.right: parent.right
                    }
                    
                    StyledText {
                        id: timeText
                        text: root.timeEstimate
                        font.pixelSize: 12
                        color: Colors.dark.subtext1
                        anchors.right: parent.right
                        visible: root.timeEstimate !== ""
                    }
                }
            }
        }

        // Battery Icon Container (Fixed width to center icon in the "bar" area)
        Item {
            id: iconContainer
            width: 56 // Standard bar width
            height: parent.height
            
            // Layout: Row to hold Icon and Bolt side-by-side
            Row {
                anchors.centerIn: parent
                spacing: 4

                // Battery Icon Wrapper
                Item {
                    width: 14 // Width of body
                    height: 35 // Total height (tip + body + margin)
                    
                    // Battery Tip (Top)
                    Rectangle {
                        id: tip
                        width: 6
                        height: 3
                        color: (root.batteryPercentage < 20 && !root.isCharging) ? root.animRedColor : root.animIconColor
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // Battery Body (Bottom)
                    Rectangle {
                        id: body
                        width: 14
                        height: 26
                        color: "transparent" // Outline only
                        border.color: (root.batteryPercentage < 20 && !root.isCharging) ? root.animRedColor : root.animIconColor
                        border.width: 2
                        radius: 2
                        anchors.top: tip.bottom
                        anchors.topMargin: 1
                        anchors.horizontalCenter: parent.horizontalCenter

                        Shape {
                            anchors.centerIn: parent
                            width: 8
                            height: 18
                            // Remove visible binding to allow fade-out
                            opacity: root.isCharging ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: Theme.animationDuration } }
                            
                            ShapePath {
                                strokeWidth: 0
                                fillColor: root.animIconColor // Foreground color
                                joinStyle: ShapePath.MiterJoin
                                capStyle: ShapePath.RoundCap
                                
                                startX: 5; startY: 0
                                PathLine { x: 0; y: 10 }
                                PathLine { x: 3; y: 10 }
                                PathLine { x: 1; y: 18 }
                                PathLine { x: 8; y: 7 }
                                PathLine { x: 4; y: 7 }
                                PathLine { x: 5; y: 0 }
                            }
                        }

                        // Battery Fill
                        Rectangle {
                            id: fillRect
                            width: parent.width - 6
                            // Height proportional to capacity. Max height is parent.height - 6 (approx)
                            height: (parent.height - 6) * (root.batteryPercentage / 100)
                            clip: true // Clip the "Filled" bolt to the fill level

                            color: (root.batteryPercentage < 20 && !root.isCharging) ? root.animRedColor : root.animIconColor
                            radius: 1
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 3
                            anchors.horizontalCenter: parent.horizontalCenter

                            // Bolt 2: The "Filled" part (Background Color). Visible inside the fill.
                            // We calculate Y manually because we want it fixed relative to the body (grandparent),
                            // but we are inside fillRect (parent) which moves/resizes.
                            // Body height 26, Bolt height 18. Centered Y in body = 4.
                            // FillRect bottom is at 23 (height-3). Top is at 23 - height.
                            // Relative Y = 4 - (23 - height) = height - 19.
                            Shape {
                                y: parent.height - 19
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 8
                                height: 18
                                // Remove visible binding to allow fade-out
                                opacity: root.isCharging ? 1.0 : 0.0
                                Behavior on opacity { NumberAnimation { duration: Theme.animationDuration } }
                                
                                ShapePath {
                                    strokeWidth: 0
                                    fillColor: root.animChargingColor // Background color (inverted)
                                    joinStyle: ShapePath.MiterJoin
                                    capStyle: ShapePath.RoundCap
                                    
                                    startX: 5; startY: 0
                                    PathLine { x: 0; y: 10 }
                                    PathLine { x: 3; y: 10 }
                                    PathLine { x: 1; y: 18 }
                                    PathLine { x: 8; y: 7 }
                                    PathLine { x: 4; y: 7 }
                                    PathLine { x: 5; y: 0 }
                                }
                            }
                        }
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
                target: background
                opacity: 1.0
            }
            PropertyChanges {
                target: root
                animIconColor: Colors.dark.text
                animRedColor: Colors.light.red
                animChargingColor: Colors.dark.base
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "hovered"
            // Colors switch
            ParallelAnimation {
                NumberAnimation { target: background; property: "opacity"; to: 1.0; duration: Theme.animationDuration; easing.type: Easing.OutQuad }
                ColorAnimation { target: root; property: "animIconColor"; duration: Theme.animationDuration; easing.type: Easing.OutQuad }
                ColorAnimation { target: root; property: "animRedColor"; duration: Theme.animationDuration; easing.type: Easing.OutQuad }
                ColorAnimation { target: root; property: "animChargingColor"; duration: Theme.animationDuration; easing.type: Easing.OutQuad }
            }
        },
        Transition {
            from: "hovered"
            to: "*"
            // Colors revert
            ParallelAnimation {
                NumberAnimation { target: background; property: "opacity"; to: 0.0; duration: Theme.animationDurationOut; easing.type: Easing.InQuad }
                ColorAnimation { target: root; property: "animIconColor"; duration: Theme.animationDurationOut; easing.type: Easing.InQuad }
                ColorAnimation { target: root; property: "animRedColor"; duration: Theme.animationDurationOut; easing.type: Easing.InQuad }
                ColorAnimation { target: root; property: "animChargingColor"; duration: Theme.animationDurationOut; easing.type: Easing.InQuad }
            }
        }
    ]
}
