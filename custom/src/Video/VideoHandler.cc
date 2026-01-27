/****************************************************************************
 *
 * (c) 2025 Custom VOXL GCS
 *
 ****************************************************************************/

#include "VideoHandler.h"

#include "QGCCorePlugin.h"
#include "QGCLoggingCategory.h"
#include "SettingsManager.h"
#include "Settings/VideoSettings.h"

#include <QtCore/QDateTime>
#include <QtCore/qapplicationstatic.h>
#include <QtQuick/QQuickItem>
#ifdef Q_OS_ANDROID
#include <QtCore/QJniObject>
#endif

namespace {
constexpr int kWatchdogIntervalMs = 300;
constexpr int kFreezeThresholdMs = 2500;
constexpr int kFreezeGraceMs = 800;
constexpr int kRecoveryCooldownMs = 2000;
constexpr int kFreezeMissesRequired = 2;
constexpr int kMaxRecoveryStep = 3;
constexpr int kSwapGraceMs = 1000;

qint64 _nowMs()
{
    return QDateTime::currentMSecsSinceEpoch();
}

void _startupTrace(const QString &message)
{
#ifdef Q_OS_ANDROID
    static const char kLoggerClass[] = "org/mavlink/qgroundcontrol/QGCStartupLogger";
    if (!QJniObject::isClassAvailable(kLoggerClass)) {
        return;
    }
    const QJniObject jMessage = QJniObject::fromString(message);
    if (!jMessage.isValid()) {
        return;
    }
    QJniObject::callStaticMethod<void>(
        kLoggerClass,
        "writeFromNative",
        "(Ljava/lang/String;)V",
        jMessage.object<jstring>());
#else
    Q_UNUSED(message);
#endif
}

QString _receiverTag(const QGstReceiver *receiver, const QGstReceiver *mainReceiver)
{
    return receiver == mainReceiver ? QStringLiteral("main") : QStringLiteral("sub");
}
} // namespace

QGC_LOGGING_CATEGORY(VideoHandlerLog, "gcs.custom.videohandler")

VideoHandler::VideoHandler(QObject *parent)
    : QObject(parent)
{
    qputenv("GST_DEBUG", "2");
    _startupTrace(QStringLiteral("VideoHandler ctor"));
    auto core = QGCCorePlugin::instance();
    if (core) {
        _mainReceiver = core->createVideoReceiver(this);
        _subReceiver  = core->createVideoReceiver(this);
        _setupReceiver(_mainReceiver, true);
        _setupReceiver(_subReceiver, false);
        _startupTrace(QStringLiteral("VideoHandler receivers ready"));
    } else {
        qCWarning(VideoHandlerLog) << "QGCCorePlugin instance not available; video receivers not created yet";
        _startupTrace(QStringLiteral("VideoHandler no core plugin"));
    }

    _watchdogTimer.setInterval(kWatchdogIntervalMs);
    _watchdogTimer.setTimerType(Qt::PreciseTimer);
    connect(&_watchdogTimer, &QTimer::timeout, this, &VideoHandler::_watchdogTick);
    _watchdogTimer.start();
}

VideoHandler::~VideoHandler()
{
    _cleanupReceiver(_mainReceiver);
    _cleanupReceiver(_subReceiver);
}

VideoHandler *VideoHandler::instance()
{
    static VideoHandler handler;
    return &handler;
}

QString VideoHandler::_normalizedUrl(const QString &url) const
{
    const QString trimmed = url.trimmed();
    if (trimmed.isEmpty()) {
        return trimmed;
    }
    if (trimmed.contains(QStringLiteral("://"))) {
        return trimmed;
    }
    return QStringLiteral("rtsp://") + trimmed;
}

uint32_t VideoHandler::_startTimeoutForUri(const QString &uri) const
{
    uint32_t timeout = 3;
    if (uri.startsWith(QStringLiteral("rtsp"), Qt::CaseInsensitive)) {
        if (auto settingsManager = SettingsManager::instance()) {
            if (auto videoSettings = settingsManager->videoSettings()) {
                const uint32_t rtspTimeout = videoSettings->rtspTimeout()->rawValue().toUInt();
                if (rtspTimeout > 0) {
                    timeout = rtspTimeout;
                }
            }
        } else {
            timeout = 8;
        }
    }
    return timeout;
}

