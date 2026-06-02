# PED OS Architecture

This document describes the current technical architecture of PED OS.

---

## Overview

PED OS is a Linux gaming desktop shell built on top of Wayland and Hyprland.

The current prototype is `ped-shell`, a Qt6/QML application with C++ backends for system information, app launching, window control, Game Mode, stats and persistent user settings.

---

## Layer Stack

```text
+--------------------------------------+
| Games and gaming launchers           |
| Steam, Lutris, Heroic, Bottles        |
+--------------------------------------+
| PED Shell UI                         |
| Main, docks, launcher, settings      |
+--------------------------------------+
| Qt6 / QML                            |
+--------------------------------------+
| C++ integration layer                |
| SystemInfo, AppLauncher, Stats       |
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
| `appLauncher` | `AppLauncher` | Launch, focus, close and detect apps |
| `systemStats` | `SystemStats` | CPU, GPU, RAM and temperature stats |
| `userSettings` | `UserSettings` | Persistent shell preferences |

The QML layer calls these objects directly from `Main.qml`, `Launcher.qml`, `SettingsPanel.qml`, `GameSettingsPanel.qml`, `FirstSetupPanel.qml` and `FpsOverlay.qml`.

---

## Main QML Surface

`qml/Main.qml` coordinates the shell:

- theme selection and persistence;
- wallpaper and particles;
- top bar;
- login flow;
- system side dock;
- gaming side dock;
- dock action menu;
- launcher;
- desktop context menu;
- notifications;
- stats overlay;
- PED Settings;
- Game Settings;
- First Setup.

The current dock is still embedded in `Main.qml`; it can later be extracted into a standalone QML component.

---

## App Launching and Window Control

`AppLauncher` is the central bridge between QML and the real desktop session.

Current responsibilities:

- launch apps with `QProcess::startDetached`;
- detect native commands with `QStandardPaths::findExecutable`;
- detect Flatpak apps with `flatpak info`;
- copy helper commands to the clipboard;
- focus existing windows before opening duplicate instances;
- close windows through Hyprland when available;
- fall back to `wmctrl`, `pgrep` and `pkill` where useful;
- launch gaming apps through MangoHud and GameMode when requested.

Hyprland is the primary target:

```bash
hyprctl clients -j
hyprctl dispatch focuswindow address:<address>
hyprctl dispatch closewindow address:<address>
```

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
- stats overlay visibility;
- first setup completion state.

These values are restored when `ped-shell` starts.

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

It shows install status and copies install commands for the user to run.

---

## Components

| Component | Current status |
|---|---|
| `ped-shell` | Implemented as the main Qt/QML app |
| `ped-dock` | Embedded in `Main.qml` |
| `ped-launcher` | Implemented in `Launcher.qml` |
| `ped-settings` | Implemented as `SettingsPanel.qml` and `GameSettingsPanel.qml` |
| `ped-store` | Planned |
| `ped-files` | Planned; current shell launches external file managers |

---

## Communication

Components communicate through:

- Qt signals and slots;
- QML context properties;
- Linux process APIs;
- Hyprland command-line IPC through `hyprctl`.

Future versions may add D-Bus or direct compositor protocols where needed.

---

## Future Direction

Near-term architecture work:

- split the docks into dedicated QML components;
- move repeated app metadata into a model or config file;
- package `ped-shell` for Arch;
- start an `archiso` profile;
- eventually replace ad hoc command wrappers with stronger service APIs.

Long term, PED OS may grow beyond a Hyprland-based shell toward a custom compositor/window manager tailored for gaming.

---

<sub>Architecture is a living document. It evolves as PED OS grows.</sub>
