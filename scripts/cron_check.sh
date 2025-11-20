#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")" && pwd)"
CONF="$(cd "$DIR/.." && pwd)/config/my_batch.conf"
if [[ -f "$CONF" ]]; then
  source "$CONF"
  "$DIR/timetable.sh" cron_check "$MY_BATCH"
else
  echo "[WARN] my_batch.conf not found"
  exit 1
fi
