message(STATUS "Adding Custom Plugin")

# Enable custom build
set_property(DIRECTORY ${CMAKE_SOURCE_DIR}
    APPEND PROPERTY COMPILE_DEFINITIONS
    QGC_CUSTOM_BUILD
    CUSTOMHEADER="CustomPlugin.h"
    CUSTOMCLASS=CustomPlugin
)

find_package(Python3 REQUIRED)

# Base resources + custom overlays
list(APPEND CUSTOM_RESOURCES
    ${CMAKE_SOURCE_DIR}/qgcimages.qrc
    ${CMAKE_SOURCE_DIR}/qgcresources.qrc
    ${CMAKE_SOURCE_DIR}/qgroundcontrol.qrc
    ${CMAKE_SOURCE_DIR}/src/FirmwarePlugin/PX4/PX4Resources.qrc
    ${CMAKE_SOURCE_DIR}/src/FirmwarePlugin/APM/APMResources.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/custom.qrc
)
set(QGC_RESOURCES ${QGC_RESOURCES} ${CUSTOM_RESOURCES} CACHE STRING "Paths to .qrc Resources" FORCE)

# Extra import path for our QML module tree
set(QML_IMPORT_PATH ${QML_IMPORT_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/qml" CACHE STRING "Extra qml import paths" FORCE)

set(CUSTOM_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/CustomPlugin.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/src/CustomPlugin.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/CustomQGCApplication.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/src/CustomQGCApplication.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/QVIOHandler.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/src/QVIOHandler.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/ToFHandler.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/src/ToFHandler.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Video/VideoHandler.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Video/VideoHandler.h
    CACHE INTERNAL "" FORCE
)

set(CUSTOM_LIBRARIES
    Qt6::Core
    CACHE INTERNAL "" FORCE
)

set(CUSTOM_DIRECTORIES
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Video
    CACHE INTERNAL "" FORCE
)
