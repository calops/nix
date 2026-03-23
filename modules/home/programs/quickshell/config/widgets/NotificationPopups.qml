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

    property var registeredBlurItems: BlurRegistry.getItemsForGroup("notificationScope")
    onRegisteredBlurItemsChanged: updateBlurRegion()

    Item {
        id: offscreenAnchor
        x: -9999
        y: -9999
        width: 1
        height: 1
        visible: true
        opacity: 0.0
    }

    function updateBlurRegion() {
        let items = registeredBlurItems || [];

        // Blur Region
        let blurStr = "import Quickshell; import Quickshell.Wayland; Region {\n";
        if (items.length === 0) {
            blurStr += "    Region { item: offscreenAnchor }\n";
        } else {
            for (let i = 0; i < items.length; i++) {
                blurStr += "    property var item" + i + ": popupWindow.registeredBlurItems[" + i + "];\n";
                blurStr += "    Region { item: item" + i + " || offscreenAnchor; radius: typeof item" + i + " !== 'undefined' && item" + i + " ? (item" + i + ".radius || 0) : 0 }\n";
            }
        }
        blurStr += "}";
        if (popupWindow.BackgroundEffect.blurRegion)
            popupWindow.BackgroundEffect.blurRegion.destroy();
        popupWindow.BackgroundEffect.blurRegion = Qt.createQmlObject(blurStr, popupWindow, "dynamicBlurRegionPopup");

        // Window Mask (same regions as blur)
        if (popupWindow.mask)
            popupWindow.mask.destroy();
        popupWindow.mask = Qt.createQmlObject(blurStr, popupWindow, "dynamicMaskPopup");
    }

    Item {
        id: notificationScope
        anchors.fill: parent
        property string blurGroupId: "notificationScope"

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
                    blurEnabled: true
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
}
