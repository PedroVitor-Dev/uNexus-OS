# uNexus Roadmap

> **Philosophy:** Open Source. Linux Powered. Gamer Focused.
> Each phase balances three tracks:
> - **UI**: visual design, experience, animation and identity
> - **Feature**: real functionality users can feel immediately
> - **Innovation**: original ideas that make uNexus distinct

---

## Status Legend

| Status | Meaning |
|---|---|
| `[x]` | Done |
| `[~]` | In progress / partially implemented |
| `[ ]` | Planned |

---

## Current State (June 2026)

Project website: <https://unexus-os.vercel.app>

### Already Done

- [x] Qt6/QML shell running on Hyprland on real hardware
- [x] Login screen with password, avatar and clock
- [x] Animated geometric wallpaper with particles
- [x] Top bar with clock, network, battery and GameMode
- [x] System dock and gaming dock with visual states
- [x] Launcher with search, categories and Steam/Lutris/Heroic/Bottles detection
- [x] CPU/GPU/RAM/TEMP overlay
- [x] uNexus Settings and Game Settings prototypes
- [x] uNexus Files MVP with navigation, folder creation, rename and trash actions
- [x] PT-BR / English localization persisted through `QSettings`
- [x] Installable Wayland sessions (`uNexus` and `uNexus Recovery`) and Hyprland autostart support
- [x] Official logo assets and wallpaper set integrated into the shell
- [x] Design tokens documented for spacing, radius, typography, surfaces and motion
- [x] Liquid Glass applied to docks, menus and notifications
- [x] Spring motion in panels and dock interactions
- [x] Windows-style global shortcuts for Launcher, Settings, Game Settings and stats overlay
- [x] Wallpaper selector in Settings > Appearance with `QSettings` persistence
- [x] Game Settings starts real Flatpak installs for supported launchers
- [x] `unexusctl`, `unexus-doctor`, `PKGBUILD`, `.desktop` and session files exist
- [x] Bootable `ISO/0.0.1` Archiso live profile exists with Hyprland, uNexus Shell, autologin, Flatpak, GameMode, MangoHud, Vulkan tools, Polkit agent, fonts and recovery utilities
- [x] USB writer exists with target validation and explicit erase confirmation
- [x] ISO visual baseline includes icon themes, Qt SVG/imageformats, desktop/MIME metadata, font fallbacks and Qt/GTK/cursor session defaults

---

## Phase 1 - Visual Foundation and Daily Trust

**Goal:** make the current shell feel intentional, original and pleasant enough for daily use inside Hyprland.

**Expected result:** a new user can use the shell without reading source code.

- [x] **UI:** Define and document the uNexus design system: spacing, radius, surfaces, Exo 2 typography, motion tokens, Liquid Glass and spring motion
- [x] **Feature:** Add global shortcuts for Launcher (`Super+S`), Settings (`Super+I`), Game Settings (`Super+Alt+G`) and stats overlay (`Super+G`)
- [ ] **Innovation:** **uNexus Pulse:** top bar subtly shifts color based on system load: cool blue while idle, violet during moderate use, amber when CPU/GPU heat rises; no numbers, just passive ambience
- [x] **UI:** Create the first official wallpaper set with 4 PNG artworks (`unexus-core`, `particle-drift`, `aurora-ice`, `ember-circuit`) and a persisted selector in Settings
- [x] **Feature:** Add empty, loading, error and unavailable states to all major panels
- [ ] **Innovation:** **Native Live Wallpaper Engine:** real-time shader wallpapers through QML `ShaderEffect`, with built-in presets and support for user-loaded GLSL
- [x] **UI:** Refine panel transitions with standardized timing/easing, spring motion and responsive laptop/desktop behavior
- [ ] **Feature:** Add actionable notifications: Open, Dismiss and Silence for 1h, with a visible queue and configurable timeout
- [ ] **Innovation:** **uNexus Focus Mode:** `Super+F` dims everything except the active window, useful for streaming, study or distraction-free gaming
- [ ] **UI:** Design a custom SVG app icon pack for the 20 most common apps, using a monochrome accent-driven style
- [x] **Feature:** Add a visible shortcut help/customization panel inside uNexus Settings
- [ ] **Innovation:** **Contextual Dock Intelligence:** gaming dock changes behavior automatically based on whether a game is open

