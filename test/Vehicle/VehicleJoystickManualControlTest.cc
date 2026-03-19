/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "VehicleJoystickManualControlTest.h"

#include "Vehicle.h"

#include <QtCore/QElapsedTimer>
#include <QtTest/QSignalSpy>
#include <QtTest/QTest>

bool VehicleJoystickManualControlTest::_waitForManualControl(QSignalSpy &spy, mavlink_manual_control_t &manualControl, int timeoutMs)
{
    int processedCount = 0;
    QElapsedTimer elapsedTimer;
    elapsedTimer.start();

    while (elapsedTimer.elapsed() < timeoutMs) {
        while (processedCount < spy.count()) {
            const QList<QVariant> arguments = spy.at(processedCount++);
            if (arguments.isEmpty()) {
                continue;
            }

            const mavlink_message_t message = qvariant_cast<mavlink_message_t>(arguments.first());
            if (message.msgid != MAVLINK_MSG_ID_MANUAL_CONTROL) {
                continue;
            }

            mavlink_msg_manual_control_decode(&message, &manualControl);
            return true;
        }

        const int remainingMs = timeoutMs - static_cast<int>(elapsedTimer.elapsed());
        if (remainingMs <= 0) {
            break;
        }

        (void) spy.wait(qMin(100, remainingMs));
    }

    return false;
}

void VehicleJoystickManualControlTest::_normalizedAuxValues()
{
    _connectMockLinkNoInitialConnectSequence();
    (void) qRegisterMetaType<mavlink_message_t>("mavlink_message_t");

    QSignalSpy spyManualControl(_vehicle, &Vehicle::mavlinkMessageSent);

    _vehicle->sendJoystickDataThreadSafe(0.0f, 0.0f, 0.0f, 0.0f, 0, 0.25f, -0.5f, 0b00001100);

    mavlink_manual_control_t manualControl{};
    QVERIFY2(_waitForManualControl(spyManualControl, manualControl), "MANUAL_CONTROL was not emitted");

    QCOMPARE(manualControl.target, static_cast<uint8_t>(_vehicle->id()));
    QCOMPARE(manualControl.aux1, static_cast<int16_t>(250));
    QCOMPARE(manualControl.aux2, static_cast<int16_t>(-500));
    QCOMPARE(manualControl.enabled_extensions & (1 << 2), (1 << 2));
    QCOMPARE(manualControl.enabled_extensions & (1 << 3), (1 << 3));

    _disconnectMockLink();
}

void VehicleJoystickManualControlTest::_disabledAuxExtensions()
{
    _connectMockLinkNoInitialConnectSequence();
    (void) qRegisterMetaType<mavlink_message_t>("mavlink_message_t");

    QSignalSpy spyManualControl(_vehicle, &Vehicle::mavlinkMessageSent);

    _vehicle->sendJoystickDataThreadSafe(0.0f, 0.0f, 0.0f, 0.0f, 0, 0.0f, 0.0f, 0);

    mavlink_manual_control_t manualControl{};
    QVERIFY2(_waitForManualControl(spyManualControl, manualControl), "MANUAL_CONTROL was not emitted");

    QCOMPARE(manualControl.target, static_cast<uint8_t>(_vehicle->id()));
    QCOMPARE(manualControl.aux1, static_cast<int16_t>(0));
    QCOMPARE(manualControl.aux2, static_cast<int16_t>(0));
    QCOMPARE(manualControl.enabled_extensions & (1 << 2), 0);
    QCOMPARE(manualControl.enabled_extensions & (1 << 3), 0);

    _disconnectMockLink();
}
