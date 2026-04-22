pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    // =========================================================================
    // Limits and Constants
    // =========================================================================

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
        // TODO: re-enable keepOnReload once dismissed/expired notifications are properly
        // untracked so they don't revive on reload
        keepOnReload: false

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
        interval: 100
        repeat: true
        running: root.transientCount > 0

        onTriggered: {
            const now = Date.now();
            for (let i = notificationModel.count - 1; i >= 0; i--) {
                const entry = notificationModel.get(i);
                if (!entry.isTransient)
                    continue;

                const notification = entry.notification;
                if (!notification)
                    continue;

                if (notification.urgency === NotificationUrgency.Critical)
                    continue;

                if (root.isInProgress(notification.hints))
                    continue;

                if (!entry.isDisplayed)
                    continue;

                const elapsed = entry.elapsedDisplayTime + (entry.displayStartTime > 0 ? now - entry.displayStartTime : 0);
                const timeoutMs = entry.expireTimeout * 1000;

                if (elapsed >= timeoutMs) {
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

        for (let i = 0; i < notificationModel.count; i++) {
            const entry = notificationModel.get(i);
            if (entry.notificationId === notificationId) {
                notificationModel.setProperty(i, "notification", notification);
                notificationModel.setProperty(i, "isTransient", true);
                notificationModel.setProperty(i, "isUnseen", true);
                notificationModel.setProperty(i, "elapsedDisplayTime", 0);
                notificationModel.setProperty(i, "displayStartTime", 0);
                notificationModel.setProperty(i, "isDisplayed", false);
                notificationModel.setProperty(i, "isDismissed", false);
                notificationModel.setProperty(i, "isExpired", false);

                const timeout = notification.expireTimeout > 0 ? notification.expireTimeout : root.defaultTimeout;
                notificationModel.setProperty(i, "expireTimeout", timeout);

                root.recomputeCounts();
                return;
            }
        }

        const timeout = notification.expireTimeout > 0 ? notification.expireTimeout : root.defaultTimeout;

        notificationModel.append({
            notification: notification,
            notificationId: notificationId,
            isTransient: true,
            isUnseen: true,
            isDismissed: false,
            isExpired: false,
            isDisplayed: false,
            elapsedDisplayTime: 0,
            displayStartTime: 0,
            expireTimeout: timeout
        });

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
        if (index < 0 || index >= notificationModel.count)
            return;

        const entry = notificationModel.get(index);
        if (entry.isDismissed)
            return;

        notificationModel.setProperty(index, "isExpired", true);
        notificationModel.setProperty(index, "isTransient", false);

        root.recomputeCounts();
    }

    function dismissNotificationAtIndex(index) {
        if (index < 0 || index >= notificationModel.count)
            return;

        const entry = notificationModel.get(index);
        if (entry.isDismissed)
            return;

        notificationModel.setProperty(index, "isDismissed", true);

        root.recomputeCounts();
    }

    function dismissById(id) {
        const idx = root.findIndexById(id);
        if (idx >= 0) {
            root.dismissNotificationAtIndex(idx);
            return true;
        }
        return false;
    }

    function removeById(id) {
        const idx = root.findIndexById(id);
        if (idx < 0)
            return;
        const entry = notificationModel.get(idx);
        if (entry.notification)
            entry.notification.dismiss();
        notificationModel.remove(idx);
        root.recomputeCounts();
    }

    function removeByIdSilent(id) {
        const idx = root.findIndexById(id);
        if (idx < 0)
            return;
        notificationModel.remove(idx);
        root.recomputeCounts();
    }

    function finalizeExpiredById(id) {
        const idx = root.findIndexById(id);
        if (idx < 0)
            return;
        const entry = notificationModel.get(idx);
        if (entry.notification)
            entry.notification.expire();
    }

    function invokeAction(notification, actionIndex) {
        if (!notification || !notification.actions || actionIndex < 0)
            return;
        if (actionIndex >= notification.actions.length)
            return;

        const action = notification.actions[actionIndex];
        action.invoke();
    }

    function sendInlineReply(notification, text) {
        if (!notification || !notification.hasInlineReply)
            return;
        notification.sendInlineReply(text);
    }

    function isInProgress(hints) {
        if (!hints)
            return false;
        const value = hints["value"];
        if (value === undefined || value === null)
            return false;
        return value < 100;
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

    function setDisplayShown(notificationId, shown) {
        const idx = root.findIndexById(notificationId);
        if (idx < 0)
            return;

        const entry = notificationModel.get(idx);
        const now = Date.now();

        if (shown) {
            if (entry.isDisplayed)
                return;

            notificationModel.setProperty(idx, "isDisplayed", true);
            if (!root.timerFrozen) {
                notificationModel.setProperty(idx, "displayStartTime", now);
            }
        } else {
            if (entry.displayStartTime > 0) {
                notificationModel.setProperty(idx, "elapsedDisplayTime", entry.elapsedDisplayTime + (now - entry.displayStartTime));
                notificationModel.setProperty(idx, "displayStartTime", 0);
            }
            notificationModel.setProperty(idx, "isDisplayed", false);
        }
    }

    // =========================================================================
    // Timer Freeze Management (called by UI)
    // =========================================================================

    function setTimerFrozen(frozen) {
        if (root.timerFrozen === frozen)
            return;

        const now = Date.now();

        if (frozen) {
            for (let i = 0; i < notificationModel.count; i++) {
                const entry = notificationModel.get(i);
                if (entry.isDisplayed && entry.displayStartTime > 0) {
                    notificationModel.setProperty(i, "elapsedDisplayTime", entry.elapsedDisplayTime + (now - entry.displayStartTime));
                    notificationModel.setProperty(i, "displayStartTime", 0);
                }
            }
        } else {
            for (let i = 0; i < notificationModel.count; i++) {
                const entry = notificationModel.get(i);
                if (entry.isDisplayed) {
                    notificationModel.setProperty(i, "displayStartTime", now);
                }
            }
        }

        root.timerFrozen = frozen;
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
            if (entry.isDismissed)
                continue;

            if (entry.isTransient)
                tCount++;
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
                isDisplayed: entry.isDisplayed,
                urgency: entry.notification?.urgency || 0,
                elapsedDisplayTime: entry.elapsedDisplayTime,
                displayStartTime: entry.displayStartTime
            });
        }
        return result;
    }

    Component.onCompleted: {
        console.log("[Notifications] Service initialized");
    }
}
