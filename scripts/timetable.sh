#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)/.."
EXPORT_DIR="${BASE_DIR}/exports"
mkdir -p "$EXPORT_DIR"

DB_USER="timetable_user"
DB_PASS="Timetable@123"
DB_NAME="timetable_db"

MYSQL_CMD="mysql -u${DB_USER} -p${DB_PASS} ${DB_NAME} -N -B"

ESC=$'\033['
RESET="${ESC}0m"
BOLD="${ESC}1m"
DIM="${ESC}2m"
UNDER="${ESC}4m"
FG_CYAN="${ESC}36m"
FG_GREEN="${ESC}32m"
FG_YELLOW="${ESC}33m"
FG_MAG="${ESC}35m"
FG_RED="${ESC}31m"
FG_BLUE="${ESC}34m"
FG_WHITE="${ESC}37m"
BG_BLUE="${ESC}44m"

UNAME="$(uname -s)"
case "$UNAME" in
  Darwin*) PLATFORM="mac" ;;
  Linux*) PLATFORM="linux" ;;
  *) PLATFORM="other" ;;
esac

run_sql_raw() {
  local sql="$1"
  printf '%s\n' "$sql" | ${MYSQL_CMD} 2>/dev/null || printf ''
}

notify_desktop() {
  local title="$1"
  local msg="$2"
  if [ "$PLATFORM" = "mac" ]; then
    if command -v terminal-notifier >/dev/null 2>&1; then
      terminal-notifier -title "${title}" -message "${msg}" >/dev/null 2>&1 || true
    else
      osascript -e "display notification \"${msg}\" with title \"${title}\"" >/dev/null 2>&1 || true
    fi
  else
    if command -v notify-send >/dev/null 2>&1; then
      notify-send "${title}" "${msg}" >/dev/null 2>&1 || true
    else
      echo "[NOTIFY] ${title} - ${msg}"
    fi
  fi
}

log_notification() {
  local batch="$1"
  local message="$2"
  local esc="${message//\'/''}"
  run_sql_raw "INSERT INTO NotificationLog(batch_id,message) VALUES ((SELECT batch_id FROM Batch WHERE batch_name='${batch}'), '${esc}');" >/dev/null || true
  echo "$(date '+%F %T') | ${batch} | ${message}" >> "${EXPORT_DIR}/log/reminder.log"
}

send_and_log() {
  local batch="$1"
  local message="$2"
  notify_desktop "Timetable — ${batch}" "${message}"
  log_notification "$batch" "$message"
}

list_batches() {
  run_sql_raw "SELECT batch_name FROM Batch ORDER BY batch_name;"
}

get_default_batch() {
  if [ -f "${BASE_DIR}/config/my_batch.conf" ]; then
    source "${BASE_DIR}/config/my_batch.conf"
    printf '%s' "${MY_BATCH:-}"
  else
    printf ''
  fi
}
set_default_batch() {
  mkdir -p "${BASE_DIR}/config"
  printf 'MY_BATCH=%s\n' "$1" > "${BASE_DIR}/config/my_batch.conf"
  echo -e "${FG_GREEN}${BOLD}Saved default batch:${RESET} ${BOLD}$1${RESET}"
}

date_add_days() {
  if [ "${PLATFORM}" = "mac" ]; then
    date -v+"${1}"d '+%Y-%m-%d'
  else
    date -d "+${1} day" '+%Y-%m-%d'
  fi
}

dayname_of_date() {
  local d="$1"
  if [ "${PLATFORM}" = "mac" ]; then
    date -j -f "%Y-%m-%d" "$d" '+%A'
  else
    date -d "$d" '+%A'
  fi
}

