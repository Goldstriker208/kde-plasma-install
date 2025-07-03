Starship custom toml file - Using Pastel Powerline preset

```
# partition drives in a partition manager
# sdX = root partition
# sdY = efi partition
```
# Arch Linux Installation Commands

## Step 1: WIFI
```bash
# For Wi-Fi (run 'station wlan0 connect SSID')
iwctl  
ping archlinux.org -c 3  # Test network
```

## Step 2: Partitioning
```bash
# use cfdisk to partition
cfdisk /dev/DISK

# or just
cfdisk
```
## Step 3: Format Partitions
```bash
# Choose either BTRFS or EXT4

# Option A: EXT4
###############################
# Root partition EXT4
mkfs.ext4 -L arch /dev/sdX

# Format EFI
mkfs.fat -F32 /dev/sdY
###############################

# Option B: BTRFS
##############################
# Format Root partition BTRFS
mkfs.btrfs -L arch /dev/sdX

# Format EFI
mkfs.fat -F32 /dev/sdY
##############################

```

## Step 4: Mount Partitions
```bash

# Option A: No Subvolumes
##############################################################
# Mount Root
mount /dev/sdX /mnt

# Mount EFI Boot Folder
mount /dev/sdY /mnt/boot
##############################################################

# Option B: BTRFS Subvolumes (optional and btrfs only)
##############################################################
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume list -a /mnt

mount -o defaults,compress,subvol=@ /dev/sdX /mnt/
mkdir /mnt/home
mount -o defaults,compress,subvol=@home /dev/sdX /mnt/home

# Mount EFI Boot Folder
mount /dev/sdY /mnt/boot
##############################################################
```

## Step 5: Install Arch Linux Base System
```bash
# Install the base system and essential packages
pacstrap /mnt base linux linux-firmware btrfs-progs
```

## Step 6: Generate fstab
```bash
# Generate fstab file with UUIDs
genfstab -U /mnt >> /mnt/etc/fstab
```

## Step 7: Chroot into Installed System
```bash
# Change root into the new system
arch-chroot /mnt
```

## Step 8: Configure System Basics
```bash
# Set timezone to US/Pacific
ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime
hwclock --systohc

# Set locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

# Set hostname
echo "myhostname" > /etc/hostname
echo "127.0.1.1 myhostname.localdomain myhostname" >> /etc/hosts
```

## Step 9: Set Root Password & Create User
```bash
# Set root password
passwd

# Create user with sudo privileges
useradd -m -G wheel -s /bin/bash myuser
passwd myuser

# Enable sudo for wheel group
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
```

## Step 10: Install & Configure GRUB (UEFI)
```bash
# Install GRUB and EFI boot manager
pacman -S grub efibootmgr

# Install GRUB to EFI
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Generate GRUB configuration file
grub-mkconfig -o /boot/grub/grub.cfg
```

## Step 11: Install KDE Plasma, Enable SDDM, NetworkManager, and Bluetooth Services
```bash
# Install KDE Plasma desktop environment and essential services
pacman -S plasma-meta plasma-wayland-session sddm networkmanager

# Enable display manager and network services
systemctl enable sddm
systemctl enable NetworkManager

# Enable Bluetooth
systemctl enable bluetooth
```

## Step 12: Install Graphics Drivers

- [Other Graphics](https://wiki.archlinux.org/title/Xorg#Driver_installation) 
- [NVIDIA](https://wiki.archlinux.org/title/NVIDIA) 
- [AMD](https://wiki.archlinux.org/title/Xorg#AMD)

```bash
# Intel Drivers
pacman -S intel-ucode mesa xf86-video-intel

# Virtualbox/VMware drivers:
pacman -S virtualbox-guest-utils xf86-video-vmware
```


## Step 13: Exit & Reboot
```bash
# Exit chroot
exit

# Unmount all mounted partitions
umount -R /mnt

# Reboot into the installed system
reboot
```

## Additional Tweaks
```bash

# Fix DPI/Scaling on SDDM Login Screen
mkdir -p /etc/sddm.conf.d/
dpi=$(xrdb -query | grep -i dpi | awk '{print $2}')
echo "[Wayland]
EnableHiDPI=true

[X11]
EnableHiDPI=true

[General]
GreeterEnvironment=QT_SCREEN_SCALE_FACTORS=1.75,QT_FONT_DPI=$dpi
" | sudo tee /etc/sddm.conf.d/hidpi.conf

# Edit Grub to turn off splash and verbose
sudo nano /etc/default/grub

# Copy and paste into GRUB_CMDLINE_LINUX_DEFAULT Variable
loglevel=3 quiet


```

## Macbook Pro 2016/2017 Patches
https://github.com/Dunedan/mbp-2016-linux  
- [Fix Sleep](https://github.com/Dunedan/mbp-2016-linux?tab=readme-ov-file#suspend--hibernation)
- [Fix Audio](https://github.com/Dunedan/mbp-2016-linux?tab=readme-ov-file#audio-input--output)

```bash

# My power/sleep settings for KDE Plasma 6 (minimize sleep wake time, not always ideal but works)
echo "[Battery][RunScript]
RunScriptIdleTimeoutSec=300

[Battery][SuspendAndShutdown]
AutoSuspendIdleTimeoutSec=300
LidAction=64
SleepMode=3" > ~/.config/powerdevilrc

# Add params to grub to force s2idle for fixing sleep and nvme issues
sudo nano /etc/default/grub

# Copy and paste into GRUB_CMDLINE_LINUX_DEFAULT Variable
mem_sleep_default=s2idle nvme_core.default_ps_max_latency_us=0

```
