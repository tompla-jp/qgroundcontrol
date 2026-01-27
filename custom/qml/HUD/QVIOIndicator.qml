import QtQuick
import QtQuick.Window
import QGroundControl
import QGroundControl.Controls

Item {
    id: root
    width: compassWidth
    height: 45
    z: 1

    // QVIO品質（0～100）
    property real quality: qvioHandler ? qvioHandler.quality : 0
    property string stateLabel: qvioHandler ? qvioHandler.stateLabel : "Lost"
    property bool invalidQuality: qvioHandler ? qvioHandler.quality < 0 : false

    function _qualityValue() {
        if (invalidQuality) {
            return 0
        }
        return Math.max(0, Math.min(quality, 100))
    }
    function _percentText() {
        if (invalidQuality) {
            return "-1%"
        }
        return Math.round(_qualityValue()) + "%"
    }

    // 棒配置用パラメータ
    property int stickCount: 10
    property real segmentWidth: root.width / stickCount
    property real stickWidth: segmentWidth * 0.6
    property real stickOffset: (segmentWidth - stickWidth) / 2
    // 2mm刻みで短くするためのステップ（px）
    property real stickStepPx: Screen.pixelDensity > 0 ? Screen.pixelDensity * 2 : 4
    // 全棒の高さを「左から2番目」と同じに揃える
    property real stickHeight: Math.max(root.height * 0.5, root.height * 0.9 - stickStepPx)
    // 既存参照互換用（FlyViewToolBarIndicatorsからの参照を満たす）
    property real compassWidth: 140

    implicitWidth: container.width + percentLabel.implicitWidth + percentLabel.anchors.leftMargin
    implicitHeight: Math.max(container.height, percentLabel.implicitHeight)

    Component.onCompleted: startStickAnimation()

    function startStickAnimation() {
        for (let i = 0; i < stickRepeater.count; i++) {
            let item = stickRepeater.itemAt(i)
            if (item && item.anim) {
                item.opacity = 0
                item.anim.restart()
            }
        }
    }

    Rectangle {
        id: container
        anchors.verticalCenter: parent.verticalCenter
        width: root.width
        height: root.height
        radius: 10
        color: "#000000"
        border.color: "#FFFFAA"
        border.width: 1

        Repeater {
            id: stickRepeater
            model: qvioHandler ? Math.floor(Math.max(0, Math.min(qvioHandler.quality, 100)) / 10) : 0

            Rectangle {
                id: stick
                width: stickWidth
                height: stickHeight
                x: index * segmentWidth + stickOffset
                y: (root.height - height) / 2
                property color stickColor: {
                    const q = qvioHandler ? Math.max(0, Math.min(qvioHandler.quality, 100)) : 0
                    if (q <= 30) return "#FF4E4E"  // 赤
                    else if (q <= 50) return "#FF9500"  // オレンジ
                    else if (q <= 70) return "#FFD000"  // 黄
                    else return "#3CD85B"  // 緑
                }
                color: stickColor
                radius: 3
                opacity: 1

                SequentialAnimation {
                    id: anim
                    running: false
                    PropertyAction { target: stick; property: "opacity"; value: 0 }
                    PauseAnimation { duration: index * 120 }
                    NumberAnimation { target: stick; property: "opacity"; from: 0; to: 1; duration: 140 }
                }
            }
        }
    }

    Text {
        id: percentLabel
        text: _percentText()
        font.pixelSize: 14
        font.bold: true
        color: invalidQuality ? "#FF4E4E" : "white"
        style: Text.Outline
        styleColor: "black"
        anchors.left: container.right
        anchors.leftMargin: 10
        anchors.verticalCenter: container.verticalCenter
    }

    Connections {
        target: qvioHandler
        onQualityChanged: {
            stickRepeater.model = qvioHandler ? Math.floor(Math.max(0, Math.min(qvioHandler.quality, 100)) / 10) : 0
            percentLabel.text = _percentText()
            for (let i = 0; i < stickRepeater.count; i++) {
                let item = stickRepeater.itemAt(i)
                if (item && item.anim) {
                    item.opacity = 0
                    item.anim.restart()
                }
            }
        }
    }
}
