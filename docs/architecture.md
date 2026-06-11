# uNexus Architecture

This document describes the current technical architecture of uNexus.

---

## Overview

uNexus is a Linux gaming desktop shell built on top of Wayland and Hyprland.

The current prototype is `unexus-shell`, a Qt6/QML application with C++ backends for system information, app launching, window control, Game Mode, stats, file actions, global shortcut commands and persistent user settings.

Around the shell there is a small OS support layer:

- installable Wayland session entries;
- a recovery Hyprland session;
- `unexus-doctor` for validation;
- `unexusctl` for state, logs, backup, rollback and update workflows;
- official logo and wallpaper resources packaged with the shell;
- XDG user directories for config, data, cache, state and logs.

---

## Layer Stack

```text
+--------------------------------------+
| Games and gaming launchers           |
| Steam, Lutris, Heroic, Bottles        |
+--------------------------------------+
| uNexus Shell UI                      |
| Main, docks, launcher, settings      |
+--------------------------------------+
| Qt6 / QML                            |
+--------------------------------------+
| C++ integration layer                |
| SystemInfo, AppLauncher, Stats       |
+--------------------------------------+
| uNexus OS control scripts            |
| unexusctl, doctor, session launchers |
+--------------------------------------+
| Hyprland / Wayland                   |
+--------------------------------------+
| Vulkan / OpenGL                      |
+--------------------------------------+
| Linux kernel                         |
+--------------------------------------+
```

---

## Runtime Architecture

`main.cpp` creates the C++ backend objects and exposes them to QML:

| Context object | C++ class | Purpose |
|---|---|---|
| `systemInfo` | `SystemInfo` | Battery and network state |
| `gameMode` | `GameMode` | Game Mode toggle/state |
| `appLauncher` | `AppLauncher` | Launch, focus, close, install and detect apps |
| `systemStats` | `SystemStats` | CPU, GPU, RAM and temperature stats |
| `userSettings` | `UserSettings` | Persistent shell preferences |
| shortcut command bridge | `GlobalShortcuts` | Hyprland-triggered command bridge for global shortcuts |
| `fileManager` | `FileManager` | Local file navigation and file actions |

The QML layer calls these objects directly from `Main.qml`, `Launcher.qml`, `SettingsPanel.qml`, `GameSettingsPanel.qml`, `FirstSetupPanel.qml`, `FilesPanel.qml` and `FpsOverlay.qml`.

---

## Main QML Surface

`qml/Main.qml` coordinates the shell:

- theme selection and persistence;
- English/PT-BR localization state;
- official wallpaper image, particles and animated line layer;
- top bar;
- login flow;
- system side dock;
- gaming side dock;
- dock action menu;
- launcher;
- desktop context menu;
- notifications;
- stats overlay;
- uNexus Settings;
- Game Settings;
- First Setup;
- uNexus Files;
- shared brand logo resource;
- global shortcut command dispatch.

The current dock is composed from `SideDock.qml` and `DockButton.qml`, with `Main.qml` owning app metadata and high-level actions.

Dock state is a mix of external app state from `AppLauncher` and internal panel state from `Main.qml`. Internal apps such as uNexus Files, uNexus Settings and Game Settings report `active` only while their panel is open, so the dock can return to a closed visual state after the panel closes. Dock buttons also expose a minimized/hidden visual state for external windows when the compositor reports them that way.

Dock icon behavior:

- real app icons are resolved through `AppLauncher::findIcon`;
- if the current icon theme does not provide an app icon, `DockButton.qml` draws a compact line-art fallback;
- both system and gaming docks use the active theme accent.

---

## Visual Identity and Assets

Official uNexus logo PNG variants live in `assets/logo`. Official wallpaper PNGs live in `assets/wallpapers`.

The base visual system starts in `qml/DesignTokens.qml`. `Main.qml` binds those tokens into root aliases for spacing, radius, motion, typography, surfaces, borders, text, shadows and status colors. Panels should prefer the root aliases so visual changes can be made centrally.

`qml/LiquidGlass.qml` is the first material layer for the long-term Liquid Glass direction. It gives docks, menus and notifications a shared translucent/depth treatment today, while leaving a stable QML API for future shader or compositor-backed blur/refraction.

Motion is tokenized as well. Panel entrance/dismissal and dock interaction use QML spring physics for position, scale and size, while opacity stays on short timed fades. This keeps motion fast and tactile instead of decorative.

`Main.qml` exposes a shared `brandLogoSource` property pointing at:

```qml
qrc:/UNexusShell/assets/logo/SF%20White.png
```

`Main.qml` also exposes a default `desktopWallpaperSource` pointing at:

```qml
qrc:/UNexusShell/assets/wallpapers/unexus-core.png
```

The first wallpaper set includes:

- `unexus-core.png`;
- `particle-drift.png`;
- `aurora-ice.png`;
- `ember-circuit.png`.

