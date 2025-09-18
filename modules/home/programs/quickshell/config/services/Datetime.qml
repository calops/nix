pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: datetime
    property var date
    property string time
    property string hours
    property string minutes
    property string seconds

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: datetime.updateDate()
    }

    function updateDate() {
        date = new Date();
        time = date.toTimeString();
        [hours, minutes, seconds] = time.split(":");
    }
}
