import QtQuick

Rectangle {
    width: parent.width
    height: parent.height

    gradient: Gradient {
        orientation: Gradient.Horizontal

        GradientStop {
            position: 0.0
            color: Palette.alpha("red", 0.5)
        }

        GradientStop {
            position: 1.0
            color: Palette.alpha("base", 0.5)
        }
    }
}