epoch_from_datetime() {
  local when_date="$1"  
  local when_time="$2"  
  if [ "${PLATFORM}" = "mac" ]; then
    date -j -f "%Y-%m-%d %T" "${when_date} ${when_time}" '+%s' 2>/dev/null || date -j -f "%Y-%m-%d %H:%M" "${when_date} ${when_time}" '+%s' 2>/dev/null || echo 0
  else
    date -d "${when_date} ${when_time}" '+%s' 2>/dev/null || echo 0
  fi
}

sql_today() {
  local batch="$1"
  printf "SELECT d.day_name,d.start_time,d.end_time,c.course_code,c.course_name,IFNULL(GROUP_CONCAT(tch.teacher_name SEPARATOR ', '),'') AS teachers,t.room
FROM Timetable t
JOIN Batch b ON t.batch_id=b.batch_id
JOIN Course c ON t.course_code=c.course_code
JOIN DaySlot d ON t.slot_id=d.slot_id
LEFT JOIN Timetable_Teachers tt ON t.tt_id=tt.tt_id
LEFT JOIN Teachers tch ON tt.teacher_code=tch.teacher_code
WHERE b.batch_name='%s' AND d.day_name = DAYNAME(CURDATE())
GROUP BY t.tt_id
ORDER BY d.start_time;" "$batch"
}

sql_tomorrow() {
  local batch="$1"
  local tdate; tdate="$(date_add_days 1)"
  local dayname; dayname="$(dayname_of_date "$tdate")"
  printf "SELECT d.day_name,d.start_time,d.end_time,c.course_code,c.course_name,IFNULL(GROUP_CONCAT(tch.teacher_name SEPARATOR ', '),'') AS teachers,t.room
FROM Timetable t
JOIN Batch b ON t.batch_id=b.batch_id
JOIN Course c ON t.course_code=c.course_code
JOIN DaySlot d ON t.slot_id=d.slot_id
LEFT JOIN Timetable_Teachers tt ON t.tt_id=tt.tt_id
LEFT JOIN Teachers tch ON tt.teacher_code=tch.teacher_code
WHERE b.batch_name='%s' AND d.day_name = '%s'
GROUP BY t.tt_id
ORDER BY d.start_time;" "$batch" "$dayname"
}

