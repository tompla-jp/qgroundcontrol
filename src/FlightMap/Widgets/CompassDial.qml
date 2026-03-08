/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette

/// This is the dial background for the compass

Item {
    id: control

    property real offsetRadius: width / 2 - ScreenTools.defaultFontPixelHeight / 2

    // 内側にラベルを少し寄せる（約3mm相当）ためのオフセット
    property real labelInset: 10
    property real labelRadius: control.offsetRadius - labelInset

    function translateCenterToAngleX(radius, angle) {
        return radius * Math.sin(angle * (Math.PI / 180))
    } 

    function translateCenterToAngleY(radius, angle) {
        return -radius * Math.cos(angle * (Math.PI / 180))
    }

    QGCLabel {
        anchors.centerIn:   parent
        text:               "F"
        font.pixelSize:     20
        font.bold:          true

        transform: Translate {
            x: translateCenterToAngleX(control.labelRadius, 0)
            y: translateCenterToAngleY(control.labelRadius, 0)
        }
    }

    QGCLabel {
        anchors.centerIn:   parent
        text:               "R"
        font.pixelSize:     20
        font.bold:          true

        transform: Translate {
            x: translateCenterToAngleX(control.labelRadius, 90)
            y: translateCenterToAngleY(control.labelRadius, 90)
        }
    }

    QGCLabel {
        anchors.centerIn:   parent
        text:               "B"
        font.pixelSize:     20
        font.bold:          true

        transform: Translate {
            x: translateCenterToAngleX(control.labelRadius, 180)
            y: translateCenterToAngleY(control.labelRadius, 180)
        }
    }

    QGCLabel {
        anchors.centerIn:   parent
        text:               "L"
        font.pixelSize:     20
        font.bold:          true

        transform: Translate {
            x: translateCenterToAngleX(control.labelRadius, 270)
            y: translateCenterToAngleY(control.labelRadius, 270)
        }
    }

    // Major tick marks
    // Major tick marks (every 45 deg)
    Repeater {
        model: 8

        Rectangle {
            id:                 majorTick
            x:                  size / 2
            width:              1.2
            height:             ScreenTools.defaultFontPixelHeight * 0.6
            color:              qgcPal.text

            transform: Rotation {
                origin.x:   0
                origin.y:   size / 2
                angle:      (45 * index)
            }
        }
    }

    // Minor tick marks (every 22.5 deg)
    Repeater {
        model: 16

        Rectangle {
            x:                  size / 2
            y:                  _margin
            width:              1
            height:             _margin
            color:              qgcPal.text

            property real _margin: ScreenTools.defaultFontPixelHeight * 0.25

            transform: Rotation {
                origin.x:   0
                origin.y:   size / 2 - _margin
                angle:      22.5 * index
            }
        }
    }
}
