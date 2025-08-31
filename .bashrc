#
# ~/.bashrc
#

# ✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨ Welcome Prompt ✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨ #



displaydate=$(date +"%I:%M:%S %p")

# Get the list of cow files, excluding the first line
list=($(cowsay -l | tail -n +2))

# Retrieve the cow file name based on the index argument
#setanimal="${list[0]}"

# Get a random index
random_index=$((RANDOM % ${#list[@]}))

# Retrieve the cow file name at the random index
setanimal="${list[$random_index]}"

#echo "$setanimal"


cowsay -f $setanimal "Welcome $USER!"


hour=$(date +"%H")

if (( hour < 12 )); then
    greeting="Good Morning! ☀"
elif (( hour >= 12 && hour < 18 )); then
    greeting="Good Afternoon! 🌤"
else
    greeting="Good Evening! 🌙"
fi

echo -e "$greeting\nThe current time is $displaydate" | boxes -d parchment

if [[ $(date +%m) == "06" ]]; then
    echo -e "\nHappy Pride Month! 🏳️‍🌈🏳️‍⚧️"
fi


# ✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨ #

# Check if kernel modules are in sync
check-kernel() {
  running=$(uname -r)
  installed=$(pacman -Q linux | awk '{print $2}')
  # Normalize installed version: replace .arch with -arch
  installed_norm=$(echo "$installed" | sed 's/\.arch/-arch/')

  echo "Running kernel:   $running"
  echo "Installed kernel: $installed_norm"

  if [[ "$running" != "$installed_norm" ]]; then
    echo "⚠️ Kernel modules are not up to date."
    echo "This is usually because you upgraded without rebooting."
    read -p "Reboot now? [Y/n] " ans
    ans=${ans:-Y}  # default = Y
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      sudo reboot
    else
      echo "Okay, remember to reboot later! ⚡"
    fi
  else
    echo "✅ Kernel and modules are in sync. No reboot needed."
  fi
}


# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#################### Prompt String 1: ####################

# Default Arch-KDE-Plasma Prompt
#PS1='[\u@\h \W]\$ '

# Default Ubuntu/Debian Prompt
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Default Debian Prompt (no color)
#PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

# Default Ubuntu/Debian Prompt (purple color)
#PS1='${debian_chroot:+($debian_chroot)}\[\033[0;35m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '


# Starship Prompt
# Edit Prompt 1 in ~/.config/starship.toml or type my alias cmd 'starship-config'
eval "$(starship init bash)"


#########################################################





# Aliases are in ~/.bash_aliases
if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi




# Shows the IOMMU Groups
# iommu-list() {
# 	for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
#     	echo "IOMMU Group ${g##*/}:"
#     	for d in $g/devices/*; do
#         	echo -e "\t$(lspci -nns ${d##*/})"
#     	done;
# 	done;
# }

iommu-list() {
    local vendor="${1,,}"  # Convert argument to lowercase for case insensitivity

    for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
        echo "IOMMU Group ${g##*/}:"
        for d in $g/devices/*; do
            [[ -e "$d" ]] || continue  # Skip if device path doesn't exist

            # Get PCI device info
            device_info=$(lspci -nns ${d##*/})

            # Filter based on vendor argument
            case "$vendor" in
                intel)
                    echo "$device_info" | grep -Ei "intel" && echo -e "\t$device_info"
                    ;;
                amd)
                    echo "$device_info" | grep -Ei "amd|advanced micro devices" && echo -e "\t$device_info"
                    ;;
                nvidia)
                    echo "$device_info" | grep -Ei "nvidia" && echo -e "\t$device_info"
                    ;;
                *)
                    echo -e "\t$device_info"  # Default: Show all devices
                    ;;
            esac
        done
    done
}