void VideoHandler::_applyVideoSettings(QGstReceiver *receiver)
{
    if (!receiver) {
        return;
    }
    if (auto settingsManager = SettingsManager::instance()) {
        if (auto videoSettings = settingsManager->videoSettings()) {
            const bool lowLatency = videoSettings->lowLatencyMode()->rawValue().toBool();
            if (receiver->lowLatency() != lowLatency) {
                receiver->setLowLatency(lowLatency);
            }
        }
    }
}

void VideoHandler::bindSurfaces(QQuickItem *mainSurface, QQuickItem *pipSurface)
{
    _startupTrace(QStringLiteral("VideoHandler bindSurfaces main=%1 pip=%2")
                      .arg(mainSurface ? QStringLiteral("ok") : QStringLiteral("null"),
                           pipSurface ? QStringLiteral("ok") : QStringLiteral("null")));
    // Lazily create receivers if they were not available during construction
    auto core = QGCCorePlugin::instance();
    if (!_mainReceiver && core) {
        _mainReceiver = core->createVideoReceiver(this);
        _setupReceiver(_mainReceiver, true);
    }
    if (!_subReceiver && core) {
        _subReceiver = core->createVideoReceiver(this);
        _setupReceiver(_subReceiver, false);
    }

    if (!_mainReceiver || !_subReceiver) {
        qCWarning(VideoHandlerLog) << "Video receivers not available, skipping bindSurfaces";
        return;
    }

    if (mainSurface) {
        _mainSurface = mainSurface;
        _mainReceiver->setWidget(mainSurface);
        if (_mainReceiver->sink()) {
            QGCCorePlugin::instance()->releaseVideoSink(_mainReceiver->sink());
            _mainReceiver->setSink(nullptr);
        }
        void *sink = core ? core->createVideoSink(mainSurface, _mainReceiver) : nullptr;
        _mainReceiver->setSink(sink);
    }

    if (pipSurface) {
        _subSurface = pipSurface;
        _subReceiver->setWidget(pipSurface);
        if (_subReceiver->sink()) {
            QGCCorePlugin::instance()->releaseVideoSink(_subReceiver->sink());
            _subReceiver->setSink(nullptr);
        }
        void *sink = core ? core->createVideoSink(pipSurface, _subReceiver) : nullptr;
        _subReceiver->setSink(sink);
    }

    _updateStreams();
    _pauseWatchdog(kSwapGraceMs);
}

void VideoHandler::setMainUrl(const QString &url)
{
    const QString normalized = _normalizedUrl(url);
    if (_mainUrl == normalized) {
        return;
    }
    if (!_mainReceiver) {
        qCWarning(VideoHandlerLog) << "Main receiver not available, ignoring main URL change";
        _mainUrl = normalized;
        return;
    }
    _mainUrl = normalized;
    _startupTrace(QStringLiteral("VideoHandler mainUrl=%1").arg(_mainUrl));

    _restartReceiver(_mainReceiver, _mainUrl);
    _mainWatch = WatchdogState{};
    _mainWatch.pauseUntilMs = _nowMs() + kFreezeGraceMs;

    emit mainUrlChanged();
}

void VideoHandler::setSubUrl(const QString &url)
{
    const QString normalized = _normalizedUrl(url);
    if (_subUrl == normalized) {
        return;
    }
    if (!_subReceiver) {
        qCWarning(VideoHandlerLog) << "Sub receiver not available, ignoring sub URL change";
        _subUrl = normalized;
        return;
    }
    _subUrl = normalized;
    _startupTrace(QStringLiteral("VideoHandler subUrl=%1").arg(_subUrl));

    _restartReceiver(_subReceiver, _subUrl);
    if (_subUrl.isEmpty()) {
        _updateSubStreamActive(false);
    }
    _subWatch = WatchdogState{};
    _subWatch.pauseUntilMs = _nowMs() + kFreezeGraceMs;

    emit subUrlChanged();
}

