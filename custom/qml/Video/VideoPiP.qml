import QtQuick
import QtQuick.Window
import QGroundControl.FlightDisplay
import QGroundControl.Controls
import QGroundControl.ScreenTools 1.0
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    property string url: ""
    property string label: ""
    property var receiver: null
    property alias surfaceItem: videoSurface
    readonly property bool _hasHandler: typeof videoHandler !== "undefined" && videoHandler !== null
    readonly property bool _displaySwapped: _hasHandler ? videoHandler.displaySwapped : false
    readonly property bool _streaming: _hasHandler ? (_displaySwapped ? videoHandler.mainStreaming : videoHandler.subStreaming) : false
    readonly property bool _hasUrl: url && url.length > 0
    readonly property int _retryDelayMinMs: 10000
    readonly property int _retryDelayMaxMs: 30000
    property int _retryDelayMs: _retryDelayMinMs
    visible: _hasHandler && videoHandler.subUrl !== ""

    on_StreamingChanged: {
        if (_streaming) {
            _retryDelayMs = _retryDelayMinMs
        }
    }

    on_HasUrlChanged: _retryDelayMs = _retryDelayMinMs

    signal swapRequested()

    readonly property real _footerSpacing: ScreenTools.defaultFontPixelHeight * 0.3
    readonly property real _footerHeight: footerRow.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.6
    readonly property real _frameHeight: Math.max(0, height - _footerHeight - _footerSpacing)

    Item {
        id: videoFrame
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: root._frameHeight
    }

    // 映像の背面に黒背景を敷く（メイン上・PiP映像下）
    Rectangle {
        anchors.fill: videoFrame
        color: "#000000"
        radius: 6
        opacity: 0.9
        z: -1    // PiP映像より下に敷く
    }

    FlightDisplayViewGStreamer {
        id: videoSurface
        objectName: "pipVideoSurface"
        anchors.fill: videoFrame
        z: 0
        receiver: root.receiver
    }

    // 映像が未受信時の待機メッセージ（PiPは中央寄せしすぎない程度）
    Column {
        anchors.horizontalCenter: videoFrame.horizontalCenter
        anchors.verticalCenter: videoFrame.verticalCenter
        anchors.verticalCenterOffset: -videoFrame.height * 0.18
        visible: !_streaming
        spacing: 4

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#00000080"
            radius: 5
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

    // ストリーム再試行
    Timer {
        interval: root._retryDelayMs
        running: _hasHandler && _hasUrl && !_streaming
        repeat: true
        onTriggered: {
            if (_hasHandler) {
                if (_displaySwapped) {
                    videoHandler.restartMainStream()
                } else {
                    videoHandler.restartSubStream()
                }
            }
            root._retryDelayMs = Math.min(root._retryDelayMaxMs, root._retryDelayMs * 2)
        }
    }

    // 枠線のみ（映像を覆わない）
    Rectangle {
        anchors.fill: videoFrame
        color: "transparent"
        border.color: "#fff5cc"
        border.width: 1
        radius: 6
        z: 2
    }

    MouseArea {
        anchors.fill: videoFrame
        onClicked: root.swapRequested()
    }

    RowLayout {
        id: footerRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: videoFrame.bottom
        anchors.topMargin: root._footerSpacing
        spacing: ScreenTools.defaultFontPixelWidth * 0.6
        z: 3

        QGCLabel {
            text: label.length ? label : qsTr("PiP")
            color: "#ffffff"
            Layout.alignment: Qt.AlignVCenter
        }

        QGCLabel {
            text: url
            color: "#b0bec5"
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            elide: Text.ElideMiddle
            maximumLineCount: 1
            wrapMode: Text.NoWrap
        }
    }

}
