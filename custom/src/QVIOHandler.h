/****************************************************************************
 *
 * (c) 2025 Custom VOXL GCS
 *
 ****************************************************************************/

#pragma once

#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QTimer>

#include "QGCMAVLink.h"

class QVIOHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(float quality READ quality NOTIFY qualityChanged)
    Q_PROPERTY(int state READ state NOTIFY stateChanged)
    Q_PROPERTY(int featureCount READ featureCount NOTIFY featureCountChanged)
    Q_PROPERTY(uint errorCode READ errorCode NOTIFY errorCodeChanged)
    Q_PROPERTY(bool stale READ stale NOTIFY staleChanged)
    Q_PROPERTY(QString errorText READ errorText NOTIFY errorTextChanged)
    Q_PROPERTY(QString stateLabel READ stateLabel NOTIFY stateLabelChanged)

public:
    explicit QVIOHandler(QObject *parent = nullptr);

    float quality() const { return _quality; }
    int state() const { return _state; }
    int featureCount() const { return _featureCount; }
    uint errorCode() const { return _errorCode; }
    bool stale() const { return _stale; }
    QString errorText() const { return _errorText; }
    QString stateLabel() const { return _stateLabel; }

    void updateFromMavlink(const mavlink_message_t &msg);
#ifdef MAVLINK_MSG_ID_QVIO_STATUS
    void updateFromStatus(const mavlink_qvio_status_t &status);
#endif

    void setQuality(float v);
    void setState(int v);
    void setFeatureCount(int v);
    void setErrorCode(uint v);
    void setStale(bool v);
    void setErrorText(const QString &v);

signals:
    void qualityChanged();
    void stateChanged();
    void featureCountChanged();
    void errorCodeChanged();
    void staleChanged();
    void errorTextChanged();
    void stateLabelChanged();

private slots:
    void _handleTimeout();

private:
    void _applyQuality(float quality);
    void _updateStateLabel(float quality);

    float _quality = 0.f;              // 0-100 (float), -1 means invalid/stale
    int _state = 0;                    // raw state from VOXL
    int _featureCount = 0;
    uint _errorCode = 0;
    bool _stale = false;
    QString _errorText;
    QString _stateLabel = QStringLiteral("Lost");
    qint64 _lastUpdateMs = 0;
    QTimer _timeoutTimer;
};
