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
- Redesigned uNexus Files with stronger sidebar, grid/list controls, operation queue and bottom status bar.
- Windows-style rubber-band selection in uNexus Files list and grid views.
- Selectable desktop area with shortcut icons, click selection, double-click launch and rubber-band selection.
- uNexus Files preview engine for image, text, PDF and video previews without opening external apps.
- Arch package release helper that emits package artifacts and a local pacman repository under `dist/arch`.
- Distro implementation status document mapping the shell-to-ISO guide to repository state.
- Hardware section in Settings showing GPU, VRAM, active driver, kernel and Mesa versions.
- GPU detection through `lspci` with NVIDIA, AMD, Intel and virtual-driver recommendations.
- uNexus Driver Wizard for guided GPU driver switching with boot-confirmed rollback protection.
- First Setup GPU Driver Manager panel with NVIDIA driver install action, hybrid-GPU messaging and Secure Boot warning.
- Polkit policy metadata for privileged uNexus GPU driver installation.
- Startup loading screen with animated uNexus logo while shell backends finish initialization.
- Actionable notification queue with Open, Dismiss, Silence 1h, clear controls and configurable timeout persistence.
- Installation milestone status document covering packaging, ISO installer, sessions, VM/hardware validation and First Setup readiness.
- Minimal native Qt/QML disk-install UI in `unexus-installer` that previews and executes `scripts/install-os.sh` through `pkexec`.
- Disk install screen with detected disk selection, first-user configuration and visible install progress.
- QEMU UEFI smoke-test result record under `docs/test-results/20260615-qemu.md`.
- Internal `uNexus CMD` terminal panel with command output, history, `cd`, `clear`, stop control and dock integration.
- Privacy-first `uNexus AI` assistant MVP with local llama-server engine wrapper, streaming chat UI and no remote fallback.
- AI privacy controls in Settings for opt-in local system context and opt-in disk history.
- Explicit `setup-ai-model.sh` helper for local GGUF model installation and checksum-gated curated downloads.
- First Setup controls for refreshing installed GGUF models and starting/stopping the local uNexus AI engine.

### Changed
- Documentation now treats the bootable ISO as an existing 0.0.2 foundation instead of a purely future path.
- Documentation now points current ISO build, USB, VM and release validation flows at `ISO/0.0.2`.
- ISO VM smoke and release validation scripts now default to the 0.0.2 image path.
- Native disk install repository copy now excludes `ISO/0.0.2` build and output directories.
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
- Desktop shortcuts are no longer shown by default, keeping the desktop surface clean while preserving wallpaper, context menu and selection behavior.
- The system dock terminal entry now opens the internal `uNexus CMD` panel instead of depending on an external terminal app.
- Documentation now defines the uNexus AI threat model, local-only architecture and model lifecycle.
- Optional uNexus AI history persistence now uses structured local JSON instead of plain text.

### Removed
- Old tracked screenshots and demo GIFs with previous branding.
- OS Provisioning checklist from uNexus Settings.
- First Setup dock item from the system dock.
- Default desktop shortcut icons.

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