### Exit Criteria - Phase 1

- [~] A clean user can use the shell without reading source code
- [x] All panels have loading/error states
- [x] The design system is documented in `docs/design-tokens.md`
- [x] Keyboard shortcuts work consistently

---

## Phase 2 - Settings That Actually Control the System

**Goal:** turn uNexus Settings and Game Settings from visual prototypes into real control panels.

- [x] **UI:** Redesign Settings as a control center with section navigation and independent scrolling content
- [~] **Feature:** Install Flatpak apps directly from uNexus flows; Game Settings already starts Steam, Lutris, Heroic and Bottles installs, but real progress and Flathub setup are still pending
- [ ] **Innovation:** **uNexus Theme Studio:** visual theme editor with accent color, blur intensity, panel opacity and live preview before applying
- [x] **UI:** Give Game Settings a gamer dashboard style with clear status chips for MangoHud, GameMode, Proton and Flatpak
- [ ] **Feature:** Detect real GameMode service status and expose enable/restart actions safely
- [ ] **Innovation:** **Gaming Environment Profiles:** named profiles such as RPG Marathon, Competitive FPS and Streaming that save GameMode, MangoHud, display and environment choices
- [ ] **UI:** Add theme preview before applying: dock, top bar and sample window rendered in QML
- [ ] **Feature:** Add Flathub remote detection, setup action and synchronization status
- [ ] **Innovation:** **Settings Sync via Git:** export/import `.unexus-config.json` and optionally sync with a private Git repository
- [ ] **UI:** Redesign First Setup as full product onboarding with step progress and persistent checklist state
- [~] **Feature:** Add safe reset settings flow; `unexusctl reset-settings` exists, but Settings still needs the full visual flow and automatic backup
- [ ] **Innovation:** **uNexus Copilot:** fully optional local AI assistant for shell settings, troubleshooting, localization help and guided configuration, using a local model when available and keeping prompts/files on-device by default

### Exit Criteria - Phase 2

- [~] uNexus Settings changes real shell preferences safely
- [~] Game Settings prepares a gaming environment without guessing
- [~] First Setup guides a clean machine toward a usable gaming setup
- [~] Themes persist across restarts; profiles are still planned

---

## Phase 3 - Gaming Core That Feels Real

**Goal:** make uNexus genuinely useful for launching, configuring and monitoring games.

- [ ] **UI:** Create an original Game Library view with cover art, play time, source launcher and status
- [ ] **Feature:** Validate MangoHud with real games and detect when it is active for launched processes
- [ ] **Innovation:** **uNexus GameSense:** analyze MangoHud logs and suggest useful performance adjustments after a session
- [ ] **UI:** Add rich game cards with SteamGridDB art, download progress and Proton compatibility badges
- [ ] **Feature:** Add per-game profiles with toggles for GameMode, MangoHud, custom resolution, env vars and pre-launch commands
- [ ] **Innovation:** **Auto Proton Selector:** use Steam AppID and ProtonDB data to recommend the best Proton version
- [ ] **UI:** Add controller status panel with visual controller layout, vibration test and deadzone settings
- [ ] **Feature:** Detect controllers through `evdev`/`udev`, including model and battery when available
- [ ] **Innovation:** **uNexus HeatMap Session:** after closing a game, show temperature/FPS/session summaries saved locally as JSON
- [ ] **UI:** Make the uNexus stats overlay visually distinct from in-game MangoHud
- [ ] **Feature:** Add graphics diagnostics for Vulkan, OpenGL, NVIDIA/AMD/Intel drivers and Mesa versions
- [ ] **Innovation:** **uNexus Stream Mode:** one-click profile that silences notifications, tunes process priority, positions MangoHud and starts OBS minimized

### Exit Criteria - Phase 3

- [~] User can start install/open flows for Steam, Lutris, Heroic and Bottles; clean-machine Flathub validation is still pending
- [ ] At least one real game runs with MangoHud + GameMode detected
- [ ] Per-game profiles save and load correctly
- [ ] The system explains what is missing when the gaming environment is incomplete

