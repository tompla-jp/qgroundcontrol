import QtQuick
import QGroundControl
import QGroundControl.Controls

Item {
    id: root
    // Vehicle is optionally passed in from MainView. Not used yet but kept
    // to match the call site and avoid property binding errors during load.
    property var vehicle
    property color warnColor: "#ff3b30"
    property color textColor: "#ffffff"
    visible: tofHandler && tofHandler.hasDistanceData

    implicitWidth: 160
    implicitHeight: 48

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: "#000000"
        opacity: 0.65
    }

    QGCLabel {
        anchors.centerIn: parent
        text: tofHandler
              ? (Number(tofHandler.distanceCm).toLocaleString(Qt.locale(), "f", 0) + qsTr(" cm"))
              : qsTr("-- cm")
        color: tofHandler && tofHandler.distanceCm <= 10 ? warnColor : textColor
        font.pixelSize: 20
        font.bold: true
    }
}
