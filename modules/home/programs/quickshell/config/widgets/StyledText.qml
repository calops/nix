import QtQuick

import "../animations"
import "../services"

Text {
    id: root
    font.family: "Aporetic Sans Mono"
    font.pixelSize: 20
    color: Colors.palette.text
    x: parent.width / 2 - width / 2

    Behavior on text {
        FadeReduceAnimation {
            target: root
        }
    }

    Behavior on color {
        PropertyAnimation {
            target: root
            property: "color"
            easing.type: Easing.OutQuad
        }
    }

    // MultiEffect {
    //     source: self
    //     anchors.fill: self
    //     shadowBlur: 0.2
    //     shadowEnabled: true
    //     shadowColor: "black"
    //     shadowVerticalOffset: 3
    //     shadowHorizontalOffset: 3
    // }
}
