import QtQuick

PropertyAnimation {
    required property var target
    property: "opacity"
    to: 0
    duration: Theme.animationDurationOut
    easing.type: Easing.Quad
}
