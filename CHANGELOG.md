# Changelog

All notable changes to uNexus will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added
- uNexus Files MVP with local directory navigation, places sidebar, file opening, folder creation, rename and move-to-trash actions.
- System and gaming side dock app states for open, minimized/hidden and closed apps.
- PT-BR interface localization with English/PT-BR language selection in uNexus Settings.
- Persistent language preference through `QSettings`.

### Changed
- Launcher, dock, settings, game settings, first setup, context menu, login, stats overlay and uNexus Files now route user-facing text through the shell localization helper.
- Internal panel dock state is recalculated when panels open/close so closed internal apps no longer remain visually active.

### Planned
- Game Mode (auto performance boost)
- GPU driver manager
- FPS overlay with MangoHud
- Steam / Lutris integration
- Controller support out of the box
- Per-game performance profiles
- Close window via hyprctl
- Auto-start uNexus Shell on login

---

## [0.3.0] — 2026-05-31

### Added
- Dual boot Arch Linux + Hyprland on real hardware
- uNexus Shell running natively on Hyprland
- AppLauncher C++ class with real app detection
- `isWindowOpen` via hyprctl and wmctrl fallback
- `isProcessRunning` via pgrep
- `focusWindow` and `focusOrLaunch` via hyprctl
- `closeWindow` via hyprctl (functional on Hyprland)
- Dock active indicator based on real process state
- Right-click dock menu with Open/Focus and Close actions
- Steam and Lutris in launcher with installed/not installed status
- Flatpak fallback for gaming apps
- Emoji icons via noto-fonts-emoji
- Exo 2 font installed on real hardware

### Fixed
- AppLauncher header contained implementations causing MOC errors
- Right-click on dock was leaking to desktop context menu
- closeWindow missing implementation causing linker error

### Environment
- Moved from Ubuntu VM to Arch Linux + Hyprland on real hardware
- hyprctl now available and functional
- sudo password issue resolved (keyboard layout)

---

## [0.2.0] — 2026-05-30

### Changed
- Project scope shifted to gaming-focused OS
- Updated philosophy: "Gaming on Linux should be effortless"
- Rewrote README, roadmap and architecture docs for gaming focus

### Added
- Real battery indicator via C++ (`SystemInfo` class)
- Real network indicator via C++ (`SystemInfo` class)
- Login screen with avatar, clock and password field
- uNexus Launcher with search and categories (All, System, Media)
- Right-click context menu on desktop
- Notification system with auto-dismiss (4s)
- Active app indicator on dock (blue dot)
- Bounce animation on dock item click
- Geometric wallpaper with glow effects
- Tooltip above dock items (RocketDock style)
- Game Mode toggle via gamemoded

---

## [0.1.0] — 2026-05-30

### Added
- Initial monorepo structure
- `unexus-shell` component with CMake + Qt6 build system
- Top bar with live clock and date
- Minimalist floating dock with 5 app slots
- Dock hover zoom effect
- Entrance animations on startup (fade + slide)
- Center logo with tagline
- Initial visual identity (dark theme, blue accent #4d9eff)

### Docs
- README with screenshots and demo GIF
- Architecture document
- Roadmap document
- Contributing guide
- Building guide

---

<sub>uNexus — built for gamers. Powered by Linux.</sub>
