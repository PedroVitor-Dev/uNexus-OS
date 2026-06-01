<div align="center">
  <h1>PED OS</h1>
  <p>A Linux-based operating system built for gamers. Fast, clean, and optimized for gaming.</p>

  ![Status](https://img.shields.io/badge/status-in%20development-blue)
  ![License](https://img.shields.io/badge/license-GPL--3.0-white)
  ![Platform](https://img.shields.io/badge/platform-Linux-black)
  ![Focus](https://img.shields.io/badge/focus-Gaming-red)
  ![Environment](https://img.shields.io/badge/environment-Arch%20%2B%20Hyprland-purple)

  <br/>

  <img src="assets/screenshots/desktop.png" width="800" alt="PED OS Desktop"/>

  <br/><br/>

  <img src="assets/demo/MP4PEDOS.gif" width="800" alt="PED OS Demo"/>
</div>

---

## Philosophy

> "Gaming on Linux should be effortless. No tweaking. No struggling. Just play."

PED OS is built around one goal: give gamers the best possible Linux experience out of the box.

---

## Why PED OS?

- **Zero configuration** — gaming optimizations applied by default
- **Clean and fast** — no bloat, no unnecessary services
- **Game-first design** — every decision prioritizes gaming performance
- **Open source** — community-driven, forever free
- **Built on Hyprland** — modern Wayland compositor, smooth and lightweight

---

## Current State

PED OS Shell is currently running natively on **Arch Linux + Hyprland** on real hardware.
The shell manages the desktop, dock, launcher, notifications and system indicators.
Window management (focus, close) is handled via `hyprctl`.

---

## Features

| Feature | Status |
|---|---|
| Login screen with avatar | ✅ |
| Geometric wallpaper with particles | ✅ |
| Top bar with clock & date | ✅ |
| Network indicator (real data) | ✅ |
| Battery indicator (real data) | ✅ |
| Game Mode toggle (real gamemoded) | ✅ |
| Minimalist dock | ✅ |
| Dock hover zoom | ✅ |
| Dock tooltip | ✅ |
| Dock bounce on click | ✅ |
| Active app indicator (real process) | ✅ |
| Focus running app from dock | ✅ |
| Close app from dock (hyprctl) | ✅ |
| Entrance animations | ✅ |
| PED Launcher with search | ✅ |
| Launcher Gaming category | ✅ |
| Steam/Lutris installed detection | ✅ |
| Flatpak fallback for gaming apps | ✅ |
| Right-click context menu | ✅ |
| Notification system | ✅ |
| GPU driver manager | 🔜 |
| FPS overlay (MangoHud) | 🔜 |
| Per-game performance profiles | 🔜 |
| Auto-start on login | 🔜 |

---

## Screenshots

<div align="center">

### Login Screen
<img src="assets/screenshots/tela_de_login.png" width="800" alt="PED OS Login Screen"/>

### Desktop
<img src="assets/screenshots/desktop.png" width="800" alt="PED OS Desktop"/>

### Launcher
<img src="assets/screenshots/laucher.png" width="800" alt="PED OS Launcher"/>

### Context Menu
<img src="assets/screenshots/menu_de_contexto.png" width="800" alt="PED OS Context Menu"/>

</div>

---

## Stack

| Layer | Technology |
|---|---|
| Kernel | Linux |
| Display Server | Wayland |
| Compositor | Hyprland |
| Rendering | Vulkan / OpenGL |
| Core | Rust, C++ |
| Interface | Qt6 / QML |
| Build System | CMake 3.20+ |
| Font | Exo 2 |

---

## Components

| Package | Description |
|---|---|
| `ped-shell` | Main desktop interface |
| `ped-dock` | Minimalist dock |
| `ped-launcher` | Universal search & app launcher |
| `ped-settings` | Control panel |
| `ped-store` | App store |
| `ped-files` | File manager |

---

## Roadmap

- [x] Phase 1 — Foundation
- [ ] Phase 2 — Real Interface
- [ ] Phase 3 — Gaming Core
- [ ] Phase 4 — Public Alpha

---

## Contributing

See [docs/contributing.md](docs/contributing.md).

---

<div align="center">
  <sub>Built for gamers. Powered by Linux.</sub>
</div>