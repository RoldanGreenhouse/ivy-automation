#!/bin/bash

# Delete all existent services from Greenhouse and later will call the clean install.

set -e

echo "Running greenhouse.update.sh..."

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"

echo "Updating Greenhouse Services in user mode."
echo "BASE_DIR=[$BASE_DIR]"
echo "USER_SYSTEMD_DIR=[$USER_SYSTEMD_DIR]"

echo "Checking the content of the directory..."
if [ ! -d "$USER_SYSTEMD_DIR" ] || [ -z "$(ls -A "$USER_SYSTEMD_DIR" 2>/dev/null)" ]; then
    echo "ERROR: The directory $USER_SYSTEMD_DIR do not exist or is empty."
    echo "Nothing to update. Use greenhouse.install.sh instead for a clean installation."
    exit 1
fi

echo "Upgrading the Greenhouse Services..."

# 1. Detener y deshabilitar los servicios que gestionamos
echo "Stopping and disabling services [greenhouse.start.service greenhouse.stop.service]"
for service in greenhouse.start.service greenhouse.stop.service; do
    if systemctl --user is-enabled "$service" &>/dev/null; then
        echo "Disabling [$service] ..."
        systemctl --user disable "$service"
    fi
    if systemctl --user is-active "$service" &>/dev/null; then
        echo "Stopping [$service] ..."
        systemctl --user stop "$service"
    fi
done

echo "Cleaning folder [$USER_SYSTEMD_DIR/greenhouse.*.service] "
rm -f "$USER_SYSTEMD_DIR"/greenhouse.*.service

echo "Reloading Systemd configuration from user [$USER]"
systemctl --user daemon-reload

echo "Clean. Forwarding to $BASE_DIR/greenhouse.install.sh ..."
"$BASE_DIR/greenhouse.install.sh"