---

## Phase 4 - Window Management and Desktop Behavior

**Goal:** make the shell behave less like an overlay and more like an operating-system desktop.

- [x] **UI:** Add visual workspace switcher with window thumbnails and drag-and-drop between workspaces
- [x] **Feature:** Add maximize/restore, move-to-workspace and special workspace actions through `hyprctl dispatch`
- [ ] **Innovation:** **uNexus Spatial Memory:** remember app position, size and workspace per user and restore them on next launch
- [~] **UI:** Workspace indicators exist in the top bar; hover previews with thumbnails are still planned
- [ ] **Feature:** Add dock pin/unpin with persistence
- [ ] **Innovation:** **Native Picture-in-Picture:** turn any window into a floating PiP through `Super+P`
- [~] **UI:** Basic multi-monitor layout rules exist; full per-monitor configuration is still pending
- [ ] **Feature:** Detect monitors through `hyprctl monitors` and expose resolution, refresh rate, HDR status and primary-monitor settings
- [ ] **Innovation:** **uNexus GameScreen:** dedicate a full monitor to a game and move the shell to another monitor automatically
- [ ] **UI:** Add recent apps in Launcher, separated from search results
- [ ] **Feature:** Expand Launcher search beyond apps to recent files, settings and installed games
- [ ] **Innovation:** **uNexus Quick Actions:** `Super+Q` opens a context-aware action HUD

### Exit Criteria - Phase 4

- [ ] User can manage windows without relying on external bars
- [ ] Workspace behavior is stable and understandable
- [ ] Multi-monitor layout persists across sessions
- [ ] Required Hyprland config is reproducible

---

## Phase 5 - uNexus Files as a Complete File Manager

**Goal:** evolve the Files MVP into a file manager that can compete with Nautilus and Dolphin while keeping uNexus-specific advantages.

- [ ] **UI:** Redesign uNexus Files with sidebar, grid/list views and a bottom status bar
- [~] **Feature:** Copy/cut/paste, multi-select and real file actions exist; visible operation queue, per-file progress and worker thread are still pending
- [ ] **Innovation:** **uNexus Files Preview Engine:** render image, video, text and PDF previews without opening external apps
- [~] **UI:** Clickable breadcrumbs exist; per-segment dropdown and direct path editing are still planned
- [ ] **Feature:** Add indexed file search with filters for type, date and size
- [ ] **Innovation:** **Smart Game Data Folder:** detect known game save/config directories and expose them as a virtual Game Data location
- [ ] **UI:** Add visual drag-and-drop with destination highlighting
- [ ] **Feature:** Add archive browsing/extraction for `.zip`, `.tar.gz` and `.7z` through libarchive
- [ ] **Innovation:** **Dual-Pane Mode:** `F3` splits Files into two independent panes
- [ ] **UI:** Add visual custom tags for files/folders persisted in `~/.local/share/unexus/tags.json`
- [x] **Feature:** Add multi-select with copy, cut, paste, rename and trash actions
- [ ] **Innovation:** **Copilot File Organizer:** optional local-only suggestions for finding files, grouping downloads, naming folders and cleaning duplicates without uploading file names or contents
- [ ] **Innovation:** **Cloud Drive Integration:** connect Google Drive, Dropbox or WebDAV through `rclone mount`

### Exit Criteria - Phase 5

- [ ] uNexus Files competes functionally with mainstream file managers
- [ ] File operations do not block the UI
- [ ] Preview works for images, videos and text
- [ ] Search returns results in under 2 seconds

---

## Phase 6 - Notification System and Communication Hub

**Goal:** go beyond passive toasts and create a real system communication center.

- [ ] **UI:** Redesign notification center as a right-side panel with grouped notifications and inline actions
- [ ] **Feature:** Implement `org.freedesktop.Notifications` D-Bus support for external app notifications
- [ ] **Innovation:** **uNexus Smart Notifications:** learn which notifications the user dismisses and suggest silence rules
- [ ] **UI:** Add Do Not Disturb mode with clear top-bar state and scheduling
- [ ] **Feature:** Add useful system notifications for high temperature, low battery, disk usage and available updates
- [ ] **Innovation:** **uNexus Event Timeline:** keep the last 24h of system/game events in a visual timeline

