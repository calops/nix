import QtQuick

PropertyAnimation {
    required property var target
    property: "opacity"
    to: 0
    duration: 300
    easing.type: Easing.Quad
}