# with grep output
get-vfio-id-full() {
    local vendor="${1,,}"  # Convert to lowercase
    local ids=()

    for d in /sys/bus/pci/devices/*; do
        [[ -e "$d" ]] || continue  # Skip if device path doesn't exist

        # Read Vendor & Device ID
        vendor_id=$(cat "$d/vendor" 2>/dev/null | sed 's/^0x//')
        device_id=$(cat "$d/device" 2>/dev/null | sed 's/^0x//')
        vfio_id="${vendor_id}:${device_id}"

        # Get full PCI device info
        device_info=$(lspci -nns "$(basename "$d")")

        case "$vendor" in
            intel)
                echo "$device_info" | grep -Ei "intel" && ids+=("$vfio_id")
                ;;
            amd)
                echo "$device_info" | grep -Ei "amd|advanced micro devices" && ids+=("$vfio_id")
                ;;
            nvidia)
                echo "$device_info" | grep -Ei "nvidia" && ids+=("$vfio_id")
                ;;
            *)
                echo "Usage: get-vfio-id <intel|amd|nvidia>"
                return 1
                ;;
        esac
    done

    # Properly format the output with commas only for IDs
    if [[ ${#ids[@]} -gt 0 ]]; then
        echo "options vfio-pci ids=$(IFS=,; echo "${ids[*]}")"
    else
        echo "No matching PCI devices found for $vendor."
    fi
}

# get-vfio-id() {
#     local vendor="${1,,}"  # Convert to lowercase
#     local ids=()
#
#     for d in /sys/bus/pci/devices/*; do
#         [[ -e "$d" ]] || continue  # Skip if device path doesn't exist
#
#         # Read Vendor & Device ID
#         vendor_id=$(cat "$d/vendor" 2>/dev/null | sed 's/^0x//')
#         device_id=$(cat "$d/device" 2>/dev/null | sed 's/^0x//')
#         vfio_id="${vendor_id}:${device_id}"
#
#         # Get PCI device info without printing
#         device_info=$(lspci -nns "$(basename "$d")")
#
#         case "$vendor" in
#             intel)
#                 echo "$device_info" | grep -Eiq "intel" && ids+=("$vfio_id")
#                 ;;
#             amd)
#                 echo "$device_info" | grep -Eiq "amd|advanced micro devices" && ids+=("$vfio_id")
#                 ;;
#             nvidia)
#                 echo "$device_info" | grep -Eiq "nvidia" && ids+=("$vfio_id")
#                 ;;
#             *)
#                 echo "Usage: get-vfio-id <intel|amd|nvidia>"
#                 return 1
#                 ;;
#         esac
#     done
#
#     # Only output the required line
#     if [[ ${#ids[@]} -gt 0 ]]; then
#         echo "options vfio-pci ids=$(IFS=,; echo "${ids[*]}")"
#     else
#         echo "No matching PCI devices found for $vendor."
#     fi
# }
#
#
# pci-switch() {
#     local vendor="$1"
#
#     if [[ "$vendor" == "amd" ]]; then
#         # Check if already in AMD passthrough
#         if grep -q "options vfio-pci ids=.*1002" /etc/modprobe.d/vfio.conf; then
#             echo "You already have AMD passthrough."
#         else
#             # Switch to AMD passthrough
#             get-vfio-id amd > /etc/modprobe.d/vfio.conf
#             echo "Switched passthrough to AMD graphics card."
#         fi
#
#     elif [[ "$vendor" == "nvidia" ]]; then
#         # Check if already in NVIDIA passthrough
#         if grep -q "options vfio-pci ids=.*10de" /etc/modprobe.d/vfio.conf; then
#             echo "You already have NVIDIA passthrough."
#         else
#             # Switch to NVIDIA passthrough
#             get-vfio-id nvidia > /etc/modprobe.d/vfio.conf
#             echo "Switched passthrough to NVIDIA graphics card."
#         fi
#     else
#         echo "Usage: pci-switch <amd|nvidia>"
#         return 1
#     fi
#
#     # Ask about rebuilding initramfs
#     read -p "Rebuild initramfs? [Y/n] " choice_initramfs
#     case "$choice_initramfs" in
#         [Yy]*)
#             echo "Rebuilding initramfs..."
#             sudo mkinitcpio -P
#             ;;
#         [Nn]*)
#             echo "You can rebuild initramfs later."
#             ;;
#         *)
#             echo "Invalid input. No changes to initramfs."
#             ;;
#     esac
#
#     # Ask if user wants to reboot
#     read -p "Would you like to reboot? [Y/n] " choice_reboot
#     case "$choice_reboot" in
#         [Yy]*)
#             echo "Rebooting now..."
#             sudo reboot
#             ;;
#         [Nn]*)
#             echo "You can reboot later."
#             ;;
#         *)
#             echo "Invalid input. No reboot will occur."
#             ;;
#     esac
# }





source /usr/local/bin/vfio-functions.sh



# Zoxide
[[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh

# Chatgpt CLI Shell

