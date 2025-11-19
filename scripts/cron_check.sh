#!/usr/bin/env bash
# scripts/cron_check.sh - wrapper used in crontab/install
DIR="$(cd "$(dirname "$0")" && pwd)"
# source config if present
CONF="$(cd "${DIR}/.." && pwd)/config/my_batch.conf"
if [[ -f "${CONF}" ]]; then
  # shellcheck source=/dev/null
  source "${CONF}"
  if [[ -z "${MY_BATCH:-}" ]]; then
    echo "[WARN] MY_BATCH not set in ${CONF}"
    exit 1
  fi
  "${DIR}/timetable.sh" cron_check "${MY_BATCH}"
else
  echo "[WARN] ${CONF} not found"
  exit 1
fi
