import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import "../services"

Item {
    id: root

    property var entry: null
    property bool isEntering: true
    property bool isExiting: false
    property real targetY: 0

    readonly property var notification: entry?.notification ?? null
    readonly property int cardWidth: 320
    readonly property int padding: 12

    implicitWidth: cardWidth
    implicitHeight: contentColumn.height + (padding * 2)
    opacity: 0.0
    x: cardWidth + 50
    y: targetY

    signal exited(string notificationId)

    readonly property color urgencyTint: {
        if (!notification)
            return Theme.backdropTint;
        if (notification.urgency === NotificationUrgency.Critical)
            return Colors.palette.red;
        return Theme.backdropTint;
    }

    ParallelAnimation {
        id: enterAnimation
        running: root.isEntering && !root.isExiting

        NumberAnimation {
            target: root
            property: "opacity"
            to: 1.0
            duration: Theme.animationDuration
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: root
            property: "x"
            to: 0
            duration: Theme.animationDuration
            easing.type: Easing.OutQuad
        }

        onFinished: root.isEntering = false
    }

    ParallelAnimation {
        id: exitAnimation
        running: root.isExiting

        NumberAnimation {
            target: root
            property: "opacity"
            to: 0.0
            duration: Theme.animationDurationOut
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: root
            property: "x"
            to: root.cardWidth + 50
            duration: Theme.animationDurationOut
            easing.type: Easing.InQuad
        }

        onFinished: {
            root.exited(root.entry?.notificationId ?? "");
            root.destroy();
        }
    }

    function startExit() {
        if (!root.isExiting) {
            root.isExiting = true;
        }
    }

    Behavior on y {
        enabled: !root.isEntering && !root.isExiting
        NumberAnimation {
            duration: Theme.animationDuration
            easing.type: Easing.OutQuad
        }
    }

    HoverBackdrop {
        id: backdrop
        anchors.fill: parent
        anchors.margins: -6
        radius: 12
        opacity: 1.0
        baseColor: Colors.alpha(root.urgencyTint, Theme.backdropOpacity)
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: padding
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Image {
                id: appIcon
                source: root.notification?.appIcon ?? ""
                sourceSize: Qt.size(20, 20)
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                fillMode: Image.PreserveAspectFit
                visible: source !== ""

                Image {
                    anchors.fill: parent
                    source: "image://icon/application-x-executable"
                    sourceSize: Qt.size(20, 20)
                    visible: appIcon.source === "" || appIcon.status !== Image.Ready
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: root.notification?.appName ?? "Unknown"
                font.pixelSize: 12
                font.bold: true
                color: Colors.palette.subtext1
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 4
                color: closeMouseArea.containsMouse ? Colors.alpha("#ffffff", 0.1) : "transparent"

                StyledText {
                    anchors.centerIn: parent
                    text: "\u00D7"
                    font.pixelSize: 14
                    color: Colors.palette.subtext0
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Notifications.dismissById(root.entry?.notificationId ?? "")
                }
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: root.notification?.summary ?? ""
            font.pixelSize: 14
            font.bold: true
            color: Colors.palette.text
            elide: Text.ElideRight
            visible: text !== ""
        }

        StyledText {
            Layout.fillWidth: true
            text: root.notification?.body ?? ""
            font.pixelSize: 13
            color: Colors.palette.text
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
            visible: text !== ""
        }
    }

    MouseArea {
        id: cardMouseArea
        anchors.fill: parent
        hoverEnabled: true
        z: 0.5
        propagateComposedEvents: true

        onClicked: function (mouse) {
            mouse.accepted = false;
            Notifications.dismissById(root.entry?.notificationId ?? "");
        }

        onContainsMouseChanged: {
            Notifications.setTimerFrozen(containsMouse);
        }
    }

    Connections {
        target: root.entry
        function onIsTransientChanged() {
            if (!root.entry?.isTransient && !root.isExiting) {
                root.startExit();
            }
        }
    }

    Connections {
        target: root.notification
        function onClosed() {
            root.startExit();
        }
    }

    Component.onDestruction: {
        if (cardMouseArea.containsMouse) {
            Notifications.setTimerFrozen(false);
        }
    }

    Component.onCompleted: {
        console.log("[ToastCard] Created for:", root.notification?.summary ?? "unknown");
    }
}
