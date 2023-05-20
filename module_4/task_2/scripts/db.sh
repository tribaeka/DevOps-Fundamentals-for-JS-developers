#!/bin/bash

DATABASE="./users.db"
LATIN_LETTERS_REGEXP="^[a-zA-Z]+$"

function add() {
    read -p "Enter username: " username
    if ! [[ "$username" =~ $LATIN_LETTERS_REGEXP ]]; then
        echo "Error: username must contain only Latin letters"
        return 1
    fi
    read -p "Enter role: " role
    if ! [[ "$role" =~ $LATIN_LETTERS_REGEXP ]]; then
        echo "Error: role must contain only Latin letters"
        return 1
    fi
    echo "$username, $role" >> "$DATABASE"
}

function backup() {
    backup_file="$(date +%Y-%m-%d)-users.db.backup"
    cp "$DATABASE" "$backup_file"
    echo "Backup created: $backup_file"
}

function restore() {
    latest_backup="$(ls -t *-users.db.backup 2>/dev/null | head -n1)"
    if [ -z "$latest_backup" ]; then
        echo "No backup file found"
        return 1
    fi
    cp "$latest_backup" "$DATABASE"
    echo "Database restored from backup: $latest_backup"
}

function find() {
    read -p "Enter username: " username
    grep -i "^$username," "$DATABASE" || echo "User not found"
}

function list() {
    local option=$1
    local line_format="%d. %s\n"
    if [[ "$option" == "--inverse" ]]; then
      local line_number=$(wc -l < "$DATABASE")
      tac "$DATABASE" | awk -F ',' -v line_format="$line_format" -v line_number="$line_number" '{ printf line_format, line_number--, $1 ", " $2 }'
    else
      awk -F ',' -v line_format="$line_format" '{ printf line_format, NR, $1 ", " $2 }' "$DATABASE"
    fi
}

function help() {
    echo "Usage: db.sh [command] [option]"
    echo "Commands:"
    echo "  add     Add a new user to the database"
    echo "  backup  Create a backup of the database"
    echo "  restore Restore the database from the latest backup"
    echo "  find    Find a user in the database"
    echo "  list    List all users in the database"
    echo "  help    Display this help message"
    echo ""
    echo "Options:"
    echo "  --inverse  List results in reverse order (from bottom to top)"
    echo ""
    echo "Validation rules:"
    echo "  - Username must contain only Latin letters"
    echo "  - Role must contain only Latin letters"
    echo ""
    echo "Example usage:"
    echo "  db.sh add"
    echo "  db.sh backup"
    echo "  db.sh restore"
    echo "  db.sh find"
    echo "  db.sh list"
    echo "  db.sh list --inverse"
}

if [ ! -f "$DATABASE" ]; then
    read -p "The database does not exist. Create it now? (y/n) " confirm
    if [ "$confirm" == "y" ]; then
        touch "$DATABASE"
        echo "Database created: $DATABASE"
    else
        echo "Database not created. Exiting..."
        exit 1
    fi
fi

case "$1" in
    add) add;;
    backup) backup;;
    restore) restore;;
    find) find;;
    list) list "$2";;
    help) help;;
    *) echo "Invalid command. Use 'db.sh help' for instructions.";;
esac
