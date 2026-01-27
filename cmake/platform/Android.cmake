# ----------------------------------------------------------------------------
# QGroundControl Android Platform Configuration
# ----------------------------------------------------------------------------

if(NOT ANDROID)
    message(FATAL_ERROR "QGC: Invalid Platform: Android.cmake included but platform is not Android")
endif()

# Ensure libc++_shared is packaged to satisfy pmr symbols on all devices
set(CMAKE_ANDROID_STL_TYPE "c++_shared" CACHE STRING "Android STL type" FORCE)
set(ANDROID_STL "c++_shared" CACHE STRING "Android STL type (legacy variable)" FORCE)

# Default to arm64-v8a (matches the installed Qt package) if the ABI was not provided.
if(NOT ANDROID_ABI)
    set(ANDROID_ABI "arm64-v8a" CACHE STRING "Android ABI" FORCE)
endif()
if(NOT CMAKE_ANDROID_ARCH_ABI)
    set(CMAKE_ANDROID_ARCH_ABI "${ANDROID_ABI}" CACHE STRING "Android ARCH ABI" FORCE)
endif()
set(QT_ANDROID_ABIS "${ANDROID_ABI}" CACHE STRING "Android ABIs" FORCE)

# qt_add_android_permission and related helpers
set(_qt_android_macros "${Qt6Core_DIR}/Qt6AndroidMacros.cmake")
if(EXISTS "${_qt_android_macros}")
    include("${_qt_android_macros}")
else()
    message(WARNING "QGC: Qt6AndroidMacros.cmake not found (expected at ${_qt_android_macros}). "
        "Defining fallback qt_add_android_permission.")
endif()

# Qt 6.8.3 Android package may not provide qt_add_android_permission, so add a
# lightweight fallback that accumulates requested permissions on the target.
if(NOT COMMAND qt_add_android_permission)
    function(qt_add_android_permission target)
        cmake_parse_arguments(ARG "" "NAME" "ATTRIBUTES" ${ARGN})
        if(NOT ARG_NAME)
            message(FATAL_ERROR "qt_add_android_permission(NAME <permission>) is required")
        endif()
        get_target_property(_perms ${target} QT_ANDROID_PERMISSIONS)
        if(_perms STREQUAL "NOTFOUND")
            unset(_perms)
        endif()
        list(APPEND _perms ${ARG_NAME})
        set_target_properties(${target} PROPERTIES QT_ANDROID_PERMISSIONS "${_perms}")
    endfunction()
endif()

# ----------------------------------------------------------------------------
# Android NDK Version Validation
# ----------------------------------------------------------------------------
# Detect the NDK version even if CMAKE_ANDROID_NDK_VERSION was not populated
set(_qgc_android_ndk_version ${CMAKE_ANDROID_NDK_VERSION})
if(NOT _qgc_android_ndk_version)
    foreach(_qgc_ndk_root ${CMAKE_ANDROID_NDK} ${ANDROID_NDK_ROOT} ${ANDROID_NDK})
        if(_qgc_ndk_root AND EXISTS "${_qgc_ndk_root}/source.properties")
            file(STRINGS "${_qgc_ndk_root}/source.properties" _qgc_ndk_revision_line REGEX "^Pkg.Revision = [0-9.]+")
            if(_qgc_ndk_revision_line)
                string(REPLACE "Pkg.Revision = " "" _qgc_android_ndk_version "${_qgc_ndk_revision_line}")
                set(CMAKE_ANDROID_NDK_VERSION "${_qgc_android_ndk_version}" CACHE STRING "Android NDK version" FORCE)
                break()
            endif()
        endif()
    endforeach()
endif()

if(Qt6_VERSION VERSION_GREATER_EQUAL "6.8")
    set(_qgc_required_ndk "26.1.10909125")
    if(NOT _qgc_android_ndk_version)
        message(FATAL_ERROR "QGC: Unable to determine NDK version. Qt ${Qt6_VERSION} requires NDK ${_qgc_required_ndk} to ship libc++_shared with pmr symbols")
    elseif(NOT _qgc_android_ndk_version MATCHES "^26\\.1")
        message(FATAL_ERROR "QGC: Invalid NDK Version: ${_qgc_android_ndk_version}. Qt ${Qt6_VERSION} requires NDK ${_qgc_required_ndk} (older NDKs miss pmr symbols like _ZTVNSt6__ndk13pmr25monotonic_buffer_resourceE)")
    endif()
