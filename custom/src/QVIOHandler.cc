/****************************************************************************
 *
 * (c) 2025 Custom VOXL GCS
 *
 ****************************************************************************/

#include "QVIOHandler.h"

#include <QtCore/QDateTime>
#include <QtMath>

#include "QGCMAVLink.h"

namespace {
constexpr int kQualityGoodThreshold = 70;
constexpr int kQualityDegradedThreshold = 30;
constexpr int kTimeoutMs = 3000;
}

QVIOHandler::QVIOHandler(QObject *parent)
    : QObject(parent)
{
    _timeoutTimer.setInterval(1000);
    connect(&_timeoutTimer, &QTimer::timeout, this, &QVIOHandler::_handleTimeout);
    _timeoutTimer.start();
}

void QVIOHandler::updateFromMavlink(const mavlink_message_t &msg)
{
    switch (msg.msgid) {
#ifdef MAVLINK_MSG_ID_QVIO_STATUS
    case MAVLINK_MSG_ID_QVIO_STATUS: {
        mavlink_qvio_status_t status{};
        mavlink_msg_qvio_status_decode(&msg, &status);
        updateFromStatus(status);
        break;
    }
#endif
    case MAVLINK_MSG_ID_ODOMETRY: {
        if (_quality < 0.f) {
            break;
        }
        mavlink_odometry_t odom{};
        mavlink_msg_odometry_decode(&msg, &odom);
        const double variance = qAbs(odom.pose_covariance[0]) + qAbs(odom.pose_covariance[7]) + qAbs(odom.pose_covariance[14]);
        const int quality = qRound(100.0 / (1.0 + variance));
        _applyQuality(quality);
        break;
    }
    case MAVLINK_MSG_ID_VISION_POSITION_ESTIMATE: {
        if (_quality < 0.f) {
            break;
        }
        mavlink_vision_position_estimate_t vio{};
        mavlink_msg_vision_position_estimate_decode(&msg, &vio);
        const double variance = qAbs(vio.covariance[0]) + qAbs(vio.covariance[7]) + qAbs(vio.covariance[14]);
        const int quality = qRound(100.0 / (1.0 + variance));
        _applyQuality(quality);
        break;
    }
    default:
        break;
    }
}

#ifdef MAVLINK_MSG_ID_QVIO_STATUS
void QVIOHandler::updateFromStatus(const mavlink_qvio_status_t &status)
{
    _lastUpdateMs = QDateTime::currentMSecsSinceEpoch();

    setStale(status.stale != 0);
    setState(status.state);
    setFeatureCount(status.feature_count);
    setErrorCode(status.error_code);
    setErrorText(QString::fromLatin1(status.error_text));

    // quality -1 or stale -> treat as invalid
    if (status.stale != 0 || status.quality < 0.f || !qIsFinite(status.quality)) {
        _applyQuality(-1.f);
    } else {
        _applyQuality(status.quality);
    }
}
#endif

void QVIOHandler::setQuality(float v)
{
    _lastUpdateMs = QDateTime::currentMSecsSinceEpoch();
    _applyQuality(v);
}

void QVIOHandler::setState(int v)
{
    if (_state == v) {
        return;
    }
    _state = v;
    emit stateChanged();
}

void QVIOHandler::setFeatureCount(int v)
{
    if (_featureCount == v) {
        return;
    }
    _featureCount = v;
    emit featureCountChanged();
}

void QVIOHandler::setErrorCode(uint v)
{
    if (_errorCode == v) {
        return;
    }
    _errorCode = v;
    emit errorCodeChanged();
}

void QVIOHandler::setStale(bool v)
{
    if (_stale == v) {
        return;
    }
    _stale = v;
    emit staleChanged();
    _updateStateLabel(_quality);
}

void QVIOHandler::setErrorText(const QString &v)
{
    if (_errorText == v) {
        return;
    }
    _errorText = v;
    emit errorTextChanged();
}

void QVIOHandler::_applyQuality(float quality)
{
    const qint64 now = QDateTime::currentMSecsSinceEpoch();
    _lastUpdateMs = now;

    float clampedQuality = quality;
    if (!qIsFinite(clampedQuality) || clampedQuality < 0.f) {
        clampedQuality = -1.f;
    } else {
        clampedQuality = qBound(0.f, clampedQuality, 100.f);
    }

    if (!qFuzzyCompare(clampedQuality, _quality)) {
        _quality = clampedQuality;
        emit qualityChanged();
    }

    _updateStateLabel(clampedQuality < 0.f ? 0.f : clampedQuality);
}

void QVIOHandler::_handleTimeout()
{
    if (_lastUpdateMs == 0) {
        return;
    }

    const qint64 ageMs = QDateTime::currentMSecsSinceEpoch() - _lastUpdateMs;
    if (ageMs > kTimeoutMs && _stateLabel != QStringLiteral("Lost")) {
        _quality = 0;
        _stateLabel = QStringLiteral("Lost");
        emit qualityChanged();
        emit stateLabelChanged();
    }
}

void QVIOHandler::_updateStateLabel(float quality)
{
    QString newLabel;
    if (_stale) {
        newLabel = QStringLiteral("Lost");
    } else if (quality >= kQualityGoodThreshold) {
        newLabel = QStringLiteral("Good");
    } else if (quality >= kQualityDegradedThreshold) {
        newLabel = QStringLiteral("Degraded");
    } else {
        newLabel = QStringLiteral("Lost");
    }

    if (newLabel != _stateLabel) {
        _stateLabel = newLabel;
        emit stateLabelChanged();
    }
}
