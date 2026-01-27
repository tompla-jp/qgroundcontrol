import QtQuick
import QGroundControl
import QGroundControl.Controls

Item {
    id: compass
    property var vehicle
    property real heading: vehicle && vehicle.heading ? vehicle.heading.value : 0

    implicitWidth: 120
    implicitHeight: 120

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const cx = width / 2
            const cy = height / 2
            const radius = Math.min(width, height) / 2 - 4

            ctx.beginPath()
            ctx.arc(cx, cy, radius, 0, 2 * Math.PI)
            ctx.strokeStyle = "#ffffff"
            ctx.lineWidth = 2
            ctx.stroke()

            const angle = (heading * Math.PI / 180)
            const pointerLength = radius - 6
            const px = cx + Math.sin(angle) * pointerLength
            const py = cy - Math.cos(angle) * pointerLength

            ctx.beginPath()
            ctx.moveTo(cx, cy)
            ctx.lineTo(px, py)
            ctx.strokeStyle = "#2b2b2b"
            ctx.lineWidth = 3
            ctx.stroke()
        }
    }

    QGCLabel {
        anchors.centerIn: parent
        text: Qt.formatNumber(heading, 0) + "°"
        color: "#ffffff"
        font.pixelSize: 18
        font.bold: true
    }
}
