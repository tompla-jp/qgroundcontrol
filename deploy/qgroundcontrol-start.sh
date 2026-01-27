#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: qgroundcontrol-start.sh [--appdir DIR] [--help] [QGC_ARGS...]

Starts a locally built QGroundControl instance. When the script lives next to
the QGroundControl binary (for example after copying it into your build
directory) no extra arguments are required. Otherwise pass --appdir to point to
the directory that contains the QGroundControl executable.
EOF
}

APPDIR_OVERRIDE=""
QGC_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --appdir)
            shift
            [[ $# -gt 0 ]] || { echo "--appdir requires a directory" >&2; exit 2; }
            APPDIR_OVERRIDE="$1"
            shift
            ;;
        --appdir=*)
            APPDIR_OVERRIDE="${1#*=}"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            QGC_ARGS+=("$@")
            break
            ;;
        *)
            QGC_ARGS+=("$1")
            shift
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -n "$APPDIR_OVERRIDE" ]]; then
    APPDIR="$(cd "$APPDIR_OVERRIDE" && pwd)"
else
    APPDIR="$SCRIPT_DIR"
fi

prepend_path() {
    local var_name="$1"
    local dir_path="$2"
    [[ -d "$dir_path" ]] || return 0
    local current=""
    if [[ -n ${!var_name+x} ]]; then
        current="${!var_name}"
    fi
    if [[ -n "$current" ]]; then
        export "$var_name=$dir_path:$current"
    else
        export "$var_name=$dir_path"
    fi
}

# Look for common executable layouts relative to APPDIR
QGC_BINARY=""
for candidate in \
    "$APPDIR/QGroundControl" \
    "$APPDIR/QGroundControl.bin" \
    "$APPDIR/QGroundControl.app/Contents/MacOS/QGroundControl" \
    "$APPDIR/QGroundControl.exe" \
    ; do
    if [[ -x "$candidate" ]]; then
        QGC_BINARY="$candidate"
        break
    fi
done

if [[ -z "$QGC_BINARY" ]]; then
    echo "Could not find QGroundControl executable under $APPDIR" >&2
    exit 1
fi

# LD path tweaks for locally bundled libs (harmless when dirs do not exist)
prepend_path LD_LIBRARY_PATH "$APPDIR"
prepend_path LD_LIBRARY_PATH "$APPDIR/lib"
prepend_path LD_LIBRARY_PATH "$APPDIR/Qt/lib"

# Qt/QML plugin directories when running from an unpackaged build tree
prepend_path QT_PLUGIN_PATH "$APPDIR/plugins"
prepend_path QT_PLUGIN_PATH "$APPDIR/Qt/plugins"
prepend_path QML2_IMPORT_PATH "$APPDIR/qml"
prepend_path QML2_IMPORT_PATH "$APPDIR/Qt/qml"

# GStreamer helpers (primarily for unit tests / video playback)
for gst_dir in \
    "$APPDIR/gstplugins" \
    "$APPDIR/lib/gstreamer-1.0" \
    "$APPDIR/Qt/gstreamer-1.0" \
    ; do
    [[ -d "$gst_dir" ]] || continue
    prepend_path GST_PLUGIN_PATH "$gst_dir"
    prepend_path GST_PLUGIN_SYSTEM_PATH_1_0 "$gst_dir"
done

exec "$QGC_BINARY" "${QGC_ARGS[@]}"
