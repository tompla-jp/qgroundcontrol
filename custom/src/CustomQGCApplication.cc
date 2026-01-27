/****************************************************************************
 *
 * (c) 2025 Custom VOXL GCS
 *
 ****************************************************************************/

#include "CustomQGCApplication.h"

#include "MultiVehicleManager.h"
#include "QGCApplication.h"
#include "QGCLoggingCategory.h"
#include "SettingsManager.h"
#include "Settings/VideoSettings.h"
#include "Video/VideoHandler.h"
#include "QVIOHandler.h"

#include <mavlink.h>

QGC_LOGGING_CATEGORY(CustomAppLog, "gcs.custom.application")

CustomQGCApplication::CustomQGCApplication(QObject *parent)
    : QObject(parent)
    , _videoHandler(VideoHandler::instance())
{
    _loadSavedUrls();
    _bindVideoSettings();

    connect(MultiVehicleManager::instance(), &MultiVehicleManager::activeVehicleChanged,
            this, &CustomQGCApplication::_activeVehicleChanged);

    connect(&_qvioHandler, &QVIOHandler::qualityChanged, this, &CustomQGCApplication::vioChanged);
    connect(&_qvioHandler, &QVIOHandler::stateLabelChanged, this, &CustomQGCApplication::vioChanged);

    if (_videoHandler) {
        connect(_videoHandler, &VideoHandler::mainUrlChanged, this, &CustomQGCApplication::_persistUrls);
        connect(_videoHandler, &VideoHandler::subUrlChanged, this, &CustomQGCApplication::_persistUrls);
    }
}

void CustomQGCApplication::recordStart()
{
    if (!_vehicle) {
        qgcApp()->showAppMessage(tr("No active vehicle to start recording."));
        return;
    }

    _vehicle->sendMavCommand(MAV_COMP_ID_CAMERA, MAV_CMD_VIDEO_START_CAPTURE, true,
                             0 /* camera id */, 0, 0, 0, 0, 0, 0);
}

void CustomQGCApplication::recordStop()
{
    if (!_vehicle) {
        qgcApp()->showAppMessage(tr("No active vehicle to stop recording."));
        return;
    }

    _vehicle->sendMavCommand(MAV_COMP_ID_CAMERA, MAV_CMD_VIDEO_STOP_CAPTURE, true,
                             0 /* camera id */, 0, 0, 0, 0, 0, 0);
}

void CustomQGCApplication::snapshot()
{
    if (!_vehicle) {
        qgcApp()->showAppMessage(tr("No active vehicle to trigger snapshot."));
        return;
    }

    // Single snapshot
    _vehicle->sendMavCommand(MAV_COMP_ID_CAMERA, MAV_CMD_IMAGE_START_CAPTURE, true,
                             0 /* interval */, 1 /* count */, 0, 0, 0, 0, 0);
}

void CustomQGCApplication::swapCamera()
{
    if (_videoHandler) {
        _videoHandler->swapCamera();
    }
}

void CustomQGCApplication::_activeVehicleChanged(Vehicle *vehicle)
{
    if (_vehicle) {
        disconnect(_vehicle, &Vehicle::mavlinkMessageReceived, this, &CustomQGCApplication::_handleMavlinkMessage);
    }

    _vehicle = vehicle;
    _tofHandler.setDistanceMm(0);

    if (_vehicle) {
        connect(_vehicle, &Vehicle::mavlinkMessageReceived, this, &CustomQGCApplication::_handleMavlinkMessage);
    }
}

void CustomQGCApplication::_handleMavlinkMessage(const mavlink_message_t &message)
{
    _qvioHandler.updateFromMavlink(message);
}

void CustomQGCApplication::_loadSavedUrls()
{
    if (!_videoHandler) {
        return;
    }
    QString main;
    VideoSettings *videoSettings = nullptr;
    if (auto settingsManager = SettingsManager::instance()) {
        videoSettings = settingsManager->videoSettings();
        if (videoSettings) {
            main = videoSettings->rtspUrl()->rawValue().toString();
        }
    }
    _settings.beginGroup(QStringLiteral("CustomVideo"));
    if (main.isEmpty()) {
        main = _settings.value(QStringLiteral("mainUrl")).toString();
    }
    const QString sub  = _settings.value(QStringLiteral("subUrl")).toString();
    _settings.endGroup();
    if (!main.isEmpty()) {
        if (videoSettings && videoSettings->rtspUrl()->rawValue().toString() != main) {
            videoSettings->rtspUrl()->setRawValue(main);
        }
        _videoHandler->setMainUrl(main);
    }
    if (!sub.isEmpty()) {
        _videoHandler->setSubUrl(sub);
    }
}

void CustomQGCApplication::_persistUrls()
{
    if (!_videoHandler) {
        return;
    }
    if (auto settingsManager = SettingsManager::instance()) {
        if (auto videoSettings = settingsManager->videoSettings()) {
            const QString current = videoSettings->rtspUrl()->rawValue().toString();
            if (current != _videoHandler->mainUrl()) {
                videoSettings->rtspUrl()->setRawValue(_videoHandler->mainUrl());
            }
        }
    }
    _settings.beginGroup(QStringLiteral("CustomVideo"));
    _settings.setValue(QStringLiteral("mainUrl"), _videoHandler->mainUrl());
    _settings.setValue(QStringLiteral("subUrl"), _videoHandler->subUrl());
    _settings.endGroup();
    _settings.sync();
}

void CustomQGCApplication::_bindVideoSettings()
{
    if (auto settingsManager = SettingsManager::instance()) {
        if (auto videoSettings = settingsManager->videoSettings()) {
            // App settings -> video handler (main) + 永続化
            connect(videoSettings->rtspUrl(), &Fact::rawValueChanged, this, [this](const QVariant &value) {
                const QString url = value.toString();
                if (_videoHandler && _videoHandler->mainUrl() != url) {
                    _videoHandler->setMainUrl(url);
                }
                // 設定値を即座に永続化（VideoHandler が null でも保存）
                _settings.beginGroup(QStringLiteral("CustomVideo"));
                _settings.setValue(QStringLiteral("mainUrl"), url);
                _settings.setValue(QStringLiteral("subUrl"), _videoHandler ? _videoHandler->subUrl() : _settings.value(QStringLiteral("subUrl")).toString());
                _settings.endGroup();
                _settings.sync();
            });
            // Video handler -> App settings (main) + 永続化
            if (_videoHandler) {
                connect(_videoHandler, &VideoHandler::mainUrlChanged, this, [this, videoSettings]() {
                    const QString url = _videoHandler->mainUrl();
                    if (videoSettings->rtspUrl()->rawValue().toString() != url) {
                        videoSettings->rtspUrl()->setRawValue(url);
                    }
                    _persistUrls();
                });
                connect(_videoHandler, &VideoHandler::subUrlChanged, this, [this]() {
                    _persistUrls();
                });
            }
        }
    }
}
