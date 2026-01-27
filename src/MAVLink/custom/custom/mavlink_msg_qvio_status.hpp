// MESSAGE QVIO_STATUS support class

#pragma once

namespace mavlink {
namespace custom {
namespace msg {

/**
 * @brief QVIO_STATUS message
 *
 * QVIO health metrics streamed from VOXL to GCS.
 */
struct QVIO_STATUS : mavlink::Message {
    static constexpr msgid_t MSG_ID = 42000;
    static constexpr size_t LENGTH = 68;
    static constexpr size_t MIN_LENGTH = 68;
    static constexpr uint8_t CRC_EXTRA = 149;
    static constexpr auto NAME = "QVIO_STATUS";


    uint32_t time_boot_ms; /*<  Time since boot on VOXL (ms) */
    float quality; /*<  QVIO quality percentage [-1 means invalid/stale] */
    int32_t feature_count; /*<  In-state feature count [-1 means invalid/stale] */
    uint32_t error_code; /*<  QVIO error bitmask from voxl-qvio-server */
    uint8_t state; /*<  QVIO state value from voxl-qvio-server */
    uint8_t stale; /*<  1 when data is stale or unavailable */
    std::array<char, 50> error_text; /*<  ASCII error or warning text (null-terminated if shorter than 50) */


    inline std::string get_name(void) const override
    {
            return NAME;
    }

    inline Info get_message_info(void) const override
    {
            return { MSG_ID, LENGTH, MIN_LENGTH, CRC_EXTRA };
    }

    inline std::string to_yaml(void) const override
    {
        std::stringstream ss;

        ss << NAME << ":" << std::endl;
        ss << "  time_boot_ms: " << time_boot_ms << std::endl;
        ss << "  quality: " << quality << std::endl;
        ss << "  feature_count: " << feature_count << std::endl;
        ss << "  error_code: " << error_code << std::endl;
        ss << "  state: " << +state << std::endl;
        ss << "  stale: " << +stale << std::endl;
        ss << "  error_text: \"" << to_string(error_text) << "\"" << std::endl;

        return ss.str();
    }

    inline void serialize(mavlink::MsgMap &map) const override
    {
        map.reset(MSG_ID, LENGTH);

        map << time_boot_ms;                  // offset: 0
        map << quality;                       // offset: 4
        map << feature_count;                 // offset: 8
        map << error_code;                    // offset: 12
        map << state;                         // offset: 16
        map << stale;                         // offset: 17
        map << error_text;                    // offset: 18
    }

    inline void deserialize(mavlink::MsgMap &map) override
    {
        map >> time_boot_ms;                  // offset: 0
        map >> quality;                       // offset: 4
        map >> feature_count;                 // offset: 8
        map >> error_code;                    // offset: 12
        map >> state;                         // offset: 16
        map >> stale;                         // offset: 17
        map >> error_text;                    // offset: 18
    }
};

} // namespace msg
} // namespace custom
} // namespace mavlink
