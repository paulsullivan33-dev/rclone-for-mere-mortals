#!/bin/sh
# sync-logs.sh -- upload new log files to storage, keeping a run log.
#
# Usage: sh sync-logs.sh [source-dir] [remote-path] [log-file]
#
# It uses COPY, never SYNC, on purpose: the device rotates its old
# logs away, and a sync would faithfully delete the archived copies
# to match. An archive wants "send what's new, delete nothing".
set -eu

SRC_DIR="${1:-device-logs}"
REMOTE="${2:-local1:store/device-logs}"
LOG_FILE="${3:-sync-logs.log}"

rclone copy "$SRC_DIR" "$REMOTE" \
    --log-file "$LOG_FILE" \
    --log-level INFO
