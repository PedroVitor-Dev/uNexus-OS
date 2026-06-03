# uNexus Roadmap

This roadmap is organized around one goal: make uNexus feel like a beautiful gaming-first desktop shell while steadily turning it into a real bootable operating system.

The order matters. Each stage balances three tracks:

- **Visual and UX**: original, clean, modern interface work.
- **Features**: gaming and desktop functionality users can feel immediately.
- **Real OS foundation**: packaging, session, services, drivers, ISO and installer work.

---

## Current Snapshot

uNexus currently has a working Qt6/QML shell running on Arch Linux + Hyprland real hardware.

### Done

- [x] Qt6/QML shell starts and runs on Hyprland
- [x] Login screen with password flow
- [x] Animated geometric wallpaper with particles
- [x] Top bar with clock, date, network, battery and Game Mode
- [x] System side dock
- [x] Gaming side dock
- [x] Dock hover, tooltip, bounce and active indicators
- [x] Real app launching through C++
- [x] Focus existing windows before opening duplicates
- [x] Close apps through Hyprland / process fallback
- [x] Dock right-click action menu
- [x] Launcher with search and categories
- [x] Gaming launcher entries for Steam, Lutris, Heroic and Bottles
- [x] Native command and Flatpak detection
- [x] Flatpak fallback for gaming apps
- [x] MangoHud and GameMode launch helpers
- [x] CPU/GPU/RAM/TEMP shell stats overlay
- [x] Missing GPU metrics displayed as `N/A`
- [x] uNexus Settings prototype
- [x] Game Settings prototype
- [x] First Setup checklist
- [x] uNexus Files MVP
- [x] English/PT-BR language selection
- [x] Persistent user settings through `QSettings`
- [x] Auto-start through Hyprland `exec-once`
- [x] Project docs updated for the current shell state

### Known Gaps

- [ ] No official visual identity yet
- [ ] No proper packaged install flow yet
- [ ] No bootable ISO yet
- [ ] No real installer yet
- [ ] No dedicated app/library data model yet
- [ ] No full file manager feature set yet
- [ ] No complete GPU driver manager yet
- [ ] No per-game profile system yet
- [ ] No controller management yet

---

## Stage 1 - Identity, Polish and Daily Shell Trust

Goal: make the current shell feel intentional, original and pleasant enough to use daily inside Hyprland.

### Visual and UX

- [ ] Design the official uNexus logo
- [ ] Define the core visual language: spacing, shadows, borders, motion and typography
- [ ] Create the first official wallpaper set
- [ ] Replace temporary text/icon fallbacks with consistent visual app icons
- [x] Polish the side docks so system and gaming areas feel distinct but related
- [ ] Refine panel transitions for Launcher, Settings, Game Settings and First Setup
- [ ] Add empty, loading, error and unavailable states to every panel
- [ ] Make the shell look good at common laptop and desktop resolutions
- [ ] Add subtle motion rules so animations feel fast, not decorative

### Features

- [x] Keep app active state tied to real process/window state
- [x] Add dock visual states for open, minimized/hidden and closed apps
- [x] Keep Open / Focus behavior on dock and launcher
- [x] Keep Close behavior available from the dock action menu
- [x] Add uNexus Files MVP with local directory navigation
- [x] Add PT-BR interface localization selectable from uNexus Settings
- [ ] Add keyboard shortcuts for Launcher, Settings, Game Settings and stats overlay
- [ ] Add a visible shortcut help panel inside uNexus Settings
- [ ] Add quick toggles for stats overlay, Game Mode and theme
- [ ] Add notification actions where useful instead of passive messages only
- [ ] Improve the desktop context menu with real actions
- [ ] Continue uNexus Files with copy/cut/paste, delete confirmations, sorting, breadcrumbs and richer previews

### Real OS Foundation

- [x] Shell runs on Arch + Hyprland real hardware
- [x] Shell can auto-start through Hyprland config
- [ ] Create a clean `.desktop` entry for `unexus-shell`
- [ ] Create a dedicated Hyprland session file for uNexus Shell
- [ ] Document exact Hyprland config needed for daily testing
- [ ] Add a simple health check screen for missing dependencies
- [ ] Keep all runtime assumptions documented in `docs/building.md`

### Exit Criteria

- [ ] A user can boot into Hyprland, see uNexus Shell, open apps, close apps and understand the interface without reading code
- [ ] The shell has a recognizable visual identity beyond "Qt prototype"
- [ ] The current feature set works after a clean clone/build on the target Arch machine

---

## Stage 2 - Settings That Actually Control the System

Goal: make uNexus Settings and Game Settings useful, not just informational.

### Visual and UX

- [x] uNexus Settings panel exists
- [x] Game Settings panel exists
- [x] First Setup panel exists
- [ ] Redesign Settings as a real control center with sections and persistent state
- [ ] Give Game Settings a gaming-dashboard feel without becoming noisy
- [ ] Add clear installed, missing, running and needs-restart states
- [ ] Add confirmation states for commands that affect the system
- [ ] Use consistent controls: toggles, segmented controls, buttons and status chips

