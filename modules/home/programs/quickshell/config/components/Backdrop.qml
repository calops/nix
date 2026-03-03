import QtQuick
import "../services"

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
            position: 0.6
            color: Colors.alpha(Colors.palette.crust, 0.65)
        }

        GradientStop {
            position: 1.0
            color: Colors.alpha(Colors.palette.crust, 0.0)
        }
    }

    Behavior on opacity {
        PropertyAnimation {
            target: root
            property: "opacity"
            easing.type: Easing.OutQuad
        }
    }
}
