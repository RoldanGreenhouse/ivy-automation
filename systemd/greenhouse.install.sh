#!/bin/bash

# Install all services for the first time or after cleaning.

set -e

echo "Running greenhouse.install.sh..."

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"

echo "Installing Greenhouse Services in user mode."
echo "BASE_DIR=[$BASE_DIR]"
echo "USER_SYSTEMD_DIR=[$USER_SYSTEMD_DIR]"

echo "Checking if User Service folder exist and is empty..."
if [ -d "$USER_SYSTEMD_DIR" ] && [ -n "$(ls -A "$USER_SYSTEMD_DIR" 2>/dev/null)" ]; then
    echo "ERROR: The directory [$USER_SYSTEMD_DIR] is not empty."
    echo "Do please, run first greenhouse.update.sh to clean it or delete them manually."
    exit 1
fi

mkdir -p "$USER_SYSTEMD_DIR"

echo "Copy Service files [greenhouse.start.service|greenhouse.stop.service] and processing them..."
for service in greenhouse.start.service greenhouse.stop.service; do
    src="$BASE_DIR/service/$service"
    dst="$USER_SYSTEMD_DIR/$service"
    if [ ! -f "$src" ]; then
        echo "ERROR: No se encuentra $src"
        exit 1
    fi
    echo "Working on $service... Replacing [__IVY_REPOSITY_PATH__] for path [$src]"
    # Reemplazar __IVY_REPOSITY_PATH__ por la ruta proporcionada
    sed "s|__IVY_REPOSITY_PATH__|$IVY_PATH|g" "$src" > "$dst"
    chmod 644 "$dst"
done

echo "Reloading Systemd configuration from user [$USER]"
systemctl --user daemon-reload

echo "Enabling services..."
for service in greenhouse.start.service greenhouse.stop.service; do
    echo "Enabling $service ..."
    systemctl --user enable "$service"
done

echo "Installation completed. The services will be executed on the next session."
echo "To start them now without closing the session, run:"
echo "  systemctl --user start greenhouse.start.service"
echo "  systemctl --user start greenhouse.stop.service"