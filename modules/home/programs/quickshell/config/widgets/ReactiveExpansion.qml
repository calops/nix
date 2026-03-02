import QtQuick

QtObject {
    id: root

    // The value to watch for changes
    property var watchValue

    // If true, changes to watchValue will be ignored
    property bool ignore: false

    // Duration the expansion stays active
    property int duration: 2000

    // Read-only state indicating if the expansion should be active
    readonly property bool active: timer.running

    // Use a regular property for _lastValue to avoid binding it to watchValue
    property var _lastValue: undefined

    onWatchValueChanged: {
        // Only trigger if we have a previous value and it's different and not ignored
        if (!ignore && _lastValue !== undefined && watchValue !== _lastValue) {
            timer.restart();
        }
        _lastValue = watchValue;
    }

    property Timer timer: Timer {
        id: timer
        interval: root.duration
        onTriggered: running = false
    }
}
