#!/bin/bash

# Default Arch install script
# konsole --hold -e "/usr/bin/archinstall"

# TUI Arch Linux Installer using dialog
# Requires: dialog, iwctl, NetworkManager, pacstrap, grub, etc.


# HOSTNAME="arch"
# TIMEZONE="US/Pacific"



# Step 0: Setup Wifi/Network

check_internet() {
    ping -c 1 -W 2 google.com > /dev/null 2>&1
}

#!/bin/bash

# Check if internet is already connected
if check_internet; then
    echo "Internet is connected"

    # Update keys and package lists
    pacman -Sy

    # Install NetworkManager and dialog
    pacman -S networkmanager dialog --noconfirm

else
    echo "No internet connection"
    sleep 2

    # Ask user to connect to Wifi
    echo "No internet connection. Connect to Wifi? (y/n)"
    read USER_CHOICE

    clear

    if [[ "$USER_CHOICE" == "y" || "$USER_CHOICE" == "Y" ]]; then
        if command -v nmtui >/dev/null 2>&1; then
            echo "Launching nmtui (NetworkManager)..."
            nmtui
        elif command -v iwctl >/dev/null 2>&1; then
            echo "Using iwctl (iwd) for Wi-Fi setup..."

            # Get the name of the wireless interface
            WIFI_DEV=$(iwctl device list | awk '/station/ {print $1}' | head -n 1)

            if [[ -z "$WIFI_DEV" ]]; then
                echo "No wireless device found."
                exit 1
            fi

            # Scan for networks
            iwctl station "$WIFI_DEV" scan
            sleep 2  # Give it a moment to scan

            # Get list of SSIDs
            NETWORK_LIST=$(iwctl station "$WIFI_DEV" get-networks | awk 'NR>4 {print $1}' | sort | uniq)

            if [[ -z "$NETWORK_LIST" ]]; then
                echo "No networks found."
                exit 1
            fi

            # List available networks
            echo "Available networks:"
            echo "$NETWORK_LIST" | nl

            # Get user input for the network to connect to
            echo "Enter the number corresponding to the Wi-Fi network you want to connect to:"
            read SSID_INDEX

            SSID_NAME=$(echo "$NETWORK_LIST" | sed -n "${SSID_INDEX}p")

            if [[ -z "$SSID_NAME" ]]; then
                echo "Invalid selection."
                exit 1
            fi

            # Ask for Wi-Fi password
            echo "Enter Wi-Fi password for '$SSID_NAME':"
            read -s WIFI_PASS

            clear
            echo "Connecting to $SSID_NAME..."

            # Attempt connection
            iwctl --passphrase "$WIFI_PASS" station "$WIFI_DEV" connect "$SSID_NAME"

            echo "Returned from iwctl network setup."
            sleep 2
        else
            echo "No recognized network tool (nmtui or iwctl) found."
            echo "Please connect manually or install a network manager."
        fi
    else
        echo "Skipped wifi setup."
        sleep 2
    fi
fi


# Ask for root password
ROOT_PASS=$(dialog --insecure --passwordbox "Enter root password:" 10 50 3>&1 1>&2 2>&3)
clear

# Confirm root password
ROOT_PASS2=$(dialog --insecure --passwordbox "Confirm root password:" 10 50 3>&1 1>&2 2>&3)
clear

if [[ "$ROOT_PASS" != "$ROOT_PASS2" ]]; then
    echo "Root password mismatch. Exiting."
    exit 1
fi

# Ask for username
USERNAME=$(dialog --inputbox "Enter new username:" 10 50 3>&1 1>&2 2>&3)
clear

# Ask for user password
USER_PASS=$(dialog --insecure --passwordbox "Enter password for $USERNAME:" 10 50 3>&1 1>&2 2>&3)
clear

# Confirm user password
USER_PASS2=$(dialog --insecure --passwordbox "Confirm password for $USERNAME:" 10 50 3>&1 1>&2 2>&3)
clear

if [[ "$USER_PASS" != "$USER_PASS2" ]]; then
    echo "User password mismatch. Exiting."
    exit 1
fi

set -e






#
# if check_internet; then
#     echo "Internet is connected"
#     sleep 2
# else
#     echo "No internet connection"
#     sleep 2
#
#     # set +e  # Temporarily disable exit-on-error
#     dialog --yesno "No internet connection. Connect to Wifi?" 7 50
#     USER_CHOICE=$?
#     # set -e  # Enable
#
#     clear
#
#     if [[ "$USER_CHOICE" -eq 0 ]]; then
#         nmtui
#         echo "Returned from nmtui"
#     else
#         echo "Skipped wifi setup."
#         sleep 2
#     fi
# fi




#
# # Update keys and package lists
# pacman -Sy
#
# # Install NetworkManager and dialog
# pacman -S networkmanager dialog --noconfirm

# Enable and start NetworkManager
systemctl enable NetworkManager
systemctl start NetworkManager

disk_options=()

# Grab all devices and partitions (skip loop, zram, etc.)
while read -r name size fstype; do
    [[ "$name" == *"loop"* || "$name" == *"zram"* ]] && continue
    desc="$size $fstype"
    disk_options+=("$name" "$desc")
done < <(lsblk -dpno NAME,SIZE,FSTYPE)

# Dialog to choose a device or partition
DISK=$(dialog --backtitle "Arch Installer" \
  --title "Choose Disk" \
  --menu "Select the disk to install Arch Linux:" 20 70 15 \
  "${disk_options[@]}" \
  3>&1 1>&2 2>&3 3>&-)

