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
    property bool blurEnabled: false

    signal dismiss()

    // Ensure we have a valid height even if content isn't ready
    width: parent ? parent.width : 0
    height: contentLayout.implicitHeight + 24

    // Cache properties to prevent "content collapse" when the notification object is closed
    readonly property string appName: (root.notification && root.notification.appName !== undefined) ? root.notification.appName : _lastAppName
    readonly property string summary: (root.notification && root.notification.summary !== undefined) ? root.notification.summary : _lastSummary
    readonly property string body: (root.notification && root.notification.body !== undefined) ? root.notification.body : _lastBody
    readonly property string appIcon: (root.notification && root.notification.appIcon !== undefined) ? root.notification.appIcon : _lastAppIcon
    readonly property int urgency: (root.notification && root.notification.urgency !== undefined) ? root.notification.urgency : _lastUrgency

    property string _lastAppName: "Notification"
    property string _lastSummary: ""
    property string _lastBody: ""
    property string _lastAppIcon: ""
    property int _lastUrgency: 0

    onNotificationChanged: {
        if (root.notification) {
            _lastAppName = root.notification.appName || "Notification";
            _lastSummary = root.notification.summary || "";
            _lastBody = root.notification.body || "";
            _lastAppIcon = root.notification.appIcon || "";
            _lastUrgency = root.notification.urgency || 0;
        }
    }

    // Find blurGroupId for backdrop
    property var _blurGroupId: ""
    function findBlurGroupId(node) {
        if (!node) return "";
        if (node.blurGroupId) return node.blurGroupId;
        return findBlurGroupId(node.parent);
    }

    Component.onCompleted: {
        _blurGroupId = findBlurGroupId(root.parent);
    }

    HoverBackdrop {
        id: backdrop
        anchors.fill: parent
        radius: root.radius
        opacity: root.isPopup ? 1.0 : 0.8
        blurGroupId: root.blurEnabled ? _blurGroupId : ""
    }

    // Urgency Border & Pulse
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border.width: root.urgency >= 2 ? 2 : 0
        border.color: Colors.palette.maroon
        visible: border.width > 0
        
        OpacityAnimator on opacity {
            running: root.urgency >= 2
            from: 0.4; to: 1.0; duration: 1000; loops: Animation.Infinite
        }
    }

    // Main Card Action (Default Action)
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (root.notification) {
                root.notification.dismiss();
                root.dismiss();
            }
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
                    if (!root.appIcon) return "image://icon/dialog-information";
                    if (root.appIcon.startsWith("/") || root.appIcon.startsWith("file://") || root.appIcon.startsWith("image://")) return root.appIcon;
                    return "image://icon/" + root.appIcon;
                }
                sourceSize.width: 16
                sourceSize.height: 16
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                fillMode: Image.PreserveAspectFit
            }
            
            StyledText {
                text: root.appName
                font.pixelSize: 11
                font.bold: true
                color: Colors.palette.subtext1
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            // Close button
            MouseArea {
                id: closeButtonMouseArea
                width: 24; height: 24
                onClicked: {
                    root.dismiss();
                }
                StyledText {
                    text: "󰅖"
                    font.pixelSize: 14
                    anchors.centerIn: parent
                    color: Colors.palette.subtext1
                    opacity: closeButtonMouseArea.containsMouse ? 1.0 : 0.6
                }
                hoverEnabled: true
            }
        }

        // Summary & Body
        StyledText {
            text: root.summary
            font.pixelSize: 14
            font.bold: true
            Layout.fillWidth: true
            elide: Text.ElideRight
            visible: text !== ""
        }

        StyledText {
            text: root.body
            font.pixelSize: 12
            color: Colors.palette.text
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            maximumLineCount: root.isPopup ? 3 : 2
            elide: Text.ElideRight
            visible: text !== ""
        }
    }
}
