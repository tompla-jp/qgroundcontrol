#pragma once
// MESSAGE QVIO_STATUS PACKING

#define MAVLINK_MSG_ID_QVIO_STATUS 42000


typedef struct __mavlink_qvio_status_t {
 uint32_t time_boot_ms; /*<  Time since boot on VOXL (ms)*/
 float quality; /*<  QVIO quality percentage [-1 means invalid/stale]*/
 int32_t feature_count; /*<  In-state feature count [-1 means invalid/stale]*/
 uint32_t error_code; /*<  QVIO error bitmask from voxl-qvio-server*/
 uint8_t state; /*<  QVIO state value from voxl-qvio-server*/
 uint8_t stale; /*<  1 when data is stale or unavailable*/
 char error_text[50]; /*<  ASCII error or warning text (null-terminated if shorter than 50)*/
} mavlink_qvio_status_t;

#define MAVLINK_MSG_ID_QVIO_STATUS_LEN 68
#define MAVLINK_MSG_ID_QVIO_STATUS_MIN_LEN 68
#define MAVLINK_MSG_ID_42000_LEN 68
#define MAVLINK_MSG_ID_42000_MIN_LEN 68

#define MAVLINK_MSG_ID_QVIO_STATUS_CRC 149
#define MAVLINK_MSG_ID_42000_CRC 149

#define MAVLINK_MSG_QVIO_STATUS_FIELD_ERROR_TEXT_LEN 50

#if MAVLINK_COMMAND_24BIT
#define MAVLINK_MESSAGE_INFO_QVIO_STATUS { \
    42000, \
    "QVIO_STATUS", \
    7, \
    {  { "time_boot_ms", NULL, MAVLINK_TYPE_UINT32_T, 0, 0, offsetof(mavlink_qvio_status_t, time_boot_ms) }, \
         { "quality", NULL, MAVLINK_TYPE_FLOAT, 0, 4, offsetof(mavlink_qvio_status_t, quality) }, \
         { "feature_count", NULL, MAVLINK_TYPE_INT32_T, 0, 8, offsetof(mavlink_qvio_status_t, feature_count) }, \
         { "error_code", NULL, MAVLINK_TYPE_UINT32_T, 0, 12, offsetof(mavlink_qvio_status_t, error_code) }, \
         { "state", NULL, MAVLINK_TYPE_UINT8_T, 0, 16, offsetof(mavlink_qvio_status_t, state) }, \
         { "stale", NULL, MAVLINK_TYPE_UINT8_T, 0, 17, offsetof(mavlink_qvio_status_t, stale) }, \
         { "error_text", NULL, MAVLINK_TYPE_CHAR, 50, 18, offsetof(mavlink_qvio_status_t, error_text) }, \
         } \
}
#else
#define MAVLINK_MESSAGE_INFO_QVIO_STATUS { \
    "QVIO_STATUS", \
    7, \
    {  { "time_boot_ms", NULL, MAVLINK_TYPE_UINT32_T, 0, 0, offsetof(mavlink_qvio_status_t, time_boot_ms) }, \
         { "quality", NULL, MAVLINK_TYPE_FLOAT, 0, 4, offsetof(mavlink_qvio_status_t, quality) }, \
         { "feature_count", NULL, MAVLINK_TYPE_INT32_T, 0, 8, offsetof(mavlink_qvio_status_t, feature_count) }, \
         { "error_code", NULL, MAVLINK_TYPE_UINT32_T, 0, 12, offsetof(mavlink_qvio_status_t, error_code) }, \
         { "state", NULL, MAVLINK_TYPE_UINT8_T, 0, 16, offsetof(mavlink_qvio_status_t, state) }, \
         { "stale", NULL, MAVLINK_TYPE_UINT8_T, 0, 17, offsetof(mavlink_qvio_status_t, stale) }, \
         { "error_text", NULL, MAVLINK_TYPE_CHAR, 50, 18, offsetof(mavlink_qvio_status_t, error_text) }, \
         } \
}
#endif

