/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#include "RCChannelMonitorController.h"
#include "Vehicle.h"
#include "MultiVehicleManager.h"
#include "QGCLoggingCategory.h"

QGC_LOGGING_CATEGORY(RCChannelMonitorControllerLog, "qgc.qmlcontrols.rcchannelmonitorcontroller")

RCChannelMonitorController::RCChannelMonitorController(QObject *parent)
    : FactPanelController(parent)
{
    // qCDebug(RCChannelMonitorControllerLog) << Q_FUNC_INFO << this;

    _setVehicle(_vehicle);
    (void) connect(MultiVehicleManager::instance(), &MultiVehicleManager::activeVehicleChanged,
                   this, &RCChannelMonitorController::_activeVehicleChanged);
}

RCChannelMonitorController::~RCChannelMonitorController()
{
    // qCDebug(RCChannelMonitorControllerLog) << Q_FUNC_INFO << this;
}

void RCChannelMonitorController::_rcChannelsChanged(int channelCount, int pwmValues[QGCMAVLink::maxRcChannels])
{
    for (int channel = 0; channel < channelCount; channel++) {
        const int channelValue = pwmValues[channel];

        if (_chanCount != channelCount) {
            _chanCount = channelCount;
            emit channelCountChanged(_chanCount);
        }

        if (channelValue != -1) {
            emit channelRCValueChanged(channel, channelValue);
        }
    }
}

void RCChannelMonitorController::_activeVehicleChanged(Vehicle *vehicle)
{
    _setVehicle(vehicle);
}

void RCChannelMonitorController::_setVehicle(Vehicle *vehicle)
{
    if (_vehicle) {
        (void) disconnect(_vehicle, &Vehicle::rcChannelsChanged, this, &RCChannelMonitorController::_rcChannelsChanged);
    }

    _vehicle = vehicle ? vehicle : MultiVehicleManager::instance()->offlineEditingVehicle();

    if (_chanCount != 0) {
        _chanCount = 0;
        emit channelCountChanged(_chanCount);
    }

    if (_vehicle) {
        (void) connect(_vehicle, &Vehicle::rcChannelsChanged, this, &RCChannelMonitorController::_rcChannelsChanged);
    }
}