### Features

- [x] Theme index persists through `QSettings`
- [x] Language selection persists through `QSettings`
- [x] Stats overlay visibility persists through `QSettings`
- [x] First Setup completion persists through `QSettings`
- [x] Game Settings can copy Steam launch options
- [x] uNexus Files can open files, create folders, rename items and move items to trash
- [ ] Add real install actions for Flatpak apps instead of only copying commands
- [ ] Add Flatpak remote detection and Flathub setup status
- [ ] Add MangoHud configuration status
- [ ] Add GameMode service status
- [ ] Add a reset settings action
- [ ] Add theme preview before applying a theme
- [ ] Add per-user preferences for dock behavior
- [ ] Add per-user preferences for file manager behavior

### Real OS Foundation

- [ ] Decide which settings are user-level and which require admin privileges
- [ ] Add a safe privileged-action strategy instead of running random shell commands
- [ ] Define where uNexus stores user config
- [ ] Define where uNexus stores system config
- [ ] Add config migration rules for future versions
- [ ] Add documentation for every setting that changes system behavior

### Exit Criteria

- [ ] uNexus Settings can change real shell preferences safely
- [ ] Game Settings can prepare a gaming environment without manual guessing
- [ ] First Setup can guide a clean machine toward a usable gaming setup

---

## Stage 3 - Gaming Core That Feels Real

Goal: make uNexus genuinely useful for launching, configuring and monitoring games.

### Visual and UX

- [ ] Turn Game Settings into a polished gaming control surface
- [ ] Create a "Game Library" view that feels original and not like a generic app grid
- [ ] Add clean status states for each launcher: installed, missing, running, updating
- [ ] Add game/app cards with compact useful information
- [ ] Design a proper MangoHud/GameMode explanation that does not feel like documentation inside the app
- [ ] Make shell stats visually distinct from in-game MangoHud

### Features

- [x] Steam launcher support
- [x] Lutris launcher support
- [x] Heroic Games Launcher support
- [x] Bottles launcher support
- [x] Flatpak fallback for gaming apps
- [x] MangoHud/GameMode launch helper path
- [ ] Validate MangoHud with actual games
- [ ] Detect whether MangoHud is active for launched games when possible
- [ ] Add Steam launch option helper flow
- [ ] Add Proton/Wine detection
- [ ] Add Heroic and Bottles install/status flows
- [ ] Add per-game profile data structure
- [ ] Add per-game toggles: GameMode, MangoHud, custom command, environment variables
- [ ] Add controller detection
- [ ] Add basic controller status panel
- [ ] Add a benchmark/test utility entry for graphics diagnostics

### Real OS Foundation

- [ ] Define default gaming packages for uNexus
- [ ] Define Flatpak vs native package policy
- [ ] Define Steam, Lutris, Heroic and Bottles defaults
- [ ] Add Vulkan driver verification
- [ ] Add 32-bit library checks for gaming
- [ ] Add GameMode service verification
- [ ] Add MangoHud config verification
- [ ] Document how gaming launchers are installed in the final OS

### Exit Criteria

- [ ] A user can install/open Steam, Lutris, Heroic and Bottles from uNexus flows
- [ ] At least one real game can be launched with MangoHud + GameMode
- [ ] The system can explain what is missing when a game environment is incomplete

---

## Stage 4 - Window Management and Desktop Behavior

Goal: make the shell behave less like an overlay and more like an operating-system desktop.

### Visual and UX

- [x] Dock action menu exists
- [x] Active app indicator exists
- [ ] Add refined window action menus: Open, Focus, Close, Maximize, Move
- [ ] Add a window preview direction for future compositor integration
- [ ] Add workspace indicators with clear visual hierarchy
- [ ] Add tasteful minimize/restore behavior that fits Hyprland
- [ ] Add polished multi-monitor layout rules

### Features

- [x] Focus existing windows with `hyprctl`
- [x] Close windows with `hyprctl`
- [x] Fallback process tracking exists
- [ ] Add maximize/restore support through Hyprland
- [ ] Add move-to-workspace support
- [ ] Add special workspace support for "minimized" windows
- [ ] Add workspace switcher UI
- [ ] Add monitor detection
- [ ] Add app pin/unpin behavior in docks
- [ ] Add recently opened apps

### Real OS Foundation

- [ ] Decide whether uNexus will remain a Hyprland shell or fork deeper behavior
- [ ] Document required Hyprland rules for uNexus Shell
- [ ] Add default Hyprland config for uNexus
- [ ] Add session environment variables
- [ ] Add startup order for shell, portals, notifications and services
- [ ] Add xdg-desktop-portal setup for Wayland apps

### Exit Criteria

- [ ] The user can manage normal desktop windows from uNexus without relying on external bars
- [ ] Workspace behavior is understandable and stable
- [ ] The Hyprland config required by uNexus is reproducible

---

## Stage 5 - Packaging and Installable Shell

Goal: stop treating uNexus Shell as a manually built project and make it installable.

### Visual and UX

