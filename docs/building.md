# Building PED OS

This guide explains how to build and run PED OS Shell from source.

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
sudo pacman -S git cmake qt6-base qt6-declarative base-devel wget noto-fonts-emoji
```

Install gaming and diagnostics dependencies:

```bash
sudo pacman -S gamemode lib32-gamemode mangohud lib32-mangohud flatpak vulkan-tools
```

Optional test utilities:

```bash
sudo pacman -S mesa-utils
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
git clone https://github.com/PedroVitor-Dev/Ped-Os.git
cd Ped-Os
```

---

## Build ped-shell

```bash
cd packages/ped-shell
cmake -B build
cmake --build build
```

---

## Run ped-shell

```bash
./build/ped-shell
```

Default password: `1234` or blank.

---

## Rebuild After Updates

Use a clean rebuild after C++ or CMake changes:

```bash
cd ~/Ped-Os/packages/ped-shell
rm -rf build
cmake -B build
cmake --build build
./build/ped-shell
```

---

## Hyprland Auto-start

Add an `exec-once` line to your Hyprland config.

Example:

```ini
exec-once = /home/<user>/Ped-Os/packages/ped-shell/build/ped-shell
```

The shell currently relies on Hyprland for the best window-management behavior.

---

## Optional Gaming Apps

Native packages or Flatpaks can be used.

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

For Steam games, PED OS can copy this launch option:

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

**`./build/ped-shell: No such file or directory`**

The build failed. Run:

```bash
cmake --build build
```

and inspect the compiler errors.

---

<sub>More components will be added as the project grows.</sub>
