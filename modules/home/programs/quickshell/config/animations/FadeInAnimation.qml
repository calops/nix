import QtQuick

PropertyAnimation {
    required property var target
    property: "opacity"
    to: 1
    duration: 300
    easing.type: Easing.Quad
}
