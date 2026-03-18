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
            console.log("NOTIF SERVICE: New notification: " + notification.appName + " - " + notification.summary);
            
            // Explicitly track the notification to keep it alive
            notification.tracked = true;

            // Add to active popups array
            if (!isCenterOpen) {
                let popups = [...activePopups];
                popups.push(notification);
                activePopups = popups;
            }
            
            unseenCount++;
            updateMaxUrgency();

            // Connect to closed signal for cleanup
            notification.closed.connect((reason) => {
                console.log("NOTIF SERVICE: Notification closed: " + notification.summary);
                // Remove from popups
                let popups = activePopups.filter(n => n !== notification);
                if (popups.length !== activePopups.length) {
                    activePopups = popups;
                }
                updateMaxUrgency();
                root.historyChanged(); // Force update on property listeners
            });
            
            root.historyChanged(); // Force update
        }
    }

    // Direct access to the server's list of notifications
    readonly property var history: {
        root.historyChanged;
        return server.notifications;
    }
    
    // Notifications currently shown as toast popups
    property var activePopups: []

    property int unseenCount: 0
    property int maxUrgency: NotificationUrgency.Low
    
    property bool isCenterOpen: false

    onIsCenterOpenChanged: {
        if (isCenterOpen) {
            unseenCount = 0;
            activePopups = [];
        }
    }

    function updateMaxUrgency() {
        let max = NotificationUrgency.Low;
        const list = server.notifications;
        if (!list) return;
        for (let i = 0; i < list.length; i++) {
            if (list[i].urgency > max) {
                max = list[i].urgency;
            }
        }
        maxUrgency = max;
    }

    function removePopup(notification) {
        let popups = activePopups.filter(n => n !== notification);
        if (popups.length !== activePopups.length) {
            activePopups = popups;
        }
    }

    function clearAll() {
        const list = server.notifications;
        if (!list) return;
        
        // Use a standard loop
        for (let i = list.length - 1; i >= 0; i--) {
            list[i].dismiss();
        }
        
        activePopups = [];
        unseenCount = 0;
        maxUrgency = NotificationUrgency.Low;
        root.historyChanged();
    }
}
