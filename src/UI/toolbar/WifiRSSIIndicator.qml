/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick

import QGroundControl
import QGroundControl.Controls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette

//------------------------------------------------------------------------
//-- WiFi-style Telemetry RSSI Indicator (HUD)
Item {
    id:             control
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          implicitWidth

    property bool showIndicator: true
    property real _hPadding:     ScreenTools.defaultFontPixelWidth / 2

    property var  _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property real _rssi:          _activeVehicle ? _activeVehicle.wifiRSSI : 0
    property int  _rssiStamp:     _activeVehicle ? _activeVehicle.wifiRSSITimeBootMs : 0
    property bool _rssiValid:     !isNaN(_rssi)
    property bool _rssiFresh:     false
    property bool _hasData:       _rssiFresh && _rssiValid
    property string _displayText: _hasData ? _rssiText(_rssi) + "dBm" : "--dBm"

    QGCPalette { id: qgcPal }

    property color _activeColor:   qgcPal.text
    property color _inactiveColor: Qt.rgba(qgcPal.text.r, qgcPal.text.g, qgcPal.text.b, 0.35)
    property color _currentColor:  _hasData ? _activeColor : _inactiveColor

    Timer {
        id:         staleTimer
        interval:   2000
        repeat:     false
        onTriggered: _rssiFresh = false
    }

    on_RssiStampChanged: {
        _rssiFresh = true
        staleTimer.restart()
    }

    on_ActiveVehicleChanged: {
        _rssiFresh = false
        staleTimer.stop()
    }

    QGCLabel {
        id:                 rssiLabel
        anchors.centerIn:   parent
        text:               _displayText
        color:              _currentColor
        font.pointSize:     ScreenTools.defaultFontPointSize * 1.2
    }

    implicitWidth: rssiLabel.implicitWidth + _hPadding * 2

    function _rssiText(value) {
        if (isNaN(value)) {
            return "--"
        }
        return Number(value).toString()
    }
}
