pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: true
        imageSupported: true
        inlineReplySupported: true
        persistenceSupported: true
        
        onNotification: (notification) => {
            console.log("NOTIF SERVICE: Received [" + notification.id + "] from " + notification.appName + " (lastGen: " + notification.lastGeneration + ")");
            
            notification.tracked = true;

            // --- State Tracking ---
            // isDismissed: permanently removed from active view (archived)
            // isUnseen: brand new, user hasn't opened widget yet

            // 1. Update/Add to history model
            let entry = getHistoryEntry(notification.id);
            if (!entry) {
                historyModel.insert(0, {
                    "notif": notification,
                    "notifId": notification.id,
                    "isDismissed": false,
                    "isUnseen": !notification.lastGeneration
                });
            } else {
                // If it's an update to an existing one, ensure it's "revived" if needed
                // but usually Quickshell updates existing objects.
                entry.notif = notification;
            }

            // 2. Add to popups if it's NOT a reload and NOT already open
            if (!notification.lastGeneration && !isCenterOpen) {
                // Ensure not already in popups (duplicate check)
                if (!isPopupPresent(notification.id)) {
                    activePopups.append({
                        "notif": notification,
                        "notifId": notification.id
                    });
                    unseenCount++;
                }
            }
            
            updateMaxUrgency();

            notification.closed.connect((reason) => {
                console.log("NOTIF SERVICE: Signal closed for [" + notification.id + "] reason: " + reason);
                removePopupById(notification.id);
                
                // archive it in history
                let hEntry = getHistoryEntry(notification.id);
                if (hEntry) {
                    // Using setProperty for reliable reactive updates in Delegates
                    for (let i = 0; i < historyModel.count; i++) {
                        if (historyModel.get(i).notifId === notification.id) {
                            historyModel.setProperty(i, "isDismissed", true);
                            break;
                        }
                    }
                }
                
                updateMaxUrgency();
            });
        }
    }

    readonly property ListModel historyModel: ListModel {}
    readonly property ListModel activePopups: ListModel {}

    property int unseenCount: 0
    property int maxUrgency: NotificationUrgency.Low
    property bool isCenterOpen: false

    onIsCenterOpenChanged: {
        if (isCenterOpen) {
            unseenCount = 0;
            activePopups.clear();
            // Mark all non-dismissed ones as seen
            for (let i = 0; i < historyModel.count; i++) {
                historyModel.setProperty(i, "isUnseen", false);
            }
        }
    }

    function getHistoryEntry(id) {
        for (let i = 0; i < historyModel.count; i++) {
            if (historyModel.get(i).notifId === id) return historyModel.get(i);
        }
        return null;
    }

    function isPopupPresent(id) {
        for (let i = 0; i < activePopups.count; i++) {
            if (activePopups.get(i).notifId === id) return true;
        }
        return false;
    }

    function updateMaxUrgency() {
        let max = NotificationUrgency.Low;
        // Check history for non-dismissed ones
        for (let i = 0; i < historyModel.count; i++) {
            let entry = historyModel.get(i);
            if (!entry.isDismissed && entry.notif) {
                if (entry.notif.urgency > max) max = entry.notif.urgency;
            }
        }
        maxUrgency = max;
    }

    function removePopupById(id) {
        for (let i = 0; i < activePopups.count; i++) {
            if (activePopups.get(i).notifId === id) {
                activePopups.remove(i);
                return;
            }
        }
    }

    function hidePopup(notification) {
        if (!notification) return;
        removePopupById(notification.id);
    }

    function dismiss(notification) {
        if (!notification) return;
        console.log("NOTIF SERVICE: Manually dismissing [" + notification.id + "]");
        notification.tracked = false; 
    }

    function clearAll() {
        console.log("NOTIF SERVICE: Clearing all history");
        // Only dismiss currently active (non-dismissed) notifications
        for (let i = 0; i < historyModel.count; i++) {
            let entry = historyModel.get(i);
            if (!entry.isDismissed && entry.notif) {
                entry.notif.tracked = false;
            }
        }
        activePopups.clear();
        historyModel.clear();
        unseenCount = 0;
        maxUrgency = NotificationUrgency.Low;
    }
}
