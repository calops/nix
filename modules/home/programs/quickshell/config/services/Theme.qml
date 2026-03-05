pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: theme

    readonly property int widgetExpandedWidth: 260
    readonly property int iconWidth: 56
    
    // Global animation timings
    readonly property int animationDuration: 300
    readonly property int animationDurationOut: 250
    readonly property int animationDurationFast: 150
    
    // Unified Backdrop
    property color backdropTint: Colors.palette.crust
    property real backdropOpacity: 0.75
    
    // Feature toggles
    property bool enableThemeSwitchOnHover: false
}
