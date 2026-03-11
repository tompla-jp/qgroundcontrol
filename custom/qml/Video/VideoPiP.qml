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
    property bool showUrlInput: false
    readonly property bool _hasHandler: typeof videoHandler !== "undefined" && videoHandler !== null
    readonly property bool _displaySwapped: _hasHandler ? videoHandler.displaySwapped : false
    readonly property bool _streaming: _hasHandler ? (_displaySwapped ? videoHandler.mainStreaming : videoHandler.subStreaming) : false
    readonly property bool _hasUrl: url && url.length > 0
    visible: videoHandler.subUrl !== ""

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
        interval: 3000
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

    // 設定ボタン（URL入力ポップアップを開閉）
    QGCButton {
        id: settingsButton
        text: qsTr("⚙")
        anchors.left: videoFrame.left
        anchors.bottom: videoFrame.top
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.4
        anchors.bottomMargin: ScreenTools.defaultFontPixelHeight * 0.35
        padding: 4
        scale: 0.6
        z: 4
        onClicked: root.showUrlInput = !root.showUrlInput
    }

    // URL input popup
    Rectangle {
        id: urlPopup
        visible: root.showUrlInput
        color: "#000000"
        opacity: 0.85
        radius: 6
        anchors.right: videoFrame.left
        anchors.verticalCenter: videoFrame.verticalCenter
        anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 0.6
        width: 260
        z: 4
        // 内容が収まるようポップアップ高さを明示
        height: urlPopupColumn.implicitHeight + 16
        border.color: "#ffffff"
        border.width: 1

        ColumnLayout {
            id: urlPopupColumn
            anchors.fill: parent
            anchors.margins: 8
            spacing: 12

            TextField {
                id: pipUrlField
                text: videoHandler.subUrl
                color: "#ffffff"
                placeholderText: qsTr("rtsp://...")
                selectByMouse: true
                Layout.fillWidth: true
                Layout.topMargin: 6    // 入力欄を上寄せしつつ少し余白
                height: ScreenTools.defaultFontPixelHeight * 2.2
                background: Rectangle {
                    radius: 4
                    color: "#222222"
                    border.color: "#555555"
                }
                onAccepted: {
                    videoHandler.subUrl = text
                    root.showUrlInput = false
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Layout.topMargin: 12
                QGCButton {
                    text: qsTr("Apply")
                    Layout.fillWidth: true
                    onClicked: {
                        videoHandler.subUrl = pipUrlField.text
                        root.showUrlInput = false
                    }
                }
                QGCButton {
                    text: qsTr("Cancel")
                    Layout.fillWidth: true
                    onClicked: root.showUrlInput = false
                }
            }
        }
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
