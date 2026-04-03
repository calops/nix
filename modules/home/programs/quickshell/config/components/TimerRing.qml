import QtQuick
import "../services"

Item {
    id: root

    property real progress: 1.0
    property bool isInProgress: false
    property bool isCritical: false
    property color ringColor: Colors.palette.subtext0
    property color trackColor: Colors.palette.surface2

    readonly property int size: 22

    implicitWidth: size
    implicitHeight: size

    signal dismissed()

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var centerX = width / 2;
            var centerY = height / 2;
            var radius = Math.max(1, Math.min(width, height) / 2 - 2);
            var lineWidth = 2.5;

            // Background track
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, 0, Math.PI * 2, false);
            ctx.strokeStyle = Qt.rgba(root.trackColor.r, root.trackColor.g, root.trackColor.b, 0.4);
            ctx.lineWidth = lineWidth;
            ctx.stroke();

            if (!root.isCritical && !root.isInProgress) {
                // Timer arc: counterclockwise drain from 12 o'clock
                var startAngle = -Math.PI / 2;
                var endAngle = startAngle + (Math.PI * 2 * root.progress);
                var arcColor = root.ringColor;

                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, startAngle, endAngle, false);
                ctx.strokeStyle = Qt.rgba(arcColor.r, arcColor.g, arcColor.b, 1.0);
                ctx.lineWidth = lineWidth;
                ctx.lineCap = "round";
                ctx.stroke();
            }

            // Cross icon (normal + critical) or hourglass (in-progress)
            ctx.fillStyle = Qt.rgba(root.ringColor.r, root.ringColor.g, root.ringColor.b, 1.0);
            ctx.font = "bold 10px sans-serif";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";

            if (root.isInProgress) {
                ctx.fillText("\u23F3", centerX, centerY);
            } else if (root.isCritical) {
                ctx.fillText("!", centerX, centerY);
            } else {
                ctx.fillText("\u00D7", centerX, centerY);
            }
        }

        onProgressChanged: requestPaint()
        onIsInProgressChanged: requestPaint()
        onIsCriticalChanged: requestPaint()
        onRingColorChanged: requestPaint()
    }

    MouseArea {
        id: ringMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.dismissed()
        cursorShape: Qt.PointingHandCursor
    }

    HoverHandler {
        id: ringHover
        onHoveredChanged: canvas.requestPaint()
    }
}
