#!/usr/bin/env bash
# scripts/install_cron.sh - installs cron entry if not present
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CRON_TARGET="${SCRIPT_DIR}/cron_check.sh"
CRON_CMD="*/5 * * * * ${CRON_TARGET}"

# create user's crontab entry if absent
(crontab -l 2>/dev/null | grep -F "${CRON_TARGET}") >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
  echo "[INFO] Cron job already installed."
else
  (crontab -l 2>/dev/null; echo "${CRON_CMD}") | crontab -
  echo "[INFO] Cron job installed: ${CRON_CMD}"
fi
# show crontab
echo "---- current crontab ----"
crontab -l
