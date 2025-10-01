import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

ColumnLayout {
    id: layout
    width: 20

    Repeater {
        id: items
        model: SystemTray.items

        SysTrayItem {}
    }
}
