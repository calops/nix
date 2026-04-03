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

    readonly property bool hasProgress: {
        if (!notification || !notification.hints)
            return false;
        var v = notification.hints["value"];
        return v !== undefined && v !== null;
    }

    readonly property real progressValue: {
        if (!hasProgress)
            return 0;
        var v = notification.hints["value"];
        return v !== undefined ? v : 0;
    }

    readonly property bool isProgressDone: {
        if (!hasProgress)
            return false;
        return progressValue >= 100;
    }

    property bool replySent: false

    property real timerProgress: 1.0

    function updateTimerProgress() {
        if (!root.entry) { root.timerProgress = 1.0; return; }
        if (root.notification && root.notification.urgency === NotificationUrgency.Critical)
        { root.timerProgress = 1.0; return; }
        if (root.hasProgress && !root.isProgressDone)
        { root.timerProgress = 1.0; return; }

        var elapsed = root.entry.elapsedDisplayTime;
        if (root.entry.displayStartTime > 0)
            elapsed += Date.now() - root.entry.displayStartTime;
        var timeoutMs = root.entry.expireTimeout * 1000;
        if (timeoutMs <= 0) { root.timerProgress = 1.0; return; }
        root.timerProgress = Math.max(0, 1.0 - (elapsed / timeoutMs));
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
        baseColor: Colors.alpha(root.urgencyTint, cardHoverHandler.hovered ? Theme.backdropOpacity + 0.05 : Theme.backdropOpacity)
    }

    HoverHandler {
        id: cardHoverHandler
        onHoveredChanged: {
            Notifications.setTimerFrozen(hovered);
        }
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

            TimerRing {
                progress: root.timerProgress
                isInProgress: root.hasProgress && !root.isProgressDone
                isCritical: root.notification && root.notification.urgency === NotificationUrgency.Critical
                ringColor: root.urgencyTint
                onDismissed: Notifications.dismissById(root.entry?.notificationId ?? "")
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

        RichText {
            Layout.fillWidth: true
            text: root.notification?.body ?? ""
            fontSize: 13
            maximumLineCount: 15
            elide: Text.ElideRight
            visible: text !== ""
        }

        Image {
            id: contentImage
            Layout.fillWidth: true
            Layout.preferredHeight: status === Image.Ready ? Math.min(200, implicitHeight) : 0
            Layout.maximumHeight: 200
            source: root.notification?.image ?? ""
            sourceSize: Qt.size(contentColumn.width, contentColumn.width)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            visible: source !== "" && status !== Image.Null
        }

        NotificationProgressBar {
            Layout.fillWidth: true
            value: root.progressValue
            fillColor: root.urgencyTint
            visible: root.hasProgress
        }

        Flow {
            Layout.fillWidth: true
            spacing: 6
            visible: root.notification && root.notification.actions && root.notification.actions.length > 0

            Repeater {
                model: (root.notification?.actions ?? []).length
                delegate: GlassButton {
                    required property int index
                    property var action: root.notification.actions[index]
                    icon: action.text
                    iconSize: 12
                    tintColor: Colors.palette.text
                    normalAlpha: 0.08
                    hoveredAlpha: 0.18
                    implicitWidth: actionLabel.implicitWidth + 16
                    Layout.fillWidth: false
                    Layout.preferredHeight: 28
                    onClicked: Notifications.invokeAction(root.notification, index)
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: replyArea.height
            visible: root.notification && root.notification.hasInlineReply && !root.replySent

            clip: false

            Row {
                id: replyArea
                width: parent.width
                spacing: 6

                Rectangle {
                    id: replyInput
                    width: parent.width - sendButton.width - parent.spacing
                    height: 28
                    radius: 6
                    color: Colors.alpha("#ffffff", 0.06)
                    border.width: 1
                    border.color: replyInputHover.hovered ? Colors.alpha("#ffffff", 0.15) : Colors.alpha("#ffffff", 0.06)

                    HoverHandler {
                        id: replyInputHover
                    }

                    TapHandler {
                        onTapped: replyField.forceActiveFocus()
                    }

                    StyledText {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        text: replyField.text === "" ? (root.notification?.inlineReplyPlaceholder || "Type a reply...") : ""
                        font.pixelSize: 12
                        color: Colors.palette.surface2
                        elide: Text.ElideRight
                        visible: replyField.text === ""
                    }

                    TextInput {
                        id: replyField
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Aporetic Sans"
                        font.pixelSize: 12
                        color: Colors.palette.text
                        clip: true
                        onActiveFocusChanged: Notifications.setTimerFrozen(activeFocus)
                    }
                }

                GlassButton {
                    id: sendButton
                    icon: "Send"
                    iconSize: 12
                    tintColor: Colors.palette.blue
                    normalAlpha: 0.15
                    hoveredAlpha: 0.30
                    Layout.fillWidth: false
                    Layout.preferredHeight: 28
                    onClicked: {
                        if (replyField.text.trim() !== "") {
                            Notifications.sendInlineReply(root.notification, replyField.text.trim());
                            root.replySent = true;
                        }
                    }
                }
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: "Sent"
            font.pixelSize: 12
            color: Colors.palette.green
            visible: root.replySent
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

    Timer {
        id: progressTimer
        interval: 100
        repeat: true
        running: (root.entry?.isDisplayed ?? false) && !root.isExiting
        onTriggered: root.updateTimerProgress()
    }

    Component.onDestruction: {
        if (cardHoverHandler.hovered) {
            Notifications.setTimerFrozen(false);
        }
    }

    Component.onCompleted: {
        console.log("[ToastCard] Created for:", root.notification?.summary ?? "unknown");
    }
}
