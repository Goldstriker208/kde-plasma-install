#!/bin/bash

CONFIG_FILE="$HOME/.config/waypaper/config.ini"
SCRIPT_PATH="$HOME/.config/waybar/scripts/wallpaper.sh"

# Ensure inotify-tools is installed
if ! command -v inotifywait &> /dev/null; then
    echo "Installing inotify-tools..."
    sudo pacman -S inotify-tools --noconfirm
fi

echo "Watching for wallpaper changes..."

# Watch for changes in Waypaper's config and trigger the script
while inotifywait -e close_write "$CONFIG_FILE"; do
    # Extract wallpaper path from the INI file
    WALLPAPER=$(awk -F ' = ' '/^wallpaper/ {print $2}' "$CONFIG_FILE" | tr -d '"')

    # Expand tilde (~) if present
    WALLPAPER=${WALLPAPER/#\~/$HOME}

    if [[ -f "$WALLPAPER" ]]; then
        echo "New wallpaper detected: $WALLPAPER"
        bash "$SCRIPT_PATH" "$WALLPAPER"
    fi
done
