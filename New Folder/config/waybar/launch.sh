#!/bin/sh

# Start Waybar

# Quit running Waybar instances
killall waybar

# Load Waybar config
if [[ $USER = "lia" ]]
then
    waybar -c ~/.config/waybar/config & -s ~/.config/waybar/style.css
else
    waybar &
fi
