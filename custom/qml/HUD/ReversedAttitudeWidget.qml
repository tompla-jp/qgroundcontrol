import QtQuick
import QtQuick.Effects

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette
import QGroundControl.FlightMap

Item {
    id: root

    property bool showPitch:    true
    property var  vehicle:      null
    property real size
    property bool showHeading:  false

    // Pilot-facing custom HUD uses the opposite roll direction from the stock widget.
    property real _rollAngle:   vehicle ? -vehicle.roll.rawValue : 0
    property real _pitchAngle:  vehicle ? vehicle.pitch.rawValue : 0

    width:  size
    height: size

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    Item {
        id:             instrument
        anchors.fill:   parent
        visible:        false

        QGCArtificialHorizon {
            rollAngle:          _rollAngle
            pitchAngle:         _pitchAngle
            anchors.fill:       parent
        }

        Image {
            id:                 pointer
            source:             "/qmlimages/attitudePointer.svg"
            mipmap:             true
            fillMode:           Image.PreserveAspectFit
            anchors.fill:       parent
            sourceSize.height:  parent.height
        }

        Image {
            id:                 instrumentDial
            source:             "/qmlimages/attitudeDial.svg"
            mipmap:             true
            fillMode:           Image.PreserveAspectFit
            anchors.fill:       parent
            sourceSize.height:  parent.height
            transform: Rotation {
                origin.x:       root.width  / 2
                origin.y:       root.height / 2
                angle:          -_rollAngle
            }
        }

        QGCPitchIndicator {
            id:                 pitchWidget
            visible:            root.showPitch
            size:               root.size * 0.5
            anchors.verticalCenter: parent.verticalCenter
            pitchAngle:         _pitchAngle
            rollAngle:          _rollAngle
            color:              Qt.rgba(0,0,0,0)
        }

        Image {
            id:                 crossHair
            anchors.centerIn:   parent
            source:             "/qmlimages/crossHair.svg"
            mipmap:             true
            width:              size * 0.75
            sourceSize.width:   width
            fillMode:           Image.PreserveAspectFit
        }
    }

    MultiEffect {
        source: instrument
        anchors.fill: instrument
        maskEnabled: true
        maskSource: mask
    }

    Item {
        id: mask
        width: instrument.width
        height: instrument.height
        layer.enabled: true
        visible: false

        Rectangle {
            width: parent.width
            height: parent.height
            radius: width / 2
            color: "black"
        }
    }

    Rectangle {
        id:             borderRect
        anchors.fill:   parent
        radius:         width / 2
        color:          Qt.rgba(0,0,0,0)
        border.color:   qgcPal.text
        border.width:   1
    }

    QGCLabel {
        anchors.bottomMargin:       Math.round(ScreenTools.defaultFontPixelHeight * .75)
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        text:                       _headingString3
        color:                      "white"
        visible:                    showHeading

        property string _headingString: vehicle ? vehicle.heading.rawValue.toFixed(0) : "OFF"
        property string _headingString2: _headingString.length === 1 ? "0" + _headingString : _headingString
        property string _headingString3: _headingString2.length === 2 ? "0" + _headingString2 : _headingString2
    }
}
