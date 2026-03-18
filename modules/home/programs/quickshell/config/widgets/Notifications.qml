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
        blurGroupId: "rightBarScope"
        Behavior on opacity { NumberAnimation { duration: Theme.animationDuration } }
    }

    // --- Bell Icon ---
    Item {
        id: iconContainer
        width: Theme.iconWidth
        height: 56
        anchors.right: parent.right
        z: 5

        readonly property color iconColor: {
            if (typeof Notifications === 'undefined') return Colors.palette.text;
            if (Notifications.maxUrgency === NotificationUrgency.Critical) return Colors.palette.maroon;
            return Colors.palette.text;
        }

        StyledText {
            id: bellIcon
            anchors.centerIn: parent
            text: "󰂜"
            font.pixelSize: 30
            font.family: "Nerd Font"
            color: iconContainer.iconColor

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

        // Number inside bell
        StyledText {
            text: (typeof Notifications !== 'undefined') ? Notifications.unseenCount : ""
            font.pixelSize: 10
            font.bold: true
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 2
            color: iconContainer.iconColor
            visible: (typeof Notifications !== 'undefined') && Notifications.unseenCount > 0
        }
    }

    // --- Expanded View: Notification Center ---
    ColumnLayout {
        id: expandedView
        anchors.fill: parent
        anchors.margins: 12
        anchors.rightMargin: 0 
        visible: opacity > 0
        opacity: root.expanded ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: Theme.animationDuration } }
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.rightMargin: 56 
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
            Layout.rightMargin: 12 
            
            // Only show non-dismissed notifications
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
                visible: !model.isDismissed
                opacity: visible ? 1.0 : 0.0

                notification: model.notif
                blurEnabled: false
                onDismiss: if (model.notif) Notifications.dismiss(model.notif)

                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }

        // Clear All Button
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.rightMargin: 12
            Layout.bottomMargin: 4
            visible: {
                if (typeof Notifications === 'undefined') return false;
                for (let i = 0; i < Notifications.historyModel.count; i++) {
                    if (!Notifications.historyModel.get(i).isDismissed) return true;
                }
                return false;
            }

            GlassIconButton {
                anchors.fill: parent
                icon: "󰅖 Clear All History"
                iconSize: 11
                onClicked: Notifications.clearAll()
            }
        }
    }
}
