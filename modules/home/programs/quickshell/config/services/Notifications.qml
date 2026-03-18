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
            notification.tracked = true;

            historyModel.insert(0, {
                "notif": notification,
                "notifId": notification.id
            });

            if (!isCenterOpen) {
                activePopups.append({
                    "notif": notification,
                    "notifId": notification.id
                });
            }
            
            unseenCount++;
            updateMaxUrgency();

            notification.closed.connect((reason) => {
                removePopupById(notification.id);
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
        }
    }

    function updateMaxUrgency() {
        let max = NotificationUrgency.Low;
        const list = server.notifications;
        if (!list) return;
        for (let i = 0; i < list.length; i++) {
            if (list[i].urgency > max) max = list[i].urgency;
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

    function removeHistoryById(id) {
        for (let i = 0; i < historyModel.count; i++) {
            if (historyModel.get(i).notifId === id) {
                historyModel.remove(i);
                return;
            }
        }
    }

    function dismiss(notification) {
        if (!notification) return;
        notification.dismiss();
        removePopupById(notification.id);
        removeHistoryById(notification.id);
    }

    function clearAll() {
        const list = server.notifications;
        if (list) {
            const copy = [];
            for (let i = 0; i < list.length; i++) copy.push(list[i]);
            for (let i = copy.length - 1; i >= 0; i--) {
                copy[i].dismiss();
            }
        }
        activePopups.clear();
        historyModel.clear();
        unseenCount = 0;
        maxUrgency = NotificationUrgency.Low;
    }
}
