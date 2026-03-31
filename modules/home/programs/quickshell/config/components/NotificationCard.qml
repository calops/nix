import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Notifications
import "../services"

Item {
    id: root

    // =========================================================================
    // Properties
    // =========================================================================

    property var entry: null
    property bool isExpanded: false
    property bool showActions: true
    property bool isInShade: false

    readonly property var notification: entry?.notification ?? null

    // Dimensions
    readonly property int maxCollapsedHeight: 120
    readonly property int maxExpandedHeight: 400
    readonly property int cardWidth: 320
    readonly property int padding: 12

    implicitWidth: cardWidth
    implicitHeight: contentColumn.height + (padding * 2)

    // Animation properties for enter/exit
    property bool isEntering: true
    property bool isExiting: false
    property real enterExitX: cardWidth + 50
    opacity: isEntering ? 0.0 : (isExiting ? 0.0 : 1.0)
    x: enterExitX

    // Determine urgency color
    readonly property color urgencyTint: {
        if (!notification) return Theme.backdropTint
        if (notification.urgency === NotificationUrgency.Critical)
            return Colors.palette.red
        return Theme.backdropTint
    }

    // Determine if body is too long
    readonly property bool bodyIsLong: bodyText.implicitHeight > 60

    // =========================================================================
    // Animations
    // =========================================================================

    // Enter animation
    ParallelAnimation {
        id: enterAnimation
        running: isEntering

        NumberAnimation {
            target: root
            property: "opacity"
            to: 1.0
            duration: Theme.animationDuration
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: root
            property: "enterExitX"
            to: 0
            duration: Theme.animationDuration
            easing.type: Easing.OutQuad
        }
        onFinished: root.isEntering = false
    }

    // Exit animation
    ParallelAnimation {
        id: exitAnimation
        running: isExiting

        NumberAnimation {
            target: root
            property: "opacity"
            to: 0.0
            duration: Theme.animationDurationOut
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: root
            property: "enterExitX"
            to: cardWidth + 50
            duration: Theme.animationDurationOut
            easing.type: Easing.InQuad
        }
        onFinished: root.destroy()
    }

    function startExit() {
        if (!isExiting) {
            isExiting = true
        }
    }

    // =========================================================================
    // Background
    // =========================================================================

    HoverBackdrop {
        id: backdrop
        anchors.fill: parent
        anchors.margins: -6
        radius: 12
        baseColor: Colors.alpha(root.urgencyTint, Theme.backdropOpacity)
        opacity: 1.0
        z: -1
    }

    // =========================================================================
    // Content
    // =========================================================================

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: padding
        spacing: 8

        // Header: App icon + name + close button
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // App icon
            Image {
                id: appIcon
                source: notification?.appIcon ?? ""
                sourceSize: Qt.size(20, 20)
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                fillMode: Image.PreserveAspectFit
                visible: source !== ""

                // Fallback to generic icon
                Image {
                    anchors.fill: parent
                    source: "image://icon/application-x-executable"
                    sourceSize: Qt.size(20, 20)
                    visible: appIcon.source === "" || appIcon.status !== Image.Ready
                }
            }

            // App name
            StyledText {
                id: appNameText
                Layout.fillWidth: true
                text: notification?.appName ?? "Unknown"
                font.pixelSize: 12
                font.bold: true
                color: Colors.palette.subtext1
                elide: Text.ElideRight
            }

            // Close button
            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 4
                color: closeMouseArea.containsMouse ? Colors.alpha("#ffffff", 0.1) : "transparent"

                StyledText {
                    anchors.centerIn: parent
                    text: "×"
                    font.pixelSize: 14
                    color: Colors.palette.subtext0
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (notification) {
                            notification.dismiss()
                        }
                    }
                }
            }
        }

        // Summary (title)
        StyledText {
            Layout.fillWidth: true
            text: notification?.summary ?? ""
            font.pixelSize: 14
            font.bold: true
            color: Colors.palette.text
            elide: Text.ElideRight
            visible: text !== ""
        }

        // Body text
        Rectangle {
            id: bodyContainer
            Layout.fillWidth: true
            Layout.preferredHeight: bodyFlickable.contentHeight
            color: "transparent"
            visible: (notification?.body ?? "") !== ""
            clip: true

            property real maxHeight: root.isExpanded ? root.maxExpandedHeight : 60

            Flickable {
                id: bodyFlickable
                anchors.fill: parent
                contentWidth: width
                contentHeight: bodyText.implicitHeight
                interactive: root.isExpanded

                StyledText {
                    id: bodyText
                    width: parent.width
                    text: notification?.body ?? ""
                    font.pixelSize: 13
                    color: Colors.palette.text
                    wrapMode: Text.WordWrap
                    textFormat: Text.PlainText

                    // Handle markup if supported
                    onLinkActivated: function(link) {
                        Qt.openUrlExternally(link)
                    }
                }
            }

            // "Show more" indicator for collapsed long text
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 20
                visible: !root.isExpanded && root.bodyIsLong
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Colors.alpha(Colors.palette.base, 0.0) }
                    GradientStop { position: 1.0; color: Colors.alpha(Colors.palette.base, 0.9) }
                }

                StyledText {
                    anchors.centerIn: parent
                    text: "Click to expand"
                    font.pixelSize: 10
                    font.italic: true
                    color: Colors.palette.subtext0
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.bodyIsLong && !root.isExpanded
                onClicked: root.isExpanded = true
            }
        }

        // Image (full-width)
        Image {
            id: notificationImage
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(implicitHeight, 200)
            source: notification?.image ?? ""
            fillMode: Image.PreserveAspectCrop
            visible: source !== ""
            cache: true

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "black"
                shadowBlur: 0.5
                shadowOpacity: 0.3
                shadowVerticalOffset: 2
            }
        }

        // Action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: root.showActions && (notification?.actions?.length ?? 0) > 0

            Repeater {
                model: notification?.actions ?? []
                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    radius: 6
                    color: actionMouseArea.containsMouse ? Colors.alpha("#ffffff", 0.15) : Colors.alpha("#ffffff", 0.08)

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        // Action icon (if hasActionIcons)
                        Image {
                            source: notification?.hasActionIcons ? modelData.identifier : ""
                            sourceSize: Qt.size(16, 16)
                            Layout.preferredWidth: visible ? 16 : 0
                            Layout.preferredHeight: 16
                            visible: source !== ""
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.text ?? ""
                            font.pixelSize: 12
                            color: Colors.palette.text
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    MouseArea {
                        id: actionMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            modelData.invoke()
                            // If not resident, dismiss after action
                            if (!notification?.resident) {
                                notification?.dismiss()
                            }
                        }
                    }
                }
            }
        }

        // Inline reply
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: root.showActions && (notification?.hasInlineReply ?? false)

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                radius: 6
                color: Colors.alpha("#ffffff", 0.08)
                border.width: replyInput.activeFocus ? 1 : 0
                border.color: Colors.palette.teal

                TextInput {
                    id: replyInput
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: 12
                    font.family: "Aporetic Sans Mono"
                    color: Colors.palette.text
                    selectionColor: Colors.palette.surface2
                    selectedTextColor: Colors.palette.text

                    StyledText {
                        anchors.fill: parent
                        anchors.leftMargin: 0
                        text: notification?.inlineReplyPlaceholder ?? "Reply..."
                        font.pixelSize: 12
                        color: Colors.palette.subtext0
                        visible: replyInput.text === ""
                        verticalAlignment: Text.AlignVCenter
                    }

                    onAccepted: {
                        if (text !== "" && notification) {
                            notification.sendInlineReply(text)
                            text = ""
                            if (!notification.resident) {
                                notification.dismiss()
                            }
                        }
                    }
                }
            }
        }

        // Collapse button (when expanded)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            radius: 4
            color: collapseMouseArea.containsMouse ? Colors.alpha("#ffffff", 0.1) : "transparent"
            visible: root.isExpanded && root.bodyIsLong

            StyledText {
                anchors.centerIn: parent
                text: "Show less"
                font.pixelSize: 11
                color: Colors.palette.subtext0
            }

            MouseArea {
                id: collapseMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.isExpanded = false
            }
        }
    }

    // =========================================================================
    // Lifecycle
    // =========================================================================

    Connections {
        target: notification
        function onClosed() {
            root.startExit()
        }
    }

    Component.onCompleted: {
        console.log("[NotificationCard] Created for:", notification?.summary ?? "unknown")
    }

    Component.onDestruction: {
        console.log("[NotificationCard] Destroyed for:", notification?.summary ?? "unknown")
    }
}
