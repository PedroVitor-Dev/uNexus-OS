# PED OS Roadmap

---

## Phase 1 - Foundation

Status: mostly complete.

- [x] Configure Linux development environment
- [x] Create GitHub repository
- [x] Create first Qt/QML interfaces
- [x] First fluid animation
- [x] Login screen
- [x] Dock with animations
- [x] Launcher with search and categories
- [x] Notification system
- [x] Context menu
- [x] Real battery and network indicators
- [x] Game Mode toggle
- [x] Real app launching via C++
- [x] Steam/Lutris detection
- [x] Heroic/Bottles launcher entries
- [x] Dock active indicator based on real window/process state
- [x] Focus/close windows through Hyprland
- [x] Dual boot Arch + Hyprland on real hardware
- [x] PED OS Shell running natively on Hyprland
- [x] Auto-start PED OS Shell through Hyprland config
- [x] Stats overlay with CPU/GPU/RAM/TEMP
- [x] Persistent user settings
- [x] First Setup panel
- [x] PED Settings panel
- [x] Game Settings panel
- [ ] Create official PED OS logo
- [ ] Create updated mockups in Figma

**Milestones:**

- [x] First PED OS window running
- [x] First fluid animations
- [x] Interface looks like a real OS shell
- [x] Running on real hardware with Hyprland
- [x] Shell can launch and manage real apps
- [ ] First official wallpaper

---

## Phase 2 - Real Interface

Status: in progress.

- [x] Auto-start PED OS Shell on login
- [x] PED Settings prototype
- [x] Game Settings prototype
- [x] First Setup checklist
- [x] Stats overlay
- [x] MangoHud/GameMode launch helpers
- [x] Gaming side dock
- [ ] Extract PED Dock into standalone component
- [ ] Extract app metadata into a shared model/config
- [ ] Extract PED Launcher into a cleaner standalone component
- [ ] Refine theme system
- [ ] Add keyboard shortcuts
- [ ] Add workspace management UI
- [ ] Improve notification center
- [ ] Improve close/focus behavior across edge cases
- [ ] Add real settings actions instead of copied install commands

**Milestones:**

- [x] Shell feels usable as a daily Hyprland overlay
- [ ] First public demo video
- [ ] First packaged Arch build

---

## Phase 3 - Gaming Core

Status: planned / partially started.

- [x] Steam launcher support
- [x] Lutris launcher support
- [x] Heroic Games Launcher support
- [x] Bottles support
- [x] Flatpak fallback for gaming apps
- [x] MangoHud launch option helper
- [ ] Validate MangoHud with real games
- [ ] Steam integration out of the box
- [ ] Lutris integration out of the box
- [ ] Proton/Wine management UI
- [ ] Per-game performance profiles
- [ ] GPU driver manager UI
- [ ] Controller detection and setup
- [ ] Controller mapping tool
- [ ] Low-latency kernel tweaks
- [ ] Auto CPU governor switching
- [ ] Game library view

**Milestones:**

- [ ] Play common Windows games out of the box
- [ ] Benchmarks against stock Arch/Ubuntu
- [ ] First external testers

---

## Phase 4 - Distribution

Status: future.

- [ ] Create Arch package / PKGBUILD for `ped-shell`
- [ ] Install QML, binary and desktop/session files cleanly
- [ ] Create `archiso` profile
- [ ] Bootable ISO
- [ ] Basic installer path
- [ ] First boot setup
- [ ] Default Hyprland session for PED OS
- [ ] Official website
- [ ] Discord/community space
- [ ] Organized release process

**Milestones:**

- [ ] First internal ISO
- [ ] First USB boot on real hardware
- [ ] First public alpha

---

## Long Term - PED OS 1.0

- Public ISO
- Working installer
- Gaming app setup out of the box
- GPU driver flow
- Per-game profiles
- Strong controller support
- Active gaming community
- External contributors

---

## Future Gaming Features

| Feature | Description |
|---|---|
| PED Game Mode | Performance profile and launch wrappers for games |
| PED FPS Overlay | In-game MangoHud plus shell stats overlay |
| PED Store | Curated gaming apps, tools and emulators |
| PED Controller | Plug-and-play controller detection and mapping |
| PED Optimizer | One-click system optimization for gaming |
| PED Streamer | Streaming tools and overlays |
| PED Library | Local game library across Steam, Lutris, Heroic and Bottles |

---

<sub>Roadmap is updated as the project evolves.</sub>
