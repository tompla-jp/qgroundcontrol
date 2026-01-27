/** @file
 *    @brief MAVLink comm protocol testsuite generated from custom.xml
 *    @see https://mavlink.io/en/
 */
#pragma once
#ifndef CUSTOM_TESTSUITE_H
#define CUSTOM_TESTSUITE_H

#ifdef __cplusplus
extern "C" {
#endif

#ifndef MAVLINK_TEST_ALL
#define MAVLINK_TEST_ALL
static void mavlink_test_common(uint8_t, uint8_t, mavlink_message_t *last_msg);
static void mavlink_test_development(uint8_t, uint8_t, mavlink_message_t *last_msg);
static void mavlink_test_custom(uint8_t, uint8_t, mavlink_message_t *last_msg);

static void mavlink_test_all(uint8_t system_id, uint8_t component_id, mavlink_message_t *last_msg)
{
    mavlink_test_common(system_id, component_id, last_msg);
    mavlink_test_development(system_id, component_id, last_msg);
    mavlink_test_custom(system_id, component_id, last_msg);
}
#endif

#include "../common/testsuite.h"
#include "../development/testsuite.h"


static void mavlink_test_qvio_status(uint8_t system_id, uint8_t component_id, mavlink_message_t *last_msg)
{
#ifdef MAVLINK_STATUS_FLAG_OUT_MAVLINK1
    mavlink_status_t *status = mavlink_get_channel_status(MAVLINK_COMM_0);
        if ((status->flags & MAVLINK_STATUS_FLAG_OUT_MAVLINK1) && MAVLINK_MSG_ID_QVIO_STATUS >= 256) {
            return;
        }
#endif
    mavlink_message_t msg;
        uint8_t buffer[MAVLINK_MAX_PACKET_LEN];
        uint16_t i;
    mavlink_qvio_status_t packet_in = {
        963497464,45.0,963497880,963498088,53,120,"STUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNO"
    };
    mavlink_qvio_status_t packet1, packet2;
        memset(&packet1, 0, sizeof(packet1));
        packet1.time_boot_ms = packet_in.time_boot_ms;
        packet1.quality = packet_in.quality;
        packet1.feature_count = packet_in.feature_count;
        packet1.error_code = packet_in.error_code;
        packet1.state = packet_in.state;
        packet1.stale = packet_in.stale;
        
        mav_array_memcpy(packet1.error_text, packet_in.error_text, sizeof(char)*50);
        
#ifdef MAVLINK_STATUS_FLAG_OUT_MAVLINK1
        if (status->flags & MAVLINK_STATUS_FLAG_OUT_MAVLINK1) {
           // cope with extensions
           memset(MAVLINK_MSG_ID_QVIO_STATUS_MIN_LEN + (char *)&packet1, 0, sizeof(packet1)-MAVLINK_MSG_ID_QVIO_STATUS_MIN_LEN);
        }
#endif
        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_qvio_status_encode(system_id, component_id, &msg, &packet1);
    mavlink_msg_qvio_status_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_qvio_status_pack(system_id, component_id, &msg , packet1.time_boot_ms , packet1.quality , packet1.feature_count , packet1.error_code , packet1.state , packet1.stale , packet1.error_text );
    mavlink_msg_qvio_status_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_qvio_status_pack_chan(system_id, component_id, MAVLINK_COMM_0, &msg , packet1.time_boot_ms , packet1.quality , packet1.feature_count , packet1.error_code , packet1.state , packet1.stale , packet1.error_text );
    mavlink_msg_qvio_status_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
        mavlink_msg_to_send_buffer(buffer, &msg);
        for (i=0; i<mavlink_msg_get_send_buffer_length(&msg); i++) {
            comm_send_ch(MAVLINK_COMM_0, buffer[i]);
        }
    mavlink_msg_qvio_status_decode(last_msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);
        
        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_qvio_status_send(MAVLINK_COMM_1 , packet1.time_boot_ms , packet1.quality , packet1.feature_count , packet1.error_code , packet1.state , packet1.stale , packet1.error_text );
    mavlink_msg_qvio_status_decode(last_msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

#ifdef MAVLINK_HAVE_GET_MESSAGE_INFO
    MAVLINK_ASSERT(mavlink_get_message_info_by_name("QVIO_STATUS") != NULL);
    MAVLINK_ASSERT(mavlink_get_message_info_by_id(MAVLINK_MSG_ID_QVIO_STATUS) != NULL);
#endif
}

static void mavlink_test_custom(uint8_t system_id, uint8_t component_id, mavlink_message_t *last_msg)
{
    mavlink_test_qvio_status(system_id, component_id, last_msg);
}

#ifdef __cplusplus
}
#endif // __cplusplus
#endif // CUSTOM_TESTSUITE_H
