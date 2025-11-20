#!/usr/bin/env bash
PLATFORM="$(uname -s)"
case "$PLATFORM" in
  Darwin)
    if command -v terminal-notifier >/dev/null 2>&1; then
      terminal-notifier -title "SmartTimetable Test" -message "Notifications are working."
      echo "terminal-notifier executed"
    else
      osascript -e 'display notification "Notifications are working." with title "SmartTimetable Test"'
      echo "osascript executed"
    fi
    ;;
  Linux)
    if command -v notify-send >/dev/null 2>&1; then
      notify-send "SmartTimetable Test" "Notifications are working."
      echo "notify-send executed"
    else
      echo "notify-send not found"
    fi
    ;;
  *)
    echo "Unsupported platform for notifications."
    ;;
esac
