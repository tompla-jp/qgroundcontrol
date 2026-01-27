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
import QGroundControl.ScreenTools
import "qrc:/qml/HUD" as CustomHUD

//-------------------------------------------------------------------------
//-- Toolbar Indicators
Row {
    id:                 indicatorRow
    anchors.verticalCenter: parent.verticalCenter
    height:             parent.height * _iconScale
    spacing:            ScreenTools.defaultFontPixelWidth * 1.5

    property var  _activeVehicle:           QGroundControl.multiVehicleManager.activeVehicle
    property real _iconScale:               0.8
    property var  _toolIndicatorsModel:     _filteredIndicators(_activeVehicle ? _activeVehicle.toolIndicators : [], [
        "FlightModeIndicator.qml"
    ])
    property var  _modeIndicatorsModel:     _filteredIndicators(_activeVehicle ? _activeVehicle.modeIndicators : [], [
        "ModeIndicator.qml"
    ])

    function _normalizedIndicatorUrl(sourceUrl) {
        if (!sourceUrl) {
            return ""
        }
        return sourceUrl.toString ? sourceUrl.toString() : "" + sourceUrl
    }

    function _filteredIndicators(indicators, excludedList) {
        if (!indicators || indicators.length === 0) {
            return []
        }
        var filtered = []
        for (var i = 0; i < indicators.length; i++) {
            var indicatorUrl = _normalizedIndicatorUrl(indicators[i])
            var excluded = false
            for (var j = 0; j < excludedList.length; j++) {
                if (indicatorUrl.indexOf(excludedList[j]) !== -1) {
                    excluded = true
                    break
                }
            }
            if (!excluded) {
                filtered.push(indicators[i])
            }
        }
        return filtered
    }

    Repeater {
        id:     appRepeater
        model:  QGroundControl.corePlugin.toolBarIndicators
        Loader {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             modelData
            visible:            item.showIndicator
        }
    }

    Repeater {
        id:     toolIndicatorsRepeater
        model:  _toolIndicatorsModel

        Loader {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             modelData
            visible:            item && item.showIndicator
        }
    }

    CustomHUD.QVIOIndicator {
        compassWidth: (ScreenTools.defaultFontPixelHeight * 5 + 80) * indicatorRow._iconScale
        height: 45 * indicatorRow._iconScale
        anchors.verticalCenter: parent.verticalCenter
    }

    // QVIOと次のインジケータが重ならないようスペーサを追加
    Item {
        width: ScreenTools.defaultFontPixelWidth * 4
        height: 1
    }

    Repeater {
        model: _modeIndicatorsModel
        Loader {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             modelData
            visible:            item && item.showIndicator
        }
    }
}
