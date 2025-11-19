#!/usr/bin/env bash
# macOS notification test

if command -v osascript >/dev/null 2>&1; then
  osascript -e 'display notification "Notifications are working!" with title "SmartTimetable Test"'
  echo "macOS notification executed"
else
  echo "osascript not found - cannot send macOS notification"
fi
