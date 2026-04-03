import QtQuick
import "../services"

Item {
    id: root

    property real value: 0.0
    property color fillColor: Theme.backdropTint
    readonly property int barHeight: 8

    implicitWidth: parent ? parent.width : 100
    implicitHeight: barHeight + 16

    Rectangle {
        width: root.width
        height: root.barHeight
        radius: root.barHeight / 2
        color: Colors.alpha("#ffffff", 0.08)

        Rectangle {
            id: fill
            width: Math.max(root.barHeight, root.width * (root.value / 100))
            height: root.barHeight
            radius: root.barHeight / 2
            clip: true

            Rectangle {
                anchors.fill: parent
                radius: root.barHeight / 2
                color: root.fillColor

                Canvas {
                    id: stripeCanvas
                    anchors.fill: parent

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();

                        var lighter = Qt.rgba(
                            Math.min(1.0, root.fillColor.r + 0.15),
                            Math.min(1.0, root.fillColor.g + 0.15),
                            Math.min(1.0, root.fillColor.b + 0.15),
                            0.6
                        );

                        ctx.fillStyle = lighter;

                        var stripeWidth = 12;
                        var offset = (Date.now() / 80) % (stripeWidth * 2);

                        ctx.save();
                        ctx.beginPath();
                        for (var x = -stripeWidth * 2 + width + stripeWidth * 2; x < width + stripeWidth * 2; x += stripeWidth) {
                            ctx.moveTo(x, 0);
                            ctx.lineTo(x + stripeWidth / 2, height);
                            ctx.lineTo(x + stripeWidth, 0);
                        }
                        ctx.fill();
                        ctx.restore();
                    }

                    Timer {
                        id: stripeAnimTimer
                        interval: 16
                        repeat: true
                        running: root.value > 0 && root.value < 100
                        onTriggered: stripeCanvas.requestPaint()
                    }
                }
            }
        }
    }

    Row {
        width: root.width
        layoutDirection: Qt.RightToLeft

        StyledText {
            font.pixelSize: 11
            color: root.fillColor
            text: Math.round(root.value) + "%"
        }
    }
}
