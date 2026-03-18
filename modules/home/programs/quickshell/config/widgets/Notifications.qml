import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Notifications
import "../services"
import "../components"

Item {
    id: root
    width: expanded ? Theme.widgetExpandedWidth : Theme.iconWidth
    
    property int expandedHeight: 400
    height: expanded ? expandedHeight : 56

    readonly property bool expanded: hoverHandler.hovered || Niri.overviewActive
    
    // Sync center state with global service
    onExpandedChanged: {
        if (typeof Notifications !== 'undefined')
            Notifications.isCenterOpen = expanded;
    }

    Behavior on width { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }
    Behavior on height { NumberAnimation { duration: Theme.animationDuration; easing.type: Easing.OutQuad } }

    HoverHandler {
        id: hoverHandler
    }

    HoverBackdrop {
        id: background
        anchors.fill: parent
        anchors.margins: 0
        anchors.leftMargin: 6
        opacity: root.expanded ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: Theme.animationDuration } }
    }

    // --- Collapsed View: Bell Icon ---
    Item {
        id: iconContainer
        width: Theme.iconWidth
        height: 56
        anchors.right: parent.right
        visible: !root.expanded || opacity > 0
        opacity: root.expanded ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation { duration: Theme.animationDuration } }

        // Bell Icon (Custom Drawing / Styled Text)
        StyledText {
            id: bellIcon
            anchors.centerIn: parent
            text: (typeof Notifications !== 'undefined' && Notifications.history && Notifications.history.length > 0) ? "󰂚" : "󰂜"
            font.pixelSize: 22
            color: {
                if (typeof Notifications === 'undefined') return Colors.palette.subtext0;
                if (Notifications.maxUrgency === NotificationUrgency.Critical) return Colors.palette.maroon;
                if (Notifications.unseenCount > 0) return Colors.palette.mauve;
                return Colors.palette.subtext0;
            }

            // Shake animation for Critical/New
            RotationAnimation on rotation {
                id: shakeAnim
                from: -15; to: 15; duration: 100; loops: 5; running: false
            }

            SequentialAnimation on opacity {
                id: breathAnim
                loops: Animation.Infinite
                running: (typeof Notifications !== 'undefined') && Notifications.unseenCount > 0 && !root.expanded
                NumberAnimation { from: 0.6; to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.0; to: 0.6; duration: 1500; easing.type: Easing.InOutSine }
            }

            // Trigger shake when a new notification arrives
            Connections {
                target: (typeof Notifications !== 'undefined') ? Notifications : null
                function onUnseenCountChanged() {
                    if (Notifications.unseenCount > 0) shakeAnim.restart();
                }
            }
        }

        // Badge
        Rectangle {
            visible: (typeof Notifications !== 'undefined') && Notifications.unseenCount > 0
            width: 16; height: 16; radius: 8
            color: Colors.palette.red
            anchors.top: bellIcon.top
            anchors.right: bellIcon.right
            anchors.topMargin: -2
            anchors.rightMargin: -4

            StyledText {
                text: (typeof Notifications !== 'undefined') ? Notifications.unseenCount : 0
                font.pixelSize: 9
                font.bold: true
                anchors.centerIn: parent
                color: "white"
            }
        }
    }

    // --- Expanded View: Notification Center ---
    ColumnLayout {
        id: expandedView
        anchors.fill: parent
        anchors.margins: 12
        visible: opacity > 0
        opacity: root.expanded ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: Theme.animationDuration } }
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            StyledText {
                text: "Notifications"
                font.pixelSize: 14; font.bold: true
                Layout.fillWidth: true
            }
            
            GlassIconButton {
                id: clearBtn
                Layout.preferredWidth: 60
                Layout.preferredHeight: 24
                icon: "󰅖 Clear"
                iconSize: 10
                onClicked: Notifications.clearAll()
            }
        }

        // List
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: (typeof Notifications !== 'undefined') ? Notifications.historyModel : []
            spacing: 8
            clip: true

            add: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.animationDuration }
                NumberAnimation { property: "y"; from: -20; to: 0; duration: Theme.animationDuration; easing.type: Easing.OutCubic }
            }

            remove: Transition {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; to: 0; duration: Theme.animationDurationOut }
                    NumberAnimation { property: "scale"; to: 0.9; duration: Theme.animationDurationOut }
                }
            }

            displaced: Transition {
                NumberAnimation { properties: "y"; duration: Theme.animationDuration; easing.type: Easing.OutQuad }
            }
            
            delegate: NotificationCard {
                notification: model.notif
                onDismiss: if (model.notif) Notifications.dismiss(model.notif)
            }
        }
    }
}
