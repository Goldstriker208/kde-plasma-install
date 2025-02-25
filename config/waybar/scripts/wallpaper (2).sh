#!/bin/bash

# Ensure swww-daemon is running
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1  # Give it time to start
fi

# Set wallpaper using waypaper
waypaper --wallpaper "$1"

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

# Overwrite style.css dynamically
cat <<EOF > ~/.config/waybar/style.css
* {
    border: none;
    font-size: 14px;
    font-family: "JetBrainsMono Nerd Font,JetBrainsMono NF";
    min-height: 25px;
}

window#waybar {
    background: transparent;
    margin: 5px;
}

#custom-logo {
padding: 0 10px;
}

.modules-left {
    background: #8A90D2;
    border-radius: 15px 15px 15px 15px;
}

.modules-center {
    background: #D89FBA;
    border-radius: 15px 15px 15px 15px;
}

.modules-right {
    background: #90CDFF;
    border-radius: 15px 15px 15px 15px;
}

#custom-clipboard,
#custom-colorpicker,
#custom-powerDraw,
#bluetooth,
#pulseaudio,
#network,
#disk,
#memory,
#backlight,
#cpu,
#temperature,
#custom-weather,
#idle_inhibitor,
#jack,
#tray,
#window,
#workspaces {
padding: 0 5px;
}
#pulseaudio {
padding-top: 0px;
}

#temperature.critical,
#pulseaudio.muted {
color: #FF0000;
padding-top: 0;
}

#battery {
padding: 0 0px;
}

#battery.charging {
    color: #ffffff;
    background-color: #26A65B;
    border-radius: 15px 15px 15px 15px;
}

#battery.warning:not(.charging) {
    background-color: #ffbe61;
    color: black;
    border-radius: 15px 15px 15px 15px;
}

#battery.critical:not(.charging) {
    background-color: #f53c3c;
    color: #ffffff;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
    border-radius: 15px 15px 15px 15px;
}

#clock {
padding: 0 10px;
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: #000000;
    }
}
EOF

# Reload Waybar
pkill waybar && waybar &
pkill hyprpaper