/**
 * @brief Pack a qvio_status message
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 *
 * @param time_boot_ms  Time since boot on VOXL (ms)
 * @param quality  QVIO quality percentage [-1 means invalid/stale]
 * @param feature_count  In-state feature count [-1 means invalid/stale]
 * @param error_code  QVIO error bitmask from voxl-qvio-server
 * @param state  QVIO state value from voxl-qvio-server
 * @param stale  1 when data is stale or unavailable
 * @param error_text  ASCII error or warning text (null-terminated if shorter than 50)
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_qvio_status_pack(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg,
                               uint32_t time_boot_ms, float quality, int32_t feature_count, uint32_t error_code, uint8_t state, uint8_t stale, const char *error_text)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_QVIO_STATUS_LEN];
    _mav_put_uint32_t(buf, 0, time_boot_ms);
    _mav_put_float(buf, 4, quality);
    _mav_put_int32_t(buf, 8, feature_count);
    _mav_put_uint32_t(buf, 12, error_code);
    _mav_put_uint8_t(buf, 16, state);
    _mav_put_uint8_t(buf, 17, stale);
    _mav_put_char_array(buf, 18, error_text, 50);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_QVIO_STATUS_LEN);
#else
    mavlink_qvio_status_t packet;
    packet.time_boot_ms = time_boot_ms;
    packet.quality = quality;
    packet.feature_count = feature_count;
    packet.error_code = error_code;
    packet.state = state;
    packet.stale = stale;
    mav_array_memcpy(packet.error_text, error_text, sizeof(char)*50);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_QVIO_STATUS_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_QVIO_STATUS;
    return mavlink_finalize_message(msg, system_id, component_id, MAVLINK_MSG_ID_QVIO_STATUS_MIN_LEN, MAVLINK_MSG_ID_QVIO_STATUS_LEN, MAVLINK_MSG_ID_QVIO_STATUS_CRC);
}

/**
 * @brief Pack a qvio_status message
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param status MAVLink status structure
 * @param msg The MAVLink message to compress the data into
 *
 * @param time_boot_ms  Time since boot on VOXL (ms)
 * @param quality  QVIO quality percentage [-1 means invalid/stale]
 * @param feature_count  In-state feature count [-1 means invalid/stale]
 * @param error_code  QVIO error bitmask from voxl-qvio-server
 * @param state  QVIO state value from voxl-qvio-server
 * @param stale  1 when data is stale or unavailable
 * @param error_text  ASCII error or warning text (null-terminated if shorter than 50)
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_qvio_status_pack_status(uint8_t system_id, uint8_t component_id, mavlink_status_t *_status, mavlink_message_t* msg,
                               uint32_t time_boot_ms, float quality, int32_t feature_count, uint32_t error_code, uint8_t state, uint8_t stale, const char *error_text)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_QVIO_STATUS_LEN];
    _mav_put_uint32_t(buf, 0, time_boot_ms);
    _mav_put_float(buf, 4, quality);
    _mav_put_int32_t(buf, 8, feature_count);
    _mav_put_uint32_t(buf, 12, error_code);
    _mav_put_uint8_t(buf, 16, state);
    _mav_put_uint8_t(buf, 17, stale);
    _mav_put_char_array(buf, 18, error_text, 50);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_QVIO_STATUS_LEN);
#else
    mavlink_qvio_status_t packet;
    packet.time_boot_ms = time_boot_ms;
    packet.quality = quality;
    packet.feature_count = feature_count;
    packet.error_code = error_code;
    packet.state = state;
    packet.stale = stale;
    mav_array_memcpy(packet.error_text, error_text, sizeof(char)*50);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_QVIO_STATUS_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_QVIO_STATUS;
#if MAVLINK_CRC_EXTRA
    return mavlink_finalize_message_buffer(msg, system_id, component_id, _status, MAVLINK_MSG_ID_QVIO_STATUS_MIN_LEN, MAVLINK_MSG_ID_QVIO_STATUS_LEN, MAVLINK_MSG_ID_QVIO_STATUS_CRC);
#else
    return mavlink_finalize_message_buffer(msg, system_id, component_id, _status, MAVLINK_MSG_ID_QVIO_STATUS_MIN_LEN, MAVLINK_MSG_ID_QVIO_STATUS_LEN);
#endif
}

/**
 * @brief Pack a qvio_status message on a channel
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param chan The MAVLink channel this message will be sent over
 * @param msg The MAVLink message to compress the data into
 * @param time_boot_ms  Time since boot on VOXL (ms)
 * @param quality  QVIO quality percentage [-1 means invalid/stale]
 * @param feature_count  In-state feature count [-1 means invalid/stale]
 * @param error_code  QVIO error bitmask from voxl-qvio-server
 * @param state  QVIO state value from voxl-qvio-server
 * @param stale  1 when data is stale or unavailable
 * @param error_text  ASCII error or warning text (null-terminated if shorter than 50)
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_qvio_status_pack_chan(uint8_t system_id, uint8_t component_id, uint8_t chan,
                               mavlink_message_t* msg,
                                   uint32_t time_boot_ms,float quality,int32_t feature_count,uint32_t error_code,uint8_t state,uint8_t stale,const char *error_text)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_QVIO_STATUS_LEN];
    _mav_put_uint32_t(buf, 0, time_boot_ms);
    _mav_put_float(buf, 4, quality);
    _mav_put_int32_t(buf, 8, feature_count);
    _mav_put_uint32_t(buf, 12, error_code);
    _mav_put_uint8_t(buf, 16, state);
    _mav_put_uint8_t(buf, 17, stale);
    _mav_put_char_array(buf, 18, error_text, 50);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_QVIO_STATUS_LEN);
#else
    mavlink_qvio_status_t packet;
    packet.time_boot_ms = time_boot_ms;
    packet.quality = quality;
    packet.feature_count = feature_count;
    packet.error_code = error_code;
    packet.state = state;
    packet.stale = stale;
    mav_array_memcpy(packet.error_text, error_text, sizeof(char)*50);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_QVIO_STATUS_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_QVIO_STATUS;
    return mavlink_finalize_message_chan(msg, system_id, component_id, chan, MAVLINK_MSG_ID_QVIO_STATUS_MIN_LEN, MAVLINK_MSG_ID_QVIO_STATUS_LEN, MAVLINK_MSG_ID_QVIO_STATUS_CRC);
}

/**
 * @brief Encode a qvio_status struct
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 * @param qvio_status C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_qvio_status_encode(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg, const mavlink_qvio_status_t* qvio_status)
{
    return mavlink_msg_qvio_status_pack(system_id, component_id, msg, qvio_status->time_boot_ms, qvio_status->quality, qvio_status->feature_count, qvio_status->error_code, qvio_status->state, qvio_status->stale, qvio_status->error_text);
}

/**
 * @brief Encode a qvio_status struct on a channel
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param chan The MAVLink channel this message will be sent over
 * @param msg The MAVLink message to compress the data into
 * @param qvio_status C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_qvio_status_encode_chan(uint8_t system_id, uint8_t component_id, uint8_t chan, mavlink_message_t* msg, const mavlink_qvio_status_t* qvio_status)
{
    return mavlink_msg_qvio_status_pack_chan(system_id, component_id, chan, msg, qvio_status->time_boot_ms, qvio_status->quality, qvio_status->feature_count, qvio_status->error_code, qvio_status->state, qvio_status->stale, qvio_status->error_text);
}

/**
 * @brief Encode a qvio_status struct with provided status structure
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param status MAVLink status structure
 * @param msg The MAVLink message to compress the data into
 * @param qvio_status C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_qvio_status_encode_status(uint8_t system_id, uint8_t component_id, mavlink_status_t* _status, mavlink_message_t* msg, const mavlink_qvio_status_t* qvio_status)
{
    return mavlink_msg_qvio_status_pack_status(system_id, component_id, _status, msg,  qvio_status->time_boot_ms, qvio_status->quality, qvio_status->feature_count, qvio_status->error_code, qvio_status->state, qvio_status->stale, qvio_status->error_text);
}

/**
 * @brief Send a qvio_status message
 * @param chan MAVLink channel to send the message
 *
 * @param time_boot_ms  Time since boot on VOXL (ms)
 * @param quality  QVIO quality percentage [-1 means invalid/stale]
 * @param feature_count  In-state feature count [-1 means invalid/stale]
 * @param error_code  QVIO error bitmask from voxl-qvio-server
 * @param state  QVIO state value from voxl-qvio-server
 * @param stale  1 when data is stale or unavailable
 * @param error_text  ASCII error or warning text (null-terminated if shorter than 50)
 */
