# Building uNexus

This guide explains how to build and run uNexus Shell from source.

---

## Current Target Environment

The active development target is:

- Arch Linux;
- Hyprland;
- Qt6;
- CMake 3.20+;
- Exo 2 UI font;
- Noto Emoji for icon fallback.

Ubuntu/Debian can still be used for early testing, but Hyprland features such as window focus/close are expected to work best on the Arch + Hyprland setup.

Windows is currently used only as a coding/editing environment in this workflow. Do not expect local Windows builds to work unless CMake and Qt6 are installed there; real build and runtime validation should happen on the Arch + Hyprland machine.

---

## Arch Linux Setup

Install core dependencies:

```bash
sudo pacman -S git cmake qt6-base qt6-declarative qt6-wayland base-devel wget noto-fonts-emoji hyprland
```

Install gaming and diagnostics dependencies:

```bash
sudo pacman -S gamemode lib32-gamemode mangohud lib32-mangohud flatpak vulkan-tools
```

Optional test utilities:

```bash
sudo pacman -S mesa-utils
```

Optional developer/system tools that may be useful while testing uNexus:

```bash
sudo pacman -S kitty alacritty zsh fish zsh-syntax-highlighting zsh-autosuggestions starship github-cli openssh python python-pip python-virtualenv sqlite postgresql-libs neovim code btop htop power-profiles-daemon tlp networkmanager
```

Enable Flathub for Flatpak gaming apps:

```bash
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

Install Exo 2:

```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget "https://github.com/google/fonts/raw/main/ofl/exo2/Exo2%5Bwght%5D.ttf" -O Exo2.ttf
fc-cache -fv
```

---

## Clone the Repository

```bash
git clone https://github.com/PedroVitor-Dev/uNexus-OS.git
cd uNexus-OS
```

---

## Install the Shell Session

The preferred local install path is:

```bash
sudo sh scripts/setup.sh
```

This script:

- configures and builds `unexus-shell`;
- installs the shell binary;
- installs `uNexus` and `uNexus Recovery` Wayland sessions;
- installs current logo and wallpaper runtime assets;
- installs `unexusctl` and `unexus-doctor`;
- initializes user XDG state directories;
- writes an install log;
- validates the install.

After install:

```bash
unexusctl doctor
unexusctl paths
unexusctl session-info
```

Display managers should show:

- `uNexus`;
- `uNexus Recovery`.

Use `uNexus Recovery` when the normal shell fails and you need terminal access.

---

## Installer Direction

The selected installer experience is graphical and double-click friendly:

- build a Qt/QML `uNexus Installer` as the user-facing installer;
- use `packaging/arch/PKGBUILD`, `makepkg` and `pacman` behind the installer;
- use Flatpak behind the installer for user applications where appropriate;
- keep `scripts/setup.sh` for development and local repair installs;
- use `archiso` + Calamares later for the bootable uNexus OS image.

See [installer-technology.md](installer-technology.md) for the decision record.

---

## Build unexus-shell

```bash
cd packages/unexus-shell
cmake -B build
cmake --build build
```

---

## Run unexus-shell

```bash
./build/unexus-shell
```

Default password: `1234` or blank.

---

## Rebuild After Updates

For installed systems, use:

```bash
cd ~/uNexus-OS
git pull
sudo sh scripts/setup.sh
```

After `unexusctl` is installed, this can also be done with:

```bash
unexusctl update --yes
```

For a manual clean rebuild after C++ or CMake changes:

```bash
cd ~/uNexus-OS/packages/unexus-shell
rm -rf build
cmake -B build
cmake --build build
./build/unexus-shell
```

---

## Hyprland Auto-start

The installed session wrapper is preferred.

Manual development testing can still use an `exec-once` line in your Hyprland config.

Example:

```ini
exec-once = /home/<user>/uNexus-OS/packages/unexus-shell/build/unexus-shell
```

The shell currently relies on Hyprland for the best window-management behavior.

---

## Optional Gaming Apps

Native packages or Flatpaks can be used. Game Settings can start Flatpak installs for these supported launcher IDs when Flatpak/Flathub are available.

Steam:

```bash
flatpak install -y flathub com.valvesoftware.Steam
```

Lutris:

```bash
flatpak install -y flathub net.lutris.Lutris
```

Heroic Games Launcher:

```bash
flatpak install -y flathub com.heroicgameslauncher.hgl
```

Bottles:

```bash
flatpak install -y flathub com.usebottles.bottles
```

---

## Testing MangoHud

Check whether tools are installed:

```bash
command -v mangohud
command -v gamemoderun
```

For Steam games, uNexus can copy this launch option:

```bash
mangohud gamemoderun %command%
```

For standalone apps, Game Mode can launch gaming apps with MangoHud/GameMode wrappers when available.

---

## Ubuntu / Debian Notes

Ubuntu is useful for basic Qt/QML testing:

```bash
sudo apt update
sudo apt install -y build-essential cmake git qt6-base-dev qt6-declarative-dev libqt6qml6 gamemode
```

Some features may not behave the same on GNOME Wayland:

- `hyprctl` is unavailable;
- `wmctrl` may not see Wayland windows;
- dock focus/close behavior is less reliable;
- process detection may be used as fallback.

---

## Troubleshooting

**Validate an installed system**

```bash
unexusctl doctor
```

`flatpak not found` can be a warning if Flatpak gaming app support is not required yet.

**Find logs**

```bash
unexusctl logs
```

Current logs:

- `~/.local/state/unexus/logs/session.log`;
- `~/.local/state/unexus/logs/install.log`;
- `~/.local/state/unexus/logs/doctor.log`;
- `~/.local/state/unexus/logs/update.log`.

**Recover from a broken shell**

Pick `uNexus Recovery` in the display manager. It starts Hyprland with a terminal only.

**Reset settings**

```bash
unexusctl reset-settings
```

This moves known uNexus settings aside instead of deleting them.

**Rollback user config**

```bash
unexusctl rollback
```

Rollback restores the latest backup created by `unexusctl backup` or `unexusctl update --yes`.

**CMake cannot find Qt6**

Install Qt6 development packages for your distro.

Arch:

```bash
sudo pacman -S qt6-base qt6-declarative
```

Ubuntu:

```bash
sudo apt install qt6-base-dev qt6-declarative-dev
```

**Window focus or close does not work**

Make sure you are running inside Hyprland and `hyprctl` works:

```bash
hyprctl clients -j
```

**MangoHud wrapper does not show in Steam itself**

MangoHud usually appears inside the game process, not necessarily in the Steam client window.

**GPU stats show N/A**

Expected on machines without exposed GPU metrics or missing drivers. CPU and RAM should still update.

**RAM looks low**

On a lightweight Arch + Hyprland session, low RAM usage can be correct. Compare with:

```bash
free -h
```

**`./build/unexus-shell: No such file or directory`**

The build failed. Run:

```bash
cmake --build build
```

and inspect the compiler errors.

---

<sub>More components will be added as the project grows.</sub>
