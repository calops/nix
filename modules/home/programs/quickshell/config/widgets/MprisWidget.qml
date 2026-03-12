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
    width: hovered || Niri.overviewActive ? expandedWidth : iconWidth
    height: expandedWidth // Perfectly square when expanded, constant height

    property int iconWidth: Theme.iconWidth
    property int expandedWidth: Theme.widgetExpandedWidth

    Behavior on width {
        NumberAnimation {
            id: widthAnim
            duration: 400
            easing.type: Easing.OutQuad
        }
    }

    property bool hovered: mouseArea.containsMouse

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
        console.log("MPRIS: Total players:", players.length);

        let found = null;
        for (let i = 0; i < players.length; i++) {
            let p = players[i];
            console.log("MPRIS: Player", i, ":", p.identity, "State:", p.playbackState, "IsPlaying:", p.isPlaying);
            if (p.playbackState === MprisPlaybackState.Playing || p.isPlaying) {
                found = p;
                break;
            }
        }

        if (!found && players.length > 0) {
            found = players[0];
        }

        if (activePlayer !== found) {
            activePlayer = found;
            if (found)
                console.log("MPRIS: Active player changed to:", found.identity);
            else
                console.log("MPRIS: Active player set to null");
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
        interval: 2000
        running: true
        repeat: true
        onTriggered: updateActivePlayer()
    }

    Component.onCompleted: updateActivePlayer()

    readonly property real duration: activePlayer ? activePlayer.length : 0
    readonly property real progress: duration > 0 ? activePlayer.position / duration : 0

    // Peak Monitor for Equalizer
    PwNodePeakMonitor {
        id: peakMonitor
        node: Pipewire.defaultAudioSink
        enabled: root.activePlayer !== null
    }

    HoverBackdrop {
        id: background
        anchors.fill: parent
        anchors.topMargin: -5
        anchors.bottomMargin: -5
        anchors.rightMargin: 0 // Flush with screen edge
        anchors.leftMargin: 6
        opacity: root.hovered || Niri.overviewActive ? 1.0 : 0.0
        imageSource: root.activePlayer ? root.activePlayer.trackArtUrl : ""
    }

    MouseArea {
        id: mouseArea
        anchors.fill: background
        hoverEnabled: true
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
                spacing: 2

                Repeater {
                    model: Math.floor(equalizerContainer.height / 4)
                    Rectangle {
                        id: bar
                        height: 2
                        anchors.right: parent.right

                        readonly property real basePeak: (peakMonitor.peaks && peakMonitor.peaks.length > 0) ? peakMonitor.peaks[index % peakMonitor.peaks.length] : 0

                        // Ensure variance is always positive to avoid Math.pow(0, negative) = Infinity
                        readonly property real variance: 0.5 + (Math.sin(index * 0.5) * 0.25)
                        readonly property real finalPeak: basePeak > 0 ? Math.pow(basePeak, variance) : 0

                        width: 4 + (finalPeak * 42)
                        radius: 1
                        color: "white"

                        Behavior on width {
                            NumberAnimation {
                                duration: 80 + (index * 4)
                                easing.type: Easing.OutQuad
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

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 8
                spacing: 12
                visible: opacity > 0

                // Metadata and Controls
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4

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
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.preferredHeight: 4
                    }

                    // Progress Slider
                    ProgressBar {
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

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20
                        Layout.topMargin: 2

                        // Previous
                        Image {
                            source: Quickshell.iconPath("media-skip-backward", 20)
                            width: 20
                            height: 20
                            opacity: root.activePlayer && root.activePlayer.canGoPrevious ? 1.0 : 0.3
                            MouseArea {
                                anchors.fill: parent
                                onClicked: if (root.activePlayer)
                                    root.activePlayer.previous()
                            }
                        }

                        // Play/Pause
                        Image {
                            source: Quickshell.iconPath(root.activePlayer && root.activePlayer.playbackState === MprisPlaybackState.Playing ? "media-playback-pause" : "media-playback-start", 24)
                            width: 24
                            height: 24
                            opacity: root.activePlayer ? 1.0 : 0.3
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (!root.activePlayer)
                                        return;
                                    if (root.activePlayer.playbackState === MprisPlaybackState.Playing)
                                        root.activePlayer.pause();
                                    else
                                        root.activePlayer.play();
                                }
                            }
                        }

                        // Next
                        Image {
                            source: Quickshell.iconPath("media-skip-forward", 20)
                            width: 20
                            height: 20
                            opacity: root.activePlayer && root.activePlayer.canGoNext ? 1.0 : 0.3
                            MouseArea {
                                anchors.fill: parent
                                onClicked: if (root.activePlayer)
                                    root.activePlayer.next()
                            }
                        }
                    }
                }
            }
        }
    }
}
