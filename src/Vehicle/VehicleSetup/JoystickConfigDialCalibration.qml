/****************************************************************************
 *
 * (c) 2009-2026 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

Item {
    id: root

    property var activeJoystick: joystickManager.activeJoystick
    property var monitoredJoystick: null

    width: availableWidth
    height: contentColumn.height + (ScreenTools.defaultFontPixelHeight * 2)

    function startDialMonitoring() {
        if (monitoredJoystick === activeJoystick) {
            return
        }

        stopDialMonitoring()

        monitoredJoystick = activeJoystick
        if (monitoredJoystick) {
            monitoredJoystick.setCalibrationMode(true)
        }
    }

    function stopDialMonitoring() {
        if (monitoredJoystick) {
            monitoredJoystick.setCalibrationMode(false)
            monitoredJoystick = null
        }
    }

    Component.onCompleted: startDialMonitoring()
    Component.onDestruction: stopDialMonitoring()
    onActiveJoystickChanged: startDialMonitoring()

    ColumnLayout {
        id: contentColumn
        width: Math.min(parent.width, ScreenTools.defaultFontPixelWidth * 72)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: ScreenTools.defaultFontPixelHeight

        QGCLabel {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: qsTr("ダイヤルごとに0位置と最大値・最小値を保存できます。設定はプロポごとに保存されます。")
        }

        QGCLabel {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            font.pointSize: ScreenTools.smallFontPointSize
            text: qsTr("ダイヤルを動かしながら現在値を確認し、必要な位置で『現在値を設定』を押してください。")
        }

        QGCLabel {
            visible: !activeJoystick || (!activeJoystick.dialAvailable(0) && !activeJoystick.dialAvailable(1))
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: qsTr("このプロポではダイヤルキャリブレーションの対象が見つかりませんでした。")
        }

        Repeater {
            model: 2

            Rectangle {
                id: dialCard

                property int dialIndex: index
                property int axisIndex: -1
                property int rawValue: 0
                property int minValue: 0
                property int maxValue: 0
                property int centerValue: 0
                property real normalizedValue: 0.0

                function refresh() {
                    if (!activeJoystick) {
                        axisIndex = -1
                        rawValue = 0
                        minValue = 0
                        maxValue = 0
                        centerValue = 0
                        normalizedValue = 0.0
                        return
                    }

                    axisIndex = activeJoystick.dialAxis(dialIndex)
                    rawValue = activeJoystick.dialCurrentValue(dialIndex)
                    minValue = activeJoystick.dialMin(dialIndex)
                    maxValue = activeJoystick.dialMax(dialIndex)
                    centerValue = activeJoystick.dialCenter(dialIndex)
                    normalizedValue = activeJoystick.dialNormalizedValue(dialIndex)
                }

                Component.onCompleted: refresh()
                visible: activeJoystick && activeJoystick.dialAvailable(dialIndex)
                Layout.fillWidth: true
                radius: ScreenTools.defaultFontPixelWidth
                color: qgcPal.window
                border.color: qgcPal.text
                border.width: 1
                implicitHeight: dialColumn.implicitHeight + (ScreenTools.defaultFontPixelHeight * 2)

                Connections {
                    target: activeJoystick

                    function onRawAxisValueChanged(axis, value) {
                        if (axis === dialCard.axisIndex) {
                            dialCard.rawValue = value
                            dialCard.normalizedValue = activeJoystick.dialNormalizedValue(dialCard.dialIndex)
                        }
                    }

                    function onDialCalibrationChanged() {
                        dialCard.refresh()
                    }
                }

                Connections {
                    target: root

                    function onActiveJoystickChanged() {
                        dialCard.refresh()
                    }
                }

                ColumnLayout {
                    id: dialColumn
                    anchors.fill: parent
                    anchors.margins: ScreenTools.defaultFontPixelHeight
                    spacing: ScreenTools.defaultFontPixelHeight * 0.7

                    QGCLabel {
                        text: qsTr("ダイヤル %1").arg(dialCard.dialIndex + 1) + qsTr("  Axis %1").arg(dialCard.axisIndex)
                        font.bold: true
                    }

                    AxisMonitor {
                        Layout.fillWidth: true
                        height: ScreenTools.defaultFontPixelHeight * 1.2
                        axisValue: dialCard.rawValue
                        deadbandValue: 0
                        narrowIndicator: true
                        mapped: true
                        reversed: false
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: ScreenTools.defaultFontPixelWidth * 2

                        QGCLabel {
                            text: qsTr("現在値: %1").arg(dialCard.rawValue)
                        }

                        QGCLabel {
                            text: qsTr("出力: %1").arg(dialCard.normalizedValue.toFixed(2))
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        rowSpacing: ScreenTools.defaultFontPixelHeight * 0.5
                        columnSpacing: ScreenTools.defaultFontPixelWidth

                        QGCLabel {
                            text: qsTr("0位置")
                            Layout.alignment: Qt.AlignVCenter
                        }
                        QGCTextField {
                            Layout.fillWidth: true
                            text: dialCard.centerValue.toString()
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            validator: IntValidator { bottom: -32767; top: 32767 }
                            onEditingFinished: {
                                const parsed = parseInt(text)
                                if (!isNaN(parsed) && activeJoystick) {
                                    activeJoystick.setDialCenter(dialCard.dialIndex, parsed)
                                }
                                dialCard.refresh()
                            }
                        }
                        QGCButton {
                            text: qsTr("現在値を設定")
                            onClicked: {
                                activeJoystick.setDialCenterToCurrent(dialCard.dialIndex)
                                dialCard.refresh()
                            }
                        }

                        QGCLabel {
                            text: qsTr("最小値")
                            Layout.alignment: Qt.AlignVCenter
                        }
                        QGCTextField {
                            Layout.fillWidth: true
                            text: dialCard.minValue.toString()
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            validator: IntValidator { bottom: -32767; top: 32767 }
                            onEditingFinished: {
                                const parsed = parseInt(text)
                                if (!isNaN(parsed) && activeJoystick) {
                                    activeJoystick.setDialMin(dialCard.dialIndex, parsed)
                                }
                                dialCard.refresh()
                            }
                        }
                        QGCButton {
                            text: qsTr("現在値を設定")
                            onClicked: {
                                activeJoystick.setDialMinToCurrent(dialCard.dialIndex)
                                dialCard.refresh()
                            }
                        }

                        QGCLabel {
                            text: qsTr("最大値")
                            Layout.alignment: Qt.AlignVCenter
                        }
                        QGCTextField {
                            Layout.fillWidth: true
                            text: dialCard.maxValue.toString()
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            validator: IntValidator { bottom: -32767; top: 32767 }
                            onEditingFinished: {
                                const parsed = parseInt(text)
                                if (!isNaN(parsed) && activeJoystick) {
                                    activeJoystick.setDialMax(dialCard.dialIndex, parsed)
                                }
                                dialCard.refresh()
                            }
                        }
                        QGCButton {
                            text: qsTr("現在値を設定")
                            onClicked: {
                                activeJoystick.setDialMaxToCurrent(dialCard.dialIndex)
                                dialCard.refresh()
                            }
                        }
                    }

                    QGCButton {
                        text: qsTr("既定値に戻す")
                        onClicked: {
                            activeJoystick.resetDialCalibration(dialCard.dialIndex)
                            dialCard.refresh()
                        }
                    }
                }
            }
        }
    }
}
