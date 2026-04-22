import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../services"
import "../services" as Services
import "."
import "../components"

Item {
    id: root
    width: hovered || Niri.overviewActive || (reactive && reactive.active) ? expandedWidth : iconWidth
    height: 50

    property int iconWidth: Theme.iconWidth
    property int expandedWidth: parent ? parent.width : Theme.widgetExpandedWidth

    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

    // Theme colors
    property color animIconColor: Colors.dark.text
    property color animBarColor: Colors.dark.mauve // Using mauve for volume
    property color animBgColor: Colors.dark.surface0

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property real systemVolume: {
        let sink = Pipewire.defaultAudioSink;
        if (!sink || !sink.audio) return 0;
        let v = sink.audio.volume;
        return isNaN(v) ? 0 : v;
    }
    readonly property bool isMuted: Pipewire.defaultAudioSink?.audio?.muted ?? false
    property real mutedFactor: isMuted ? 1.0 : 0.0
    Behavior on mutedFactor { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

    property real localVolume: systemVolume
    readonly property int percentage: Math.round(systemVolume * 100)
    property bool isInteracting: false
    property bool isDragging: false

    Binding {
        target: root
        property: "localVolume"
        value: systemVolume
        when: !root.isInteracting
    }

    Behavior on localVolume {
        enabled: !root.isDragging
        NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
    }
    
    Binding { target: root; property: "isDragging"; value: volumeSlider.pressed }
    Binding { target: root; property: "isInteracting"; value: true; when: volumeSlider.pressed }
    onIsDraggingChanged: if (!isDragging) syncTimer.restart()

    Timer {
        id: syncTimer
        interval: 1000
        onTriggered: {
            isInteracting = false;
        }
    }

    ReactiveExpansion {
        id: reactive
        watchValue: systemVolume + ":" + isMuted + ":" + (Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.id : "null")
        ignore: hovered || isInteracting
    }

    // Combine hover states to prevent widget collapsing when interacting with slider
    property bool hovered: mouseArea.containsMouse || volumeSlider.containsMouse || volumeSlider.pressed

    MouseArea {
        id: mouseArea
        anchors.fill: background
        hoverEnabled: true
        
        // Scroll to change volume
        onWheel: (wheel) => {
            isInteracting = true;
            syncTimer.restart();
            let step = 0.05;
            let val = localVolume;
            if (wheel.angleDelta.y < 0) {
                val = Math.max(0, val - step);
            } else {
                val = Math.min(1, val + step);
            }
            localVolume = val;
            if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                Pipewire.defaultAudioSink.audio.volume = val;
            }
        }

        onClicked: {
            if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                Pipewire.defaultAudioSink.audio.muted = !isMuted;
            }
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
                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

                // Volume Slider
                ProgressBar {
                    id: volumeSlider
                    Layout.fillWidth: true
                    Layout.preferredHeight: 26
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    
                    value: root.localVolume
                    color: root.animBarColor
                    contentOpacity: 1.0 - (root.mutedFactor * 0.6)
                    trackOpacity: 0.3 - (root.mutedFactor * 0.2)
                    
                    onMoved: (val) => {
                        root.localVolume = val;
                        if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                            Pipewire.defaultAudioSink.audio.volume = val;
                        }
                    }
                }


                // Text Column
                Column {
                    id: textColumn
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.preferredWidth: 45
                    
                    StyledText {
                        text: Math.round(root.localVolume * 100) + "%"
                        font.pixelSize: 20
                        color: Colors.alpha(Colors.dark.text, 1.0 - (root.mutedFactor * 0.6))
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
                width: 24 
                height: 24
                anchors.centerIn: parent
                
                // Speaker Body
                Shape {
                    id: speakerShape
                    anchors.fill: parent
                    anchors.leftMargin: 2
                    
                    ShapePath {
                        strokeWidth: 2
                        strokeColor: root.animIconColor
                        fillColor: "transparent"
                        
                        // Back rectangle
                        startX: 2; startY: 8
                        PathLine { x: 6; y: 8 }
                        PathLine { x: 12; y: 4 }
                        PathLine { x: 12; y: 20 }
                        PathLine { x: 6; y: 16 }
                        PathLine { x: 2; y: 16 }
                        PathLine { x: 2; y: 8 }
                    }
                    // Fill for the cone part
                    ShapePath {
                        strokeWidth: 0
                        fillColor: Services.Colors.alpha(root.animIconColor, 1.0 - (root.mutedFactor * 0.7))
                        
                        startX: 2; startY: 8
                        PathLine { x: 6; y: 8 }
                        PathLine { x: 12; y: 4 }
                        PathLine { x: 12; y: 20 }
                        PathLine { x: 6; y: 16 }
                        PathLine { x: 2; y: 16 }
                        PathLine { x: 2; y: 8 }
                    }
                }
                Item {
                    anchors.fill: parent
                    opacity: 1.0 - root.mutedFactor
                    
                    Repeater {
                        model: 5 // More segments for smoother progression
                        Shape {
                            anchors.fill: parent
                            
                            readonly property real threshold: index * 0.2
                            readonly property real segmentVolume: Math.max(0, Math.min(1, (root.localVolume - threshold) / 0.2))
                            
                            ShapePath {
                                strokeWidth: 2
                                strokeColor: Services.Colors.alpha(root.animIconColor, segmentVolume)
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap
                                
                                PathAngleArc {
                                    centerX: 10
                                    centerY: 12
                                    radiusX: 5 + index * 3
                                    radiusY: 5 + index * 3
                                    startAngle: -45
                                    sweepAngle: 90
                                }
                            }
                        }
                    }
                }

                // Mute Cross (Diagonal Line)
                Shape {
                    anchors.fill: parent
                    opacity: root.mutedFactor
                    
                    ShapePath {
                        strokeWidth: 2
                        strokeColor: root.animIconColor
                        capStyle: ShapePath.RoundCap
                        
                        startX: 4; startY: 4
                        PathLine { x: 20; y: 20 }
                    }
                }
            }
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
                animBarColor: Colors.light.mauve
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "hovered"
            ParallelAnimation {
                NumberAnimation { target: background; property: "opacity"; to: 1.0; duration: 300; easing.type: Easing.OutQuad }
                ColorAnimation { target: root; property: "animIconColor"; duration: 300; easing.type: Easing.OutQuad }
                ColorAnimation { target: root; property: "animBarColor"; duration: 300; easing.type: Easing.OutQuad }
            }
        },
        Transition {
            from: "hovered"
            to: "*"
            ParallelAnimation {
                NumberAnimation { target: background; property: "opacity"; to: 0.0; duration: 250; easing.type: Easing.InQuad }
                ColorAnimation { target: root; property: "animIconColor"; duration: 250; easing.type: Easing.InQuad }
                ColorAnimation { target: root; property: "animBarColor"; duration: 250; easing.type: Easing.InQuad }
            }
        }
    ]
}