#ifdef MAVLINK_USE_CONVENIENCE_FUNCTIONS

static inline void mavlink_msg_qvio_status_send(mavlink_channel_t chan, uint32_t time_boot_ms, float quality, int32_t feature_count, uint32_t error_code, uint8_t state, uint8_t stale, const char *error_text)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_QVIO_STATUS_LEN];
    _mav_put_uint32_t(buf, 0, time_boot_ms);
    _mav_put_float(buf, 4, quality);
    _mav_put_int32_t(buf, 8, feature_count);
    _mav_put_uint32_t(buf, 12, error_code);
    _mav_put_uint8_t(buf, 16, state);
    _mav_put_uint8_t(buf, 17, stale);
    _mav_put_char_array(buf, 18, error_text, 50);
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_QVIO_STATUS, buf, MAVLINK_MSG_ID_QVIO_STATUS_MIN_LEN, MAVLINK_MSG_ID_QVIO_STATUS_LEN, MAVLINK_MSG_ID_QVIO_STATUS_CRC);
#else
    mavlink_qvio_status_t packet;
    packet.time_boot_ms = time_boot_ms;
    packet.quality = quality;
    packet.feature_count = feature_count;
    packet.error_code = error_code;
    packet.state = state;
    packet.stale = stale;
    mav_array_memcpy(packet.error_text, error_text, sizeof(char)*50);
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_QVIO_STATUS, (const char *)&packet, MAVLINK_MSG_ID_QVIO_STATUS_MIN_LEN, MAVLINK_MSG_ID_QVIO_STATUS_LEN, MAVLINK_MSG_ID_QVIO_STATUS_CRC);
#endif
}