endif()

# ----------------------------------------------------------------------------
# Android Version Number Validation
# ----------------------------------------------------------------------------

# Generation of Android version numbers must be consistent release to release
# to ensure they are always increasing for Google Play Store
if(CMAKE_PROJECT_VERSION_MAJOR GREATER 9)
    message(FATAL_ERROR "QGC: Major version must be single digit (0-9), got: ${CMAKE_PROJECT_VERSION_MAJOR}")
endif()
if(CMAKE_PROJECT_VERSION_MINOR GREATER 9)
    message(FATAL_ERROR "QGC: Minor version must be single digit (0-9), got: ${CMAKE_PROJECT_VERSION_MINOR}")
endif()
if(CMAKE_PROJECT_VERSION_PATCH GREATER 99)
    message(FATAL_ERROR "QGC: Patch version must be two digits (0-99), got: ${CMAKE_PROJECT_VERSION_PATCH}")
endif()

# ----------------------------------------------------------------------------
# Android ABI to Bitness Code Mapping
# ----------------------------------------------------------------------------
# NOTE: Bitness codes are 66/34 instead of 64/32 due to a historical
# version number bump requirement from an earlier Android release
set(ANDROID_BITNESS_CODE)
if(CMAKE_ANDROID_ARCH_ABI STREQUAL "armeabi-v7a" OR CMAKE_ANDROID_ARCH_ABI STREQUAL "x86")
    set(ANDROID_BITNESS_CODE 34)
elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "arm64-v8a" OR CMAKE_ANDROID_ARCH_ABI STREQUAL "x86_64")
    set(ANDROID_BITNESS_CODE 66)
else()
    message(FATAL_ERROR "QGC: Unsupported Android ABI: ${CMAKE_ANDROID_ARCH_ABI}. Supported: armeabi-v7a, arm64-v8a, x86, x86_64")
endif()

# ----------------------------------------------------------------------------
# Android Version Code Generation
# ----------------------------------------------------------------------------
# Zero-pad patch version if less than 10
set(ANDROID_PATCH_VERSION ${CMAKE_PROJECT_VERSION_PATCH})
if(CMAKE_PROJECT_VERSION_PATCH LESS 10)
    set(ANDROID_PATCH_VERSION "0${CMAKE_PROJECT_VERSION_PATCH}")
endif()

# Version code format: BBMIPPDDD (B=Bitness, M=Major, I=Minor, P=Patch, D=Dev) - Dev not currently supported and always 000
set(ANDROID_VERSION_CODE "${ANDROID_BITNESS_CODE}${CMAKE_PROJECT_VERSION_MAJOR}${CMAKE_PROJECT_VERSION_MINOR}${ANDROID_PATCH_VERSION}000")
message(STATUS "QGC: Android version code: ${ANDROID_VERSION_CODE}")