void VideoHandler::restartMainStream()
{
    if (!_mainReceiver) {
        return;
    }
    if (_mainUrl.isEmpty()) {
        return;
    }
    if (_mainReceiver->uri() != _mainUrl) {
        _restartReceiver(_mainReceiver, _mainUrl);
        return;
    }
    if (_mainReceiver->started()) {
        return;
    }
    if (_startingReceivers.contains(_mainReceiver)) {
        return;
    }
    _restartReceiver(_mainReceiver, _mainUrl);
    _mainWatch.pauseUntilMs = qMax(_mainWatch.pauseUntilMs, _nowMs() + kFreezeGraceMs);
}

void VideoHandler::restartSubStream()
{
    if (!_subReceiver) {
        return;
    }
    if (_subUrl.isEmpty()) {
        _updateSubStreamActive(false);
        return;
    }
    if (_subReceiver->uri() != _subUrl) {
        _restartReceiver(_subReceiver, _subUrl);
        return;
    }
    if (_subReceiver->started()) {
        return;
    }
    if (_startingReceivers.contains(_subReceiver)) {
        return;
    }
    _restartReceiver(_subReceiver, _subUrl);
    if (_subUrl.isEmpty()) {
        _updateSubStreamActive(false);
    }
    _subWatch.pauseUntilMs = qMax(_subWatch.pauseUntilMs, _nowMs() + kFreezeGraceMs);
}

void VideoHandler::swapCamera()
{
    if (_swapInProgress) {
        _startupTrace(QStringLiteral("VideoHandler swapCamera ignored (swap in progress)"));
        return;
    }
    if (!_mainReceiver || !_subReceiver || !_mainSurface || !_subSurface) {
        _startupTrace(QStringLiteral("VideoHandler swapCamera skipped (missing receiver/surface)"));
        return;
    }
    if (_subUrl.isEmpty()) {
        _startupTrace(QStringLiteral("VideoHandler swapCamera skipped (sub URL empty)"));
        return;
    }

    _swapInProgress = true;
    _pauseWatchdog(kSwapGraceMs);

    QPointer<QQuickItem> oldMain = _mainSurface;
    QPointer<QQuickItem> oldSub = _subSurface;
    _mainSurface = oldSub;
    _subSurface = oldMain;

    _displaySwapped = !_displaySwapped;
    emit displaySwappedChanged();

    _requestMainRebind(_mainSurface);
    _requestSubRebind(_subSurface);
}