sql_week() {
  local batch="$1"
  printf "SELECT d.day_name,d.start_time,d.end_time,c.course_code,c.course_name,IFNULL(GROUP_CONCAT(tch.teacher_name SEPARATOR ', '),'') AS teachers,t.room
FROM Timetable t
JOIN Batch b ON t.batch_id=b.batch_id
JOIN Course c ON t.course_code=c.course_code
JOIN DaySlot d ON t.slot_id=d.slot_id
LEFT JOIN Timetable_Teachers tt ON t.tt_id=tt.tt_id
LEFT JOIN Teachers tch ON tt.teacher_code=tch.teacher_code
WHERE b.batch_name='%s'
GROUP BY t.tt_id
ORDER BY FIELD(d.day_name,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'), d.start_time;" "$batch"
}

sql_next() {
  local batch="$1"
  printf "SELECT b.batch_name, c.course_code, c.course_name, IFNULL(GROUP_CONCAT(tch.teacher_name SEPARATOR ', '),'') AS teachers, d.day_name, d.start_time, d.end_time, t.room
FROM Timetable t
JOIN Batch b ON t.batch_id=b.batch_id
JOIN Course c ON t.course_code=c.course_code
JOIN DaySlot d ON t.slot_id=d.slot_id
LEFT JOIN Timetable_Teachers tt ON t.tt_id=tt.tt_id
LEFT JOIN Teachers tch ON tt.teacher_code=tch.teacher_code
WHERE b.batch_name='%s' AND d.day_name = DAYNAME(CURDATE()) AND d.start_time > CURTIME()
GROUP BY t.tt_id
ORDER BY d.start_time
LIMIT 1;" "$batch"
}

sql_now() {
  local batch="$1"
  printf "SELECT d.day_name,d.start_time,d.end_time,c.course_code,c.course_name,IFNULL(GROUP_CONCAT(tch.teacher_name SEPARATOR ', '),'') AS teachers,t.room
FROM Timetable t
JOIN Batch b ON t.batch_id=b.batch_id
JOIN Course c ON t.course_code=c.course_code
JOIN DaySlot d ON t.slot_id=d.slot_id
LEFT JOIN Timetable_Teachers tt ON t.tt_id=tt.tt_id
LEFT JOIN Teachers tch ON tt.teacher_code=tch.teacher_code
WHERE b.batch_name='%s' AND d.day_name = DAYNAME(CURDATE()) AND d.start_time <= CURTIME() AND d.end_time > CURTIME()
GROUP BY t.tt_id
ORDER BY d.start_time;" "$batch"
}

print_table_auto() {
  local header_line="$1"
  local -a rows
  local ln
  while IFS= read -r ln; do rows+=("$ln"); done

  IFS='|' read -ra headers <<< "$header_line"
  local ncol=${#headers[@]}
  local -a widths
  for ((i=0;i<ncol;i++)); do widths[i]=${#headers[i]}; done

  # compute column widths
  for r in "${rows[@]}"; do
    IFS=$'\t' read -ra fields <<< "$r"
    for ((i=0;i<ncol;i++)); do
      local val="${fields[i]:-}"
      val="$(printf '%s' "$val" | tr -s '[:space:]' ' ')"
      local l=${#val}
      if (( l > widths[i] )); then widths[i]=$l; fi
    done
  done

  # Shrink if terminal is small
  local termw=9999
  if command -v tput >/dev/null 2>&1; then
    termw="$(tput cols 2>/dev/null || echo 9999)"
  fi

  local totalw=1
  for w in "${widths[@]}"; do totalw=$(( totalw + w + 3 )); done

  if (( totalw > termw )); then
    for key in "teachers" "course_name" "code" "room"; do
      for ((i=0;i<ncol;i++)); do
        if [[ "${headers[i],,}" == *"$key"* ]]; then
          widths[i]=$(( widths[i] - 10 ))
          (( widths[i] < 8 )) && widths[i]=8
          totalw=1
          for w in "${widths[@]}"; do totalw=$(( totalw + w + 3 )); done
          (( totalw <= termw )) && break 2
        fi
      done
    done
  fi

  local TL="╔" TR="╗" BL="╚" BR="╝" HOR="═" VER="║" TJ="╦" MJ="╬" BJ="╩"

  local top="$TL"
  for ((i=0;i<ncol;i++)); do
    top+=$(printf '%*s' $((widths[i]+2)) '' | tr ' ' "$HOR")
    if (( i < ncol-1 )); then top+="╦"; fi
  done
  top+="$TR"
  echo -e "${FG_BLUE}${BOLD}${top}${RESET}"

  printf "%b " "$VER"
  for ((i=0;i<ncol;i++)); do
    printf "%b%s%b" "${FG_CYAN}${BOLD}" "${headers[i]}" "${RESET}"
    printf '%*s' $((widths[i]-${#headers[i]}+1)) ''
    printf "%b " "$VER"
  done
  echo

  local mid="╠"
  for ((i=0;i<ncol;i++)); do
    mid+=$(printf '%*s' $((widths[i]+2)) '' | tr ' ' '─')
    if (( i < ncol-1 )); then mid+="╬"; fi
  done
  mid+="╣"
  echo -e "${FG_BLUE}${mid}${RESET}"

  for r in "${rows[@]}"; do
    IFS=$'\t' read -ra flds <<< "$r"
    printf "%b " "$VER"
    for ((i=0;i<ncol;i++)); do
      local val="${flds[i]:-}"
      val="$(printf '%s' "$val" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"
      if (( ${#val} > widths[i] )); then
        val="${val:0:$((widths[i]-1))}…"
      fi
      printf "%-*s " "${widths[i]}" "$val"
      printf "%b" "$VER"
    done
    echo
  done

  local bot="$BL"
  for ((i=0;i<ncol;i++)); do
    bot+=$(printf '%*s' $((widths[i]+2)) '' | tr ' ' "$HOR")
    if (( i < ncol-1 )); then bot+="╩"; fi
  done
  bot+="$BR"
  echo -e "${FG_BLUE}${BOLD}${bot}${RESET}"
}

query_and_print() {
  local sql="$1"
  local header="$2"
  local raw
  raw="$(run_sql_raw "$sql")"
  if [ -z "$raw" ]; then
    echo -e "${FG_YELLOW}No rows found.${RESET}"
    return
  fi
  printf '%s\n' "$raw" | print_table_auto "$header"
}

# ---------- Export CSV ----------
export_today_csv() {
  local batch="$1"
  if [ -z "$batch" ]; then batch="$(get_default_batch)"; fi
  if [ -z "$batch" ]; then echo -e "${FG_RED}No batch selected.${RESET}"; return; fi
  local file="${EXPORT_DIR}/today_${batch}_$(date '+%Y%m%d').csv"
  echo "day,start_time,end_time,course_code,course_name,teachers,room" > "$file"
  run_sql_raw "$(sql_today "$batch")" | awk -F'\t' '{gsub(/"/,"\"\""); printf "\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n",$1,$2,$3,$4,$5,$6,$7}' >> "$file"
  echo -e "${FG_GREEN}Exported → $file${RESET}"
}

# ---------- Add Extra Class ----------

add_extra_class_today_menu() {
  local batch="$1"
  if [ -z "$batch" ]; then batch="$(get_default_batch)"; fi
  if [ -z "$batch" ]; then 
    echo -e "${FG_RED}No batch selected. Use option 9.${RESET}"
    return
  fi

  echo -e "${BOLD}${FG_CYAN}Add Extra Class for Batch $batch (Today)${RESET}"

  # ASK FOR ALL REQUIRED DETAILS
  read -rp "Enter course code: " course
  read -rp "Enter teacher name: " teacher_name
  read -rp "Enter room name: " room

  # CALL SQL PROCEDURE
  local raw
  raw=$(run_sql_raw "CALL add_extra_class_today('$batch', '$course', '$teacher_name', '$room');")
  echo "RAW OUTPUT = '$raw'"

  # CLEAN SQL OUTPUT
  raw=$(echo "$raw" | tr -d '\r' | tr -d '\n' | xargs)
  
  # ERROR HANDLING
  if [[ "$raw" == "TEACHER_NOT_FOUND" ]]; then
      echo -e "${FG_RED}Teacher '$teacher_name' not found.${RESET}"
      return
  fi

  if [[ "$raw" == "NO_COMMON_FREE_SLOT" ]]; then
      echo -e "${FG_RED}No free slot available (batch + teacher + room busy).${RESET}"
      return
  fi

  # SUCCESS — EXTRACT SLOT NUMBER
  slot="${raw#EXTRA_CLASS_ADDED:}"
  slot="${slot:-0}"

  # FETCH SLOT TIMINGS SAFELY
  slot_start="$(run_sql_raw "SELECT start_time FROM DaySlot WHERE slot_id=$slot LIMIT 1;" || echo "")"
  slot_end="$(run_sql_raw "SELECT end_time FROM DaySlot WHERE slot_id=$slot LIMIT 1;" || echo "")"

  # FALLBACK IF EMPTY
  slot_start="${slot_start:-UNKNOWN}"
  slot_end="${slot_end:-UNKNOWN}"

  # DISPLAY SUCCESS MESSAGE
  echo -e "${FG_GREEN}Extra class added in Slot $slot ($slot_start-$slot_end).${RESET}"

  # LOG + NOTIFICATION
  send_and_log "$batch" \
"Extra class added: $course by $teacher_name | Slot $slot ($slot_start-$slot_end) | Room $room"
}



# ---------- Next class helpers ----------
get_next_class_row() {
  local batch="$1"
  run_sql_raw "$(sql_next "$batch")"
}

# live countdown: checks next class start and shows countdown; notifies at 10 minutes and at start.
live_countdown_for_next() {
  local batch="$1"
  if [ -z "$batch" ]; then batch="$(get_default_batch)"; fi
  if [ -z "$batch" ]; then echo -e "${FG_RED}No batch selected.${RESET}"; return; fi

  # fetch next class
  local row
  row="$(get_next_class_row "$batch")"
  if [ -z "$row" ]; then echo -e "${FG_YELLOW}No upcoming class today.${RESET}"; return; fi

  # row fields: batch, course_code, course_name, teachers, day_name, start_time, end_time, room
  IFS=$'\t' read -r nb code cname teachers day start end room <<< "$row"

  # compute epoch for today's date + start time
  local today_date
  today_date="$(date '+%Y-%m-%d')"
  local start_epoch
  start_epoch="$(epoch_from_datetime "$today_date" "$start")"
  if [ "$start_epoch" = "0" ]; then echo -e "${FG_RED}Could not parse class time.${RESET}"; return; fi

  # signal flags
  local ten_notified=0
  echo -e "${FG_GREEN}Countdown started for:${RESET} ${BOLD}${code} - ${cname}${RESET} at ${start} (${room})"
  # loop until start_epoch
  while true; do
    local now_epoch
    now_epoch="$(date +%s)"
    local diff=$(( start_epoch - now_epoch ))
    if (( diff <= 0 )); then
      send_and_log "$batch" "Class starting now: ${code} - ${cname} in ${room}"
      echo -e "${FG_GREEN}Class has started.${RESET}"
      break
    fi
    if (( diff <= 600 && ten_notified == 0 )); then
      send_and_log "$batch" "Upcoming class in 10 minutes: ${code} - ${cname} at ${start} in ${room}"
      ten_notified=1
    fi
    local hours=$(( diff / 3600 ))
    local mins=$(( (diff % 3600) / 60 ))
    local secs=$(( diff % 60 ))
    printf "\r%sCountdown: %02d:%02d:%02d until %s %s (%s)    " "${FG_CYAN}" "$hours" "$mins" "$secs" "${code}" "${cname}" "${RESET}"
    sleep 1
  done
  echo
}

manual_reminder_now() {
  local batch="$1"
  if [ -z "$batch" ]; then batch="$(get_default_batch)"; fi
  if [ -z "$batch" ]; then echo -e "${FG_RED}No batch selected.${RESET}"; return; fi
  local row
  row="$(get_next_class_row "$batch")"
  if [ -z "$row" ]; then echo -e "${FG_YELLOW}No upcoming class today.${RESET}"; return; fi
  IFS=$'\t' read -r nb code cname teachers day start end room <<< "$row"
  local msg="Manual reminder: ${code} - ${cname} at ${start} in ${room}"
  send_and_log "$batch" "$msg"
  echo -e "${FG_GREEN}Reminder sent.${RESET}"
}

choose_batch_menu() {
  local def; 
  def="$(get_default_batch)"
  echo -e "${BOLD}Available batches:${RESET}"
  local -a items; local idx=0
  while IFS= read -r b; do
    items+=("$b")
    idx=$((idx+1))
    if [ "$b" = "$def" ]; then
      echo -e " $idx) ${b} ${FG_YELLOW}(default)${RESET}"
    else
      echo -e " $idx) ${b}"
    fi
  done < <(list_batches)
  echo " 0) Cancel"
  read -rp "Choose number: " sel
  if [ -z "$sel" ] || [ "$sel" = "0" ]; then return 1; fi
  if ! [[ "$sel" =~ ^[0-9]+$ ]]; then echo "Invalid"; return 1; fi
  local choice="${items[$((sel-1))]:-}"
  if [ -z "$choice" ]; then echo "Invalid choice"; return 1; fi
  set_default_batch "$choice"
  return 0
}

while true; do
  clear
  current_batch="$(get_default_batch)"
  echo -e "${BOLD}${FG_MAG}                                    ${current_batch} Timetable${RESET}"
  echo -e "${FG_CYAN} Batch:${RESET} ${BOLD}${FG_GREEN}${current_batch:-<none>}${RESET}"
  echo
  echo -e "${FG_BLUE} 1)${RESET} ${FG_CYAN}Today${RESET}      ${FG_BLUE}2)${RESET} ${FG_CYAN}Tomorrow${RESET}   ${FG_BLUE}3)${RESET} ${FG_CYAN}Week${RESET}"
  echo -e "${FG_BLUE} 4)${RESET} ${FG_CYAN}Next class${RESET} ${FG_BLUE}5)${RESET} ${FG_CYAN}Now${RESET}       ${FG_BLUE}6)${RESET} ${FG_CYAN}Countdown (next)${RESET}"
  echo -e "${FG_BLUE} 7)${RESET} ${FG_CYAN}Manual reminder${RESET}  ${FG_BLUE}8)${RESET} ${FG_CYAN}Export Today (CSV)${RESET}"
  echo -e "${FG_BLUE} 9)${RESET} ${FG_CYAN}Change batch${RESET}  ${FG_BLUE}0)${RESET} ${FG_RED}Exit${RESET}     ${FG_BLUE}10)${RESET} ${FG_CYAN}Add Extra Class (Today)${RESET}"

  echo
  read -rp $'Choose option [0-9]: ' opt
  case "$opt" in
    1)
      if [ -z "$current_batch" ]; then echo -e "${FG_RED}No batch selected. Use option 9 to set.${RESET}"; read -rp "Press Enter..." _; continue; fi
      echo
      query_and_print "$(sql_today "$current_batch")" "day|start|end|code|course_name|teachers|room"
      ;;
    2)
      if [ -z "$current_batch" ]; then echo -e "${FG_RED}No batch selected. Use option 9 to set.${RESET}"; read -rp "Press Enter..." _; continue; fi
      echo
      query_and_print "$(sql_tomorrow "$current_batch")" "day|start|end|code|course_name|teachers|room"
      ;;
    3)
      if [ -z "$current_batch" ]; then echo -e "${FG_RED}No batch selected. Use option 9 to set.${RESET}"; read -rp "Press Enter..." _; continue; fi
      echo
      query_and_print "$(sql_week "$current_batch")" "day|start|end|code|course_name|teachers|room"
      ;;
    4)
      if [ -z "$current_batch" ]; then echo -e "${FG_RED}No batch selected. Use option 9 to set.${RESET}"; read -rp "Press Enter..." _; continue; fi
      echo
      query_and_print "$(sql_next "$current_batch")" "batch|code|course_name|teachers|day|start|end|room"
      ;;
    5)
      if [ -z "$current_batch" ]; then echo -e "${FG_RED}No batch selected. Use option 9 to set.${RESET}"; read -rp "Press Enter..." _; continue; fi
      echo
      query_and_print "$(sql_now "$current_batch")" "day|start|end|code|course_name|teachers|room"
      ;;
    6)
      live_countdown_for_next "$current_batch"
      ;;
    7)
      manual_reminder_now "$current_batch"
      ;;
    8)
      export_today_csv "$current_batch"
      ;;
    9)
      choose_batch_menu
      ;;
    10)
      add_extra_class_today_menu "$current_batch"
      ;;

    0)
      echo -e "${FG_GREEN}Bye!${RESET}"
      exit 0
      ;;
    *)
      echo -e "${FG_YELLOW}Invalid option${RESET}"
      ;;
  esac
  echo
  read -rp "Press Enter to continue..." _
done