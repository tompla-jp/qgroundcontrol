import QtQuick
import QGroundControl.FlightDisplay
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QtQuick.Controls

Item {
    id: root
    property string url: ""
    property string label: ""
    property var receiver: null
    property alias surfaceItem: videoSurface
    readonly property bool _hasHandler: typeof videoHandler !== "undefined" && videoHandler !== null
    readonly property bool _displaySwapped: _hasHandler ? videoHandler.displaySwapped : false
    readonly property bool _streaming: _hasHandler ? (_displaySwapped ? videoHandler.subStreaming : videoHandler.mainStreaming) : false
    readonly property bool _hasUrl: url && url.length > 0

    FlightDisplayViewGStreamer {
        id: videoSurface
        objectName: "mainVideoSurface"
        anchors.fill: parent
        receiver: root.receiver
    }

    // 映像が未受信時の待機メッセージ（やや上寄せ）
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -parent.height * 0.18
        visible: !_streaming
        spacing: 6

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#00000080"
            radius: 6
            border.color: "#444"
            border.width: 1

            QGCLabel {
                id: waitLabel
                text: qsTr("映像待機中")
                color: "#ffffff"
                font.pointSize: ScreenTools.defaultFontPointSize
                horizontalAlignment: Text.AlignHCenter
                anchors.centerIn: parent
            }

            implicitWidth: waitLabel.implicitWidth + ScreenTools.defaultFontPixelWidth * 2
            implicitHeight: waitLabel.implicitHeight + ScreenTools.defaultFontPixelHeight
        }
    }

    // ストリームが落ちている場合の再起動リトライ
    Timer {
        interval: 3000
        running: _hasHandler && _hasUrl && !_streaming
        repeat: true
        onTriggered: {
            if (_hasHandler) {
                if (_displaySwapped) {
                    videoHandler.restartSubStream()
                } else {
                    videoHandler.restartMainStream()
                }
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 8
        radius: 4
        color: "#000000"
        opacity: 0.55

        Row {
            spacing: 6
            anchors.margins: 6
            anchors.fill: parent
            QGCLabel {
                text: label.length ? label : qsTr("Main")
                color: "#ffffff"
            }
            QGCLabel {
                text: url
                color: "#b0bec5"
            }
        }
    }
}
