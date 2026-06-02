// MESSAGE CUSMVL_SAFE_SHUTDOWN support class

#pragma once

namespace mavlink {
namespace custom {
namespace msg {

/**
 * @brief CUSMVL_SAFE_SHUTDOWN message
 *
 * Companion-computer safe shutdown request from QGC or another MAVLink endpoint.
 */
struct CUSMVL_SAFE_SHUTDOWN : mavlink::Message {
    static constexpr msgid_t MSG_ID = 42010;
    static constexpr size_t LENGTH = 40;
    static constexpr size_t MIN_LENGTH = 40;
    static constexpr uint8_t CRC_EXTRA = 220;
    static constexpr auto NAME = "CUSMVL_SAFE_SHUTDOWN";


    uint32_t request_id; /*<  Requester-generated id for correlation and deduplication. */
    uint8_t target_system; /*<  Target system id, or 0 to broadcast. */
    uint8_t target_component; /*<  Target companion component id, or 0 to broadcast. */
    uint8_t confirmation; /*<  Must be set to 1 to authorize shutdown. */
    uint8_t shutdown_type; /*<  Shutdown mode. */
    std::array<char, 32> reason; /*<  Optional human-readable reason. */


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
        ss << "  request_id: " << request_id << std::endl;
        ss << "  target_system: " << +target_system << std::endl;
        ss << "  target_component: " << +target_component << std::endl;
        ss << "  confirmation: " << +confirmation << std::endl;
        ss << "  shutdown_type: " << +shutdown_type << std::endl;
        ss << "  reason: \"" << to_string(reason) << "\"" << std::endl;

        return ss.str();
    }

    inline void serialize(mavlink::MsgMap &map) const override
    {
        map.reset(MSG_ID, LENGTH);

        map << request_id;                    // offset: 0
        map << target_system;                 // offset: 4
        map << target_component;              // offset: 5
        map << confirmation;                  // offset: 6
        map << shutdown_type;                 // offset: 7
        map << reason;                        // offset: 8
    }

    inline void deserialize(mavlink::MsgMap &map) override
    {
        map >> request_id;                    // offset: 0
        map >> target_system;                 // offset: 4
        map >> target_component;              // offset: 5
        map >> confirmation;                  // offset: 6
        map >> shutdown_type;                 // offset: 7
        map >> reason;                        // offset: 8
    }
};

} // namespace msg
} // namespace custom
} // namespace mavlink