`packages/unexus-shell/CMakeLists.txt` registers logo and wallpaper assets through Qt resources so QML can load them at runtime without depending on absolute filesystem paths. Wallpapers are also installed to `${CMAKE_INSTALL_DATADIR}/unexus/wallpapers`.

The current logo is used on:

- desktop center mark;
- login screen;
- Settings About section;
- README hero.

The First Setup header intentionally no longer includes a small logo badge; the panel is kept text-first and minimal. Old screenshot/demo assets with previous branding were removed from tracked media.

---

## App Launching and Window Control

`AppLauncher` is the central bridge between QML and the real desktop session.

Current responsibilities:

- launch apps with `QProcess::startDetached`;
- detect native commands with `QStandardPaths::findExecutable`;
- detect Flatpak apps with `flatpak info`;
- start real Flatpak installs for approved gaming launcher IDs;
- copy helper commands to the clipboard;
- focus existing windows before opening duplicate instances;
- close windows through Hyprland when available;
- maximize windows through Hyprland;
- move windows to the next workspace;
- minimize windows to a Hyprland special workspace and restore them;
- expose active workspace data for the shell UI;
- expose a window preview direction hint for future compositor integration;
- fall back to `wmctrl`, `pgrep` and `pkill` where useful;
- launch gaming apps through MangoHud and GameMode when requested.

Hyprland is the primary target:

```bash
hyprctl clients -j
hyprctl dispatch focuswindow address:<address>
hyprctl dispatch closewindow address:<address>
hyprctl dispatch fullscreen 1
hyprctl dispatch movetoworkspace <workspace>,address:<address>
hyprctl dispatch movetoworkspacesilent special:minimized,address:<address>
```

---

## Global Shortcuts

Global shell shortcuts are handled through Hyprland binds that call:

```bash
unexus-shell --shortcut launcher
unexus-shell --shortcut settings
unexus-shell --shortcut gameSettings
unexus-shell --shortcut stats
```

`GlobalShortcuts` writes and watches a small command file under the runtime directory. The running shell receives the command and opens the matching panel/toggle without starting a duplicate UI instance.

Default shortcuts:

| Shortcut | Action |
|---|---|
| `Super+S` | Launcher |
| `Super+I` | Settings |
| `Super+G` | Stats overlay |
| `Super+Alt+G` | Game Settings |

Settings includes a shortcut editor, explicit apply buttons, default restore and a help panel.

---

## Gaming Architecture

### Game Mode

Game Mode is exposed through `gameMode` and controlled from the top bar and Game Settings panel.

When Game Mode is active, gaming apps can be launched through:

```bash
mangohud gamemoderun <app>
```

For Steam game launch options, the shell can copy:

```bash
mangohud gamemoderun %command%
```

### Gaming Launchers

The launcher and gaming dock support:

- Steam;
- Lutris;
- Heroic Games Launcher;
- Bottles.

Each app can define:

- native command;
- Flatpak app ID;
- Hyprland window classes;
- process names;
- gaming flag.

Game Settings can start real Flatpak installs for those supported launcher IDs. Native/pacman installs are not automated yet.

### MangoHud

MangoHud is currently integrated as a launch wrapper for gaming apps and documented in the Game Settings / First Setup panels.

The internal `FpsOverlay.qml` is a shell stats overlay, not a replacement for MangoHud's in-game overlay.

---

## System Stats

`SystemStats` updates every second.

Current metrics:

- CPU usage from `/proc/stat`;
- GPU usage from DRM sysfs when available;
- NVIDIA fallback through `nvidia-smi`;
- GPU temperature when exposed by hardware;
- RAM usage through Linux memory APIs.

If GPU metrics are unavailable, QML displays `N/A` instead of stale values.

---

## User Settings

`UserSettings` stores persistent preferences through `QSettings`.

Current settings:

- selected theme index;
- selected interface language (`en` or `pt-BR`);
- stats overlay visibility;
- persistent notification preference;
- global shortcut strings for Launcher, Settings, Game Settings and stats overlay;
- first setup completion state;
- active Settings control center section.

These values are restored when `unexus-shell` starts.

---

## OS Session and Control Layer

The installed OS-facing layer is intentionally simple and shell-script based for now.

| File | Purpose |
|---|---|
| `packaging/linux/unexus-session` | Normal Hyprland session wrapper that starts `unexus-shell` and logs failures |
| `packaging/linux/unexus-recovery-session` | Terminal-only Hyprland recovery session |
| `packaging/linux/unexus.desktop` | Display manager session entry |
| `packaging/linux/unexus-recovery.desktop` | Display manager recovery session entry |
| `scripts/unexus-doctor.sh` | Install and dependency validator |
| `scripts/unexusctl.sh` | User control command for state, diagnostics, logs, backup, rollback and update |

The normal session generates a Hyprland config in:

```text
${XDG_RUNTIME_DIR:-/tmp}/unexus/hyprland.conf
```

Persistent logs live in:

```text
~/.local/state/unexus/logs/
```

