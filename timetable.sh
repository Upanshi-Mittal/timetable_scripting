[200~#!/bin/bash

DB_USER="system"
DB_PASS="oracle"

ADMIN_FILE="admin.db"
LOG_FILE="/tmp/timetable.log"

trap "echo 'CTRL+C blocked! Please logout properly.'" INT

### Colors ###
G="\033[0;32m"
R="\033[0;31m"
Y="\033[1;33m"
NC="\033[0m"

log() { echo "$(date): $1" >> $LOG_FILE; }

check_db(){
    ps -ef | grep -q "sqlplus"
}

admin_login() {
    echo -n "Enter password: "
    read -s pass

    stored=$(cat $ADMIN_FILE)

    if [[ $(echo $pass | sha256sum) == $stored ]]; then
        echo -e "\n${G}Login success${NC}"
    else
        echo -e "\n${R}Invalid password${NC}"
        exit
    fi
}

add_class() {
    echo "Day: "; read day
    echo "Time: "; read time
    echo "Subject: "; read sub
    echo "Room: "; read room

sqlplus -s $DB_USER/$DB_PASS <<EOF
EXEC add_class('$day','$time','$sub','$room');
EXIT;
EOF

    log "Class added: $day $time"
}

show_menu() {
while true
do
echo -e "${Y}1) Add Class
2) View Timetable
3) Export
4) Search
5) Exit${NC}"
read -p "Choice: " ch

case $ch in
    1) add_class ;;
    2) sqlplus -s $DB_USER/$DB_PASS <<EOF
SET LINES 200;
SELECT * FROM classes ORDER BY day,time;
EOF
       ;;
    3) sqlplus -s $DB_USER/$DB_PASS <<EOF > timetable.txt
SELECT * FROM classes;
EOF
       echo "Exported!"
       ;;
    4) read -p "Search subject: " key
       grep -i "$key" timetable.txt
       ;;
    5) exit ;;
esac
done
}

admin_login
show_menu

