#!/bin/bash

# Set wallpaper
swww img "$1"

# Generate colors with pywal
wal -i "$1" -q

# Extract primary color
COLOR=$(jq -r '.colors.color4' ~/.cache/wal/colors.json)
echo "Extracted Color: $COLOR"

# Ensure COLOR is a valid hex
if [[ ! $COLOR =~ ^#[0-9A-Fa-f]{6}$ ]]; then
    echo "Error: Invalid color extracted!"
    exit 1
fi

# Replace the placeholder in Waybar CSS
sed -i "s/__WAL_COLOR__/$COLOR/g" ~/.config/waybar/style.css

# Reload Waybar
pkill waybar && waybar &
