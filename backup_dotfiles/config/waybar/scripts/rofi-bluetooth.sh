#!/bin/bash

# Function to get available Bluetooth devices
get_devices() {
    bluetoothctl devices | awk '{print $2 " " substr($0, index($0,$3))}'
}

# Show menu with available devices
device=$(get_devices | rofi -dmenu -p "Select device to pair" | awk '{print $1}')

# If a device was selected
if [[ -n "$device" ]]; then
    # Pair and connect the selected device
    bluetoothctl pair "$device"
    bluetoothctl connect "$device"
    rofi -e "Pairing attempt for $device initiated."
fi
