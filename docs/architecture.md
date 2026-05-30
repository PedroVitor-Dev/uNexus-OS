# PED OS Architecture

This document describes the technical architecture of PED OS.

---

## Overview

PED OS is a Linux-based desktop operating system built on top of Wayland,
using a customized Hyprland compositor and a Qt/QML interface layer.

---
## Layer Stack

```
┌─────────────────────────────────────┐
│           User Applications         │
├─────────────────────────────────────┤
│         PED Shell Components        │
│  (Dock, Launcher, Settings, Store)  │
├─────────────────────────────────────┤
│         Qt / QML Interface          │
├─────────────────────────────────────┤
│      Hyprland Compositor (fork)     │
├─────────────────────────────────────┤
│         Wayland Display Server      │
├─────────────────────────────────────┤
│       Vulkan / OpenGL Rendering     │
├─────────────────────────────────────┤
│            Linux Kernel             │
└─────────────────────────────────────┘
```

## Components

### ped-shell
Main desktop interface. Manages the overall layout, wallpaper, top bar,
dock and coordinates all other components.

**Current implementation:**
- Top bar with live clock and date
- Minimalist floating dock
- Dock hover zoom effect
- Dock tooltip on hover
- Dock bounce animation on click
- Entrance animations on startup

### ped-dock
Minimalist application dock. Handles pinned apps, running indicators and
smooth animations. Currently embedded in ped-shell, will be extracted
as a standalone component.

### ped-launcher
Universal search and app launcher. Keyboard-driven, fast and minimal.

### ped-settings
System control panel. Manages themes, display, network, audio and system
preferences.

### ped-store
Application store. Handles discovery, installation and updates of packages.

### ped-files
File manager. Clean, fast and keyboard-friendly.

---

## Communication

Components communicate via:
- **D-Bus** — system-level signals and inter-process communication
- **Wayland protocols** — compositor and window management
- **Qt signals/slots** — internal component communication

---

## Languages

| Layer | Language |
|---|---|
| Core system | Rust |
| Compositor integration | C++ |
| Interface | QML |
| Scripts & tooling | Bash, Python |

---

## Future: PEDWM

The long-term goal is to replace the Hyprland fork with **PEDWM**,
a compositor written from scratch tailored specifically for PED OS,
with deeper integration and full control over the rendering pipeline.

---

<sub>Architecture is a living document — it evolves as PED OS grows.</sub>