The recovery session starts Hyprland with only a terminal and basic keybinds, giving a safe path back into the system if the shell breaks.

---

## uNexus Control CLI

`unexusctl` is the command-line control surface for the OS layer.

Current commands:

| Command | Purpose |
|---|---|
| `unexusctl init` | Create XDG config/data/cache/state/log directories |
| `unexusctl paths` | Print all uNexus state and log paths |
| `unexusctl doctor` | Run `unexus-doctor` and save `doctor.log` |
| `unexusctl session-info` | Show session, runtime and binary paths |
| `unexusctl reset-settings` | Move shell settings aside safely |
| `unexusctl logs` | Print log locations |
| `unexusctl backup` | Snapshot user config controlled by uNexus |
| `unexusctl rollback [backup]` | Restore a uNexus-created config backup |
| `unexusctl update --yes` | Pull, build and install from the Git repository |
| `unexusctl version` | Show repo, branch, commit and shell binary status |

The next architectural step is to add `unexusctl provision` so future provisioning UI can apply named profiles instead of copying individual commands.

---

## Settings Control Center

`SettingsPanel.qml` uses section navigation with persisted active section:

- System;
- Appearance;
- Language;
- Shortcuts;
- Help;
- About.

The previous OS Provisioning checklist was removed from Settings to keep the control center cleaner. System-level provisioning should return later through a safer backend such as `unexusctl provision` with manifests, dry-run output and explicit privilege boundaries.

Settings currently controls shell preferences such as theme, language, stats overlay visibility, notification behavior and shortcut strings. The shortcut section includes explicit apply buttons, default shortcut restore and a help panel that lists global shell and uNexus Files keyboard shortcuts.

---

## Localization

The current localization layer lives in `Main.qml`.

QML uses:

- `root.tr("English string")` for direct interface strings;
- `root.trAppMessage(...)` and `root.trLabelMessage(...)` for small templated notifications;
- `userSettings.languageCode` to persist the selected language.

The first localized target is PT-BR. English remains the source/fallback language, so internal app metadata and logic can continue using stable English keys while display text is translated at render time.

The language selector is available in `SettingsPanel.qml`.

---

## uNexus Files

`FileManager` provides the backend for `FilesPanel.qml`.

Current responsibilities:

- expose the home path and common places;
- list readable directory entries;
- classify files by kind;
- open files through `QDesktopServices`;
- create folders;
- rename files/folders;
- copy selected paths;
- cut/move selected paths;
- paste into the current directory;
- show richer preview/details metadata;
- multi-select rows from QML;
- move files/folders to trash through `gio trash` when available.

uNexus Files is currently an embedded panel, not a standalone process. Its dock state is driven by the panel's `dockActive` property. The panel supports common desktop shortcuts such as Ctrl+C, Ctrl+X, Ctrl+V, Ctrl+A, Delete, Return, F2 and Escape, plus a right-click context menu for rows and blank list space.

---

## First Setup

`FirstSetupPanel.qml` gives the user a checklist for core gaming dependencies:

- Flatpak;
- MangoHud;
- GameMode;
- Steam;
- Lutris;
- Heroic;
- Bottles.

It shows install status and still copies manual commands for dependencies that are not safe to install automatically yet. Game Settings separately starts real Flatpak installs for the supported gaming launchers.

---

## Components

| Component | Current status |
|---|---|
| `unexus-shell` | Implemented as the main Qt/QML app |
| `unexus-dock` | Implemented through `SideDock.qml` and `DockButton.qml` |
| `unexus-launcher` | Implemented in `Launcher.qml` |
| `unexus-settings` | Implemented as `SettingsPanel.qml` and `GameSettingsPanel.qml` |
| `unexus-store` | Planned |
| `unexus-files` | Rich embedded file manager panel backed by `FileManager` |
| `unexusctl` | Implemented as the current OS control CLI |
| `unexus-recovery-session` | Implemented as the safe session fallback |

---

## Communication

Components communicate through:

- Qt signals and slots;
- QML context properties;
- Linux process APIs;
- Hyprland command-line IPC through `hyprctl`;
- runtime command files for global shortcut dispatch.

Future versions may add D-Bus or direct compositor protocols where needed.

---

## Future Direction

Near-term architecture work:

- add `unexusctl provision` with manifest-driven profiles and dry-run;
- design a safer provisioning UI after the backend exists;
- add systemd user service definitions for session health and startup tasks;
- move repeated app metadata into a model or config file;
- evolve Liquid Glass from a QML material into shader/compositor-backed blur and refraction;
- build a graphical double-click installer while keeping `setup.sh` as the dev/recovery path;
- harden the existing `ISO/0.0.1` Archiso profile with boot polish, hardware validation and installer integration;
- eventually replace ad hoc command wrappers with stronger service APIs.

Long term, uNexus may grow beyond a Hyprland-based shell toward a custom compositor/window manager tailored for gaming.

---

<sub>Architecture is a living document. It evolves as uNexus grows.</sub>
