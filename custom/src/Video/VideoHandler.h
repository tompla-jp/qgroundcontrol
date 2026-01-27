/****************************************************************************
 *
 * (c) 2025 Custom VOXL GCS
 *
 ****************************************************************************/

#pragma once

#include <QtCore/QLoggingCategory>
#include <QtCore/QMetaType>
#include <QtCore/QObject>
#include <QtCore/QPointer>
#include <QtCore/QSet>
#include <QtCore/QTimer>

#include "VideoReceiver.h"

// Align naming with the requested GStreamer receiver type
using QGstReceiver = VideoReceiver;

class QQuickItem;

Q_DECLARE_LOGGING_CATEGORY(VideoHandlerLog)

class VideoHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString mainUrl READ mainUrl WRITE setMainUrl NOTIFY mainUrlChanged)
    Q_PROPERTY(QString subUrl READ subUrl WRITE setSubUrl NOTIFY subUrlChanged)
    Q_PROPERTY(bool mainStreaming READ mainStreaming NOTIFY streamingChanged)
    Q_PROPERTY(bool subStreaming READ subStreaming NOTIFY streamingChanged)
    Q_PROPERTY(bool subStreamActive READ subStreamActive NOTIFY subStreamActiveChanged)
    Q_PROPERTY(bool displaySwapped READ displaySwapped NOTIFY displaySwappedChanged)
    Q_PROPERTY(QGstReceiver *mainReceiver READ mainReceiver CONSTANT)
    Q_PROPERTY(QGstReceiver *subReceiver READ subReceiver CONSTANT)

public:
    static VideoHandler *instance();

    QString mainUrl() const { return _mainUrl; }
    QString subUrl() const { return _subUrl; }
    QGstReceiver *mainReceiver() const { return _mainReceiver; }
    QGstReceiver *subReceiver() const { return _subReceiver; }

    bool mainStreaming() const { return _mainStreaming; }
    bool subStreaming() const { return _subStreaming; }
    bool subStreamActive() const { return _subStreamActive; }
    bool displaySwapped() const { return _displaySwapped; }

    Q_INVOKABLE void bindSurfaces(QQuickItem *mainSurface, QQuickItem *pipSurface);
    Q_INVOKABLE void swapCamera();

public slots:
    void setMainUrl(const QString &url);
    void setSubUrl(const QString &url);
    void restartMainStream();
    void restartSubStream();

signals:
    void mainUrlChanged();
    void subUrlChanged();
    void streamingChanged();
    void subStreamActiveChanged();
    void displaySwappedChanged();

private:
    struct WatchdogState {
        qint64 pauseUntilMs = 0;
        qint64 lastRecoveryMs = 0;
        int missCount = 0;
        int recoveryStep = 0;
        bool pendingDecoderRestart = false;
    };

    explicit VideoHandler(QObject *parent = nullptr);
    ~VideoHandler() override;

    QString _normalizedUrl(const QString &url) const;
    uint32_t _startTimeoutForUri(const QString &uri) const;
    void _applyVideoSettings(QGstReceiver *receiver);

    void _setupReceiver(QGstReceiver *receiver, bool isMain);
    void _restartReceiver(QGstReceiver *receiver, const QString &uri);
    void _stopReceiver(QGstReceiver *receiver);
    void _cleanupReceiver(QGstReceiver *receiver);
    void _ensureSink(QGstReceiver *receiver, bool isMain);
    void _rebindReceiver(QGstReceiver *receiver, QQuickItem *surface, bool isMain);
    void _requestMainRebind(QQuickItem *surface);
    void _requestSubRebind(QQuickItem *surface);
    void _applyMainRebind();
    void _applySubRebind();
    void _maybeFinishSwap();
    void _watchdogTick();
    void _pauseWatchdog(int ms);
    void _checkStream(QGstReceiver *receiver, WatchdogState &state, bool isMain);
    void _recoverStream(QGstReceiver *receiver, WatchdogState &state, bool isMain, qint64 deltaMs);
    void _resetDecoder(QGstReceiver *receiver, WatchdogState &state, bool isMain);
    void _hardResetReceiver(QGstReceiver *receiver, bool isMain);
    void _startReceiver(QGstReceiver *receiver, const QString &uri);
    void _updateStreams();
    void _updateSubStreamActive(bool active);
    void _stopAll();
    void _startAll();
    void _releaseSinks();

    QGstReceiver *_mainReceiver = nullptr;
    QGstReceiver *_subReceiver = nullptr;
    QPointer<QQuickItem> _mainSurface;
    QPointer<QQuickItem> _subSurface;
    QPointer<QQuickItem> _pendingMainSurface;
    QPointer<QQuickItem> _pendingSubSurface;
    QString _mainUrl;
    QString _subUrl;
    bool _mainStreaming = false;
    bool _subStreaming = false;
    bool _subStreamActive = false;
    bool _displaySwapped = false;
    bool _swapInProgress = false;
    bool _mainDecoding = false;
    bool _subDecoding = false;
    bool _pendingMainRebind = false;
    bool _pendingSubRebind = false;
    QTimer _watchdogTimer;
    WatchdogState _mainWatch;
    WatchdogState _subWatch;
    QSet<QGstReceiver*> _restartBlock;
    QSet<QGstReceiver*> _startingReceivers;
};

Q_DECLARE_OPAQUE_POINTER(VideoHandler*)
Q_DECLARE_METATYPE(VideoHandler*)
Q_DECLARE_METATYPE(QGstReceiver*)