/**
 * @brief Send a qvio_status message
 * @param chan MAVLink channel to send the message
 * @param struct The MAVLink struct to serialize
 */
static inline void mavlink_msg_qvio_status_send_struct(mavlink_channel_t chan, const mavlink_qvio_status_t* qvio_status)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    mavlink_msg_qvio_status_send(chan, qvio_status->time_boot_ms, qvio_status->quality, qvio_status->feature_count, qvio_status->error_code, qvio_status->state, qvio_status->stale, qvio_status->error_text);
#else
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_QVIO_STATUS, (const char *)qvio_status, MAVLINK_MSG_ID_QVIO_STATUS_MIN_LEN, MAVLINK_MSG_ID_QVIO_STATUS_LEN, MAVLINK_MSG_ID_QVIO_STATUS_CRC);
#endif
}

#if MAVLINK_MSG_ID_QVIO_STATUS_LEN <= MAVLINK_MAX_PAYLOAD_LEN
/*
  This variant of _send() can be used to save stack space by re-using
  memory from the receive buffer.  The caller provides a
  mavlink_message_t which is the size of a full mavlink message. This
  is usually the receive buffer for the channel, and allows a reply to an
  incoming message with minimum stack space usage.
 */
static inline void mavlink_msg_qvio_status_send_buf(mavlink_message_t *msgbuf, mavlink_channel_t chan,  uint32_t time_boot_ms, float quality, int32_t feature_count, uint32_t error_code, uint8_t state, uint8_t stale, const char *error_text)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char *buf = (char *)msgbuf;
    _mav_put_uint32_t(buf, 0, time_boot_ms);
    _mav_put_float(buf, 4, quality);
    _mav_put_int32_t(buf, 8, feature_count);
    _mav_put_uint32_t(buf, 12, error_code);
    _mav_put_uint8_t(buf, 16, state);
    _mav_put_uint8_t(buf, 17, stale);
    _mav_put_char_array(buf, 18, error_text, 50);
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_QVIO_STATUS, buf, MAVLINK_MSG_ID_QVIO_STATUS_MIN_LEN, MAVLINK_MSG_ID_QVIO_STATUS_LEN, MAVLINK_MSG_ID_QVIO_STATUS_CRC);
#else
    mavlink_qvio_status_t *packet = (mavlink_qvio_status_t *)msgbuf;
    packet->time_boot_ms = time_boot_ms;
    packet->quality = quality;
    packet->feature_count = feature_count;
    packet->error_code = error_code;
    packet->state = state;
    packet->stale = stale;
    mav_array_memcpy(packet->error_text, error_text, sizeof(char)*50);
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_QVIO_STATUS, (const char *)packet, MAVLINK_MSG_ID_QVIO_STATUS_MIN_LEN, MAVLINK_MSG_ID_QVIO_STATUS_LEN, MAVLINK_MSG_ID_QVIO_STATUS_CRC);
#endif
}
#endif

