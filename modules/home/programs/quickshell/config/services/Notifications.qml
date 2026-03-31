pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    // =========================================================================
    // Limits and Constants
    // =========================================================================

    readonly property int maxTransientCount: 5
    readonly property int maxShadeCount: 50
    readonly property real defaultTimeout: 10.0  // seconds

    // =========================================================================
    // Data Model
    // =========================================================================

    ListModel {
        id: notificationModel
    }

    // Expose model for UI binding
    readonly property alias model: notificationModel

    // =========================================================================
    // Computed Properties (read-only for UI)
    // =========================================================================

    property int transientCount: 0
    property int unseenCount: 0
    property int shadeCount: 0
    property bool hasCriticalUnseen: false

    // =========================================================================
    // NotificationServer Configuration
    // =========================================================================

    NotificationServer {
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true
        inlineReplySupported: true
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => {
            notification.tracked = true;
            root.handleNewNotification(notification);
        }
    }

    // =========================================================================
    // Expiration Timer (single aggregated timer)
    // =========================================================================

    property bool timerFrozen: false  // Set by UI when shade is open

    Timer {
        id: expirationCheckTimer
        interval: 100  // Check every 100ms
        repeat: true
        running: root.transientCount > 0

        onTriggered: {
            const now = Date.now();
            for (let i = notificationModel.count - 1; i >= 0; i--) {
                const entry = notificationModel.get(i);
                if (!entry.isTransient) continue;

                const notification = entry.notification;
                if (!notification) continue;

                // Critical notifications never auto-expire
                if (notification.urgency === NotificationUrgency.Critical) continue;

                // Calculate effective elapsed time accounting for frozen duration
                const totalElapsed = (now - entry.createdAt) / 1000;
                const effectiveElapsed = totalElapsed - (entry.frozenDuration / 1000);

                if (effectiveElapsed >= entry.expireTimeout) {
                    root.expireNotificationAtIndex(i);
                }
            }
        }
    }

    // =========================================================================
    // Core Functions
    // =========================================================================

    function handleNewNotification(notification) {
        const now = Date.now();
        const notificationId = notification.id;

        // Check for replacement (same ID)
        for (let i = 0; i < notificationModel.count; i++) {
            const entry = notificationModel.get(i);
            if (entry.notificationId === notificationId) {
                // Replace existing notification - reset timing
                notificationModel.setProperty(i, "notification", notification);
                notificationModel.setProperty(i, "createdAt", now);
                notificationModel.setProperty(i, "frozenDuration", 0);

                // Update expireTimeout in case it changed
                const timeout = notification.expireTimeout > 0 ? notification.expireTimeout : root.defaultTimeout;
                notificationModel.setProperty(i, "expireTimeout", timeout);

                // Re-trigger as transient if it was
                if (entry.isTransient && !entry.isDismissed) {
                    notificationModel.setProperty(i, "isUnseen", true);
                }
                root.recomputeCounts();
                console.log("[Notifications] Replaced notification ID:", notificationId);
                return;
            }
        }

        // Determine timeout
        const timeout = notification.expireTimeout > 0 ? notification.expireTimeout : root.defaultTimeout;

        // Add new notification
        notificationModel.append({
            notification: notification,
            notificationId: notificationId,
            isTransient: true,
            isUnseen: true,
            isDismissed: false,
            createdAt: now,
            frozenDuration: 0,  // Total time spent frozen (ms)
            freezeStartTime: root.timerFrozen ? now : 0,  // When current freeze started
            expireTimeout: timeout
        });

        console.log("[Notifications] New notification:", notification.appName || "Unknown", "-", notification.summary);

        // Handle transient overflow
        root.handleTransientOverflow();

        // Enforce shade limit
        root.enforceShadeLimit();

        root.recomputeCounts();
    }

    function findIndexById(notificationId) {
        for (let i = 0; i < notificationModel.count; i++) {
            if (notificationModel.get(i).notificationId === notificationId) {
                return i;
            }
        }
        return -1;
    }

    function expireNotificationAtIndex(index) {
        if (index < 0 || index >= notificationModel.count) return;

        const entry = notificationModel.get(index);
        console.log("[Notifications] Expired:", entry.notification?.summary || "unknown");

        // Move from transient to unseen (still visible in shade)
        notificationModel.setProperty(index, "isTransient", false);

        // Call expire on the notification object
        if (entry.notification) {
            entry.notification.expire();
        }

        root.recomputeCounts();
    }

    function dismissNotificationAtIndex(index) {
        if (index < 0 || index >= notificationModel.count) return;

        const entry = notificationModel.get(index);
        console.log("[Notifications] Dismissed:", entry.notification?.summary || "unknown");

        // Call dismiss on the notification object first
        if (entry.notification) {
            entry.notification.dismiss();
        }

        // Remove immediately from model
        notificationModel.remove(index);
        root.recomputeCounts();
    }

    function dismissById(id) {
        for (let i = 0; i < notificationModel.count; i++) {
            if (notificationModel.get(i).notificationId === id) {
                root.dismissNotificationAtIndex(i);
                return true;
            }
        }
        return false;
    }

    function invokeAction(notification, actionIndex) {
        if (!notification || !notification.actions || actionIndex < 0) return;
        if (actionIndex >= notification.actions.length) return;

        const action = notification.actions[actionIndex];
        console.log("[Notifications] Invoking action:", action.text);
        action.invoke();
    }

    function sendInlineReply(notification, text) {
        if (!notification || !notification.hasInlineReply) return;
        console.log("[Notifications] Sending inline reply");
        notification.sendInlineReply(text);
    }

    function markAllSeen() {
        for (let i = 0; i < notificationModel.count; i++) {
            notificationModel.setProperty(i, "isUnseen", false);
        }
        root.recomputeCounts();
    }

    function clearAll() {
        // Dismiss all and clear immediately
        for (let i = notificationModel.count - 1; i >= 0; i--) {
            const entry = notificationModel.get(i);
            if (entry.notification) {
                entry.notification.dismiss();
            }
        }
        notificationModel.clear();
        root.recomputeCounts();
    }

    function handleTransientOverflow() {
        // Count current transient notifications
        let transientCount = 0;
        for (let i = 0; i < notificationModel.count; i++) {
            if (notificationModel.get(i).isTransient && !notificationModel.get(i).isDismissed) {
                transientCount++;
            }
        }

        // If over limit, move oldest to unseen (no longer transient)
        while (transientCount > root.maxTransientCount) {
            for (let i = 0; i < notificationModel.count; i++) {
                const entry = notificationModel.get(i);
                if (entry.isTransient && !entry.isDismissed) {
                    notificationModel.setProperty(i, "isTransient", false);
                    transientCount--;
                    console.log("[Notifications] Overflow: moved to unseen:", entry.notification?.summary);
                    break;
                }
            }
        }
    }

    function enforceShadeLimit() {
        // Remove oldest non-transient entries if over limit
        while (notificationModel.count > root.maxShadeCount) {
            for (let i = 0; i < notificationModel.count; i++) {
                const entry = notificationModel.get(i);
                if (!entry.isTransient) {
                    notificationModel.remove(i);
                    console.log("[Notifications] Shade limit: removed:", entry.notification?.summary);
                    break;
                }
            }
        }
    }

    // =========================================================================
    // Timer Freeze Management (called by UI)
    // =========================================================================

    function setTimerFrozen(frozen) {
        if (root.timerFrozen === frozen) return;

        const now = Date.now();

        if (frozen) {
            // Starting freeze - record start time for each transient
            for (let i = 0; i < notificationModel.count; i++) {
                const entry = notificationModel.get(i);
                if (entry.isTransient && entry.freezeStartTime === 0) {
                    notificationModel.setProperty(i, "freezeStartTime", now);
                }
            }
        } else {
            // Ending freeze - accumulate frozen duration
            for (let i = 0; i < notificationModel.count; i++) {
                const entry = notificationModel.get(i);
                if (entry.isTransient && entry.freezeStartTime > 0) {
                    const additionalFrozen = now - entry.freezeStartTime;
                    notificationModel.setProperty(i, "frozenDuration", entry.frozenDuration + additionalFrozen);
                    notificationModel.setProperty(i, "freezeStartTime", 0);
                }
            }
        }

        root.timerFrozen = frozen;
        console.log("[Notifications] Timer frozen:", frozen);
    }

    // =========================================================================
    // Count Recomputation
    // =========================================================================

    function recomputeCounts() {
        let tCount = 0;
        let uCount = 0;
        let sCount = 0;
        let hasCritical = false;

        for (let i = 0; i < notificationModel.count; i++) {
            const entry = notificationModel.get(i);
            if (entry.isDismissed) continue;

            if (entry.isTransient) tCount++;
            if (entry.isUnseen) {
                uCount++;
                if (entry.notification && entry.notification.urgency === NotificationUrgency.Critical) {
                    hasCritical = true;
                }
            }
            sCount++;
        }

        root.transientCount = tCount;
        root.unseenCount = uCount;
        root.shadeCount = sCount;
        root.hasCriticalUnseen = hasCritical;
    }

    // =========================================================================
    // Debug Helpers
    // =========================================================================

    function getList() {
        const result = [];
        for (let i = 0; i < notificationModel.count; i++) {
            const entry = notificationModel.get(i);
            result.push({
                id: entry.notificationId,
                appName: entry.notification?.appName || "",
                summary: entry.notification?.summary || "",
                isTransient: entry.isTransient,
                isUnseen: entry.isUnseen,
                urgency: entry.notification?.urgency || 0,
                frozenDuration: entry.frozenDuration,
                freezeStartTime: entry.freezeStartTime
            });
        }
        return result;
    }

    Component.onCompleted: {
        console.log("[Notifications] Service initialized");
    }
}
