import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "../services"
import "."
import "../components"
Item {
    id: root
    width: hovered || Niri.overviewActive || (reactive && reactive.active) ? expandedWidth : iconWidth
    height: 50

    property int iconWidth: Theme.iconWidth
    property int expandedWidth: Theme.widgetExpandedWidth

    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

    // Dynamic theme switching: Animated colors
    property color animIconColor: Colors.dark.text
    property color animRedColor: Colors.dark.red
    property color animChargingColor: Colors.dark.base
    // animBoltColor is no longer used for a separate icon, but we keep it if needed or remove it.
    // The user requested monochrome inversion, so we'll strictly use iconColor and chargingColor (background).


    // Hover state handling
    property bool hovered: mouseArea.containsMouse || 
                           (profileRepeater.itemAt(0) && profileRepeater.itemAt(0).isHovered) ||
                           (profileRepeater.itemAt(1) && profileRepeater.itemAt(1).isHovered) ||
                           (profileRepeater.itemAt(2) && profileRepeater.itemAt(2).isHovered)

    // UPower integration: Mapping built-in service to UI variables
    readonly property bool hasBattery: UPower.displayDevice !== null && UPower.displayDevice !== undefined
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

    readonly property int profileStepIndex: {
        const p = PowerProfiles.profile;
        if (p === PowerProfile.PowerSaver) return 0;
        if (p === PowerProfile.Balanced) return 1;
        if (p === PowerProfile.Performance) return 2;
        return 1;
    }

    MouseArea {
        id: mouseArea
        anchors.fill: background // Constrain hover area to the visual backdrop
        hoverEnabled: true
    }

    ReactiveExpansion {
        id: reactive
        watchValue: isCharging + ":" + PowerProfiles.profile
        ignore: hovered
    }

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
            width: Math.max(0, root.width - iconContainer.width)
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
                
                // Power Profile Buttons
                RowLayout {
                    id: profileButtons
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Repeater {
                        id: profileRepeater
                        model: [
                            { icon: "", name: "Power", profile: PowerProfile.PowerSaver, color: Colors.dark.green },
                            { icon: "⚖", name: "Bal.", profile: PowerProfile.Balanced, color: Colors.dark.blue },
                            { icon: "", name: "Perf.", profile: PowerProfile.Performance, color: Colors.dark.red }
                        ]
                        
                        Rectangle {
                            id: button
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            radius: 8

                            
                            readonly property bool isActive: root.profileStepIndex === index
                            property bool isHovered: btnMouseArea.containsMouse
                            
                            // Glass Neumorphic Base
                            color: Colors.alpha("#ffffff", isActive ? 0.2 : (isHovered ? 0.22 : 0.08))
                            
                            // Define the glass edges with a subtle white border
                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                border.width: 1
                                border.color: Colors.alpha("#ffffff", isActive ? 0.15 : (isHovered ? 0.45 : 0.25))
                            }

                            // True Neumorphic Relief (LIGHT-ONLY SHEBANG)
                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                opacity: 0.5
                                gradient: Gradient {
                                    // Inactive (Raised): Bright Top, Soft White Bottom
                                    // Active (Inset): Soft White Top, Bright Bottom
                                    GradientStop { 
                                        position: 0.0
                                        color: button.isActive ? Colors.alpha("#ffffff", 0.1) : Colors.alpha("#ffffff", 0.8) 
                                    }
                                    GradientStop { position: 0.5; color: "transparent" }
                                    GradientStop { 
                                        position: 1.0
                                        color: button.isActive ? Colors.alpha("#ffffff", 0.8) : Colors.alpha("#ffffff", 0.1) 
                                    }
                                }
                            }
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 0
                                
                                StyledText {
                                    text: modelData.icon
                                    font.pixelSize: 14
                                    color: button.isActive ? modelData.color : Colors.dark.text
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    Behavior on color { ColorAnimation { duration: Theme.animationDuration } }
                                }
                                
                                StyledText {
                                    text: modelData.name
                                    font.pixelSize: 8
                                    color: button.isActive ? modelData.color : Colors.dark.text
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    opacity: 0.8
                                    Behavior on color { ColorAnimation { duration: Theme.animationDuration } }
                                }
                            }
                            
                            MouseArea {
                                id: btnMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: PowerProfiles.profile = modelData.profile
                            }
                            Behavior on color { ColorAnimation { duration: Theme.animationDurationFast } }
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
                        color: Colors.dark.text
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
            when: root.hovered || Niri.overviewActive || (reactive && reactive.active)
            PropertyChanges {
                target: background
                opacity: 1.0
            }
            PropertyChanges {
                target: root
                animIconColor: Colors.dark.text
                animRedColor: Colors.dark.red
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