#endif

// MESSAGE QVIO_STATUS UNPACKING


/**
 * @brief Get field time_boot_ms from qvio_status message
 *
 * @return  Time since boot on VOXL (ms)
 */
static inline uint32_t mavlink_msg_qvio_status_get_time_boot_ms(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint32_t(msg,  0);
}

/**
 * @brief Get field quality from qvio_status message
 *
 * @return  QVIO quality percentage [-1 means invalid/stale]
 */
static inline float mavlink_msg_qvio_status_get_quality(const mavlink_message_t* msg)
{
    return _MAV_RETURN_float(msg,  4);
}

/**
 * @brief Get field feature_count from qvio_status message
 *
 * @return  In-state feature count [-1 means invalid/stale]
 */
static inline int32_t mavlink_msg_qvio_status_get_feature_count(const mavlink_message_t* msg)
{
    return _MAV_RETURN_int32_t(msg,  8);
}

/**
 * @brief Get field error_code from qvio_status message
 *
 * @return  QVIO error bitmask from voxl-qvio-server
 */
static inline uint32_t mavlink_msg_qvio_status_get_error_code(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint32_t(msg,  12);
}

/**
 * @brief Get field state from qvio_status message
 *
 * @return  QVIO state value from voxl-qvio-server
 */
static inline uint8_t mavlink_msg_qvio_status_get_state(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint8_t(msg,  16);
}

/**
 * @brief Get field stale from qvio_status message
 *
 * @return  1 when data is stale or unavailable
 */
static inline uint8_t mavlink_msg_qvio_status_get_stale(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint8_t(msg,  17);
}

/**
 * @brief Get field error_text from qvio_status message
 *
 * @return  ASCII error or warning text (null-terminated if shorter than 50)
 */
static inline uint16_t mavlink_msg_qvio_status_get_error_text(const mavlink_message_t* msg, char *error_text)
{
    return _MAV_RETURN_char_array(msg, error_text, 50,  18);
}

/**
 * @brief Decode a qvio_status message into a struct
 *
 * @param msg The message to decode
 * @param qvio_status C-struct to decode the message contents into
 */
static inline void mavlink_msg_qvio_status_decode(const mavlink_message_t* msg, mavlink_qvio_status_t* qvio_status)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    qvio_status->time_boot_ms = mavlink_msg_qvio_status_get_time_boot_ms(msg);
    qvio_status->quality = mavlink_msg_qvio_status_get_quality(msg);
    qvio_status->feature_count = mavlink_msg_qvio_status_get_feature_count(msg);
    qvio_status->error_code = mavlink_msg_qvio_status_get_error_code(msg);
    qvio_status->state = mavlink_msg_qvio_status_get_state(msg);
    qvio_status->stale = mavlink_msg_qvio_status_get_stale(msg);
    mavlink_msg_qvio_status_get_error_text(msg, qvio_status->error_text);
#else
        uint8_t len = msg->len < MAVLINK_MSG_ID_QVIO_STATUS_LEN? msg->len : MAVLINK_MSG_ID_QVIO_STATUS_LEN;
        memset(qvio_status, 0, MAVLINK_MSG_ID_QVIO_STATUS_LEN);
    memcpy(qvio_status, _MAV_PAYLOAD(msg), len);
#endif
}
