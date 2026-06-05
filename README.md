<div align="center">
  <img src="assets/logo/SF%20White.png" width="320" alt="uNexus logo">
  <h1>uNexus</h1>
  <p>A gaming-first Linux shell built around speed, focus, and a polished desktop experience.</p>

  ![Status](https://img.shields.io/badge/status-in%20development-blue)
  ![License](https://img.shields.io/badge/license-GPL--3.0-white)
  ![Platform](https://img.shields.io/badge/platform-Linux-black)
  ![Focus](https://img.shields.io/badge/focus-Gaming-red)
  ![Environment](https://img.shields.io/badge/environment-Arch%20%2B%20Hyprland-purple)

</div>

---

## Philosophy

> "Open Source. Linux Powered. Gamer Focused."

uNexus is built around one goal: make Linux gaming feel immediate, focused, and polished out of the box.

---

## Current State

uNexus Shell is currently running natively on **Arch Linux + Hyprland** on real hardware.

The current prototype manages:

- desktop wallpaper and top bar;
- fullscreen login screen;
- system and gaming side docks;
- themed system and gaming side docks with real icon lookup and drawn icon fallbacks;
- app launcher with search, categories and installed/running/missing status chips;
- uNexus Files with navigation, breadcrumbs, sorting, multi-select, clipboard actions and previews;
- right-click desktop context menu;
- notifications;
- uNexus Settings control center with OS Provisioning checklist;
- Game Settings dashboard;
- first-run setup checklist;
- PT-BR / English interface language selection;
- CPU/GPU/RAM stats overlay;
- real app launch, focus, close, maximize, move and minimize/restore through C++ and `hyprctl`;
- workspace indicators and compositor-ready window preview direction;
- installable Hyprland session and recovery session;
- `unexusctl` for doctor, logs, backup, rollback, update and state management.

The shell can be installed as a Wayland session through `scripts/setup.sh`.

---

## Why uNexus?

- **Game-first workflow**: Steam, Lutris, Heroic and Bottles are first-class launcher targets.
- **Hyprland-native control**: window focus, close, maximize, move and minimize/restore actions use `hyprctl` when available.
- **Real system data**: battery, network, CPU, GPU, RAM and temperature data come from C++ backends.
- **Gaming helpers**: Game Mode, MangoHud detection, Flatpak fallbacks and copied Steam launch options.
- **Clean interface**: side docks, launcher, settings panels, notifications and setup live in one cohesive token-driven shell.
- **uNexus visual language**: shared design tokens, Liquid Glass surfaces and spring motion give the shell a recognizable feel.
- **Open source**: GPL-3.0 and community-driven.

---

## Features

| Feature | Status |
|---|---|
| Login screen with avatar, clock and password | Done |
| Geometric wallpaper with particles | Done |
| Top bar with clock, date, network, battery and Game Mode | Done |
| Game Mode toggle through C++ | Done |
| CPU/GPU/RAM stats overlay | Done |
| Missing GPU metrics shown as N/A | Done |
| System side dock | Done |
| Gaming side dock | Done |
| Theme-synced dock accents | Done |
| Dock icon lookup and drawn fallbacks | Done |
| Dock hover, tooltip, bounce and active indicator | Done |
| Dock open, minimized and closed app states | Done |
| Design token system for spacing, radius, motion, type and surfaces | Done |
| Liquid Glass QML material for docks, menus and notifications | Done |
| Spring physics for panel and dock motion | Done |
| Real app launch through C++ | Done |
| Focus running apps before opening duplicates | Done |
| Close apps through `hyprctl` / process fallback | Done |
| Maximize, move, minimize and restore through dock action menu | Done |
| Workspace indicators in the top bar | Done |
| Dock right-click action menu | Done |
| Launcher with search and categories | Done |
| Gaming category with Steam, Lutris, Heroic and Bottles | Done |
| Installed/not installed detection for gaming apps | Done |
| Flatpak fallback for gaming apps | Done |
| MangoHud/GameMode launch path for gaming apps | Done |
| uNexus Settings panel | Done |
| Settings control center sections with persistent active section | Done |
| Settings OS Provisioning checklist | Done |
| Game Settings panel | Done |
| Game Settings dashboard summary | Done |
| First Setup panel | Done |
| uNexus Files file manager with copy/cut/paste, multi-select and previews | Done |
| PT-BR / English language selection in Settings | Done |
| Persistent user settings through `QSettings` | Done |
| Notification system | Done |
| Desktop context menu | Done |
| Installable uNexus Hyprland session | Done |
| uNexus Recovery session | Done |
| `unexus-doctor` install validation | Done |
| `unexusctl` state, logs, backup, rollback and update controls | Done |
| Arch PKGBUILD | Done |
| GPU driver manager | Planned |
| Per-game performance profiles | Planned |
| Bootable ISO | Planned |


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
| `docs` | Architecture, build guide, roadmap and contribution docs |
| `assets` | Visual and media assets |
| `scripts` | Build, install, package, uninstall, doctor and control scripts |

---

## Installer Direction

uNexus targets a graphical, double-click installer experience.

- `uNexus Installer` is planned as a Qt/QML visual installer.
- Arch packages and `pacman` remain the native backend.
- Flatpak can power friendly user-app installs.
- `scripts/setup.sh` remains the development/local repair installer.
- `archiso` + Calamares is the planned path for a future bootable uNexus OS image.

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
| uNexus Settings | `qml/SettingsPanel.qml`, `usersettings.cpp` | Control center sections, OS provisioning, appearance and shell preferences |
| Game Settings | `qml/GameSettingsPanel.qml` | Dashboard, MangoHud, GameMode and gaming launchers |
| First Setup | `qml/FirstSetupPanel.qml` | First-run checklist and install commands |
| uNexus Files | `qml/FilesPanel.qml`, `filemanager.cpp` | Local file navigation, multi-select, copy/cut/paste, open, create folder, rename, previews and trash |
| Session control | `packaging/linux/unexus-session`, `unexus-recovery-session` | Normal and recovery Hyprland sessions |
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

---

## Roadmap

See [docs/roadmap.md](docs/roadmap.md).

Current near-term focus:

- build the first graphical double-click uNexus Installer MVP;
- turn OS Provisioning from copied commands into `unexusctl provision` profiles;
- deepen Liquid Glass toward shader/compositor-backed blur and refraction;
- start the Game Library and per-game profile data model;
- start the bootable ISO path with `archiso`.

---

## Contributing

See [docs/contributing.md](docs/contributing.md).

---

<div align="center">
  <sub>Open Source. Linux Powered. Gamer Focused.</sub>
</div>
