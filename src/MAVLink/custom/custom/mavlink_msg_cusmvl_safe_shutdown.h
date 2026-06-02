#pragma once
// MESSAGE CUSMVL_SAFE_SHUTDOWN PACKING

#define MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN 42010


typedef struct __mavlink_cusmvl_safe_shutdown_t {
 uint32_t request_id; /*<  Requester-generated id for correlation and deduplication.*/
 uint8_t target_system; /*<  Target system id, or 0 to broadcast.*/
 uint8_t target_component; /*<  Target companion component id, or 0 to broadcast.*/
 uint8_t confirmation; /*<  Must be set to 1 to authorize shutdown.*/
 uint8_t shutdown_type; /*<  Shutdown mode.*/
 char reason[32]; /*<  Optional human-readable reason.*/
} mavlink_cusmvl_safe_shutdown_t;

#define MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN 40
#define MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_MIN_LEN 40
#define MAVLINK_MSG_ID_42010_LEN 40
#define MAVLINK_MSG_ID_42010_MIN_LEN 40

#define MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_CRC 220
#define MAVLINK_MSG_ID_42010_CRC 220

#define MAVLINK_MSG_CUSMVL_SAFE_SHUTDOWN_FIELD_REASON_LEN 32

#if MAVLINK_COMMAND_24BIT
#define MAVLINK_MESSAGE_INFO_CUSMVL_SAFE_SHUTDOWN { \
    42010, \
    "CUSMVL_SAFE_SHUTDOWN", \
    6, \
    {  { "request_id", NULL, MAVLINK_TYPE_UINT32_T, 0, 0, offsetof(mavlink_cusmvl_safe_shutdown_t, request_id) }, \
         { "target_system", NULL, MAVLINK_TYPE_UINT8_T, 0, 4, offsetof(mavlink_cusmvl_safe_shutdown_t, target_system) }, \
         { "target_component", NULL, MAVLINK_TYPE_UINT8_T, 0, 5, offsetof(mavlink_cusmvl_safe_shutdown_t, target_component) }, \
         { "confirmation", NULL, MAVLINK_TYPE_UINT8_T, 0, 6, offsetof(mavlink_cusmvl_safe_shutdown_t, confirmation) }, \
         { "shutdown_type", NULL, MAVLINK_TYPE_UINT8_T, 0, 7, offsetof(mavlink_cusmvl_safe_shutdown_t, shutdown_type) }, \
         { "reason", NULL, MAVLINK_TYPE_CHAR, 32, 8, offsetof(mavlink_cusmvl_safe_shutdown_t, reason) }, \
         } \
}
#else
#define MAVLINK_MESSAGE_INFO_CUSMVL_SAFE_SHUTDOWN { \
    "CUSMVL_SAFE_SHUTDOWN", \
    6, \
    {  { "request_id", NULL, MAVLINK_TYPE_UINT32_T, 0, 0, offsetof(mavlink_cusmvl_safe_shutdown_t, request_id) }, \
         { "target_system", NULL, MAVLINK_TYPE_UINT8_T, 0, 4, offsetof(mavlink_cusmvl_safe_shutdown_t, target_system) }, \
         { "target_component", NULL, MAVLINK_TYPE_UINT8_T, 0, 5, offsetof(mavlink_cusmvl_safe_shutdown_t, target_component) }, \
         { "confirmation", NULL, MAVLINK_TYPE_UINT8_T, 0, 6, offsetof(mavlink_cusmvl_safe_shutdown_t, confirmation) }, \
         { "shutdown_type", NULL, MAVLINK_TYPE_UINT8_T, 0, 7, offsetof(mavlink_cusmvl_safe_shutdown_t, shutdown_type) }, \
         { "reason", NULL, MAVLINK_TYPE_CHAR, 32, 8, offsetof(mavlink_cusmvl_safe_shutdown_t, reason) }, \
         } \
}
#endif

