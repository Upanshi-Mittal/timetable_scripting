#!/usr/bin/env bash
# install.sh - Universal installer (macOS + Linux)
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$PROJECT_DIR/exports/log"
mkdir -p "$LOG_DIR"

echo "🔧 Starting Smart Timetable Universal Installer..."
echo "📁 Project directory: $PROJECT_DIR"

# defaults
DB_USER="timetable_user"
DB_PASS="Timetable@123"
DB_NAME="timetable_db"

# detect OS
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="mac" ;;
  Linux) PLATFORM="linux" ;;
  *) PLATFORM="other" ;;
esac

echo "[INFO] Detected platform: $PLATFORM"

# helper to run apt/brew installs
install_packages() {
  if [[ "$PLATFORM" == "mac" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
      echo "❌ Homebrew not installed. Install it from https://brew.sh/ and re-run installer."
      exit 1
    fi
    echo "[INFO] Installing mysql + terminal-notifier via brew..."
    brew install mysql || true
    brew install terminal-notifier || true
  elif [[ "$PLATFORM" == "linux" ]]; then
    echo "[INFO] Installing mysql-server, mysql-client, libnotify-bin via apt..."
    sudo apt update -y
    sudo apt install -y mysql-server mysql-client libnotify-bin mailutils || true
  else
    echo "Unsupported platform: $OS"
    exit 1
  fi
}

# start mysql service
start_mysql() {
  if [[ "$PLATFORM" == "mac" ]]; then
    echo "[INFO] Starting MySQL service (brew)..."
    brew services start mysql || true
  else
    echo "[INFO] Starting MySQL service (systemctl)..."
    sudo systemctl start mysql || sudo service mysql start || true
  fi
}

# create DB user (attempt multiple auth modes)
create_db_user() {
  echo "[INFO] Creating DB user '${DB_USER}' with provided password."
  # Try to create using root password prompt
  echo "If MySQL root user requires a password, enter it now. If not, press Enter."
  read -s -p "MySQL root password (leave blank if none): " ROOTPASS
  echo
  # Try root with password first
  if [[ -n "$ROOTPASS" ]]; then
    mysql -u root -p"$ROOTPASS" -e "DROP USER IF EXISTS '${DB_USER}'@'localhost'; CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}'; GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" >/dev/null 2>>"$LOG_DIR/mysql_queries.log" && return 0 || echo "[WARN] root+password attempt failed"
  fi
  # Try socket/no-password root login (common on some installs)
  if mysql -u root -e "SELECT 1" >/dev/null 2>>"$LOG_DIR/mysql_queries.log"; then
    mysql -u root -e "DROP USER IF EXISTS '${DB_USER}'@'localhost'; CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}'; GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" >/dev/null 2>>"$LOG_DIR/mysql_queries.log" && return 0
  fi
  # If we get here, ask user to create manually
  echo "❌ Could not create DB user automatically. Please create user manually with root privileges:"
  echo "    CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
  echo "    GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;"
  exit 1
}

# import SQL files using mysql client and DB user
import_sql_files() {
  echo "[INFO] Importing SQL (this may take a few seconds)..."
  # create database and import using root or the new user
  # First try using the timetable_user directly (if created)
  if mysql -u "${DB_USER}" -p"${DB_PASS}" -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" >/dev/null 2>>"$LOG_DIR/mysql_queries.log"; then
    for f in "$PROJECT_DIR"/sql/*.sql; do
      echo "[INFO] Importing $f"
      mysql -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" < "$f" 2>>"$LOG_DIR/mysql_queries.log" || {
        echo "[ERROR] Import failed for $f — check $LOG_DIR/mysql_queries.log"
        exit 1
      }
    done
  else
    # fallback: try root
    echo "[INFO] Fallback: attempting import with root (you may be prompted)"
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" 2>>"$LOG_DIR/mysql_queries.log" || true
    for f in "$PROJECT_DIR"/sql/*.sql; do
      echo "[INFO] Importing $f as root"
      mysql "${DB_NAME}" < "$f" 2>>"$LOG_DIR/mysql_queries.log" || {
        echo "[ERROR] Import failed for $f — check $LOG_DIR/mysql_queries.log"
        exit 1
      }
    done
  fi
}

# install cron job (absolute path)
install_cron() {
  SCRIPT="$PROJECT_DIR/scripts/cron_check.sh"
  CRON_CMD="*/5 * * * * $SCRIPT"
  (crontab -l 2>/dev/null | grep -F "$SCRIPT") >/dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    echo "[INFO] Cron job already exists."
  else
    (crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -
    echo "[INFO] Cron job installed: $CRON_CMD"
  fi
  echo "---- current crontab ----"
  crontab -l
}

# set user batch config
set_batch_config() {
  read -p "📌 Enter your batch name (example: CS_1): " BATCH
  echo "MY_BATCH=$BATCH" > "$PROJECT_DIR/config/my_batch.conf"
  echo "[INFO] Saved your batch preference."
}

# notification test (platform-specific)
send_setup_notification() {
  local msg="Smart Timetable is now running."
  if [[ "$PLATFORM" == "mac" ]]; then
    if command -v terminal-notifier >/dev/null 2>&1; then
      terminal-notifier -title "Setup Complete" -message "$msg" >/dev/null 2>&1 || true
    else
      osascript -e "display notification \"$msg\" with title \"Setup Complete\""
    fi
  else
    if command -v notify-send >/dev/null 2>&1; then
      notify-send "Setup Complete" "$msg"
    else
      echo "[WARN] notify-send not found; skipping desktop notification."
    fi
  fi
}

# main flow
install_packages
start_mysql
create_db_user
import_sql_files
set_batch_config
install_cron
send_setup_notification

touch "$PROJECT_DIR/config/installed.flag"
echo "🎉 Smart Timetable installed successfully!"
echo "➡ Run: ./scripts/timetable.sh today \$MY_BATCH"