DISK=$(echo $DISK | grep -o '/dev/[^[:space:]]\+')
echo $DISK
sleep 2
echo "DEBUG: Selected disk is '$DISK'"

if [ -n "$DISK" ]; then
  echo "Opening cfdisk on $DISK"
  sudo cfdisk "$DISK"
else
  echo "No disk selected or dialog cancelled."
fi

#
# DISK=$(echo $DISK | grep -o '/dev/[^[:space:]]\+')
# echo $DISK
# exit 0

lsblk -pno NAME,FSTYPE

# Step 2: Select Partitions

disk_options=()

# Grab all devices and partitions (skip loop, zram, etc.)
while read -r name size fstype; do
    [[ "$name" == *"loop"* || "$name" == *"zram"* ]] && continue
    desc="$size $fstype"
    disk_options+=("$name" "$desc")
done < <(lsblk -pno NAME,SIZE,FSTYPE)

# Dialog to choose a device or partition
ROOT=$(dialog --backtitle "Arch Installer" \
  --title "Choose Root Partition" \
  --menu "Select the root partition to install Arch Linux:" 20 70 15 \
  "${disk_options[@]}" \
  3>&1 1>&2 2>&3 3>&-)

ROOT=$(echo $ROOT | grep -o '/dev/[^[:space:]]\+')
echo $ROOT
sleep 2



disk_options=()

# Grab all devices and partitions (skip loop, zram, etc.)
while read -r name size fstype; do
    [[ "$name" == *"loop"* || "$name" == *"zram"* ]] && continue
    desc="$size $fstype"
    disk_options+=("$name" "$desc")
done < <(lsblk -pno NAME,SIZE,FSTYPE)

# Dialog to choose a device or partition
EFI=$(dialog --backtitle "Arch Installer" \
  --title "Choose EFI Partition" \
  --menu "Select the efi partition to install Arch Linux:" 20 70 15 \
  "${disk_options[@]}" \
  3>&1 1>&2 2>&3 3>&-)

EFI=$(echo $EFI | grep -o '/dev/[^[:space:]]\+')
echo $EFI
sleep 2

# Step 3: Format Partitions
dialog --menu "Choose root filesystem:" 10 40 2 1 "BTRFS" 2 "EXT4" 2>fs_choice.txt
FS=$(<fs_choice.txt)
rm fs_choice.txt


echo "Formatting $ROOT and $EFI"
sleep 2

echo "3"
sleep 1
echo "2"
sleep 1
echo "1"
sleep 1


if [[ "$FS" == "1" ]]; then
    mkfs.btrfs -f -L arch "$ROOT"
else
    mkfs.ext4 -L arch "$ROOT"
fi
mkfs.fat -F32 "$EFI"

# Step 4: Mount Partitions
mount "$ROOT" /mnt

if [[ "$FS" == "1" ]]; then
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    umount /mnt
    mount -o defaults,compress=zstd,subvol=@ "$ROOT" /mnt
    mkdir /mnt/home
    mount -o defaults,compress=zstd,subvol=@home "$ROOT" /mnt/home
fi

mkdir -p /mnt/boot
mount "$EFI" /mnt/boot

# Step 5: Install base system
pacstrap /mnt base linux linux-firmware btrfs-progs

# Step 6: fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Step 7: Chroot
arch-chroot /mnt /bin/bash <<EOF

# Step 8: Locale & Time
ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "arch" > /etc/hostname
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts


pacman -S --noconfirm dialog git sudo

dialog --yesno "Use Goldstriker208's dotfiles?" 7 50
IS_CONFIG=$?
if [[ "$IS_CONFIG" -eq 0 ]]; then
    cd ~
    git clone https://github.com/Goldstriker208/kde-plasma-install
    sudo cp -a kde-plasma-install/. /etc/skel/
    #rm /etc/skel/install.sh
else
    echo "skipped"
    sleep 2
fi


# Step 9: User & root

echo "Setting up user/root passwords"
sleep 2
useradd -m -G wheel -s /bin/bash $USERNAME
echo "root:$ROOT_PASS" | chpasswd
echo "$USERNAME:$USER_PASS" | chpasswd


echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel

# Step 10: GRUB
echo "installing grub bootloader"
sleep 5
pacman -S --noconfirm grub efibootmgr

EOF

# Prompt outside chroot
set +e  # Temporarily disable exit-on-error
dialog --yesno "Are you installing on a Mac? (Use --removable GRUB flag)" 7 50
IS_MAC=$?
set -e  # enable

arch-chroot /mnt /bin/bash <<EOF

if [[ "$IS_MAC" -eq 0 ]]; then
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable
else
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
fi

grub-mkconfig -o /boot/grub/grub.cfg


# Step 11: KDE, SDDM, NetworkManager
echo "Installing KDE Plasma"
sleep 2

pacman -S --noconfirm plasma-meta sddm networkmanager firefox konsole ark kate gwenview spectacle kcalc dolphin
systemctl enable sddm
systemctl enable NetworkManager

# Step 12: Drivers

echo "Installing Drivers"
sleep 2

# Intel Graphics
pacman -S --noconfirm intel-ucode mesa xf86-video-intel

# AMD Graphics
#sudo pacman -S mesa xf86-video-amdgpu vulkan-radeon libva-mesa-driver

# NVIDIA Graphics
#sudo pacman -S nvidia nvidia-utils nvidia-settings

EOF

# Step 13: Finish

umount -R /mnt
dialog --msgbox "Installation complete. Rebooting!" 6 40
reboot