/**
 * @brief Pack a cusmvl_safe_shutdown message
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 *
 * @param request_id  Requester-generated id for correlation and deduplication.
 * @param target_system  Target system id, or 0 to broadcast.
 * @param target_component  Target companion component id, or 0 to broadcast.
 * @param confirmation  Must be set to 1 to authorize shutdown.
 * @param shutdown_type  Shutdown mode.
 * @param reason  Optional human-readable reason.
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_cusmvl_safe_shutdown_pack(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg,
                               uint32_t request_id, uint8_t target_system, uint8_t target_component, uint8_t confirmation, uint8_t shutdown_type, const char *reason)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN];
    _mav_put_uint32_t(buf, 0, request_id);
    _mav_put_uint8_t(buf, 4, target_system);
    _mav_put_uint8_t(buf, 5, target_component);
    _mav_put_uint8_t(buf, 6, confirmation);
    _mav_put_uint8_t(buf, 7, shutdown_type);
    _mav_put_char_array(buf, 8, reason, 32);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN);
#else
    mavlink_cusmvl_safe_shutdown_t packet;
    packet.request_id = request_id;
    packet.target_system = target_system;
    packet.target_component = target_component;
    packet.confirmation = confirmation;
    packet.shutdown_type = shutdown_type;
    mav_array_memcpy(packet.reason, reason, sizeof(char)*32);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN;
    return mavlink_finalize_message(msg, system_id, component_id, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_MIN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_CRC);
}

/**
 * @brief Pack a cusmvl_safe_shutdown message
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param status MAVLink status structure
 * @param msg The MAVLink message to compress the data into
 *
 * @param request_id  Requester-generated id for correlation and deduplication.
 * @param target_system  Target system id, or 0 to broadcast.
 * @param target_component  Target companion component id, or 0 to broadcast.
 * @param confirmation  Must be set to 1 to authorize shutdown.
 * @param shutdown_type  Shutdown mode.
 * @param reason  Optional human-readable reason.
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_cusmvl_safe_shutdown_pack_status(uint8_t system_id, uint8_t component_id, mavlink_status_t *_status, mavlink_message_t* msg,
                               uint32_t request_id, uint8_t target_system, uint8_t target_component, uint8_t confirmation, uint8_t shutdown_type, const char *reason)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN];
    _mav_put_uint32_t(buf, 0, request_id);
    _mav_put_uint8_t(buf, 4, target_system);
    _mav_put_uint8_t(buf, 5, target_component);
    _mav_put_uint8_t(buf, 6, confirmation);
    _mav_put_uint8_t(buf, 7, shutdown_type);
    _mav_put_char_array(buf, 8, reason, 32);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN);
#else
    mavlink_cusmvl_safe_shutdown_t packet;
    packet.request_id = request_id;
    packet.target_system = target_system;
    packet.target_component = target_component;
    packet.confirmation = confirmation;
    packet.shutdown_type = shutdown_type;
    mav_array_memcpy(packet.reason, reason, sizeof(char)*32);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN;
#if MAVLINK_CRC_EXTRA
    return mavlink_finalize_message_buffer(msg, system_id, component_id, _status, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_MIN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_CRC);
#else
    return mavlink_finalize_message_buffer(msg, system_id, component_id, _status, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_MIN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN);
#endif
}

/**
 * @brief Pack a cusmvl_safe_shutdown message on a channel
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param chan The MAVLink channel this message will be sent over
 * @param msg The MAVLink message to compress the data into
 * @param request_id  Requester-generated id for correlation and deduplication.
 * @param target_system  Target system id, or 0 to broadcast.
 * @param target_component  Target companion component id, or 0 to broadcast.
 * @param confirmation  Must be set to 1 to authorize shutdown.
 * @param shutdown_type  Shutdown mode.
 * @param reason  Optional human-readable reason.
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_cusmvl_safe_shutdown_pack_chan(uint8_t system_id, uint8_t component_id, uint8_t chan,
                               mavlink_message_t* msg,
                                   uint32_t request_id,uint8_t target_system,uint8_t target_component,uint8_t confirmation,uint8_t shutdown_type,const char *reason)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN];
    _mav_put_uint32_t(buf, 0, request_id);
    _mav_put_uint8_t(buf, 4, target_system);
    _mav_put_uint8_t(buf, 5, target_component);
    _mav_put_uint8_t(buf, 6, confirmation);
    _mav_put_uint8_t(buf, 7, shutdown_type);
    _mav_put_char_array(buf, 8, reason, 32);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN);
#else
    mavlink_cusmvl_safe_shutdown_t packet;
    packet.request_id = request_id;
    packet.target_system = target_system;
    packet.target_component = target_component;
    packet.confirmation = confirmation;
    packet.shutdown_type = shutdown_type;
    mav_array_memcpy(packet.reason, reason, sizeof(char)*32);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN;
    return mavlink_finalize_message_chan(msg, system_id, component_id, chan, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_MIN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_CRC);
}

/**
 * @brief Encode a cusmvl_safe_shutdown struct
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 * @param cusmvl_safe_shutdown C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_cusmvl_safe_shutdown_encode(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg, const mavlink_cusmvl_safe_shutdown_t* cusmvl_safe_shutdown)
{
    return mavlink_msg_cusmvl_safe_shutdown_pack(system_id, component_id, msg, cusmvl_safe_shutdown->request_id, cusmvl_safe_shutdown->target_system, cusmvl_safe_shutdown->target_component, cusmvl_safe_shutdown->confirmation, cusmvl_safe_shutdown->shutdown_type, cusmvl_safe_shutdown->reason);
}

/**
 * @brief Encode a cusmvl_safe_shutdown struct on a channel
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param chan The MAVLink channel this message will be sent over
 * @param msg The MAVLink message to compress the data into
 * @param cusmvl_safe_shutdown C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_cusmvl_safe_shutdown_encode_chan(uint8_t system_id, uint8_t component_id, uint8_t chan, mavlink_message_t* msg, const mavlink_cusmvl_safe_shutdown_t* cusmvl_safe_shutdown)
{
    return mavlink_msg_cusmvl_safe_shutdown_pack_chan(system_id, component_id, chan, msg, cusmvl_safe_shutdown->request_id, cusmvl_safe_shutdown->target_system, cusmvl_safe_shutdown->target_component, cusmvl_safe_shutdown->confirmation, cusmvl_safe_shutdown->shutdown_type, cusmvl_safe_shutdown->reason);
}

/**
 * @brief Encode a cusmvl_safe_shutdown struct with provided status structure
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param status MAVLink status structure
 * @param msg The MAVLink message to compress the data into
 * @param cusmvl_safe_shutdown C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_cusmvl_safe_shutdown_encode_status(uint8_t system_id, uint8_t component_id, mavlink_status_t* _status, mavlink_message_t* msg, const mavlink_cusmvl_safe_shutdown_t* cusmvl_safe_shutdown)
{
    return mavlink_msg_cusmvl_safe_shutdown_pack_status(system_id, component_id, _status, msg,  cusmvl_safe_shutdown->request_id, cusmvl_safe_shutdown->target_system, cusmvl_safe_shutdown->target_component, cusmvl_safe_shutdown->confirmation, cusmvl_safe_shutdown->shutdown_type, cusmvl_safe_shutdown->reason);
}

/**
 * @brief Send a cusmvl_safe_shutdown message
 * @param chan MAVLink channel to send the message
 *
 * @param request_id  Requester-generated id for correlation and deduplication.
 * @param target_system  Target system id, or 0 to broadcast.
 * @param target_component  Target companion component id, or 0 to broadcast.
 * @param confirmation  Must be set to 1 to authorize shutdown.
 * @param shutdown_type  Shutdown mode.
 * @param reason  Optional human-readable reason.
 */
