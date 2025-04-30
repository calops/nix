import QtQuick
import "../services"

Text {
    color: "white"
    text: Datetime.hours + "\n" + Datetime.minutes
    font.family: "Aporetic Sans Mono"
    font.pixelSize: 20
}
