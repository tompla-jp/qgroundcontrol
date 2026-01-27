import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl.Palette
import QGroundControl.ScreenTools

/// Standard push button control:
///     If there is both an icon and text the icon will be to the left of the text
///     If icon only, icon will be centered
Button {
    id:             control
    hoverEnabled:   !ScreenTools.isMobile
    topPadding:     _verticalPadding
    bottomPadding:  _verticalPadding
    leftPadding:    _horizontalPadding
    rightPadding:   _horizontalPadding
    focusPolicy:    Qt.ClickFocus
    font.family:    ScreenTools.normalFontFamily
    text:           ""

    property bool   primary:        false                               ///< primary button for a group of buttons
    property bool   showBorder:     qgcPal.globalTheme === QGCPalette.Light
    property real   backRadius:     ScreenTools.buttonBorderRadius
    property real   heightFactor:   ScreenTools.isMobile ? 0.5 : 0.32
    property real   settingsButtonHeightFactor: NaN
    property real   settingsButtonTextPixelSize: NaN
    property string iconSource:     ""
    property real   fontWeight:     Font.Normal // default for qml Text
    property real   pointSize:      ScreenTools.defaultFontPointSize

    property alias wrapMode:            text.wrapMode
    property alias horizontalAlignment: text.horizontalAlignment
    property alias backgroundColor:     backRect.color
    property alias textColor:           text.color

    property bool   _showHighlight:     enabled && (pressed | checked)

    property int _horizontalPadding:    ScreenTools.defaultFontPixelWidth * 2
    property real _settingsButtonHeightFactor: {
        if (!isNaN(settingsButtonHeightFactor)) {
            return settingsButtonHeightFactor
        }
        var item = control.parent
        while (item) {
            if (item.settingsButtonHeightFactor !== undefined && !isNaN(item.settingsButtonHeightFactor)) {
                return item.settingsButtonHeightFactor
            }
            item = item.parent
        }
        return NaN
    }
    property real _settingsButtonTextPixelSize: {
        if (!isNaN(settingsButtonTextPixelSize)) {
            return settingsButtonTextPixelSize
        }
        var item = control.parent
        while (item) {
            if (item.settingsButtonTextPixelSize !== undefined && !isNaN(item.settingsButtonTextPixelSize)) {
                return item.settingsButtonTextPixelSize
            }
            item = item.parent
        }
        return NaN
    }
    property bool _useSettingsTextMetrics:        !isNaN(_settingsButtonTextPixelSize)
    property real _effectiveSettingsTextPixelSize: {
        if (!_useSettingsTextMetrics) {
            return NaN
        }
        return Math.min(_settingsButtonTextPixelSize, ScreenTools.smallFontPixelHeight)
    }
    property real _effectiveHeightFactor: isNaN(_settingsButtonHeightFactor) ? heightFactor : _settingsButtonHeightFactor
    property real _implicitHeightScale: {
        if (isNaN(_settingsButtonHeightFactor)) {
            return 1.0
        }
        var base = _useSettingsTextMetrics ? 0.5 : (ScreenTools.isMobile ? 0.5 : 0.32)
        return _effectiveHeightFactor / base
    }
    property int _verticalPadding: {
        var factor = _effectiveHeightFactor
        if (_useSettingsTextMetrics) {
            factor = Math.min(factor, ScreenTools.isMobile ? 0.4 : 0.28)
        }
        return Math.round(ScreenTools.defaultFontPixelHeight * factor)
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    background: Rectangle {
        id:             backRect
        radius:         backRadius
        implicitWidth:  ScreenTools.implicitButtonWidth
        implicitHeight: Math.round(ScreenTools.implicitButtonHeight * _implicitHeightScale)
        border.width:   showBorder ? 1 : 0
        border.color:   qgcPal.buttonBorder
        color:          primary ? qgcPal.primaryButton : qgcPal.button

        Rectangle {
            anchors.fill:   parent
            color:          qgcPal.buttonHighlight
            opacity:        _showHighlight ? 1 : control.enabled && control.hovered ? .2 : 0
            radius:         parent.radius
        }
    }

    contentItem: RowLayout {
            spacing: ScreenTools.defaultFontPixelWidth

            QGCColoredImage {
                id:                     icon
                Layout.alignment:       Qt.AlignHCenter
                source:                 control.iconSource
                height:                 text.height
                width:                  height
                color:                  text.color
                fillMode:               Image.PreserveAspectFit
                sourceSize.height:      height
                visible:                control.iconSource !== ""
            }

            QGCLabel {
                id:                     text
                Layout.alignment:       Qt.AlignHCenter
                text:                   control.text === "" ? (control.primary ? qsTr("OK") : qsTr("Cancel")) : control.text
                font.family:            control.font.family
                font.weight:            fontWeight
                // Keep text inside button bounds
                font.pixelSize:         isNaN(control._effectiveSettingsTextPixelSize)
                                        ? Math.min(ScreenTools.defaultFontPixelHeight * 1.2, Math.max(ScreenTools.defaultFontPixelHeight * 0.9, control.height * 0.45))
                                        : control._effectiveSettingsTextPixelSize
                color:                  _showHighlight ? qgcPal.buttonHighlightText : (primary ? qgcPal.primaryButtonText : qgcPal.buttonText)
                visible:                text !== ""
            }
    }
}
