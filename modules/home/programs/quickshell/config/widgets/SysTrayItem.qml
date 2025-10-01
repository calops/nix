pragma ComponentBehavior: Bound

import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

Image {
    id: icon
    required property SystemTrayItem modelData
    Layout.alignment: Qt.AlignCenter
    source: modelData.icon
    sourceSize.width: 16
    sourceSize.height: 16
}
