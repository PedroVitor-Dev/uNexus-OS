# Building uNexus

This guide explains how to build and run uNexus Shell from source.

Project website: <https://unexus-os.vercel.app>

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
- use the existing `ISO/0.0.1` Archiso profile as the live image foundation;
- add Calamares or the native graphical installer later for disk installation.

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

## Build the Live ISO

The first bootable uNexus OS image profile lives in `ISO/0.0.1`.

Install Archiso tools on the build host:

```bash
sudo pacman -S archiso base-devel rsync
```

Build the image:

```bash
cd ~/uNexus-OS
sudo sh ISO/0.0.1/build-iso.sh
```

The generated image is written to:

```text
ISO/0.0.1/out/
```

During ISO creation, `build-iso.sh` packages the current checkout into a local `unexus-shell` Arch package, creates a temporary local pacman repository and adds that repository to the generated Archiso profile. This keeps the live image install path package-based instead of compiling uNexus inside `customize_airootfs.sh`.

Validate the generated ISO in QEMU:

```bash
sh scripts/test-iso-vm.sh
```

The VM test waits for the live ISO to emit `UNEXUS_SMOKE_OK` over the serial port after checking the installed uNexus session files, services and `unexus-doctor`. Install the VM dependencies on Arch Linux with:

```bash
sudo pacman -S qemu-full edk2-ovmf
```

Use `--bios-only` when OVMF is not installed yet.

Run the full release gate before publishing an ISO:

```bash
sh scripts/validate-iso-release.sh --build
```

The release gate runs static checks, builds the project, optionally rebuilds the ISO, writes `SHA256SUMS` and runs QEMU smoke tests when available. Use `--require-vm` for release builds that must fail if BIOS/UEFI VM validation cannot run. When `ISO/0.0.1/out/` is not writable, reports and fallback checksums are written to `/tmp/unexus-release-checks/`.

The live profile includes Hyprland, the uNexus shell/session, Qt6, PipeWire, NetworkManager, Flatpak, GameMode, MangoHud, Vulkan tools, graphical Polkit authentication, Papirus/Breeze/Adwaita/hicolor icons, Qt SVG/imageformat plugins, Noto/DejaVu/Liberation fallback fonts and recovery utilities.

The normal session also writes GTK settings and exports Qt/GTK/cursor defaults so the first boot does not depend on a manually configured desktop theme.

The ISO boot menu provides normal boot, safe graphics, text recovery, doctor and settings rollback entries. The recovery and doctor entries intentionally run on tty1 so they remain useful when the graphical session is broken.

Write it to a USB disk:

```bash
lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS
sudo sh ISO/0.0.1/write-usb.sh /dev/sdX
```

Use the whole USB disk, not a partition. The writer shows the target and requires typing `WRITE` before erasing it.

Install the live system to a disk by previewing the native installer plan:

```bash
sudo sh scripts/install-os.sh --target /dev/sdX --username pedro --timezone America/Fortaleza
```

Then run the destructive install with explicit confirmation:

```bash
sudo sh scripts/install-os.sh --target /dev/sdX --username pedro --timezone America/Fortaleza --execute --confirm ERASE-AND-INSTALL
```

This first disk installer backend targets UEFI systems with systemd-boot and creates a 1 GiB EFI system partition plus a root partition.

The installer supports offline installs from the live ISO package cache:

```bash
sudo sh scripts/install-os.sh --target /dev/sdX --username pedro --timezone America/Fortaleza --offline --execute --confirm ERASE-AND-INSTALL
```

`--online` forces pacman repository downloads. Without either flag, the installer uses the local cache when package files are present and falls back to online repositories otherwise.

The installed user's first setup state is seeded from installer options such as `--locale`, `--timezone` and `--keymap`. The shell's First Setup panel then shows system defaults, network status, update channel access, runtime tools and optional game launchers.

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

If `unexus-shell` crashes during a normal `uNexus` session, the session wrapper opens the `uNexus Recovery Shell` TUI automatically inside the fallback terminal.

You can also pick `uNexus Recovery` in the display manager. It starts Hyprland safely and opens the same TUI menu with options to restart the shell, run `unexusctl doctor`, inspect logs, reset settings, roll back a backup, open a terminal, exit the session, reboot or power off.

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
