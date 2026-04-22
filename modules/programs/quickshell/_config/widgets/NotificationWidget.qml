import QtQuick
import "../services"
import "../components"

Item {
    id: root

    width: Theme.iconWidth
    height: 50

    // State from Notifications service
    readonly property int unseenCount: Notifications.unseenCount
    readonly property bool hasCritical: Notifications.hasCriticalUnseen

    // Track previous count to detect new notifications
    property int previousUnseenCount: 0

    // Ring animation state
    property bool isRinging: false

    // Trigger ring when count increases
    onUnseenCountChanged: {
        if (unseenCount > previousUnseenCount && previousUnseenCount >= 0) {
            root.isRinging = true;
        }
        previousUnseenCount = unseenCount;
    }

    // Dynamic icon color - red for critical, text color otherwise
    property color iconColor: hasCritical ? Colors.palette.red : Colors.palette.text

    Behavior on iconColor {
        ColorAnimation {
            duration: Theme.animationDuration
        }
    }

    // Pulse animation for critical notifications
    property real pulseOpacity: 1.0

    // =========================================================================
    // Ring Animation
    // =========================================================================

    SequentialAnimation {
        id: ringAnimation
        running: root.isRinging
        onFinished: root.isRinging = false

        NumberAnimation {
            target: bellIcon
            property: "rotation"
            to: 12
            duration: 80
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: bellIcon
            property: "rotation"
            to: -12
            duration: 80
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: bellIcon
            property: "rotation"
            to: 8
            duration: 80
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: bellIcon
            property: "rotation"
            to: -8
            duration: 80
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: bellIcon
            property: "rotation"
            to: 0
            duration: 80
            easing.type: Easing.OutQuad
        }
    }

    // Pulse animation for critical (only when not ringing)
    SequentialAnimation {
        running: root.hasCritical && !root.isRinging
        loops: Animation.Infinite

        NumberAnimation {
            target: root
            property: "pulseOpacity"
            to: 0.5
            duration: 500
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            property: "pulseOpacity"
            to: 1.0
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }

    // =========================================================================
    // Bell Icon (Nerd Font)
    // =========================================================================

    Item {
        id: bellIcon
        width: 22
        height: 22
        anchors.centerIn: parent
        opacity: root.pulseOpacity

        Text {
            id: bellText
            anchors.centerIn: parent
            text: "\uF0A2" //  - nf-fa-bell
            font.family: "Symbols Nerd Font Mono"
            font.pixelSize: 30
            color: root.iconColor
        }

        // Notification count badge
        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 5
            text: root.unseenCount > 99 ? "99" : root.unseenCount.toString()
            font.pixelSize: 10
            font.bold: true
            color: root.iconColor
            visible: root.unseenCount > 0
        }
    }

    // =========================================================================
    // Lifecycle
    // =========================================================================

    Component.onCompleted: {
        previousUnseenCount = unseenCount;
        console.log("[NotificationWidget] Initialized with unseenCount:", root.unseenCount);
    }
}
