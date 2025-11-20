#!/usr/bin/env bash
# scripts/timetable.sh - universal notifications (macOS + Linux)
set -u
BASE_DIR="$(cd "$(dirname "$0")" && pwd)/.."
HELPERS_DIR="$(cd "$(dirname "$0")" && pwd)/helpers"

# load helpers (optional)
[ -f "${HELPERS_DIR}/color.sh" ] && source "${HELPERS_DIR}/color.sh"
[ -f "${HELPERS_DIR}/logger.sh" ] && source "${HELPERS_DIR}/logger.sh"

DB_USER="timetable_user"
DB_PASS="Timetable@123"
DB_NAME="timetable_db"
MYSQL_CMD="mysql -u${DB_USER} -p${DB_PASS} ${DB_NAME} -N -B -e"

# detect platform for notifications
PLATFORM="$(uname -s)"
case "$PLATFORM" in
  Darwin) PLATFORM="mac" ;;
  Linux) PLATFORM="linux" ;;
esac

run_sql() {
  local q="$1"
  echo "$q" | ${MYSQL_CMD}
}

# notification helper
notify_user() {
  local title="$1"
  local message="$2"
  if [[ "$PLATFORM" == "mac" ]]; then
    if command -v terminal-notifier >/dev/null 2>&1; then
      terminal-notifier -title "$title" -message "$message" || true
    else
      osascript -e "display notification \"${message}\" with title \"${title}\""
    fi
  else
    if command -v notify-send >/dev/null 2>&1; then
      notify-send "$title" "$message" || true
    else
      echo "[WARN] notify-send not found. Message: $title - $message"
    fi
  fi
}

send_notification() {
  local batch="$1"
  local message="$2"
  notify_user "Timetable Reminder — ${batch}" "${message}"
  # log into DB (escape single quotes)
  local esc=$(echo "$message" | sed "s/'/''/g")
  run_sql "INSERT INTO NotificationLog(batch_id, message) VALUES ((SELECT batch_id FROM Batch WHERE batch_name='${batch}'), '${esc}');" >/dev/null 2>&1 || true
  # also append to file log
  echo "$(date '+%F %T') | ${batch} | ${message}" >> "${BASE_DIR}/exports/log/reminder.log"
}

view_timetable() {
  local batch="$1"
  run_sql "SELECT * FROM final_timetable_view WHERE batch_name='${batch}';"
}

today_schedule() {
  local batch="$1"
  run_sql "CALL get_today_schedule('${batch}');"
}

next_class() {
  local batch="$1"
  run_sql "CALL get_next_class('${batch}');"
}

export_today_csv() {
  local batch="$1"; local out="$2"
  mkdir -p "${BASE_DIR}/exports"
  echo "day,start_time,end_time,course_code,course_name,teacher,room" > "$out"
  ${MYSQL_CMD} "CALL get_today_schedule('${batch}');" | awk -F'\t' '{printf "%s,%s,%s,%s,%s,%s,%s\n",$1,$2,$3,$4,$5,$6,$7}' >> "$out"
  echo "[INFO] Exported to $out"
}

cron_check() {
  local batch="$1"
  local row
  row="$(next_class "$batch")" || row=""
  if [[ -z "$row" ]]; then exit 0; fi
  IFS=$'\t' read -r b code cname teacher day start end room <<< "$row"
  now=$(date +%s)
  class_time=$(date -j -f "%Y-%m-%d %T" "$(date +%F) ${start}" +%s 2>/dev/null || date -d "$(date +%F) ${start}" +%s 2>/dev/null || echo 0)
  if [[ "$class_time" == "0" ]]; then exit 0; fi
  diff=$(( (class_time - now) / 60 ))
  if (( diff <= 10 && diff >= 0 )); then
    send_notification "$batch" "Next class ${code} - ${cname} at ${start} in ${room} (${diff} minutes left)"
  fi
}

cron_me() {
  if [[ -f "${BASE_DIR}/config/my_batch.conf" ]]; then
    # shellcheck source=/dev/null
    source "${BASE_DIR}/config/my_batch.conf"
    cron_check "${MY_BATCH}"
  else
    echo "[WARN] my_batch.conf not found"
  fi
}

manual_reminder() {
  local batch="$1"
  local row
  row="$(next_class "$batch")" || row=""
  if [[ -z "$row" ]]; then echo "No upcoming class"; exit 0; fi
  IFS=$'\t' read -r b code cname teacher day start end room <<< "$row"
  send_notification "$batch" "Manual reminder: ${code} - ${cname} at ${start} in ${room}"
}

help_menu() {
  cat <<EOF
Smart Timetable - Usage:
  ./timetable.sh view <BATCH>
  ./timetable.sh today <BATCH>
  ./timetable.sh next <BATCH>
  ./timetable.sh export <BATCH> <file.csv>
  ./timetable.sh cron_check <BATCH>
  ./timetable.sh cron_me
  ./timetable.sh manual_reminder <BATCH>
EOF
}

case "${1:-}" in
  view) view_timetable "${2:-}" ;;
  today) today_schedule "${2:-}" ;;
  next) next_class "${2:-}" ;;
  export) export_today_csv "${2:-}" "${3:-}" ;;
  cron_check) cron_check "${2:-}" ;;
  cron_me) cron_me ;;
  manual_reminder) manual_reminder "${2:-}" ;;
  *) help_menu ;;
esac
