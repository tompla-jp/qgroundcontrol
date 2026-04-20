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
    property real _signalPercent: _hasData ? _percentForRssi(_rssi) : NaN
    property string _displayText: _hasData ? _percentText(_signalPercent) : "--%"

    property color _currentColor:  "#ffffff"

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

    function _percentForRssi(value) {
        if (isNaN(value)) {
            return NaN
        }

        let percent = 0

        if (value <= -85) {
            percent = 0
        } else if (value <= -75) {
            percent = (value + 85) * 3
        } else if (value <= -65) {
            percent = 30 + (value + 75) * 3
        } else if (value <= -55) {
            percent = 60 + (value + 65) * 2
        } else if (value <= -45) {
            percent = 80 + (value + 55) * 2
        } else {
            percent = 100
        }

        return Math.max(0, Math.min(100, Math.round(percent / 5) * 5))
    }

    function _percentText(value) {
        return isNaN(value) ? "--%" : Number(value).toString() + "%"
    }
}
