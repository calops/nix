import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import "../services"
import "."

Item {
    id: root
    property var notification
    property bool isPopup: false
    property int radius: 12

    signal dismiss()

    width: parent.width
    height: contentLayout.implicitHeight + 24

    // Register with the blur group of the parent scope (popup window or right bar)
    property var blurGroupId: ""
    function findBlurGroupId(node) {
        if (!node) return "";
        if (node.blurGroupId) return node.blurGroupId;
        return findBlurGroupId(node.parent);
    }
    
    Component.onCompleted: {
        blurGroupId = findBlurGroupId(root.parent);
        if (blurGroupId) BlurRegistry.registerItem(blurGroupId, root);
    }
    Component.onDestruction: {
        if (blurGroupId) BlurRegistry.unregisterItem(blurGroupId, root);
    }

    HoverBackdrop {
        id: backdrop
        anchors.fill: parent
        radius: root.radius
        opacity: root.isPopup ? 1.0 : 0.8
        // Don't auto-register inside the card, as we handle it manually to ensures consistent grouping
        blurGroupId: "" 
    }

    // Urgency Border & Pulse
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border.width: (root.notification && root.notification.urgency >= 2) ? 2 : 0
        border.color: Colors.palette.maroon
        visible: border.width > 0
        
        OpacityAnimator on opacity {
            running: root.notification && root.notification.urgency >= 2
            from: 0.4; to: 1.0; duration: 1000; loops: Animation.Infinite
        }
    }

    Component.onCompleted: {
        if (root.notification) {
            console.log("NOTIF CARD: Created for " + root.notification.appName + " (summary: " + root.notification.summary + ")");
        } else {
            console.log("NOTIF CARD: Created with no notification object!");
        }
    }

    ColumnLayout {
        id: contentLayout
        anchors {
            fill: parent
            margins: 12
        }
        spacing: 4

        // App Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Image {
                source: {
                    if (!root.notification || !root.notification.appIcon) return "image://icon/dialog-information";
                    const icon = root.notification.appIcon;
                    if (icon.startsWith("/") || icon.startsWith("file://") || icon.startsWith("image://")) return icon;
                    return "image://icon/" + icon;
                }
                sourceSize.width: 16
                sourceSize.height: 16
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                fillMode: Image.PreserveAspectFit
            }
            
            StyledText {
                text: (root.notification && root.notification.appName) ? root.notification.appName : "Notification"
                font.pixelSize: 11
                font.bold: true
                color: Colors.palette.subtext1
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            // Close button
            MouseArea {
                width: 16; height: 16
                onClicked: root.dismiss()
                StyledText {
                    text: "󰅖"
                    font.pixelSize: 14
                    anchors.centerIn: parent
                    color: Colors.palette.subtext1
                    opacity: parent.containsMouse ? 1.0 : 0.6
                }
                hoverEnabled: true
            }
        }

        // Summary & Body
        StyledText {
            text: (root.notification && root.notification.summary) ? root.notification.summary : ""
            font.pixelSize: 14
            font.bold: true
            Layout.fillWidth: true
            elide: Text.ElideRight
            visible: text !== ""
        }

        StyledText {
            text: (root.notification && root.notification.body) ? root.notification.body : ""
            font.pixelSize: 12
            color: Colors.palette.text
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            maximumLineCount: root.isPopup ? 3 : 2
            elide: Text.ElideRight
            visible: text !== ""
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (root.notification) {
                root.notification.dismiss(); // Trigger default action
                root.dismiss();
            }
        }
    }
}
