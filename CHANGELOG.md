# Changelog

All notable changes to uNexus will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added
- Project website link: <https://unexus-os.vercel.app>.
- First bootable `archiso` live image profile under `ISO/0.0.1`.
- ISO build script that stages the repository into the live image and writes output to `ISO/0.0.1/out/`.
- USB writing helper with block-device validation, target display and explicit `WRITE` confirmation.
- Live ISO autologin flow for the `unexus` user on tty1.
- Archiso boot loader files for current systemd boot mode and BIOS/syslinux support.
- Live ISO packages for graphical Polkit authentication, Noto fonts, emoji fallback and disk recovery tools.
- Live ISO icon stack with Papirus, Breeze, Adwaita, hicolor, Qt SVG/imageformats and desktop/MIME metadata support.
- Official wallpaper set under `assets/wallpapers`: `unexus-core`, `particle-drift`, `aurora-ice` and `ember-circuit`.
- Wallpaper resources registered in Qt and installed to the uNexus data directory.
- Windows-style global shortcuts for Launcher, Settings, Game Settings and stats overlay.
- Shortcut customization, explicit apply buttons, default restore and shortcut help panel in uNexus Settings.
- Real Flatpak install start actions for Steam, Lutris, Heroic and Bottles in Game Settings.
- Extra uNexus Files keyboard shortcuts and blank-space context-menu behavior.
- Installable `uNexus` and `uNexus Recovery` Wayland sessions.
- `unexus-doctor` install validation command and `unexusctl` state/log/update helpers.
- Animated Plymouth boot splash for the live ISO.
- `uNexus Recovery Shell` TUI menu that opens automatically after shell crashes.
- Graphical Qt/QML installer wizard with readiness checks, install options, progress steps and backend log view.
- Installer provisioning for target user groups, Hyprland defaults, Flathub, GameMode/MangoHud, default gaming launchers and safe boot defaults.
- Post-install welcome quick actions in the graphical installer.
- Stable/beta update channel preference in Settings > About.
- Integrated bug report generator available through `Super+B`.

### Changed
- Documentation now treats the bootable ISO as an existing 0.0.1 foundation instead of a purely future path.
- `unexus-session` starts the KDE Polkit authentication agent when it is installed.
- `unexus-session` and `unexus-recovery-session` now export consistent Qt/GTK style, icon and cursor defaults.
- uNexus Shell now sets a default Qt icon theme and hicolor fallback at startup.
- README Feature Status was reduced to the latest shipping focus instead of the full feature inventory.
- Settings documentation now reflects the removal of the old OS Provisioning checklist.
- Main desktop now uses the official `unexus-core` wallpaper image under the animated background layer.
- Settings now focuses on shell preferences, shortcuts, help, language and About.
- Game Settings now starts supported Flatpak installs instead of only copying commands.
- uNexus Files panel layout, context-click behavior and shortcut handling were tightened.
- Shell session packaging now includes stronger logging/recovery behavior.
- `uNexus Recovery` now starts the recovery TUI instead of a plain terminal-only fallback.
- Visual language is now documented through tokenized spacing, typography, surfaces and motion.

### Removed
- Old tracked screenshots and demo GIFs with previous branding.
- OS Provisioning checklist from uNexus Settings.
- First Setup dock item from the system dock.

### Planned
- `unexusctl provision` profiles with dry-run support.
- GPU driver manager.
- Controller support out of the box.
- Per-game performance profiles.
- Graphical installer MVP.
- ISO hardware validation, boot polish and disk installer integration.

---

## [0.3.0] - 2026-05-31

### Added
- Dual boot Arch Linux + Hyprland on real hardware.
- uNexus Shell running natively on Hyprland.
- AppLauncher C++ class with real app detection.
- `isWindowOpen` via hyprctl and wmctrl fallback.
- `isProcessRunning` via pgrep.
- `focusWindow` and `focusOrLaunch` via hyprctl.
- `closeWindow` via hyprctl.
- Dock active indicator based on real process state.
- Right-click dock menu with Open/Focus and Close actions.
- Steam and Lutris in launcher with installed/not installed status.
- Flatpak fallback for gaming apps.
- Emoji icons via noto-fonts-emoji.
- Exo 2 font installed on real hardware.

### Fixed
- AppLauncher header contained implementations causing MOC errors.
- Right-click on dock was leaking to desktop context menu.
- `closeWindow` missing implementation caused linker errors.

### Environment
- Moved from Ubuntu VM to Arch Linux + Hyprland on real hardware.
- `hyprctl` now available and functional.
- Sudo password issue resolved through keyboard-layout correction.

---

## [0.2.0] - 2026-05-30

### Changed
- Project scope shifted to a gaming-focused OS.
- Updated philosophy around effortless Linux gaming.
- Rewrote README, roadmap and architecture docs for gaming focus.

### Added
- Real battery indicator via C++ (`SystemInfo` class).
- Real network indicator via C++ (`SystemInfo` class).
- Login screen with avatar, clock and password field.
- uNexus Launcher with search and categories.
- Right-click context menu on desktop.
- Notification system with auto-dismiss.
- Active app indicator on dock.
- Bounce animation on dock item click.
- Geometric wallpaper with glow effects.
- Tooltip above dock items.
- Game Mode toggle via gamemoded.

---

## [0.1.0] - 2026-05-30

### Added
- Initial monorepo structure.
- `unexus-shell` component with CMake + Qt6 build system.
- Top bar with live clock and date.
- Minimalist floating dock with 5 app slots.
- Dock hover zoom effect.
- Entrance animations on startup.
- Center logo with tagline.
- Initial visual identity.

### Docs
- README with screenshots and demo GIF.
- Architecture document.
- Roadmap document.
- Contributing guide.
- Building guide.

---

<sub>uNexus - built for gamers. Powered by Linux.</sub>
