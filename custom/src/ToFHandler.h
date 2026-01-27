/****************************************************************************
 *
 * (c) 2025 Custom VOXL GCS
 *
 ****************************************************************************/

#pragma once

#include <QtCore/QObject>

class ToFHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int distanceMm READ distanceMm NOTIFY distanceMmChanged)
    Q_PROPERTY(double distanceCm READ distanceCm NOTIFY distanceCmChanged)
    Q_PROPERTY(bool hasDistanceData READ hasDistanceData NOTIFY hasDistanceDataChanged)

public:
    explicit ToFHandler(QObject *parent = nullptr) : QObject(parent) { }

    int  distanceMm() const { return _distanceMm; }
    double distanceCm() const { return _distanceMm / 10.0; }
    bool hasDistanceData() const { return _hasDistanceData; }

    void setDistanceMm(int mm);

signals:
    void distanceCmChanged();
    void distanceMmChanged();
    void hasDistanceDataChanged();

private:
    int  _distanceMm = 0;
    bool _hasDistanceData = false;
    int  _lastUpdateMs = 0;
};
