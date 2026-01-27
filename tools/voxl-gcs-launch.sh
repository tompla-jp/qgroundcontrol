#!/usr/bin/env bash
set -euo pipefail
BIN="/home/parallels/dev/qgroundcontrol/build/Release/Release/VOXL-GCS"
# Kill existing instances before launch
if pgrep -f "$BIN" >/dev/null 2>&1; then
  pkill -f "$BIN" || true
  sleep 0.5
fi
exec "$BIN" "$@"
