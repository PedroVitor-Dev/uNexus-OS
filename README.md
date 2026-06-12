<div align="center">
  <img src="assets/logo/SF%20White.png" width="320" alt="uNexus logo">

  <p>A gaming-first Linux shell built around speed, focus, and a polished desktop experience.</p>

  ![Status](https://img.shields.io/badge/status-in%20development-blue)
  ![License](https://img.shields.io/badge/license-GPL--3.0-white)
  ![Platform](https://img.shields.io/badge/platform-Linux-black)
  ![Focus](https://img.shields.io/badge/focus-Gaming-red)
  ![Environment](https://img.shields.io/badge/environment-Arch%20%2B%20Hyprland-purple)

  <p><a href="https://unexus-os.vercel.app">Project website</a></p>

</div>

---

## Preview

<div align="center">
  <img src="assets/screenshots/02-desktop.png" width="900" alt="uNexus desktop">
  <br>
  <sub>uNexus desktop with the default visual identity.</sub>
</div>

<br>

<table>
  <tr>
    <td width="50%">
      <img src="assets/screenshots/03-launcher.png" alt="uNexus Launcher">
      <br>
      <sub><b>Launcher</b> with categories, search and app state chips.</sub>
    </td>
    <td width="50%">
      <img src="assets/screenshots/04-file-manager.png" alt="uNexus File Manager">
      <br>
      <sub><b>uNexus Files</b> with places, breadcrumbs, sorting and file actions.</sub>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <img src="assets/screenshots/05-settings.png" alt="uNexus Settings">
      <br>
      <sub><b>Settings</b> for system, appearance, language and shortcuts.</sub>
    </td>
    <td width="50%">
      <img src="assets/screenshots/06-game-settings.png" alt="uNexus Game Settings">
      <br>
      <sub><b>Game Settings</b> for launchers, GameMode and overlay tooling.</sub>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <img src="assets/screenshots/01-login.png" alt="uNexus login screen">
      <br>
      <sub><b>Login</b> with the same polished visual language as the desktop.</sub>
    </td>
    <td width="50%">
      <img src="assets/screenshots/07-first-setup.png" alt="uNexus First Setup">
      <br>
      <sub><b>First Setup</b> for initial system and gaming readiness checks.</sub>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <img src="assets/screenshots/08-settings-appearance.png" alt="uNexus Appearance Settings">
      <br>
      <sub><b>Appearance</b> with theme and wallpaper customization.</sub>
    </td>
    <td width="50%">
      <img src="assets/screenshots/11-desktop-ember-circuit.png" alt="uNexus Ember Circuit wallpaper">
      <br>
      <sub><b>Wallpapers</b> with alternate desktop styles.</sub>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <img src="assets/screenshots/09-desktop-particle-drift.png" alt="uNexus Particle Drift wallpaper">
      <br>
      <sub><b>Particle Drift</b> wallpaper.</sub>
    </td>
    <td width="50%">
      <img src="assets/screenshots/10-desktop-aurora-ice.png" alt="uNexus Aurora Ice wallpaper">
      <br>
      <sub><b>Aurora Ice</b> wallpaper.</sub>
    </td>
  </tr>
</table>

---

## Philosophy

> "Open Source. Linux Powered. Gamer Focused."

uNexus is built around one goal: make Linux gaming feel immediate, focused, and polished out of the box.

---

## Current State

uNexus Shell is currently running natively on **Arch Linux + Hyprland** on real hardware.

The current prototype manages:

- branded desktop wallpaper set, animated background layer and top bar;
- first bootable `archiso` live image profile under `ISO/0.0.1`;
- fullscreen login screen;
- system and gaming side docks with real icon lookup and drawn fallbacks;
- app launcher with search, categories and installed/running/missing status chips;
- uNexus Files with navigation, breadcrumbs, sorting, multi-select, clipboard actions, keyboard shortcuts and previews;
- right-click desktop and file-manager context menus;
- notifications, persistent notification preference and stats overlay;
- uNexus Settings control center with appearance, language, shortcuts, help and about sections;
- Game Settings dashboard with GameMode, MangoHud and real Flatpak launcher install actions;
- first-run setup checklist;
- PT-BR / English interface language selection;
- real app launch, focus, close, maximize, move and minimize/restore through C++ and `hyprctl`;
- Windows-like global shortcuts for Launcher, Settings, Game Settings and stats overlay;
- workspace indicators and compositor-ready window preview direction;
- installable Hyprland session, recovery session and automatic TUI recovery menu after shell crashes;
- `unexusctl` for doctor, logs, backup, rollback, update and state management.
- graphical Qt/QML installer wizard for local install, repair, diagnostics, removal and system provisioning flows.
- Settings > About update channel selection and a `Super+B` bug report generator for logs/specs/version capture.

The shell can be installed as a Wayland session through `scripts/setup.sh`.
The first live ISO profile can be built with `ISO/0.0.1/build-iso.sh`.

---

## Test Release

The first public ISO is available under [release v0.0.1](https://github.com/PedroVitor-Dev/uNexus-OS/releases/tag/v0.0.1).

This build is **not recommended for daily use yet**. It was generated for boot, visual and workflow testing, and it should be treated as an early live-image snapshot while the installer, packaging and hardware validation continue to mature.

Because this ISO targets the real Hyprland/uNexus session stack, test it on spare hardware or a disposable machine, not as a daily driver.

---

## Why uNexus?

- **Game-first workflow**: Steam, Lutris, Heroic and Bottles are first-class launcher targets.
- **Hyprland-native control**: window focus, close, maximize, move and minimize/restore actions use `hyprctl` when available.
- **Real system data**: battery, network, CPU, GPU, RAM and temperature data come from C++ backends.
- **Gaming helpers**: Game Mode, MangoHud detection, Steam launch-option helpers and real Flatpak launcher installs.
- **Clean interface**: side docks, launcher, settings panels, notifications and setup live in one cohesive token-driven shell.
- **uNexus visual language**: shared design tokens, Liquid Glass surfaces, spring motion and official wallpapers give the shell a recognizable feel.
- **Open source**: GPL-3.0 and community-driven.

---

## Feature Status

Recent shipping focus:

| Area | Status |
|---|---|
| Official wallpaper identity set | Added `unexus-core`, `particle-drift`, `aurora-ice` and `ember-circuit` assets |
| Wayland session packaging | Installable `uNexus` and `uNexus Recovery` sessions are in place |
| Global shortcuts | Windows-style Launcher, Settings, Game Settings and stats shortcuts are implemented |
| Settings shortcuts/help | Shortcut customization, apply buttons, restore defaults and help panel are available |
| Game launcher installs | Game Settings starts real Flatpak installs for Steam, Lutris, Heroic and Bottles |
| uNexus Files polish | Context menu, copy/cut/paste hotkeys, sorting, previews and layout fixes are in place |
| Visual language | Tokens now cover spacing, radius, typography, surfaces and motion |
| Bootable ISO 0.0.1 | Archiso live profile with Hyprland, uNexus Shell, autologin, recovery tools and USB writer |
| Session authentication | The normal session starts the KDE Polkit agent when available for graphical privilege prompts |
| Visual defaults | ISO/session now include icon themes, Qt SVG support, fonts, MIME metadata and Qt/GTK style defaults |

For the full staged roadmap, see [docs/roadmap.md](docs/roadmap.md).

---

## Stack

| Layer | Technology |
|---|---|
| Kernel | Linux |
| Display Server | Wayland |
| Compositor | Hyprland |
| Rendering | Vulkan / OpenGL |
| Core | C++ / Qt |
| Interface | Qt6 / QML |
| Build System | CMake 3.20+ |
| Settings Storage | QSettings |
| Font | Exo 2 |

---

## Repository Layout

| Path | Description |
|---|---|
| `packages/unexus-shell` | Main Qt/QML desktop shell |
| `packages/unexus-shell/src` | C++ system integration backends |
| `packages/unexus-shell/include` | C++ headers exposed to Qt/QML |
| `packages/unexus-shell/qml` | Shell UI, design tokens, docks, launcher, settings and overlays |
| `packaging/linux` | Desktop entries, Wayland sessions and session launchers |
| `packaging/arch` | Arch Linux PKGBUILD |
| `ISO/0.0.1` | First bootable Archiso live image profile and USB writer |
| `docs` | Architecture, build guide, roadmap and contribution docs |
| `assets` | Logo, wallpaper and media assets |
| `scripts` | Build, install, package, uninstall, doctor and control scripts |

---

## Installer Direction

uNexus targets a graphical, double-click installer experience.

- `uNexus Installer` is planned as a Qt/QML visual installer.
- Arch packages and `pacman` remain the native backend.
- Flatpak can power friendly user-app installs.
- `scripts/setup.sh` remains the development/local repair installer.
- `ISO/0.0.1` is the first `archiso` live image foundation.
- Calamares or a native graphical installer remains the planned disk-install path.

See [docs/installer-technology.md](docs/installer-technology.md).

---

## unexus-shell Components

| Component | File(s) | Description |
|---|---|---|
| Desktop shell | `qml/Main.qml` | Top bar, wallpaper, docks, panels and app orchestration |
| Design tokens | `qml/DesignTokens.qml` | Shared spacing, radius, motion, type, surface, text and status values |
| Liquid Glass material | `qml/LiquidGlass.qml` | Shared translucent depth material for docks, menus and notifications |
| Launcher | `qml/Launcher.qml` | App search, categories and gaming app status |
| Login screen | `qml/LoginScreen.qml` | Startup login flow |
| Notifications | `qml/NotificationCenter.qml` | Toast notifications |
| Desktop menu | `qml/ContextMenu.qml` | Right-click desktop actions |
| Stats overlay | `qml/FpsOverlay.qml`, `systemstats.cpp` | CPU, GPU, RAM and temperature overlay |
| uNexus Settings | `qml/SettingsPanel.qml`, `usersettings.cpp` | Control center sections, appearance, shortcuts, language and shell preferences |
| Game Settings | `qml/GameSettingsPanel.qml` | Dashboard, MangoHud, GameMode and gaming launcher installs |
| First Setup | `qml/FirstSetupPanel.qml` | First-run checklist and dependency guidance |
| uNexus Files | `qml/FilesPanel.qml`, `filemanager.cpp` | Local file navigation, multi-select, copy/cut/paste, open, create folder, rename, previews and trash |
| Global shortcuts | `globalshortcuts.cpp`, `main.cpp` | Hyprland-triggered shortcut command bridge |
| Session control | `packaging/linux/unexus-session`, `unexus-recovery-session`, `unexus-recovery-menu` | Normal session, recovery session and automatic TUI crash fallback |
| Installer | `packages/unexus-installer` | Graphical Qt/QML installer wizard backed by setup, doctor and uninstall scripts |
| CLI control | `scripts/unexusctl.sh`, `scripts/unexus-doctor.sh` | State management, diagnostics, update, rollback and logs |
| System info | `systeminfo.cpp` | Battery and network data |
| App launcher | `applauncher.cpp` | Launch, focus, close, Flatpak and MangoHud helpers |
| Game Mode | `gamemode.cpp` | Game Mode state and integration |
| Localization | `qml/Main.qml`, `usersettings.cpp` | English/PT-BR text mapping and persisted language preference |

---

## Build

See [docs/building.md](docs/building.md).

Quick Arch install from the repository:

```bash
cd ~/uNexus-OS
git pull
sudo sh scripts/setup.sh
unexusctl doctor
```

Manual build:

```bash
cd packages/unexus-shell
cmake -B build
cmake --build build
./build/unexus-shell
```

Default login password: `1234` or blank.

Build the first live ISO profile on Arch Linux:

```bash
cd ~/uNexus-OS
sudo sh ISO/0.0.1/build-iso.sh
```

Write the generated ISO to a USB disk:

```bash
sudo sh ISO/0.0.1/write-usb.sh /dev/sdX
```

Replace `/dev/sdX` with the whole USB disk, not a partition.

The live image is expected to boot with the uNexus visual baseline already present: Papirus/Breeze/Adwaita/hicolor icons, Qt SVG/imageformat plugins, Noto/DejaVu/Liberation fallback fonts, GTK dark defaults, Adwaita cursor settings and the First Setup checklist on first login.

---

## Roadmap

See [docs/roadmap.md](docs/roadmap.md).

Current near-term focus:

- validate the current Stage 1 shell polish on Arch + Hyprland;
- build the first graphical double-click uNexus Installer MVP;
- package Qt/QML dependencies and runtime assets correctly;
- add Flathub setup/status and safer provisioning backends;
- start the Game Library and per-game profile data model;
- validate and iterate on the bootable ISO 0.0.1 live environment.

---

## Contributing

See [docs/contributing.md](docs/contributing.md).

---

<div align="center">
  <sub>Open Source. Linux Powered. Gamer Focused.</sub>
</div>