### Exit Criteria - Phase 6

- [ ] External app notifications work through D-Bus
- [ ] Notification center is accessible by shortcut and icon
- [ ] Do Not Disturb works and persists across sessions

---

## Phase 7 - GPU Driver Manager and Hardware Diagnostics

**Goal:** solve one of Linux gaming's biggest pain points: driver management.

- [ ] **UI:** Add Hardware section in Settings with GPU, VRAM, active driver, kernel and Mesa versions
- [ ] **Feature:** Detect GPU through `lspci` and map it to recommended drivers
- [ ] **Innovation:** **uNexus Driver Wizard:** guided GPU driver switching with rollback if the next boot fails
- [ ] **UI:** Add exportable Hardware Report as PDF or JSON
- [ ] **Feature:** Verify 32-bit gaming libraries and offer safe install paths
- [ ] **Innovation:** **uNexus Benchmark Mode:** run `glmark2` or `vkmark` from Settings and show visual results

### Exit Criteria - Phase 7

- [ ] GPU driver is detected correctly on NVIDIA, AMD and Intel
- [ ] Driver Wizard completes driver changes without manual terminal work
- [ ] Gaming library checks work and can install missing components

---

## Phase 8 - Packaging and Installable Shell

**Goal:** stop treating uNexus Shell as a manual project and make it installable.

- [ ] **UI:** Create a startup loading screen with uNexus logo animation while C++ backends initialize
- [x] **Feature:** Create `PKGBUILD`, CMake install target, `.desktop`, Wayland session files and recovery session for reproducible installation
- [ ] **Innovation:** **uNexus Update Manager:** Settings-integrated updater using GitHub Releases and package install progress
- [ ] **UI:** Add clear failure screen for missing Qt/QML resources or backend startup errors
- [ ] **Feature:** Show version and changelog in Settings > About
- [ ] **Innovation:** **uNexus Sandbox Apps:** run untrusted apps through bubblewrap directly from Launcher

### Exit Criteria - Phase 8

- [~] A clean Arch machine can use scripts/PKGBUILD/session files; final dependency packaging validation is still pending
- [x] Installed shell starts from session or `.desktop` entry
- [~] Versioned releases are possible with PKGBUILD

---

## Phase 9 - Bootable uNexus ISO Prototype

**Goal:** create the first bootable USB image that opens into a uNexus session.

- [ ] **UI:** Create Plymouth boot splash with animated uNexus logo
- [x] **Feature:** Create `archiso` profile with Hyprland, Qt6, unexus-shell, Flatpak, MangoHud, GameMode, Vulkan tools, terminal, browser layer and PipeWire
- [ ] **Innovation:** **uNexus Recovery Shell:** automatic TUI recovery menu if the shell crashes
- [~] **UI:** Create first-boot welcome/readiness flow; First Setup opens on first login, while a pre-desktop readiness gate is still planned
- [~] **Feature:** Define default Hyprland config optimized for uNexus and gaming; the session wrapper now generates the live config and starts the Polkit agent when available
- [ ] **Innovation:** **Live Gaming Mode:** bootable ISO can run games directly from live environment with optimizations enabled

### Exit Criteria - Phase 9

- [~] uNexus boots from USB on real hardware; broader hardware validation is pending
- [x] User reaches the shell without manual terminal work through live-user autologin
- [ ] Basic apps open
- [ ] First Setup is visible and useful

---

## Phase 10 - Installer and Public Alpha

**Goal:** turn the bootable prototype into something testers can install and report on.

- [ ] **UI:** Create graphical installer in Qt6/QML or themed Calamares
- [ ] **Feature:** Installer configures user, bootloader, Hyprland session, Flatpak/Flathub, GameMode/MangoHud and default gaming launchers
- [ ] **Innovation:** **uNexus Migration Tool:** detect existing Windows/Linux installs and import Steam saves, game lists and app settings where possible
- [ ] **UI:** Create post-install welcome flow with quick action cards
- [ ] **Feature:** Add stable/beta update channel selection in Settings > About
- [ ] **Innovation:** **Integrated Bug Reporter:** `Super+B` collects logs/specs/version and prepares a GitHub issue report

