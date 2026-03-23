import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../services"
import "../components"

PanelWindow {
    id: popupWindow
    screen: Quickshell.screens[0]

    anchors {
        top: true
        bottom: true
        right: true
    }

    margins {
        top: 20
        right: 100
    }

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: true

    width: 320

    function updateBlurRegion() {
        // Accessing contentItem children which are the delegates
        let delegates = popupList.contentItem.children;

        // Construct an explicit surgical mask based on the actual items in the ListView.
        // We iterate through the visible items and extract their geometry relative to the window.
        let blurStr = "import Quickshell; import Quickshell.Wayland; Region {\n";
        blurStr += "    width: 0; height: 0\n"; // Force surgical union

        let found = false;
        for (let i = 0; i < delegates.length; i++) {
            let d = delegates[i];
            // Only include actual visible cards that aren't marked for deletion
            if (d && d.width > 0 && d.height > 0 && d.opacity > 0.01) {
                // Map the delegate's geometry to the window
                let pos = d.mapToItem(popupWindow.contentItem, 0, 0);
                blurStr += "    Region { x: " + Math.round(pos.x) +
                           "; y: " + Math.round(pos.y) +
                           "; width: " + Math.round(d.width) +
                           "; height: " + Math.round(d.height) +
                           "; radius: 12 }\n";
                found = true;
            }
        }

        if (!found) {
            blurStr += "    Region { x: -9999; y: -9999; width: 1; height: 1 }\n";
        }

        blurStr += "}";

        if (popupWindow.BackgroundEffect.blurRegion) popupWindow.BackgroundEffect.blurRegion.destroy();
        popupWindow.BackgroundEffect.blurRegion = Qt.createQmlObject(blurStr, popupWindow, "dynamicBlurRegionPopup");

        if (popupWindow.mask) popupWindow.mask.destroy();
        popupWindow.mask = Qt.createQmlObject(blurStr, popupWindow, "dynamicMaskPopup");
    }

    // Refresh mask frequently to follow animations perfectly
    Timer {
        interval: 16
        running: true
        repeat: true
        onTriggered: popupWindow.updateBlurRegion()
    }

    ListView {
        id: popupList
        anchors.fill: parent
        spacing: 12
        interactive: false
        model: Notifications.activePopups

        opacity: count > 0 ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: Theme.animationDuration } }

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.animationDuration }
            NumberAnimation { property: "x"; from: 50; to: 0; duration: Theme.animationDuration; easing.type: Easing.OutCubic }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; to: 0; duration: Theme.animationDurationOut }
                NumberAnimation { property: "scale"; to: 0.8; duration: Theme.animationDurationOut }
                NumberAnimation { property: "x"; to: 100; duration: Theme.animationDurationOut; easing.type: Easing.InCubic }
            }
        }

        displaced: Transition {
            NumberAnimation { properties: "y"; duration: Theme.animationDuration; easing.type: Easing.OutQuad }
        }

        delegate: Item {
            id: delegateRoot
            width: popupList.width
            height: card.height

            readonly property var notification: model.notif

            NotificationCard {
                id: card
                notification: delegateRoot.notification
                isPopup: true
                radius: 12
                blurEnabled: false // We handle blur surgically at the window level now
                onDismiss: {
                    if (delegateRoot.notification) {
                        Notifications.dismiss(delegateRoot.notification);
                    }
                }
            }

            Timer {
                interval: {
                    if (!delegateRoot.notification || delegateRoot.notification.urgency === NotificationUrgency.Critical) return 0;
                    if (delegateRoot.notification.expireTimeout > 0) return delegateRoot.notification.expireTimeout;
                    return 8000;
                }
                running: interval > 0 && popupList.opacity > 0.5
                onTriggered: {
                    if (delegateRoot.notification) {
                        Notifications.hidePopup(delegateRoot.notification);
                    }
                }
            }
        }
    }
}
