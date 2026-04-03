import QtQuick
import "../services"

Text {
    id: root

    property string fontFamily: "Aporetic Sans"
    property int fontSize: 13
    property color textColor: Colors.palette.text

    font.family: root.fontFamily
    font.pixelSize: root.fontSize
    color: root.textColor
    textFormat: Text.RichText
    wrapMode: Text.WordWrap
}
