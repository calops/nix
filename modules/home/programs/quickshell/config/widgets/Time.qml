import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Effects

import "../services"
import "../animations"

Button {
    id: root

    background: Rectangle {
        id: background
        color: "transparent"
        radius: 500
    }

    contentItem: Column {
        StyledText {
            text: Datetime.hours
            color: Colors.palette.text
        }
        StyledText {
            text: Datetime.minutes
            color: Colors.palette.subtext0
        }
        StyledText {
            id: seconds
            text: Datetime.seconds
            color: Colors.palette.overlay0
        }
    }

    PropertyAnimation {
        id: unfocus
        target: background
        property: "color"
        to: "transparent"
        duration: 200
    }

    PropertyAnimation {
        id: focus
        target: background
        property: "color"
        to: "red"
        duration: 200
    }

    onHoveredChanged: {
        if (hovered) {
            focus.start();
        } else {
            unfocus.start();
        }
    }
}