void VideoHandler::_setupReceiver(QGstReceiver *receiver, bool isMain)
{
    if (!receiver) {
        return;
    }

    receiver->setName(isMain ? QStringLiteral("mainVideo") : QStringLiteral("pipVideo"));

    connect(receiver, &VideoReceiver::onStartComplete, this, [this, receiver, isMain](VideoReceiver::STATUS status) {
        _startupTrace(QStringLiteral("VideoHandler startComplete %1 status=%2 uri=%3")
                          .arg(isMain ? QStringLiteral("main") : QStringLiteral("sub"),
                               QString::number(static_cast<int>(status)),
                               receiver ? receiver->uri() : QString()));
        _startingReceivers.remove(receiver);
        if (status == VideoReceiver::STATUS_OK) {
            receiver->setStarted(true);
            if (!isMain && !_subUrl.isEmpty()) {
                _updateSubStreamActive(true);
            }
            if (receiver->sink()) {
                receiver->startDecoding(receiver->sink());
            }
            return;
        }

        receiver->setStarted(false);
        if (status == VideoReceiver::STATUS_INVALID_URL || status == VideoReceiver::STATUS_INVALID_STATE) {
            return;
        }
        _restartReceiver(receiver, receiver->uri());
    });

    connect(receiver, &VideoReceiver::onStopComplete, this, [this, receiver, isMain](VideoReceiver::STATUS status) {
        _startupTrace(QStringLiteral("VideoHandler stopComplete %1 status=%2 uri=%3")
                          .arg(isMain ? QStringLiteral("main") : QStringLiteral("sub"),
                               QString::number(static_cast<int>(status)),
                               receiver ? receiver->uri() : QString()));
        receiver->setStarted(false);
        _startingReceivers.remove(receiver);
        if (!isMain) {
            _updateSubStreamActive(false);
        }
        if (_restartBlock.remove(receiver)) {
            return;
        }
        if (status == VideoReceiver::STATUS_INVALID_URL) {
            return;
        }
        if (receiver->uri().isEmpty() || !receiver->widget()) {
            return;
        }
        _ensureSink(receiver, isMain);
        if (!receiver->sink()) {
            return;
        }
        receiver->start(5);
    });

    connect(receiver, &VideoReceiver::streamingChanged, this, [this, isMain](bool active) {
        _startupTrace(QStringLiteral("VideoHandler streaming %1=%2")
                          .arg(isMain ? QStringLiteral("main") : QStringLiteral("sub"),
                               active ? QStringLiteral("1") : QStringLiteral("0")));
        if (isMain) {
            _mainStreaming = active;
        } else {
            _subStreaming = active;
            _updateSubStreamActive(active && !_subUrl.isEmpty());
        }
        emit streamingChanged();
    });

    connect(receiver, &VideoReceiver::decodingChanged, this, [this, receiver](bool active) {
        if (receiver == _mainReceiver) {
            _mainDecoding = active;
            if (!active) {
                _applyMainRebind();
            }
        } else if (receiver == _subReceiver) {
            _subDecoding = active;
            if (!active) {
                _applySubRebind();
            }
        }
    });

    connect(receiver, &VideoReceiver::onStopDecodingComplete, this, [this, receiver, isMain](VideoReceiver::STATUS) {
        WatchdogState &state = isMain ? _mainWatch : _subWatch;
        if (!state.pendingDecoderRestart) {
            return;
        }
        state.pendingDecoderRestart = false;
        if (_swapInProgress || _pendingMainRebind || _pendingSubRebind) {
            return;
        }
        if (receiver && receiver->sink()) {
            receiver->startDecoding(receiver->sink());
            state.pauseUntilMs = qMax(state.pauseUntilMs, _nowMs() + kFreezeGraceMs);
        }
    });
}

void VideoHandler::_stopReceiver(QGstReceiver *receiver)
{
    if (!receiver) {
        return;
    }
    _startingReceivers.remove(receiver);
    if (!receiver->uri().isEmpty()) {
        receiver->stop();
    }
}

void VideoHandler::_cleanupReceiver(QGstReceiver *receiver)
{
    if (!receiver) {
        return;
    }
    _startingReceivers.remove(receiver);
    if (!receiver->uri().isEmpty()) {
        _restartBlock.insert(receiver);
        receiver->stop();
    }
    if (receiver->sink()) {
        QGCCorePlugin::instance()->releaseVideoSink(receiver->sink());
        receiver->setSink(nullptr);
    }
    receiver->setUri(QString());
}

void VideoHandler::_ensureSink(QGstReceiver *receiver, bool isMain)
{
    if (!receiver || !receiver->widget()) {
        return;
    }
    if (!receiver->sink()) {
        void *sink = QGCCorePlugin::instance()->createVideoSink(receiver->widget(), receiver);
        receiver->setSink(sink);
    }
    receiver->setName(isMain ? QStringLiteral("mainVideo") : QStringLiteral("pipVideo"));
    if (receiver->sink() && receiver->started()) {
        receiver->startDecoding(receiver->sink());
    }
}

void VideoHandler::_rebindReceiver(QGstReceiver *receiver, QQuickItem *surface, bool isMain)
{
    if (!receiver || !surface) {
        return;
    }
    auto core = QGCCorePlugin::instance();
    if (!core) {
        return;
    }

    receiver->setWidget(surface);
    if (receiver->sink()) {
        core->releaseVideoSink(receiver->sink());
        receiver->setSink(nullptr);
    }

    void *sink = core->createVideoSink(surface, receiver);
    receiver->setSink(sink);
    receiver->setName(isMain ? QStringLiteral("mainVideo") : QStringLiteral("pipVideo"));

    if (sink && receiver->started()) {
        receiver->startDecoding(sink);
    }
}

