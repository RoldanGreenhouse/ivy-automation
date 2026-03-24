#!/bin/bash
# Orchestrator for installation/update of user services suggested by Greenhouse team.

set -e

# User service directory
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"

# Check if the user service directory exists and is not empty
if [ -d "$USER_SYSTEMD_DIR" ] && [ -n "$(ls -A "$USER_SYSTEMD_DIR" 2>/dev/null)" ]; then
    echo "The directory $USER_SYSTEMD_DIR exists and is not empty. Updating..."
    "$(dirname "$0")/greenhouse.update.sh"
else
    echo "The directory $USER_SYSTEMD_DIR do not exist. Installing..."
    "$(dirname "$0")/greenhouse.install.sh"
fi