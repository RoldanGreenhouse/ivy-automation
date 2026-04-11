#!/bin/bash

# backup-greenhouse.sh - Backup triggered through CRON using Borg from external config file.
# Execute next to ensure the scrupts is executable
# sudo chmod +x /workspace/greenhouse/ivy-automation/cron/scripts/backup.sh

# -e : exit immediately if any command fails (returns a non‑zero exit status).
# -u : treat unset variables as an error and exit.
# -o pipefail : a pipeline (e.g., cmd1 | cmd2) fails if any command in it fails, not just the last one.
set -euo pipefail

DATE_FORMAT_LOG="+%Y/%m/%d|%H:%M:%S"
DATE_FORMAT_BORG="+%Y%m%d_%H%M%S"
DATE_FORMAT_DEFAULT_FILENAME="+%Y%m%d"

# Capture full command line for debugging
COMMAND_LINE="$0 $*"

help() {
    cat <<EOF
Usage: $0 -c|--config <config_file> -p|--passphrase <passphrase_file> [--log-path <dir>] [--log-filename <name>]

Required:
  -c, --config       Configuration file (REPO, KEEP_DAILY, KEEP_WEEKLY, KEEP_MONTHLY, SOURCE_DIRS)
  -p, --passphrase   File containing the encryption passphrase (plain text, no extra newlines)

Optional:
  --log-path         Directory where log file will be written (if omitted, no log file is created)
  --log-filename     Log filename (default: greenhouse_backup_<timestamp>.log, only used with --log-path)

Example:
  $0 --config /etc/borg/greenhouse.conf --passphrase /etc/borg/passphrase --log-path /var/log/borg --log-filename mybackup.log
  $0 -c /etc/borg/greenhouse.conf -p /etc/borg/passphrase --log-path /var/log/borg
EOF
    exit 1
}

echo "[$(date "$DATE_FORMAT_LOG")] Starting Greenhouse backup..." >&2

if [ "$EUID" -ne 0 ]; then
    echo "[$(date "$DATE_FORMAT_LOG")] Error: This script must be run with sudo or as root to avoid permission issues with Borg." >&2
    exit 1
fi

# Default values
CONFIG_FILE=""
PASSPHRASE_FILE=""
LOG_PATH=""
LOG_NAME=""

# Use getopt: short options c and p only; long options config, passphrase, log-path, log-filename, help
OPTS=$(getopt -o "c:p:" --long config:,passphrase:,log-path:,log-filename:,help -n "$0" -- "$@")
if [ $? -ne 0 ]; then
    help
fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -p|--passphrase)
            PASSPHRASE_FILE="$2"
            shift 2
            ;;
        --log-path)
            LOG_PATH="$2"
            shift 2
            ;;
        --log-filename)
            LOG_NAME="$2"
            shift 2
            ;;
        --help)
            help
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error"
            exit 1
            ;;
    esac
done

# Helper to print command line to stderr (for early errors)
print_command_line() {
    echo "[$(date "$DATE_FORMAT_LOG")] Command line: $COMMAND_LINE" >&2
}

# Required arguments check
if [ -z "$CONFIG_FILE" ] || [ -z "$PASSPHRASE_FILE" ]; then
    print_command_line
    help
fi

echo "[$(date "$DATE_FORMAT_LOG")] Flags -cp detected..." >&2

# Validate files exist
if [ ! -f "$CONFIG_FILE" ]; then
    print_command_line
    echo "[$(date "$DATE_FORMAT_LOG")] Error: Configuration file '$CONFIG_FILE' not found" >&2
    exit 1
fi

if [ ! -f "$PASSPHRASE_FILE" ]; then
    print_command_line
    echo "[$(date "$DATE_FORMAT_LOG")] Error: Passphrase file '$PASSPHRASE_FILE' not found" >&2
    exit 1
fi

echo "[$(date "$DATE_FORMAT_LOG")] Flags -cp validated." >&2

# Load configuration
source "$CONFIG_FILE"

# Validate required config variables
: "${REPO:?Variable REPO not defined in config}"
: "${KEEP_DAILY:?Variable KEEP_DAILY not defined}"
: "${KEEP_WEEKLY:?Variable KEEP_WEEKLY not defined}"
: "${KEEP_MONTHLY:?Variable KEEP_MONTHLY not defined}"
: "${SOURCE_DIRS:?Variable SOURCE_DIRS not defined (must be an array)}"

# Check SOURCE_DIRS is an array
if ! declare -p SOURCE_DIRS 2>/dev/null | grep -q 'declare -a'; then
    print_command_line
    echo "[$(date "$DATE_FORMAT_LOG")] Error: SOURCE_DIRS must be a bash array. Example: SOURCE_DIRS=( \"/path1\" \"/path2\" )" >&2
    exit 1
fi

# Setup logging if log path is provided
if [ -n "$LOG_PATH" ]; then
    if [ -z "$LOG_NAME" ]; then
        TIMESTAMP_FOR_LOG=$(date "$DATE_FORMAT_DEFAULT_FILENAME")
        LOG_NAME="greenhouse_backup_${TIMESTAMP_FOR_LOG}.log"
    fi
    FULL_LOG_FILE="${LOG_PATH}/${LOG_NAME}"

    if [ ! -d "$LOG_PATH" ]; then
        mkdir -p "$LOG_PATH" || {
            print_command_line
            echo "[$(date "$DATE_FORMAT_LOG")] Error: Cannot create log directory '$LOG_PATH'" >&2
            exit 1
        }
    fi

    # Dual output: console + file
    exec > >(tee -a "$FULL_LOG_FILE") 2>&1
    echo "[$(date "$DATE_FORMAT_LOG")] Logging to $FULL_LOG_FILE (console + file)"
    echo "[$(date "$DATE_FORMAT_LOG")] Command line: $COMMAND_LINE"
fi

# Export passphrase
export BORG_PASSPHRASE="$(cat "$PASSPHRASE_FILE" | tr -d '\n\r')"

# Check Borg
if ! command -v borg &>/dev/null; then
    echo "[$(date "$DATE_FORMAT_LOG")] Error: borg is not installed. Install with: sudo apt install borgbackup"
    exit 1
fi

# Init repo if needed
if ! borg info "$REPO" &>/dev/null; then
    echo "[$(date "$DATE_FORMAT_LOG")] Error: Repository not found. Initialization required."
    exit 1
fi

# Perform backup
TIMESTAMP=$(date "$DATE_FORMAT_BORG")
BACKUP_NAME="greenhouse-backup-${TIMESTAMP}"

echo "[$(date "$DATE_FORMAT_LOG")] Starting backup: $BACKUP_NAME"
borg create --stats --progress --compression lz4 \
    "$REPO::$BACKUP_NAME" \
    "${SOURCE_DIRS[@]}"

# Prune old backups
echo "[$(date "$DATE_FORMAT_LOG")] Applying retention: daily=$KEEP_DAILY, weekly=$KEEP_WEEKLY, monthly=$KEEP_MONTHLY"
borg prune --keep-daily "$KEEP_DAILY" \
           --keep-weekly "$KEEP_WEEKLY" \
           --keep-monthly "$KEEP_MONTHLY" \
           "$REPO"

echo "[$(date "$DATE_FORMAT_LOG")] Borg last 5 backups in repository:"
borg list "$REPO" --last 5 | sed 's/^/  /'

echo "[$(date "$DATE_FORMAT_LOG")] Backup completed successfully"