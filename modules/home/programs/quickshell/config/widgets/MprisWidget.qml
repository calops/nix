import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import "../services"
import "../components"

Item {
    id: root
    width: (activePlayer !== null && (hovered || Niri.overviewActive || reactive.active)) ? expandedWidth : iconWidth
    height: expandedWidth // Perfectly square when expanded, constant height

    property int iconWidth: Theme.iconWidth
    property int expandedWidth: Theme.widgetExpandedWidth

    Behavior on width {
        NumberAnimation {
            id: widthAnim
            duration: root.width > iconWidth ? Theme.animationDuration : Theme.animationDurationOut
            easing.type: Easing.OutQuad
        }
    }

    property bool hovered: mouseArea.containsMouse || 
                           prevBtn.hovered || playBtn.hovered || nextBtn.hovered || 
                           seeker.containsMouse || seeker.pressed

    // Player Selection
    property var activePlayer: null

    function updateActivePlayer() {
        if (typeof Mpris === "undefined") {
            console.log("MPRIS: Mpris singleton is undefined");
            return;
        }

        if (!Mpris.players) {
            console.log("MPRIS: Mpris.players is null");
            return;
        }

        let players = Mpris.players.values || [];
        // console.log("MPRIS: Total players:", players.length);

        let found = null;
        // 1. Priority: If any player is actually PLAYING, that takes immediate precedence.
        for (let i = 0; i < players.length; i++) {
            let p = players[i];
            if (p.playbackState === MprisPlaybackState.Playing || p.isPlaying) {
                found = p;
                break;
            }
        }

        // 2. Sticky Logic: If no player is playing, keep the current active player if it still exists.
        if (!found && root.activePlayer !== null) {
            for (let i = 0; i < players.length; i++) {
                if (players[i] === root.activePlayer) {
                    found = root.activePlayer;
                    break;
                }
            }
        }

        // 3. Fallback: If current player is gone and none are playing, pick the first available.
        if (!found && players.length > 0) {
            found = players[0];
        }

        if (root.activePlayer !== found) {
            root.activePlayer = found;
            if (found)
                console.log("MPRIS: Active player changed to:", found.identity);
            else
                console.log("MPRIS: Active player set to null (No Media)");
        }
    }

    // React to players adding/removing
    Connections {
        target: Mpris.players
        function onCountChanged() {
            updateActivePlayer();
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: updateActivePlayer()
    }

    ReactiveExpansion {
        id: reactive
        watchValue: activePlayer ? (activePlayer.trackTitle + ":" + activePlayer.playbackState) : ""
    }

    Component.onCompleted: updateActivePlayer()

    readonly property real duration: activePlayer ? activePlayer.length : 0
    readonly property real progress: duration > 0 ? activePlayer.position / duration : 0

    // Intensity calculated from real frequencies
    readonly property real intensity: CavaService.frequencies.length > 0 ? (CavaService.frequencies.reduce((a, b) => a + b, 0) / CavaService.frequencies.length) : 0

    HoverBackdrop {
        id: background
        anchors.fill: parent
        anchors.topMargin: -5
        anchors.bottomMargin: -5
        anchors.rightMargin: 0 // Flush with screen edge
        anchors.leftMargin: 6
        opacity: (activePlayer !== null && (root.hovered || Niri.overviewActive || reactive.active)) ? 1.0 : 0.0
        imageSource: root.activePlayer ? root.activePlayer.trackArtUrl : ""

        // Legibility Gradient
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            opacity: parent.opacity
            gradient: Gradient {
                GradientStop { position: 0.0; color: Colors.alpha(Colors.dark.base, 0.8) }
                GradientStop { position: 0.4; color: Colors.alpha(Colors.dark.base, 0.2) }
                GradientStop { position: 0.7; color: "transparent" }
                GradientStop { position: 1.0; color: Colors.alpha(Colors.dark.base, 0.4) }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: background.opacity > 0 ? Theme.animationDuration : Theme.animationDurationOut
                easing.type: Easing.Linear
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: background
        hoverEnabled: true
        enabled: activePlayer !== null
    }

    // Main Layout
    Row {
        id: row
        anchors.fill: parent
        layoutDirection: Qt.RightToLeft
        spacing: 0

        // Equalizer (Collapsed View / Persistent on the right)
        Item {
            id: equalizerContainer
            width: iconWidth
            height: parent.height

            Column {
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Repeater {
                    id: barsRepeater
                    property int barCount: Math.floor(equalizerContainer.height / 4)
                    model: barCount
                    Item {
                        width: iconWidth
                        height: 4

                        Rectangle {
                            id: bar
                            height: 2
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            // Total number of bars from the Repeater
                            readonly property int total: barsRepeater.barCount
                            
                            // Normalized position (0.0 to 1.0) for the envelope
                            readonly property real normPos: index / (total - 1)
                            
                            // Dynamic envelope power that expands/contracts with intensity
                            readonly property real envelopePower: 1.2 + (root.intensity * 2.5)
                            readonly property real envelope: 1.0 - Math.pow(Math.abs(normPos - 0.5) * 2, envelopePower)

                            // Real Frequency Data from Cava
                            // Map our local bar index to the full spectrum of Cava frequencies
                            readonly property real frequency: {
                                let freqs = CavaService.frequencies;
                                if (!freqs || freqs.length === 0) return 0;
                                let cavaIndex = Math.min(Math.floor(normPos * (freqs.length - 1)), freqs.length - 1);
                                return freqs[cavaIndex];
                            }

                            // Final Width Calculation:
                            // Use Math.sqrt to boost smaller values for better visual response
                            readonly property real scaledFreq: Math.sqrt(frequency) * envelope
                            
                            // Smooth scaling without minimum width for seamless silence
                            width: scaledFreq * 46
                            radius: 1
                            color: Colors.palette.text

                            Behavior on width {
                                NumberAnimation {
                                    duration: 50
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }
            }
        }

        // Expanded View Content
        Item {
            id: expandedContent
            width: Math.max(0, root.width - iconWidth)
            height: parent.height
            clip: true
            opacity: root.width > iconWidth ? (root.width - iconWidth) / (expandedWidth - iconWidth) : 0

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                anchors.topMargin: 12
                anchors.bottomMargin: 12
                spacing: 0
                visible: opacity > 0

                // Metadata at the Top
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    
                    StyledText {
                        text: root.activePlayer ? root.activePlayer.trackTitle : "No Media"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: root.activePlayer ? root.activePlayer.trackArtist : "Unknown Artist"
                        font.pixelSize: 11
                        color: Colors.palette.subtext0
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        opacity: 0.9
                    }
                }

                Item { Layout.fillHeight: true }

                // Centered Playback Buttons
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12
                    Layout.bottomMargin: 12

                    GlassIconButton {
                        id: prevBtn
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 32
                        icon: "󰒮" // Previous
                        iconSize: 16
                        enabled: root.activePlayer && root.activePlayer.canGoPrevious
                        opacity: enabled ? 1.0 : 0.3
                        onClicked: if (root.activePlayer) root.activePlayer.previous()
                    }

                    GlassIconButton {
                        id: playBtn
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 38
                        isActive: root.activePlayer?.playbackState === MprisPlaybackState.Playing ?? false
                        icon: root.activePlayer && root.activePlayer.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊" // Play/Pause
                        iconSize: 20
                        enabled: root.activePlayer !== null
                        onClicked: {
                            if (!root.activePlayer) return;
                            if (root.activePlayer.playbackState === MprisPlaybackState.Playing)
                                root.activePlayer.pause();
                            else
                                root.activePlayer.play();
                        }
                    }

                    GlassIconButton {
                        id: nextBtn
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 32
                        icon: "󰒭" // Next
                        iconSize: 16
                        enabled: root.activePlayer && root.activePlayer.canGoNext
                        opacity: enabled ? 1.0 : 0.3
                        onClicked: if (root.activePlayer) root.activePlayer.next()
                    }
                }

                // Full-width Seeker Bar
                ProgressBar {
                    id: seeker
                    Layout.fillWidth: true
                    Layout.preferredHeight: 12
                    value: root.progress
                    color: Colors.palette.mauve
                    trackHeight: 4
                    handleSize: 10
                    onMoved: val => {
                        if (root.activePlayer && root.activePlayer.canSeek) {
                            root.activePlayer.position = val * root.duration;
                        }
                    }
                }
            }
        }
    }
}
