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

#include <QtCore/QHash>
#include <QtCore/QRegularExpression>

QGC_LOGGING_CATEGORY(CustomAppLog, "gcs.custom.application")

namespace {
constexpr int kStatusOverlayWarningMs = 7000;

QString cleanedStatusText(QString text)
{
    text = text.trimmed();
    if (text.startsWith(QChar(0x26A0))) {
        text.remove(0, 1);
        if (!text.isEmpty() && text.at(0).unicode() == 0xFE0F) {
            text.remove(0, 1);
        }
    }

    return text.trimmed();
}
}

CustomQGCApplication::CustomQGCApplication(QObject *parent)
    : QObject(parent)
    , _videoHandler(VideoHandler::instance())
{
    _statusOverlayTimer.setSingleShot(true);
    _statusOverlayTimer.setInterval(kStatusOverlayWarningMs);
    connect(&_statusOverlayTimer, &QTimer::timeout, this, &CustomQGCApplication::_handleTransientStatusOverlayTimeout);

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
        disconnect(_vehicle, &Vehicle::textMessageReceived, this, &CustomQGCApplication::_handleTextMessage);
    }

    _vehicle = vehicle;
    _tofHandler.setDistanceMm(0);
    _clearStatusOverlay();

    if (_vehicle) {
        connect(_vehicle, &Vehicle::mavlinkMessageReceived, this, &CustomQGCApplication::_handleMavlinkMessage);
        connect(_vehicle, &Vehicle::textMessageReceived, this, &CustomQGCApplication::_handleTextMessage);
    }
}

void CustomQGCApplication::_handleMavlinkMessage(const mavlink_message_t &message)
{
    _qvioHandler.updateFromMavlink(message);
}

void CustomQGCApplication::_handleTextMessage(int sysid, int componentid, int severity, QString text, QString description)
{
    Q_UNUSED(sysid)
    Q_UNUSED(componentid)
    Q_UNUSED(severity)
    Q_UNUSED(description)

    QString displayMessage;
    bool persistent = false;
    if (!_parseStatusOverlayMessage(text, displayMessage, persistent)) {
        return;
    }

    if (persistent) {
        _persistentStatusOverlayMessage = displayMessage;
        _statusOverlayTimer.stop();
        _setStatusOverlayMessage(_persistentStatusOverlayMessage);
        return;
    }

    if (_persistentStatusOverlayMessage.isEmpty()) {
        _setStatusOverlayMessage(displayMessage);
        _statusOverlayTimer.start();
    }
}

bool CustomQGCApplication::_parseStatusOverlayMessage(const QString &text, QString &displayMessage, bool &persistent) const
{
    static const QRegularExpression codeExpression(QStringLiteral("^<([CEWID])-([0-9]{3})>\\s*(.*)$|^([CEWID])-([0-9]{3})\\b\\s*(.*)$"));
    static const QHash<QString, QString> exactMessages {
        { QStringLiteral("C-510|ESC Overheat"), QStringLiteral("<C-510> ESC温度が100℃を超過しました") },
        { QStringLiteral("W-510|ESC High Temperature"), QStringLiteral("<W-510> ESC温度が80℃を超過しました") },
        { QStringLiteral("E-210|Abnormal Vibration"), QStringLiteral("<E-010> 異常振動を検知しました") },
    };

    const QString cleanedText = cleanedStatusText(text);
    const QRegularExpressionMatch match = codeExpression.match(cleanedText);
    if (!match.hasMatch()) {
        return false;
    }

    const QString levelText = match.captured(1).isEmpty() ? match.captured(4) : match.captured(1);
    const QString numberText = match.captured(2).isEmpty() ? match.captured(5) : match.captured(2);
    const QString shortText = (match.captured(3).isEmpty() ? match.captured(6) : match.captured(3)).trimmed();
    const QChar level = levelText.at(0);
    if (level == QLatin1Char('I') || level == QLatin1Char('D')) {
        return false;
    }

    const QString code = QStringLiteral("%1-%2").arg(levelText, numberText);
    const int genre = numberText.left(1).toInt();
    const QString exactKey = QStringLiteral("%1|%2").arg(code, shortText);
    persistent = (level == QLatin1Char('C') || level == QLatin1Char('E'));

    const auto exactMessage = exactMessages.constFind(exactKey);
    if (exactMessage != exactMessages.constEnd()) {
        displayMessage = QStringLiteral("⚠️%1").arg(exactMessage.value());
        return true;
    }

    displayMessage = QStringLiteral("⚠️<%1> %2").arg(code, _translatedStatusText(code, level, genre));

    return true;
}

QString CustomQGCApplication::_translatedStatusText(const QString &code, QChar level, int genre) const
{
    static const QHash<QString, QString> exactMessages {
        { QStringLiteral("E-301"), QStringLiteral("MPA / Pipe / Dataでエラーが発生しました。アームしないでください。") },
    };

    const auto exactMessage = exactMessages.constFind(code);
    if (exactMessage != exactMessages.constEnd()) {
        return exactMessage.value();
    }

    const QString genreText = [genre]() {
        switch (genre) {
        case 0:
            return QStringLiteral("PX4 / Flight Core");
        case 1:
            return QStringLiteral("VIO / QVIO");
        case 2:
            return QStringLiteral("センサー");
        case 3:
            return QStringLiteral("MPA / Pipe / Data");
        case 4:
            return QStringLiteral("MAVLink / 通信");
        case 5:
            return QStringLiteral("電源 / バッテリー");
        case 6:
            return QStringLiteral("システム");
        case 7:
            return QStringLiteral("ナビゲーション / 障害物回避");
        case 8:
            return QStringLiteral("設定 / セットアップ");
        case 9:
            return QStringLiteral("デバッグ / 開発");
        default:
            return QStringLiteral("システム");
        }
    }();

    switch (level.toLatin1()) {
    case 'C':
        return QStringLiteral("%1で致命的な異常が発生しました。直ちに安全な場所へ着陸してください。").arg(genreText);
    case 'E':
        return QStringLiteral("%1でエラーが発生しました。アームしないでください。").arg(genreText);
    case 'W':
        return QStringLiteral("%1で警告が発生しました。状態を確認してください。").arg(genreText);
    default:
        return QString();
    }
}

void CustomQGCApplication::_setStatusOverlayMessage(const QString &message)
{
    if (_statusOverlayMessage == message) {
        return;
    }

    _statusOverlayMessage = message;
    emit statusOverlayChanged();
}

void CustomQGCApplication::_clearStatusOverlay()
{
    _statusOverlayTimer.stop();
    _persistentStatusOverlayMessage.clear();
    _setStatusOverlayMessage(QString());
}

void CustomQGCApplication::_handleTransientStatusOverlayTimeout()
{
    _setStatusOverlayMessage(_persistentStatusOverlayMessage);
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
