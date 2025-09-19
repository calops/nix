import QtQuick

import "../animations"
import "../services"

Text {
    id: self
    font.family: "Aporetic Sans Mono"
    font.pixelSize: 20
    color: Colors.palette.text

    Behavior on text {
        FadeReduceAnimation {
            target: self
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
