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

        onNotification: notification => {
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

            // 2. Add to popups if it's NOT a reload
            // Note: popups are independent from overlay - they coexist
            if (!notification.lastGeneration) {
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
            rebuildOverlayModel();

            // Only attach closed handler once per notification ID
            if (!handlerAttached[notification.id]) {
                handlerAttached[notification.id] = true;
                notification.closed.connect(reason => {
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

                    // Clean up handler tracking
                    delete handlerAttached[notification.id];

                    updateMaxUrgency();
                    rebuildOverlayModel();
                    pruneHistory();
                });
            }
        }
    }

    readonly property ListModel historyModel: ListModel {}
    readonly property ListModel activePopups: ListModel {}

    // Sorted model for overlay: urgency DESC, then timestamp DESC
    // Built from historyModel filtered to non-dismissed
    readonly property ListModel overlayModel: ListModel {}

    // Track which notifications already have closed handlers attached
    readonly property var handlerAttached: ({})

    // Prune old dismissed notifications when history exceeds this count
    readonly property int maxHistorySize: 50

    // Prune dismissed notifications from history to prevent unbounded growth
    function pruneHistory() {
        // Remove dismissed notifications from the end (oldest) first
        // Iterate backwards to safely remove while iterating
        let removed = 0;
        for (let i = historyModel.count - 1; i >= 0 && historyModel.count > maxHistorySize; i--) {
            let entry = historyModel.get(i);
            if (entry && entry.isDismissed) {
                historyModel.remove(i);
                removed++;
            }
        }
    }

    property int unseenCount: 0
    property int maxUrgency: NotificationUrgency.Low
    property bool isCenterOpen: false

    onIsCenterOpenChanged: {
        if (isCenterOpen) {
            unseenCount = 0;
            // Mark all non-dismissed ones as seen
            for (let i = 0; i < historyModel.count; i++) {
                historyModel.setProperty(i, "isUnseen", false);
            }
        }
        // Note: we do NOT clear activePopups - overlay and popups are independent
    }

    // Rebuild overlayModel from historyModel, sorted by urgency then timestamp
    function rebuildOverlayModel() {
        // Collect non-dismissed entries
        let entries = [];
        for (let i = 0; i < historyModel.count; i++) {
            let entry = historyModel.get(i);
            if (!entry.isDismissed && entry.notif) {
                entries.push({
                    notif: entry.notif,
                    notifId: entry.notifId,
                    urgency: entry.notif.urgency || 0,
                    time: entry.notif.time || 0
                });
            }
        }

        // Sort: urgency DESC, then time DESC
        entries.sort((a, b) => {
            if (a.urgency !== b.urgency)
                return b.urgency - a.urgency;
            return b.time - a.time;
        });

        // Rebuild model
        overlayModel.clear();
        for (let e of entries) {
            overlayModel.append({
                "notif": e.notif,
                "notifId": e.notifId
            });
        }
    }

    function getHistoryEntry(id) {
        for (let i = 0; i < historyModel.count; i++) {
            if (historyModel.get(i).notifId === id)
                return historyModel.get(i);
        }
        return null;
    }

    function isPopupPresent(id) {
        for (let i = 0; i < activePopups.count; i++) {
            if (activePopups.get(i).notifId === id)
                return true;
        }
        return false;
    }

    function updateMaxUrgency() {
        let max = NotificationUrgency.Low;
        // Check history for non-dismissed ones
        for (let i = 0; i < historyModel.count; i++) {
            let entry = historyModel.get(i);
            if (!entry.isDismissed && entry.notif) {
                if (entry.notif.urgency > max)
                    max = entry.notif.urgency;
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
        if (!notification)
            return;
        removePopupById(notification.id);
    }

    function dismiss(notification) {
        if (!notification)
            return;
        notification.tracked = false;
    }

    function clearAll() {
        // Only dismiss currently active (non-dismissed) notifications
        for (let i = 0; i < historyModel.count; i++) {
            let entry = historyModel.get(i);
            if (!entry.isDismissed && entry.notif) {
                entry.notif.tracked = false;
            }
        }
        activePopups.clear();
        historyModel.clear();
        overlayModel.clear();
        unseenCount = 0;
        maxUrgency = NotificationUrgency.Low;
    }
}
