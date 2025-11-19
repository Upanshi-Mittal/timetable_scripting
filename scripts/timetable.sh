#!/usr/bin/env bash
# scripts/timetable.sh
# Main Timetable CLI
# No TTS, only notify-send / email (if available). Works with config/my_batch.conf.

set -u
BASE_DIR="$(cd "$(dirname "$0")" && pwd)/.."
HELPERS_DIR="$(cd "$(dirname "$0")" && pwd)/helpers"

# load helpers
source "${HELPERS_DIR}/color.sh" 2>/dev/null || true
source "${HELPERS_DIR}/logger.sh" 2>/dev/null || true

# DB config (defaults)
DB_USER="timetable_user"
DB_PASS="timetable_pass"
DB_NAME="timetable_db"
MYSQL_CMD="mysql -u${DB_USER} -p${DB_PASS} ${DB_NAME} -N -B -e"

NOTIFY_CMD="notify-send"
MAIL_CMD="mail"      # optional

# run SQL query and print results
run_sql() {
  local sql="$1"
  echo "$sql" | ${MYSQL_CMD}
  return $?
}

# view full timetable (from view)
view_timetable() {
  local batch="$1"
  echo -e "${BLUE}Full timetable for ${batch}:${RESET}"
  run_sql "SELECT * FROM final_timetable_view WHERE batch_name='${batch}';"
}

# today's schedule
today_schedule() {
  local batch="$1"
  echo -e "${GREEN}Today's schedule for ${batch}:${RESET}"
  run_sql "CALL get_today_schedule('${batch}');"
}

# next class
next_class() {
  local batch="$1"
  run_sql "CALL get_next_class('${batch}');"
}

# export today's schedule to CSV
export_today_csv() {
  local batch="$1"
  local out="$2"
  if [[ -z "${out}" ]]; then
    echo -e "${RED}Please provide output path.${RESET}"
    return 1
  fi
  echo "day,start_time,end_time,course_code,course_name,teacher,room" > "${out}"
  ${MYSQL_CMD} "CALL get_today_schedule('${batch}');" | \
    awk -F'\t' '{printf "%s,%s,%s,%s,%s,%s,%s\n",$1,$2,$3,$4,$5,$6,$7}' >> "${out}"
  log_success "Exported today's timetable to ${out}"
}

# internal notification + DB log
send_notification() {
  local batch="$1"; shift
  local message="$*"

  # desktop
  if command -v "${NOTIFY_CMD}" >/dev/null 2>&1; then
    "${NOTIFY_CMD}" "Timetable Reminder — ${batch}" "${message}"
  fi

  # email (optional)
  if command -v "${MAIL_CMD}" >/dev/null 2>&1; then
    echo "${message}" | ${MAIL_CMD} -s "Class Reminder - ${batch}" "${USER}@localhost" 2>/dev/null || true
  fi

  # log into NotificationLog (safe-escape single quotes)
  local esc=$(echo "${message}" | sed "s/'/''/g")
  run_sql "INSERT INTO NotificationLog(batch_id, message) VALUES ((SELECT batch_id FROM Batch WHERE batch_name='${batch}'), '${esc}');" >/dev/null 2>&1 || true
}

# cron_check: checks next class and sends reminder if <= 10 min
cron_check() {
  local batch="$1"
  local row
  row="$(next_class "${batch}")" || row=""

  if [[ -z "${row}" ]]; then
    # no upcoming class
    exit 0
  fi

  # Expecting tab-separated: batch, course_code, course_name, teacher, day_name, start_time, end_time, room
  IFS=$'\t' read -r b course_code course_name teacher day start_time end_time room <<< "${row}"

  # compute time difference
  now_epoch=$(date +%s)
  # class datetime today
  class_epoch=$(date -d "$(date +%F) ${start_time}" +%s 2>/dev/null || echo 0)
  if [[ "${class_epoch}" -eq 0 ]]; then
    exit 0
  fi
  diff_seconds=$(( class_epoch - now_epoch ))
  diff_minutes=$(( diff_seconds / 60 ))

  if (( diff_minutes <= 10 && diff_minutes >= 0 )); then
    send_notification "${batch}" "Next class ${course_code} - ${course_name} at ${start_time} in ${room} (${diff_minutes} minutes left)"
  fi
}

# cron_me: read my_batch.conf and run cron_check for that batch (used by cron wrapper)
cron_me() {
  local conf="${BASE_DIR}/config/my_batch.conf"
  if [[ ! -f "${conf}" ]]; then
    log_error "Batch config not found (${conf})."
    exit 1
  fi
  # shellcheck source=/dev/null
  source "${conf}"
  if [[ -z "${MY_BATCH:-}" ]]; then
    log_error "MY_BATCH not set in ${conf}."
    exit 1
  fi
  cron_check "${MY_BATCH}"
}

manual_reminder() {
  local batch="$1"
  local row
  row="$(next_class "${batch}")" || row=""
  if [[ -z "${row}" ]]; then
    echo "No upcoming class found for ${batch} today."
    exit 0
  fi
  IFS=$'\t' read -r b course_code course_name teacher day start_time end_time room <<< "${row}"
  send_notification "${batch}" "Manual reminder: ${course_code} - ${course_name} at ${start_time} in ${room}"
  echo "Reminder sent."
}

help_menu() {
  cat <<EOF
Smart Timetable - Usage:
  ./timetable.sh view <BATCH>             - show full timetable
  ./timetable.sh today <BATCH>            - show today's schedule
  ./timetable.sh next <BATCH>             - show next class (DB)
  ./timetable.sh export <BATCH> <file.csv> - export today's schedule
  ./timetable.sh cron_check <BATCH>       - (internal) run cron check for BATCH
  ./timetable.sh cron_me                  - (internal) read config/my_batch.conf and check
  ./timetable.sh manual_reminder <BATCH>  - force reminder
EOF
}

# Router
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
