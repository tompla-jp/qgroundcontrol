/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
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

Button {
    id:             control
    padding:        ScreenTools.defaultFontPixelWidth * 0.75 * paddingScale
    hoverEnabled:   !ScreenTools.isMobile
    autoExclusive:  true
    icon.color:     textColor

    property color textColor: checked || pressed ? qgcPal.buttonHighlightText : qgcPal.buttonText
    property real  iconPixelSize: ScreenTools.defaultFontPixelHeight
    property real  textPointSize: ScreenTools.defaultFontPointSize
    property real  paddingScale: 1.0

    QGCPalette {
        id:                 qgcPal
        colorGroupEnabled:  control.enabled
    }

    background: Rectangle {
        color:      qgcPal.buttonHighlight
        opacity:    checked || pressed ? 1 : enabled && hovered ? .2 : 0
        radius:     ScreenTools.defaultFontPixelWidth / 2
    }

    contentItem: RowLayout {
        spacing: ScreenTools.defaultFontPixelWidth

        QGCColoredImage {
            source: control.icon.source
            color:  control.icon.color
            width:  control.iconPixelSize
            height: control.iconPixelSize
        }

        QGCLabel {
            id:                     displayText
            Layout.fillWidth:       true
            text:                   control.text
            color:                  control.textColor
            font.pointSize:         control.textPointSize
            horizontalAlignment:    QGCLabel.AlignLeft
        }
    }
}