void VideoHandler::_requestMainRebind(QQuickItem *surface)
{
    _pendingMainSurface = surface;
    _pendingMainRebind = true;

    if (_mainDecoding && _mainReceiver) {
        _mainReceiver->stopDecoding();
        return;
    }
    _applyMainRebind();
}

void VideoHandler::_requestSubRebind(QQuickItem *surface)
{
    _pendingSubSurface = surface;
    _pendingSubRebind = true;

    if (_subDecoding && _subReceiver) {
        _subReceiver->stopDecoding();
        return;
    }
    _applySubRebind();
}

void VideoHandler::_applyMainRebind()
{
    if (!_pendingMainRebind || !_mainReceiver) {
        return;
    }
    _rebindReceiver(_mainReceiver, _pendingMainSurface, true);
    _pendingMainRebind = false;
    _mainWatch.pauseUntilMs = qMax(_mainWatch.pauseUntilMs, _nowMs() + kSwapGraceMs);
    _maybeFinishSwap();
}

void VideoHandler::_applySubRebind()
{
    if (!_pendingSubRebind || !_subReceiver) {
        return;
    }
    _rebindReceiver(_subReceiver, _pendingSubSurface, false);
    _pendingSubRebind = false;
    _subWatch.pauseUntilMs = qMax(_subWatch.pauseUntilMs, _nowMs() + kSwapGraceMs);
    _maybeFinishSwap();
}

void VideoHandler::_maybeFinishSwap()
{
    if (_pendingMainRebind || _pendingSubRebind) {
        return;
    }
    _swapInProgress = false;
    _pauseWatchdog(kSwapGraceMs);
}

void VideoHandler::_watchdogTick()
{
    if (_swapInProgress || _pendingMainRebind || _pendingSubRebind) {
        return;
    }

    _checkStream(_mainReceiver, _mainWatch, true);
    _checkStream(_subReceiver, _subWatch, false);
}

void VideoHandler::_pauseWatchdog(int ms)
{
    const qint64 until = _nowMs() + ms;
    _mainWatch.pauseUntilMs = qMax(_mainWatch.pauseUntilMs, until);
    _subWatch.pauseUntilMs = qMax(_subWatch.pauseUntilMs, until);
}

void VideoHandler::_checkStream(QGstReceiver *receiver, WatchdogState &state, bool isMain)
{
    if (!receiver) {
        return;
    }

    const QString &uri = isMain ? _mainUrl : _subUrl;
    if (uri.isEmpty()) {
        return;
    }
    if (!receiver->started()) {
        return;
    }
    if (!receiver->widget() || !receiver->sink()) {
        return;
    }

    const qint64 now = _nowMs();
    if (now < state.pauseUntilMs) {
        return;
    }

    const qint64 lastFrameMs = receiver->lastFrameTimeMs();
    if (lastFrameMs <= 0) {
        return;
    }

    const qint64 deltaMs = now - lastFrameMs;
    if (deltaMs < kFreezeThresholdMs) {
        state.missCount = 0;
        if (state.recoveryStep > 0 && (now - state.lastRecoveryMs) > kRecoveryCooldownMs) {
            state.recoveryStep = 0;
        }
        return;
    }

    if ((now - state.lastRecoveryMs) < kRecoveryCooldownMs) {
        return;
    }

    state.missCount++;
    if (state.missCount < kFreezeMissesRequired) {
        return;
    }
    state.missCount = 0;
    _recoverStream(receiver, state, isMain, deltaMs);
}

void VideoHandler::_recoverStream(QGstReceiver *receiver, WatchdogState &state, bool isMain, qint64 deltaMs)
{
    const qint64 now = _nowMs();
    state.lastRecoveryMs = now;
    state.pauseUntilMs = now + kFreezeGraceMs;
    state.recoveryStep = qMin(state.recoveryStep + 1, kMaxRecoveryStep);

    const QString streamName = isMain ? QStringLiteral("main") : QStringLiteral("sub");
    const QString logLine = QStringLiteral("VideoHandler watchdog %1 freeze delta=%2 step=%3")
                                .arg(streamName,
                                     QString::number(deltaMs),
                                     QString::number(state.recoveryStep));
    qCWarning(VideoHandlerLog) << logLine;
    _startupTrace(logLine);

    switch (state.recoveryStep) {
    case 1:
        _resetDecoder(receiver, state, isMain);
        break;
    case 2:
        _restartReceiver(receiver, receiver->uri());
        break;
    case 3:
        _hardResetReceiver(receiver, isMain);
        break;
    default:
        break;
    }
}

