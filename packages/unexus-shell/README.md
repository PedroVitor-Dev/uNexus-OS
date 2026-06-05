# unexus-shell

Main Qt6/QML desktop interface of uNexus.

## Current Scope

`unexus-shell` owns the desktop wallpaper, top bar, side docks, launcher, Settings, Game Settings, uNexus Files, notifications, login flow, stats overlay and Hyprland-facing window controls.

Recent shell work includes:

- official logo and wallpaper resources;
- shared visual-language tokens;
- Liquid Glass surfaces and spring motion;
- Windows-style global shortcuts through `unexus-shell --shortcut`;
- real Flatpak install actions for supported gaming launchers;
- richer uNexus Files actions, context menu and keyboard shortcuts;
- installable `uNexus` and `uNexus Recovery` Wayland sessions.

## Build

```bash
cmake -B build
cmake --build build
```

## Run

```bash
./build/unexus-shell
```

Use the root [building guide](../../docs/building.md) for Arch/Hyprland dependency and install-session notes.

## Stack

- C++20
- Qt6 / QML
- CMake
- Hyprland / Wayland integration
