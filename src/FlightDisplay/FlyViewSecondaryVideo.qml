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
import QGroundControl.FlightDisplay

Item {
    id: root

    property Item pipView
    property Item pipState: secondaryPipState
    property Item primaryVideoItem: null

    readonly property bool _hasThermalStream: QGroundControl.videoManager.hasThermal
    readonly property bool _hasMirrorFallback: !_hasThermalStream && primaryVideoItem
    readonly property bool hasSecondaryStream: _hasThermalStream || _hasMirrorFallback

    visible: pipView && hasSecondaryStream

    PipState {
        id:         secondaryPipState
        pipView:    root.pipView
        isDark:     true

        onWindowAboutToOpen: {
            QGroundControl.videoManager.stopVideo()
            videoStartDelay.start()
        }

        onWindowAboutToClose: {
            QGroundControl.videoManager.stopVideo()
            videoStartDelay.start()
        }

        onStateChanged: {
            if (pipState.state !== pipState.fullState) {
                QGroundControl.videoManager.fullScreen = false
            }
        }
    }

    Timer {
        id:           videoStartDelay
        interval:     2000
        running:      false
        repeat:       false
        onTriggered:  QGroundControl.videoManager.startVideo()
    }

    Rectangle {
        anchors.fill:   parent
        color:          "black"
        opacity:        0.85
        visible:        hasSecondaryStream
    }

    QGCVideoBackground {
        id:             secondaryVideo
        objectName:     "thermalVideo"
        anchors.fill:   parent
        visible:        _hasThermalStream
    }

    ShaderEffectSource {
        id:             mirrorSource
        sourceItem:     root.primaryVideoItem
        live:           true
        recursive:      true
        hideSource:     false
        enabled:        _hasMirrorFallback
    }

    ShaderEffect {
        anchors.fill:   parent
        visible:        _hasMirrorFallback
        property variant source: mirrorSource
        fragmentShader: "
            uniform sampler2D source;
            varying highp vec2 qt_TexCoord0;
            void main() {
                gl_FragColor = texture2D(source, qt_TexCoord0);
            }
        "
    }
}
