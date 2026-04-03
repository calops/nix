import QtQuick
import "../services"

Text {
    id: root

    property string fontFamily: "Aporetic Sans"
    property int fontSize: 13
    property color textColor: Colors.palette.text
    property string rawText: ""

    font.family: root.fontFamily
    font.pixelSize: root.fontSize
    color: root.textColor
    textFormat: Text.RichText
    wrapMode: Text.WordWrap
    text: rawText !== "" ? ("<style>a { color: " + Colors.palette.peach + "; }</style>" + rawText) : ""

    onLinkActivated: (link) => Qt.openUrlExternally(link)

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}