#ifdef MAVLINK_USE_CONVENIENCE_FUNCTIONS

static inline void mavlink_msg_cusmvl_safe_shutdown_send(mavlink_channel_t chan, uint32_t request_id, uint8_t target_system, uint8_t target_component, uint8_t confirmation, uint8_t shutdown_type, const char *reason)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN];
    _mav_put_uint32_t(buf, 0, request_id);
    _mav_put_uint8_t(buf, 4, target_system);
    _mav_put_uint8_t(buf, 5, target_component);
    _mav_put_uint8_t(buf, 6, confirmation);
    _mav_put_uint8_t(buf, 7, shutdown_type);
    _mav_put_char_array(buf, 8, reason, 32);
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN, buf, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_MIN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_CRC);
#else
    mavlink_cusmvl_safe_shutdown_t packet;
    packet.request_id = request_id;
    packet.target_system = target_system;
    packet.target_component = target_component;
    packet.confirmation = confirmation;
    packet.shutdown_type = shutdown_type;
    mav_array_memcpy(packet.reason, reason, sizeof(char)*32);
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN, (const char *)&packet, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_MIN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_CRC);
#endif
}

/**
 * @brief Send a cusmvl_safe_shutdown message
 * @param chan MAVLink channel to send the message
 * @param struct The MAVLink struct to serialize
 */
static inline void mavlink_msg_cusmvl_safe_shutdown_send_struct(mavlink_channel_t chan, const mavlink_cusmvl_safe_shutdown_t* cusmvl_safe_shutdown)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    mavlink_msg_cusmvl_safe_shutdown_send(chan, cusmvl_safe_shutdown->request_id, cusmvl_safe_shutdown->target_system, cusmvl_safe_shutdown->target_component, cusmvl_safe_shutdown->confirmation, cusmvl_safe_shutdown->shutdown_type, cusmvl_safe_shutdown->reason);
#else
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN, (const char *)cusmvl_safe_shutdown, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_MIN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_CRC);
#endif
}

#if MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN <= MAVLINK_MAX_PAYLOAD_LEN
/*
  This variant of _send() can be used to save stack space by reusing
  memory from the receive buffer.  The caller provides a
  mavlink_message_t which is the size of a full mavlink message. This
  is usually the receive buffer for the channel, and allows a reply to an
  incoming message with minimum stack space usage.
 */
