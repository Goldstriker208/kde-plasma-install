#!/bin/bash

# Ensure swww-daemon is running
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1  # Give it time to start
fi
#
# # Set wallpaper using waypaper
# waypaper --wallpaper "$1"

# Generate colors with pywal
wal -i "$1" -q

# Function to brighten a color
lighten_color() {
    HEX="$1"
    R=$((0x${HEX:1:2} + 50))
    G=$((0x${HEX:3:2} + 50))
    B=$((0x${HEX:5:2} + 50))

    R=$(($R > 255 ? 255 : $R))
    G=$(($G > 255 ? 255 : $G))
    B=$(($B > 255 ? 255 : $B))

    printf "#%02X%02X%02X\n" "$R" "$G" "$B"
}

# Get three different brightened colors from pywal

# Background Color off
#BG_COLOR=$(lighten_color "$(jq -r '.colors.color0' ~/.cache/wal/colors.json)")

LEFT_COLOR=$(lighten_color "$(jq -r '.colors.color2' ~/.cache/wal/colors.json)")
CENTER_COLOR=$(lighten_color "$(jq -r '.colors.color4' ~/.cache/wal/colors.json)")
RIGHT_COLOR=$(lighten_color "$(jq -r '.colors.color6' ~/.cache/wal/colors.json)")

# Debugging: Print extracted colors
echo "Background Color: $BG_COLOR"
echo "Left Modules Color: $LEFT_COLOR"
echo "Center Modules Color: $CENTER_COLOR"
echo "Right Modules Color: $RIGHT_COLOR"

# Save dynamic colors separately in wal-style.css
cat <<EOF > ~/.config/waybar/wal-style.css
.modules-left {
    background: $LEFT_COLOR;
    border-radius: 15px;
}

.modules-center {
    background: $CENTER_COLOR;
    border-radius: 15px;
}

.modules-right {
    background: $RIGHT_COLOR;
    border-radius: 15px;
}
EOF

# Reload Waybar
pkill waybar && waybar &
#pkill hyprpaper
