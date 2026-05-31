# Changelog

All notable changes to PED OS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Planned
- Game Mode (auto performance boost)
- GPU driver manager
- FPS overlay
- Steam / Lutris integration
- Controller support out of the box
- Per-game performance profiles

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
- PED Launcher with search and categories (All, System, Media)
- Right-click context menu on desktop
- Notification system with auto-dismiss (4s)
- Active app indicator on dock (blue dot)
- Bounce animation on dock item click
- Geometric wallpaper with glow effects
- Tooltip above dock items (RocketDock style)

---

## [0.1.0] — 2026-05-30

### Added
- Initial monorepo structure
- `ped-shell` component with CMake + Qt6 build system
- Top bar with live clock and date
- Minimalist floating dock with 5 app slots
- Dock hover zoom effect
- Entrance animations on startup (fade + slide)
- Center logo with tagline "the OS should disappear."
- Initial visual identity (dark theme, blue accent #4d9eff)

### Docs
- README with screenshots and demo GIF
- Architecture document
- Roadmap document
- Contributing guide
- Building guide

---

<sub>PED OS — built for gamers. Powered by Linux.</sub>