- [ ] Add a first-run experience that feels like product onboarding, not a dev checklist
- [ ] Add a clean loading state for shell startup
- [ ] Add failure screens for missing Qt/QML resources or backends
- [ ] Create release screenshots that match the current UI

### Features

- [ ] Add release build configuration
- [ ] Add install target in CMake
- [ ] Install binary, QML files and assets to correct system paths
- [ ] Add `.desktop` launcher file
- [ ] Add uNexus session file
- [ ] Add version display in Settings
- [ ] Add changelog display or release notes link

### Real OS Foundation

- [ ] Create Arch `PKGBUILD` for `unexus-shell`
- [ ] Package Qt/QML dependencies correctly
- [ ] Package runtime assets correctly
- [ ] Add a clean uninstall path
- [ ] Add CI or repeatable local release script
- [ ] Add package signing plan later
- [ ] Decide package naming and versioning policy

### Exit Criteria

- [ ] A clean Arch machine can install uNexus Shell without manually running CMake
- [ ] The installed shell can launch from a session or desktop entry
- [ ] Versioned releases are possible

---

## Stage 6 - Bootable uNexus Prototype

Goal: create the first bootable USB image that launches into a uNexus session.

### Visual and UX

- [ ] Create boot splash direction
- [ ] Create first boot welcome flow
- [ ] Create login/session visual polish
- [ ] Make the first boot desktop look intentional even before apps are installed
- [ ] Prepare official screenshots for the ISO prototype

### Features

- [ ] Include uNexus Shell by default
- [ ] Include Hyprland by default
- [ ] Include Flatpak and Flathub setup
- [ ] Include MangoHud and GameMode
- [ ] Include Vulkan tools and basic diagnostics
- [ ] Include sane default terminal, browser and file manager
- [ ] Include First Setup on first login
- [ ] Include fallback path if GPU stats are unavailable

### Real OS Foundation

- [ ] Create `archiso` profile
- [ ] Define package list
- [ ] Define user/session creation
- [ ] Define default Hyprland config
- [ ] Define service startup
- [ ] Define GPU driver baseline
- [ ] Define network setup
- [ ] Define persistent install strategy separately from live ISO
- [ ] Test boot on real USB hardware

### Exit Criteria

- [ ] uNexus boots from USB on real hardware
- [ ] User reaches uNexus Shell without manual terminal work
- [ ] Basic apps launch
- [ ] Game setup checklist is visible and useful

---

## Stage 7 - Installer and Public Alpha

Goal: turn the bootable prototype into something testers can install and report on.

### Visual and UX

- [ ] Design a clean installer experience
- [ ] Decide whether to use Calamares first or build a custom installer later
- [ ] Add clear warnings for disk operations
- [ ] Add post-install welcome flow
- [ ] Add feedback/report issue affordance

### Features

- [ ] Install uNexus to disk
- [ ] Create user account
- [ ] Configure bootloader
- [ ] Configure Hyprland session
- [ ] Configure Flatpak/Flathub
- [ ] Configure GameMode/MangoHud
- [ ] Provide default gaming launchers or install path
- [ ] Provide update path

### Real OS Foundation

- [ ] Choose installer technology
- [ ] Define partitioning defaults
- [ ] Define secure boot stance
- [ ] Define update strategy
- [ ] Define package repositories
- [ ] Define bug report process
- [ ] Define public alpha release checklist

### Exit Criteria

- [ ] External testers can install uNexus
- [ ] Testers can play at least one common game path
- [ ] Bugs can be reported and reproduced
- [ ] The project has a repeatable release process

---

## Stage 8 - uNexus 1.0 Direction

Goal: mature from a promising gaming shell into a reliable gaming-focused Linux OS.

### Visual and UX

- [ ] Complete brand system
- [ ] Refined animations and themes
- [ ] Strong multi-monitor behavior
- [ ] Cohesive app icon and panel system
- [ ] Polished setup, settings and game library flows

### Features

- [ ] Game library across Steam, Lutris, Heroic and Bottles
- [ ] Per-game profiles
- [ ] Controller management
- [ ] GPU driver manager
- [ ] Proton/Wine management
- [ ] One-click gaming diagnostics
- [ ] Streaming/recording helper direction

### Real OS Foundation

- [ ] Public ISO
- [ ] Working installer
- [ ] Update mechanism
- [ ] Package/repository strategy
- [ ] Hardware compatibility matrix
- [ ] Security and permission model
- [ ] Documentation for users and contributors
- [ ] Community support process

---

## Guiding Rules

- uNexus should look original, not like a theme pasted on top of another desktop.
- Every visual element should make gaming setup feel simpler or the desktop feel calmer.
- Every feature should move toward a real OS, not just a mock shell.
- If a feature requires system privileges, design the permission model before making the UI pretty.
- If a feature helps gaming, prefer real integrations over fake indicators.
- If hardware data is unavailable, show honest states like `N/A` instead of misleading numbers.
- Keep Arch + Hyprland as the development truth until the ISO path is ready.

---

<sub>Roadmap is updated as uNexus evolves from shell prototype to bootable gaming OS.</sub>
