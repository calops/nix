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
    visible: Notifications.activePopups.length > 0

    implicitWidth: 320
    implicitHeight: popupList.contentHeight

    // Mask/Blur logic
    property string blurGroupId: "popupWindow"
    property var registeredBlurItems: BlurRegistry.getItemsForGroup(blurGroupId)
    onRegisteredBlurItemsChanged: updateBlurRegion()

    Item { id: offscreenAnchor; x: -9999; y: -9999; visible: true; opacity: 0.0 }

    function updateBlurRegion() {
        var items = registeredBlurItems || [];
        
        // Blur Region
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

        // Mask (identical to blur region for popups)
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

        move: Transition {
            NumberAnimation { properties: "y"; duration: Theme.animationDuration; easing.type: Easing.OutCubic }
        }

        remove: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: Theme.animationDurationOut }
            NumberAnimation { property: "scale"; to: 0.95; duration: Theme.animationDurationOut }
        }

        delegate: NotificationCard {
            id: card
            notification: modelData
            isPopup: true
            radius: 12
            
            // Set the modelData (notification object) as a property for the card
            // so the dismissal logic can work correctly
            onDismiss: {
                if (modelData) {
                    Notifications.removePopup(modelData);
                }
            }

            Timer {
                interval: {
                    if (!modelData || modelData.urgency === NotificationUrgency.Critical) return 0;
                    if (modelData.expireTimeout > 0) return modelData.expireTimeout;
                    return 8000;
                }
                running: interval > 0 && popupWindow.visible
                onTriggered: {
                    if (modelData) Notifications.removePopup(modelData);
                }
            }
        }
    }
}
