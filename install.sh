#!/bin/bash

# Default Arch install script
# konsole --hold -e "/usr/bin/archinstall"

# TUI Arch Linux Installer using dialog
# Requires: dialog, iwctl, NetworkManager, pacstrap, grub, etc.

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



# Step 0: Setup Wifi/Network

check_internet() {
    ping -c 1 -W 2 google.com > /dev/null 2>&1
}

if check_internet; then
    echo "Internet is connected"
    sleep 2
else
    echo "No internet connection"
    sleep 2

    # set +e  # Temporarily disable exit-on-error
    dialog --yesno "No internet connection. Connect to Wifi?" 7 50
    USER_CHOICE=$?
    # set -e  # Enable

    clear

    if [[ "$USER_CHOICE" -eq 0 ]]; then
        nmtui
        echo "Returned from nmtui"
    else
        echo "Skipped wifi setup."
        sleep 2
    fi
fi



# Update keys and package lists
pacman -Sy

# Install NetworkManager and dialog 
pacman -S networkmanager dialog --noconfirm

# Enable and start NetworkManager
systemctl enable NetworkManager
systemctl start NetworkManager


# Step 1: Select DISK
DISK=$(dialog --menu "Select disk to partition" 10 40 2 \
  /dev/sda "Disk 1" \
  /dev/sdb "Disk 2" 3>&1 1>&2 2>&3)

clear

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
sleep 3



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

# Step 9: User & root

# Install sudo (required for /etc/sudoers.d)
pacman -S --noconfirm sudo

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

pacman -S --noconfirm plasma-meta sddm networkmanager firefox konsole ark kate gwenview spectacle kcalc
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
