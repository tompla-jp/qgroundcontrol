set(QGC_APP_NAME "QGroundControl" CACHE STRING "App Name" FORCE)
set(QGC_ORG_NAME "VOXL" CACHE STRING "Org Name" FORCE)
set(QGC_ORG_DOMAIN "voxl.local" CACHE STRING "Domain" FORCE)
set(QGC_PACKAGE_NAME "com.voxl.gcs" CACHE STRING "Package Name" FORCE)

# Force PX4-only stack for this derivative
set(QGC_DISABLE_APM_MAVLINK ON CACHE BOOL "Disable APM Dialect" FORCE)
set(QGC_DISABLE_APM_PLUGIN ON CACHE BOOL "Disable APM Plugin" FORCE)
set(QGC_DISABLE_APM_PLUGIN_FACTORY ON CACHE BOOL "Disable APM Plugin Factory" FORCE)
