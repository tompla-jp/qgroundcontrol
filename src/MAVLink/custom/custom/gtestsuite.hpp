/** @file
 *	@brief MAVLink comm testsuite protocol generated from custom.xml
 *	@see http://mavlink.org
 */

#pragma once

#include <gtest/gtest.h>
#include "custom.hpp"

#ifdef TEST_INTEROP
using namespace mavlink;
#undef MAVLINK_HELPER
#include "mavlink.h"
#endif


TEST(custom, QVIO_STATUS)
{
    mavlink::mavlink_message_t msg;
    mavlink::MsgMap map1(msg);
    mavlink::MsgMap map2(msg);

    mavlink::custom::msg::QVIO_STATUS packet_in{};
    packet_in.time_boot_ms = 963497464;
    packet_in.quality = 45.0;
    packet_in.feature_count = 963497880;
    packet_in.error_code = 963498088;
    packet_in.state = 53;
    packet_in.stale = 120;
    packet_in.error_text = to_char_array("STUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNO");

    mavlink::custom::msg::QVIO_STATUS packet1{};
    mavlink::custom::msg::QVIO_STATUS packet2{};

    packet1 = packet_in;

    //std::cout << packet1.to_yaml() << std::endl;

    packet1.serialize(map1);

    mavlink::mavlink_finalize_message(&msg, 1, 1, packet1.MIN_LENGTH, packet1.LENGTH, packet1.CRC_EXTRA);

    packet2.deserialize(map2);

    EXPECT_EQ(packet1.time_boot_ms, packet2.time_boot_ms);
    EXPECT_EQ(packet1.quality, packet2.quality);
    EXPECT_EQ(packet1.feature_count, packet2.feature_count);
    EXPECT_EQ(packet1.error_code, packet2.error_code);
    EXPECT_EQ(packet1.state, packet2.state);
    EXPECT_EQ(packet1.stale, packet2.stale);
    EXPECT_EQ(packet1.error_text, packet2.error_text);
}

#ifdef TEST_INTEROP
TEST(custom_interop, QVIO_STATUS)
{
    mavlink_message_t msg;

    // to get nice print
    memset(&msg, 0, sizeof(msg));

    mavlink_qvio_status_t packet_c {
         963497464, 45.0, 963497880, 963498088, 53, 120, "STUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNO"
    };

    mavlink::custom::msg::QVIO_STATUS packet_in{};
    packet_in.time_boot_ms = 963497464;
    packet_in.quality = 45.0;
    packet_in.feature_count = 963497880;
    packet_in.error_code = 963498088;
    packet_in.state = 53;
    packet_in.stale = 120;
    packet_in.error_text = to_char_array("STUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNO");

    mavlink::custom::msg::QVIO_STATUS packet2{};

    mavlink_msg_qvio_status_encode(1, 1, &msg, &packet_c);

    // simulate message-handling callback
    [&packet2](const mavlink_message_t *cmsg) {
        MsgMap map2(cmsg);

        packet2.deserialize(map2);
    } (&msg);

    EXPECT_EQ(packet_in.time_boot_ms, packet2.time_boot_ms);
    EXPECT_EQ(packet_in.quality, packet2.quality);
    EXPECT_EQ(packet_in.feature_count, packet2.feature_count);
    EXPECT_EQ(packet_in.error_code, packet2.error_code);
    EXPECT_EQ(packet_in.state, packet2.state);
    EXPECT_EQ(packet_in.stale, packet2.stale);
    EXPECT_EQ(packet_in.error_text, packet2.error_text);

#ifdef PRINT_MSG
    PRINT_MSG(msg);
#endif
}
#endif