set_property(TARGET ${CMAKE_PROJECT_NAME} PROPERTY QT_ANDROID_ABIS "${CMAKE_ANDROID_ARCH_ABI}")
# QT_ANDROID_SDK_BUILD_TOOLS_REVISION
set_property(TARGET ${CMAKE_PROJECT_NAME} PROPERTY QT_ANDROID_MIN_SDK_VERSION ${QGC_QT_ANDROID_MIN_SDK_VERSION})
set_property(TARGET ${CMAKE_PROJECT_NAME} PROPERTY QT_ANDROID_TARGET_SDK_VERSION ${QGC_QT_ANDROID_TARGET_SDK_VERSION})
set_property(TARGET ${CMAKE_PROJECT_NAME} PROPERTY QT_ANDROID_COMPILE_SDK_VERSION ${QGC_QT_ANDROID_COMPILE_SDK_VERSION})
set_property(TARGET ${CMAKE_PROJECT_NAME} PROPERTY QT_ANDROID_PACKAGE_NAME "${QGC_ANDROID_PACKAGE_NAME}")
set_property(TARGET ${CMAKE_PROJECT_NAME} PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR "${QGC_ANDROID_PACKAGE_SOURCE_DIR}")
set_property(TARGET ${CMAKE_PROJECT_NAME} PROPERTY QT_ANDROID_VERSION_NAME "${CMAKE_PROJECT_VERSION}")
set_property(TARGET ${CMAKE_PROJECT_NAME} PROPERTY QT_ANDROID_VERSION_CODE ${ANDROID_VERSION_CODE})
set_property(TARGET ${CMAKE_PROJECT_NAME} PROPERTY QT_ANDROID_APP_NAME "${CMAKE_PROJECT_NAME}")
set_property(TARGET ${CMAKE_PROJECT_NAME} PROPERTY QT_ANDROID_APP_ICON "@drawable/icon")
# QT_QML_IMPORT_PATH
set_property(TARGET ${CMAKE_PROJECT_NAME} PROPERTY QT_QML_ROOT_PATH "${CMAKE_SOURCE_DIR}")
# QT_ANDROID_SYSTEM_LIBS_PREFIX

# Link explicitly against libc++_shared and mark as extra lib for deployment to avoid
# pmr symbol resolution issues on vendor libc++ variants (seen on some Redmi devices)
find_library(_qgc_android_cxx_shared c++_shared)
if(_qgc_android_cxx_shared)
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE ${_qgc_android_cxx_shared})
    set_property(TARGET ${CMAKE_PROJECT_NAME}
        APPEND
        PROPERTY QT_ANDROID_EXTRA_LIBS "${_qgc_android_cxx_shared}"
    )
else()
    message(WARNING "QGC: c++_shared not found in NDK; pmr symbols may be missing on some devices")
endif()

# if(CMAKE_BUILD_TYPE STREQUAL "Debug")
#     set(QT_ANDROID_APPLICATION_ARGUMENTS)
# endif()

list(APPEND QT_ANDROID_MULTI_ABI_FORWARD_VARS QGC_STABLE_BUILD QT_HOST_PATH)

# ----------------------------------------------------------------------------
# Android OpenSSL Libraries
# ----------------------------------------------------------------------------
CPMAddPackage(
    NAME android_openssl
    URL https://github.com/KDAB/android_openssl/archive/refs/heads/master.zip
)

if(android_openssl_ADDED)
    include(${android_openssl_SOURCE_DIR}/android_openssl.cmake)
    add_android_openssl_libraries(${CMAKE_PROJECT_NAME})
    message(STATUS "QGC: Android OpenSSL libraries added")
else()
    message(WARNING "QGC: Failed to add Android OpenSSL libraries")
endif()

# ----------------------------------------------------------------------------
# Android Permissions
# ----------------------------------------------------------------------------

if(QGC_ENABLE_BLUETOOTH)
    qt_add_android_permission(${CMAKE_PROJECT_NAME}
        NAME android.permission.BLUETOOTH_SCAN
        ATTRIBUTES
            minSdkVersion 31
            usesPermissionFlags neverForLocation
    )
    qt_add_android_permission(${CMAKE_PROJECT_NAME}
        NAME android.permission.BLUETOOTH_CONNECT
        ATTRIBUTES
            minSdkVersion 31
            usesPermissionFlags neverForLocation
    )
endif()

if(NOT QGC_NO_SERIAL_LINK)
    qt_add_android_permission(${CMAKE_PROJECT_NAME}
        NAME android.permission.USB_PERMISSION
    )
endif()

# Need MulticastLock to receive broadcast UDP packets
qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.CHANGE_WIFI_MULTICAST_STATE
)

# Needed to keep working while 'asleep'
qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.WAKE_LOCK
)

# Needed for read/write to SD Card Path in AppSettings
qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.WRITE_EXTERNAL_STORAGE
)
qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.READ_EXTERNAL_STORAGE
    ATTRIBUTES
        maxSdkVersion 33
)
qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.MANAGE_EXTERNAL_STORAGE
)

message(STATUS "QGC: Android platform configuration applied")
