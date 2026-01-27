/****************************************************************************
 *
 * (c) 2025 Custom VOXL GCS
 *
 ****************************************************************************/

#include "ToFHandler.h"

void ToFHandler::setDistanceMm(int mm)
{
    const int newValue = mm;
    const bool hasData = newValue > 0;
    const bool distanceChanged = newValue != _distanceMm;

    if (distanceChanged) {
        _distanceMm = newValue;
        emit distanceMmChanged();
        emit distanceCmChanged();
    }
    if (_hasDistanceData != hasData) {
        _hasDistanceData = hasData;
        emit hasDistanceDataChanged();
    }
}
