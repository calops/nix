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
        right: true
    }

    margins {
        top: 20
        right: 20
    }

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: Notifications.activePopups.count > 0

    implicitWidth: 320
    implicitHeight: popupList.contentHeight

    // Mask/Blur logic
    property string blurGroupId: "popupWindow"
    property var registeredBlurItems: BlurRegistry.getItemsForGroup(blurGroupId)
    onRegisteredBlurItemsChanged: updateBlurRegion()

    Item { id: offscreenAnchor; x: -9999; y: -9999; visible: true; opacity: 0.0 }

    function updateBlurRegion() {
        var items = registeredBlurItems || [];
        
        var blurStr = "import Quickshell; import Quickshell.Wayland; Region {\n";
        if (items.length === 0) {
            blurStr += "    Region { item: offscreenAnchor }\n";
        } else {
            for (var i = 0; i < items.length; i++) {
                blurStr += "    property var item" + i + ": popupWindow.registeredBlurItems[" + i + "];\n";
                blurStr += "    Region { item: item" + i + " || offscreenAnchor; radius: typeof item" + i + " !== 'undefined' && item" + i + " ? (item" + i + ".radius || 0) : 0 }\n";
            }
        }
        blurStr += "}";
        if (popupWindow.BackgroundEffect.blurRegion) popupWindow.BackgroundEffect.blurRegion.destroy();
        popupWindow.BackgroundEffect.blurRegion = Qt.createQmlObject(blurStr, popupWindow, "dynamicBlurRegionPopup");

        if (popupWindow.mask) popupWindow.mask.destroy();
        popupWindow.mask = Qt.createQmlObject(blurStr, popupWindow, "dynamicMaskPopup");
    }

    ListView {
        id: popupList
        width: parent.width
        height: contentHeight
        spacing: 12
        interactive: false
        model: Notifications.activePopups

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
                running: interval > 0 && popupWindow.visible
                onTriggered: {
                    if (delegateRoot.notification) {
                        console.log("POPUP: Auto-hide triggered for [" + delegateRoot.notification.id + "]");
                        Notifications.hidePopup(delegateRoot.notification);
                    }
                }
            }
        }
    }
}
