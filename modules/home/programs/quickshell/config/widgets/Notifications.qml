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

    // --- Bell Icon (Visible in both states) ---
    Item {
        id: iconContainer
        width: Theme.iconWidth
        height: 56
        anchors.right: parent.right
        z: 5

        StyledText {
            id: bellIcon
            anchors.centerIn: parent
            text: (typeof Notifications !== 'undefined' && Notifications.historyModel && Notifications.historyModel.count > 0) ? "󰂚" : "󰂜"
            font.pixelSize: 26 // Bigger icon
            font.bold: true   // Thicker lines
            color: {
                if (typeof Notifications === 'undefined') return Colors.palette.subtext0;
                if (Notifications.maxUrgency === NotificationUrgency.Critical) return Colors.palette.maroon;
                if (Notifications.unseenCount > 0) return Colors.palette.text; // Proper text color when active
                return Colors.palette.subtext0;
            }

            // Ringing animation (shakes and resets to 0)
            SequentialAnimation on rotation {
                id: shakeAnim
                running: false
                NumberAnimation { from: 0; to: -15; duration: 80; easing.type: Easing.OutQuad }
                NumberAnimation { from: -15; to: 15; duration: 80; easing.type: Easing.InOutQuad; loops: 4 }
                NumberAnimation { from: 15; to: 0; duration: 80; easing.type: Easing.InQuad }
            }

            SequentialAnimation on opacity {
                id: breathAnim
                loops: Animation.Infinite
                running: (typeof Notifications !== 'undefined') && Notifications.unseenCount > 0 && !root.expanded
                NumberAnimation { from: 0.6; to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.0; to: 0.6; duration: 1500; easing.type: Easing.InOutSine }
            }

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
            width: 18; height: 18; radius: 9
            color: Colors.palette.red
            anchors.top: bellIcon.top
            anchors.right: bellIcon.right
            anchors.topMargin: -2
            anchors.rightMargin: -4

            StyledText {
                text: (typeof Notifications !== 'undefined') ? Notifications.unseenCount : 0
                font.pixelSize: 10
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
        anchors.rightMargin: 0 // Flush with the icon column
        visible: opacity > 0
        opacity: root.expanded ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: Theme.animationDuration } }
        spacing: 12

        // Header (Title only, Clear button moved to bottom)
        RowLayout {
            Layout.fillWidth: true
            Layout.rightMargin: 56 // Leave room for the bell icon
            Layout.topMargin: 8
            StyledText {
                text: "Notifications"
                font.pixelSize: 16; font.bold: true
                Layout.fillWidth: true
            }
        }

        // List
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.rightMargin: 12 // Spacing from edge
            model: (typeof Notifications !== 'undefined') ? Notifications.historyModel : []
            spacing: 10
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
                blurEnabled: false
                onDismiss: if (model.notif) Notifications.dismiss(model.notif)
            }
        }

        // Clear All Button (Full width at bottom)
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.rightMargin: 12
            Layout.bottomMargin: 4
            visible: (typeof Notifications !== 'undefined' && Notifications.historyModel && Notifications.historyModel.count > 0)

            GlassIconButton {
                anchors.fill: parent
                icon: "󰅖 Clear All History"
                iconSize: 11
                onClicked: Notifications.clearAll()
            }
        }
    }
}