static inline void mavlink_msg_cusmvl_safe_shutdown_send_buf(mavlink_message_t *msgbuf, mavlink_channel_t chan,  uint32_t request_id, uint8_t target_system, uint8_t target_component, uint8_t confirmation, uint8_t shutdown_type, const char *reason)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char *buf = (char *)msgbuf;
    _mav_put_uint32_t(buf, 0, request_id);
    _mav_put_uint8_t(buf, 4, target_system);
    _mav_put_uint8_t(buf, 5, target_component);
    _mav_put_uint8_t(buf, 6, confirmation);
    _mav_put_uint8_t(buf, 7, shutdown_type);
    _mav_put_char_array(buf, 8, reason, 32);
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN, buf, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_MIN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_CRC);
#else
    mavlink_cusmvl_safe_shutdown_t *packet = (mavlink_cusmvl_safe_shutdown_t *)msgbuf;
    packet->request_id = request_id;
    packet->target_system = target_system;
    packet->target_component = target_component;
    packet->confirmation = confirmation;
    packet->shutdown_type = shutdown_type;
    mav_array_memcpy(packet->reason, reason, sizeof(char)*32);
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN, (const char *)packet, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_MIN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_CRC);
#endif
}
#endif

#endif

// MESSAGE CUSMVL_SAFE_SHUTDOWN UNPACKING


/**
 * @brief Get field request_id from cusmvl_safe_shutdown message
 *
 * @return  Requester-generated id for correlation and deduplication.
 */
static inline uint32_t mavlink_msg_cusmvl_safe_shutdown_get_request_id(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint32_t(msg,  0);
}

/**
 * @brief Get field target_system from cusmvl_safe_shutdown message
 *
 * @return  Target system id, or 0 to broadcast.
 */
static inline uint8_t mavlink_msg_cusmvl_safe_shutdown_get_target_system(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint8_t(msg,  4);
}

/**
 * @brief Get field target_component from cusmvl_safe_shutdown message
 *
 * @return  Target companion component id, or 0 to broadcast.
 */
static inline uint8_t mavlink_msg_cusmvl_safe_shutdown_get_target_component(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint8_t(msg,  5);
}

/**
 * @brief Get field confirmation from cusmvl_safe_shutdown message
 *
 * @return  Must be set to 1 to authorize shutdown.
 */
static inline uint8_t mavlink_msg_cusmvl_safe_shutdown_get_confirmation(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint8_t(msg,  6);
}

/**
 * @brief Get field shutdown_type from cusmvl_safe_shutdown message
 *
 * @return  Shutdown mode.
 */
static inline uint8_t mavlink_msg_cusmvl_safe_shutdown_get_shutdown_type(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint8_t(msg,  7);
}

/**
 * @brief Get field reason from cusmvl_safe_shutdown message
 *
 * @return  Optional human-readable reason.
 */
static inline uint16_t mavlink_msg_cusmvl_safe_shutdown_get_reason(const mavlink_message_t* msg, char *reason)
{
    return _MAV_RETURN_char_array(msg, reason, 32,  8);
}

/**
 * @brief Decode a cusmvl_safe_shutdown message into a struct
 *
 * @param msg The message to decode
 * @param cusmvl_safe_shutdown C-struct to decode the message contents into
 */
static inline void mavlink_msg_cusmvl_safe_shutdown_decode(const mavlink_message_t* msg, mavlink_cusmvl_safe_shutdown_t* cusmvl_safe_shutdown)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    cusmvl_safe_shutdown->request_id = mavlink_msg_cusmvl_safe_shutdown_get_request_id(msg);
    cusmvl_safe_shutdown->target_system = mavlink_msg_cusmvl_safe_shutdown_get_target_system(msg);
    cusmvl_safe_shutdown->target_component = mavlink_msg_cusmvl_safe_shutdown_get_target_component(msg);
    cusmvl_safe_shutdown->confirmation = mavlink_msg_cusmvl_safe_shutdown_get_confirmation(msg);
    cusmvl_safe_shutdown->shutdown_type = mavlink_msg_cusmvl_safe_shutdown_get_shutdown_type(msg);
    mavlink_msg_cusmvl_safe_shutdown_get_reason(msg, cusmvl_safe_shutdown->reason);
#else
        uint8_t len = msg->len < MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN? msg->len : MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN;
        memset(cusmvl_safe_shutdown, 0, MAVLINK_MSG_ID_CUSMVL_SAFE_SHUTDOWN_LEN);
    memcpy(cusmvl_safe_shutdown, _MAV_PAYLOAD(msg), len);
#endif
}
