#!/bin/bash
# ---------------------------------------------------------
# Smart Timetable – FULL AUTO INSTALLER (macOS Version)
# User clones repo → runs install.sh → everything ready
# ---------------------------------------------------------

echo "🔧 Starting Smart Timetable Installer..."

# 1. Detect project path
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "📁 Project directory: $PROJECT_DIR"

# 2. Ensure scripts are executable
chmod +x "$PROJECT_DIR/scripts/"*.sh
chmod +x "$PROJECT_DIR/scripts/helpers/"*.sh

# 3. Install required packages (macOS)
echo "📦 Installing required packages..."
if ! command -v brew >/dev/null 2>&1; then
    echo "❌ Error: Homebrew not installed."
    echo "➡ Install from https://brew.sh/"
    exit 1
fi

brew install mysql
brew install terminal-notifier

# 4. Start MySQL service
echo "▶ Starting MySQL service..."
brew services start mysql

# 5. Ask user to enter MySQL root password
echo "🔐 Please enter your MySQL root password to continue setup:"
read -s ROOTPASS

# 6. Create DB user for timetable system
echo "👤 Creating MySQL user 'timetable_user'..."

mysql -u root -p"$ROOTPASS" <<EOF
DROP USER IF EXISTS 'timetable_user'@'localhost';
CREATE USER 'timetable_user'@'localhost' IDENTIFIED BY 'Timetable@123';
GRANT ALL PRIVILEGES ON *.* TO 'timetable_user'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

echo "✅ MySQL user created successfully!"

# 7. Import all SQL files using new user
echo "🗄 Importing database schema & data..."

mysql -u timetable_user -p"Timetable@123" <<EOF
SOURCE $PROJECT_DIR/sql/schema.sql;
SOURCE $PROJECT_DIR/sql/sample_data.sql;
SOURCE $PROJECT_DIR/sql/procedures.sql;
SOURCE $PROJECT_DIR/sql/triggers.sql;
SOURCE $PROJECT_DIR/sql/views.sql;
EOF

echo "✅ Database imported successfully!"

# 8. Ask user for batch name
echo -n "📌 Enter your batch name (example: CS_1): "
read BATCH

CONFIG_FILE="$PROJECT_DIR/config/my_batch.conf"
echo "MY_BATCH=$BATCH" > "$CONFIG_FILE"
echo "📌 Saved your batch preference."

# 9. Install cron job
echo "⏰ Installing cron job..."
chmod +x "$PROJECT_DIR/scripts/install_cron.sh"
"$PROJECT_DIR/scripts/install_cron.sh"

# 10. Final macOS notification
echo "🔔 Sending test notification..."
osascript -e 'display notification "Smart Timetable is now running." with title "Setup Complete"'

# 11. Mark installation complete
touch "$PROJECT_DIR/config/installed.flag"

echo "🎉 Smart Timetable installed successfully!"
echo "➡ Run: ./scripts/timetable.sh today $BATCH"
