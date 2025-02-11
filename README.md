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
```
## Step 3: Format Partitions
```bash
# Choose either BTRFS or EXT4

# root partition BTRFS
mkfs.btrfs -L arch /dev/vda2

# root partition EXT4
mkfs.ext4 -L arch /dev/vda2 
 
# If needed use this command to clear filesystem signatures or just use -f option on mkfs.btrfs command
wipefs --all --force


# Format Partitions

# Btrfs root 
mkfs.btrfs -f /dev/sdX

# EFI
mkfs.fat -F32 /dev/sdY

```

## Step 4: Mount Partitions
```bash
mount /dev/sdaX /mnt

# Optional (BTRFS subvolumes)
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume list -a /mnt

umount /dev/sdX /mnt

# Optional (BTRFS subvolumes)
mount -o defaults,compress,subvol=@ /dev/vda2 /mnt/
mkdir /mnt/home
mount -o defaults,compress,subvol=@home /dev/vda2 /mnt/home
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

## Step 11: Install KDE Plasma, SDDM, & NetworkManager
```bash
# Install KDE Plasma desktop environment and essential services
pacman -S plasma-meta plasma-wayland-session sddm networkmanager

# Enable display manager and network services
systemctl enable sddm
systemctl enable NetworkManager
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


## Step 12: Exit & Reboot
```bash
# Exit chroot
exit

# Unmount all mounted partitions
umount -R /mnt

# Reboot into the installed system
reboot
```