### Exit Criteria - Phase 10

- [ ] External testers can install uNexus without help
- [ ] At least one common game path works after clean install
- [ ] Bugs can be reported and reproduced
- [ ] Project has a repeatable release process

---

## Phase 11 - Accessibility and Real Internationalization

**Goal:** make uNexus usable beyond Brazilian Arch developers.

- [ ] **UI:** Add high contrast mode and automated color-contrast linting
- [ ] **Feature:** Expand localization to Spanish, English, Portuguese, French and German through Qt `.ts` files and Weblate-friendly workflow
- [ ] **Innovation:** **uNexus Voice Commands:** optional local `Whisper.cpp` voice commands in PT-BR and English
- [ ] **UI:** Add font scaling at 100%, 125% and 150% without layout breakage
- [ ] **Feature:** Add complete keyboard navigation across all panels
- [ ] **Innovation:** **uNexus Adaptive UI:** automatically switch layout for Steam Deck-like devices

### Exit Criteria - Phase 11

- [ ] At least 4 complete languages are available
- [ ] Keyboard navigation works across all main panels
- [ ] High contrast mode passes accessibility linting

---

## Phase 12 - uNexus 1.0: Complete and Distinct OS

**Goal:** consolidate everything into an OS that can replace Windows or SteamOS for real users.

- [ ] **UI:** Complete brand system with logo, palette, motion guide, QML component docs and official screenshots
- [ ] **Feature:** Unified game library across Steam, Lutris, Heroic and Bottles with SteamGridDB art
- [ ] **Innovation:** **uNexus NexLink:** local-network sharing protocol for files, game saves and screen sharing through mDNS discovery
- [ ] **UI:** Community theme gallery in Settings with preview, download and one-click install
- [ ] **Feature:** Complete GPU Driver Manager for NVIDIA, AMD and Intel with rollback and validation
- [ ] **Innovation:** **uNexus AI Game Coach:** local post-session performance analysis with personalized tips and no telemetry
- [ ] **UI:** Final polish pass over all loading, error, success and motion states
- [ ] **Feature:** Update mechanism with stable/beta channels, delta updates and system snapshot before update
- [ ] **Innovation:** **uNexus Community Stats (opt-in):** anonymous hardware/game stats dashboard to guide compatibility priorities
- [~] **UI:** Official website exists at <https://unexus-os.vercel.app>; generated docs, screenshots, downloads and contribution guide are still pending
- [ ] **Feature:** Public hardware compatibility matrix
- [ ] **Innovation:** **uNexus Portable Profile:** `.unexus-profile` file containing settings, themes, keybinds, game list and performance profiles

### Exit Criteria - Phase 12 (uNexus 1.0)

- [~] Public ISO foundation exists; hosted public download flow is still pending
- [ ] Installer works on at least 5 tested hardware configurations
- [ ] Update mechanism is functional
- [ ] At least 3 non-technical gamers use uNexus as their main OS for 30 days
- [ ] Complete user documentation in PT-BR and English
- [ ] Community support process is established

---

## Project Guiding Rules

- uNexus should look original, not like a theme pasted onto another desktop.
- Every visual element should make gaming setup simpler or the desktop calmer.
- Every feature should move toward a real OS, not just a simulated shell.
- If a feature requires system privileges, design the permission model before polishing the UI.
- If a feature helps gaming, prefer real integrations over fake indicators.
- If hardware data is unavailable, show honest states like `N/A` instead of misleading numbers.
- AI features must be optional, local-first and privacy-preserving; no file names, prompts, configs or telemetry should leave the device unless the user explicitly enables an external provider.
- Innovations should be useful first and impressive second.
- Keep Arch + Hyprland as the development truth while the ISO path is validated on more hardware.

---

<sub>Roadmap is updated as uNexus evolves from shell prototype to bootable gaming OS.</sub>