void VideoHandler::_resetDecoder(QGstReceiver *receiver, WatchdogState &state, bool isMain)
{
    if (!receiver || !receiver->sink()) {
        return;
    }
    const bool decodingActive = isMain ? _mainDecoding : _subDecoding;
    if (!decodingActive) {
        receiver->startDecoding(receiver->sink());
        return;
    }
    state.pendingDecoderRestart = true;
    receiver->stopDecoding();
}

void VideoHandler::_hardResetReceiver(QGstReceiver *receiver, bool isMain)
{
    if (!receiver) {
        return;
    }
    const QString uri = receiver->uri();
    if (uri.isEmpty()) {
        return;
    }
    QPointer<QQuickItem> surface = isMain ? _mainSurface : _subSurface;
    if (!surface) {
        return;
    }
    _rebindReceiver(receiver, surface, isMain);
    _restartReceiver(receiver, uri);
}

void VideoHandler::_startReceiver(QGstReceiver *receiver, const QString &uri)
{
    if (!receiver) {
        return;
    }
    if (!receiver->widget()) {
        receiver->setUri(uri);
        if (receiver == _subReceiver && uri.isEmpty()) {
            _updateSubStreamActive(false);
        }
        return;
    }
    _applyVideoSettings(receiver);
    _ensureSink(receiver, receiver == _mainReceiver);
    if (!receiver->sink()) {
        receiver->setUri(uri);
        return;
    }
    receiver->setUri(uri);
    if (uri.isEmpty()) {
        if (receiver == _subReceiver) {
            _updateSubStreamActive(false);
        }
        return;
    }
    _startingReceivers.insert(receiver);
    _startupTrace(QStringLiteral("VideoHandler start %1 uri=%2 timeout=%3")
                      .arg(_receiverTag(receiver, _mainReceiver),
                           uri,
                           QString::number(_startTimeoutForUri(uri))));
    receiver->start(_startTimeoutForUri(uri));
}

void VideoHandler::_restartReceiver(QGstReceiver *receiver, const QString &uri)
{
    if (!receiver) {
        return;
    }

    const bool isMain = receiver == _mainReceiver;
    _startupTrace(QStringLiteral("VideoHandler restart %1 uri=%2")
                      .arg(_receiverTag(receiver, _mainReceiver), uri));
    if (uri.isEmpty()) {
        if (!isMain) {
            _updateSubStreamActive(false);
        }
        if (!receiver->uri().isEmpty()) {
            receiver->stop();
        }
        receiver->setUri(QString());
        return;
    }

    receiver->setUri(uri);
    if (!receiver->widget()) {
        return;
    }
    _applyVideoSettings(receiver);
    _ensureSink(receiver, isMain);
    if (!receiver->sink()) {
        return;
    }
    if (receiver->started()) {
        receiver->stop();
        return;
    }
    _startingReceivers.insert(receiver);
    receiver->start(_startTimeoutForUri(uri));
}

void VideoHandler::_updateStreams()
{
    restartMainStream();
    restartSubStream();
}

void VideoHandler::_stopAll()
{
    _cleanupReceiver(_mainReceiver);
    _cleanupReceiver(_subReceiver);
    _updateSubStreamActive(false);
}

void VideoHandler::_startAll()
{
    _startReceiver(_mainReceiver, _mainUrl);
    _startReceiver(_subReceiver, _subUrl);
}

void VideoHandler::_releaseSinks()
{
    _cleanupReceiver(_mainReceiver);
    _cleanupReceiver(_subReceiver);
}

void VideoHandler::_updateSubStreamActive(bool active)
{
    if (_subStreamActive == active) {
        return;
    }
    _subStreamActive = active;
    emit subStreamActiveChanged();
}
