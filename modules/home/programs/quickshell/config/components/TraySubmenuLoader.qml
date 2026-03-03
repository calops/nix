import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell

// TraySubmenuLoader.qml
// A thin wrapper used exclusively to break the QML infinite recursion detection
// when a TrayMenu needs to spawn another TrayMenu.
Item {
    id: root

    property var tray: null
    property var parentWindow: null
    property var sourceItem: null
    property var menuModel: null
    
    // Pass the actual instantiated item up to the parent
    property Item childMenuItem: menuInstance

    TrayMenu {
        id: menuInstance
        isSubmenu: true
        tray: root.tray
        parentWindow: root.parentWindow
        sourceItem: root.sourceItem
        menuModel: root.menuModel
    }
}
