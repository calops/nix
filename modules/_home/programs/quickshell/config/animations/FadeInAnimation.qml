import QtQuick

PropertyAnimation {
    required property var target
    property: "opacity"
    to: 1
    duration: Theme.animationDuration
    easing.type: Easing.Quad
}
