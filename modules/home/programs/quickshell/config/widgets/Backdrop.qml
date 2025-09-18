import QtQuick
import "../services"
import "../animations/"

Rectangle {
    id: root
    property bool enabled: false

    width: parent.width
    height: parent.height
    opacity: enabled ? 1 : 0

    gradient: Gradient {
        id: gradient
        orientation: Gradient.Horizontal

        GradientStop {
            position: 0.0
            color: Colors.alpha(Colors.palette.crust, 1.0)
        }

        GradientStop {
            position: 0.5
            color: Colors.alpha(Colors.palette.crust, 0.65)
        }

        GradientStop {
            position: 1.0
            color: Colors.alpha(Colors.palette.crust, 0.0)
        }
    }

    Behavior on opacity {
        NumberAnimation {
            target: root
            property: "opacity"
            easing.type: Easing.Quad
        }
    }
}
