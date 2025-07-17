# 🐧 My Arch Linux Packages List

## 📦 Pacman Packages (Official Repos)

### 🖼️ KDE Plasma
- `gwenview`  
- `kcalc`  
- `spectacle`  
- `kate`  
- `konsole`  
- `krunner`
- `okular` 

### 🌐 Hyprland Environment
- `hyprland`  
- `hyprcursor`  
- `hyprgraphics`  
- `hyprpaper`  
- `hyprpicker`  
- `hyprshot`  
- `hyprutils`  
- `hyprwayland-scanner`  
- `waybar`
- `waypaper`   
- `rofi`

### Hyprland Themeing w/ kde qt & gtk
- `adw-gtk-theme`
- `xdg-desktop-portal-gtk`
- `qt5-wayland`
- `qt6-wayland`
- `qt5ct`
- `qt6ct`( GUI for qt settings)
- `nwg-look` (GUI for gtk settings)
- KDE Plasma System Settings -> Themes -> Your Theme (only if kde plasma is installed)

### 🧰 Graphical Applications
- `firefox`  
- `virt-manager`  
- `looking-glass`  
- `timeshift`  
- `wine`  
- `obs-studio`  
- `cider`
- `kitty`

### 🖥️ CLI Tools
- `cmatrix`  
- `neofetch`  
- `hyfetch`  
- `fastfetch`  
- `nyancat`  
- `tree`  
- `ostree`  
- `boxes`  
- `cowsay`  
- `htop`  
- `btop`  
- `ffmpeg`  
- `starship`  
- `cava`  
- `chatgpt-shell-cli`  

### 🛠️ Development Tools
- `git`  
- `gcc`  
- `make`  
- `cmake`  
- `python`  
- `python-pip`  
- `bzip2`  

### 📁 File Utilities
- `ranger`  
- `ncdu`  
- `eza`  
- `duf`  
- `fd`  
- `ripgrep`  
- `zoxide` (aliased as `z`)  
- `superfile`  
- `trash-cli`  

### ⚙️ System Utilities
- `net-tools`  
- `ufw`  
- `timeshift`  
- `htop`  
- `btop`  
- `speedtest-cli`  
- `ntfs-3g`  
- `wine`  
- `usbmuxd`  

---

## 🧩 AUR Packages (via `yay`)

### 🖼️ KDE Plasma
- `kwin-effect-rounded-corners-git`  

### 🌐 Hyprland
- `swww`  

### 🧰 Applications
- `librewolf-bin`  
- `zen-browser-bin`  
- `vesktop`  
- `thorium-browser-bin`  

---

## 🧪 Virtual Machine Drivers

| Platform    | Drivers                             |
|-------------|--------------------------------------|
| QEMU/VirtIO | `xf86-video-qxl`, `virtio-gpu` (kernel built-in) |
| VMware      | `xf86-video-vmware`                 |
| VirtualBox  | `virtualbox-guest-utils`            |

---

## 📦 Flatpak Applications
- Discord  
- Dolphin Emulator  
- Google Chrome  
- Parsec  
- Clapper  
- Visual Studio Code  
- Krita  
- IntelliJ IDEA Community  
- PyCharm Community  
- Minecraft  
- Minecraft: Pi Edition  
- FreeTube  
- Webcamoid  
- ProtonUp-Qt  
- Protontricks  
- Flatseal  
- LibreOffice  
- Prism Launcher  
- Wireshark  
- Zoom  
- Filelight  

---

## 🖥️ Display Servers
- `wayland`  
- `xorg-server`  
- `xorg-xwayland`  
- `xwayland-run-git`  

---

## 🔷 Bluetooth Drivers
- `bluedevil`  
- `bluez`  
- `bluez-libs`  
- `bluez-qt`  
- `bluez-qt5`  

---

## 🔤 Fonts
- `CascadiaCove Nerd Font`    
- `Caveat`
- `z003`
---

## 🎮 Graphics Drivers

### Nvidia
- `linux-headers`  
- `nvidia-dkms`  
- `nvidia-utils`  
- `nvidia-open-dkms`  
- `lib32-nvidia-utils`  

### Intel
- `mesa`  
- `vulkan-intel`  
- `lib32-vulkan-intel`  

### AMD
- `mesa`  
- `vulkan-radeon`  
- `lib32-vulkan-radeon`  

---

## 🎮 Steam & Gaming
- `steam`  
- `lib32-mesa`  
- `lib32-vulkan-<your-driver>` *(choose intel, radeon, or nvidia)*  
- `lib32-nvidia-utils` *(NVIDIA users only)*  
- `gamemode`  
- `protonup-qt`  
- `steam-native-runtime`
- `xwayland` *(if using wayland)*

```bash
# Fix font/ui issues on steam
sudo pacman -S webkit2gtk ttf-dejavu noto-fonts ttf-liberation
```

