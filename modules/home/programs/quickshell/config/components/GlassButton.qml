import QtQuick
import QtQuick.Layouts
import "../services"

Item {
    id: root

    property string icon: ""
    property color iconColor: Colors.dark.text
    property int iconSize: 14
    property bool isActive: false
    property alias hovered: btnMouseArea.containsMouse

    // Tint color and per-state alpha values — override to customise appearance
    property color tintColor: Colors.dark.text
    property real normalAlpha: 0.10
    property real hoveredAlpha: 0.26
    property real activeAlpha: 0.32

    signal clicked()

    Layout.fillWidth: true
    Layout.preferredHeight: 36

    ShaderEffect {
        anchors.fill: parent

        property real radius: 8
        property color baseColor: Colors.alpha(root.tintColor,
            root.isActive ? root.activeAlpha : (root.hovered ? root.hoveredAlpha : root.normalAlpha))
        property real uWidth: width
        property real uHeight: height
        property real recessed: (root.isActive || btnMouseArea.pressed) ? 1.0 : 0.0

        // Multi-shape defaults (silence warnings)
        property rect rect1: Qt.rect(0, 0, 0, 0)
        property rect rect2: Qt.rect(0, 0, 0, 0)
        property rect rect3: Qt.rect(0, 0, 0, 0)
        property real radius1: 0
        property real radius2: 0
        property real radius3: 0
        property real smoothness: 0
        property variant imageSource: null
        property real useImage: 0.0

        fragmentShader: Shaders.get("glass")

        Behavior on baseColor { ColorAnimation { duration: Theme.animationDurationFast } }
        Behavior on recessed { NumberAnimation { duration: Theme.animationDurationFast } }
    }

    StyledText {
        id: label
        text: root.icon
        font.pixelSize: root.iconSize
        color: root.iconColor
        Behavior on color { ColorAnimation { duration: Theme.animationDuration } }
    }

    implicitWidth: label.implicitWidth + 16
    implicitHeight: Math.max(36, label.implicitHeight + 16)

    MouseArea {
        id: btnMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
