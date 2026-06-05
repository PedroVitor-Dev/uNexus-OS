# uNexus Project Context

Last updated: 2026-06-05

This file is the main handoff note for another AI/chat/dev session. Read it before changing code. It captures the current technical context, user workflow, completed work, recent commits, known gaps and recommended next steps.

---

## Project Summary

uNexus is a gaming-focused Linux desktop shell project. The current implementation is `unexus-shell`, a Qt6/QML shell running on Arch Linux + Hyprland real hardware.

The product direction is a clean, fast, game-first Linux experience where Steam, Lutris, Heroic, Bottles, GameMode, MangoHud and basic desktop tasks are integrated into one polished shell.

Current development truth:

- Target runtime: Arch Linux + Hyprland + Wayland.
- Main app: `packages/unexus-shell`.
- UI: Qt6/QML.
- System integration: C++ context objects exposed to QML.
- Build system: CMake.
- Persistent settings: `QSettings`.
- Official logo assets live in `assets/logo`.
- Official wallpaper assets live in `assets/wallpapers`.
- Current Codex machine may be Windows, but real build/test should happen on the user's Arch + Hyprland PC.

---

## User Workflow Preferences

Important preferences from the project owner:

- Do not try to compile on Windows. This local environment may not have CMake/Qt configured.
- The user tests on Arch + Hyprland after pulling changes.
- Do not update docs unless the user explicitly asks.
- Do not push by default. Stage and commit locally, then tell the user so they can push from VS Code unless they explicitly ask for `git push`.
- Keep implementation moving; make practical, repo-consistent changes.
- Preserve unrelated user changes if the worktree is dirty.
- The user prefers Portuguese in conversation.

---

## Tech Stack

| Area | Technology |
|---|---|
| OS target | Linux, currently Arch |
| Compositor | Hyprland |
| Display | Wayland |
| UI framework | Qt6/QML |
| Backend | C++ |
| Build | CMake 3.20+ |
| Settings | `QSettings` |
| Window control | `hyprctl`, with fallbacks where useful |
| App launch | `QProcess`, native command detection and Flatpak helpers |
| Game helpers | GameMode, MangoHud |
| File actions | `FileManager`, `QDesktopServices`, `gio trash` |
| Assets | Qt resources loaded from `assets/logo` and `assets/wallpapers` |
| UI font | Exo 2 |

---

## Repository Map

| Path | Purpose |
|---|---|
| `packages/unexus-shell` | Main Qt/QML shell |
| `packages/unexus-shell/qml` | Shell UI: main surface, docks, launcher, panels, overlays |
| `packages/unexus-shell/src` | C++ backends |
| `packages/unexus-shell/include` | Backend headers |
| `docs` | Architecture, roadmap, build and contribution docs |
| `assets/logo` | Official uNexus logo PNG variants |
| `assets/wallpapers` | Official wallpaper set |
| `packaging/linux` | `.desktop`, Wayland session and launch wrapper files |
| `packaging/arch` | Arch package files |
| `scripts` | Helper scripts, setup, doctor, package and unexusctl |

Important QML files:

- `Main.qml`: owns shell orchestration, theme, localization, app metadata, dock actions, panel wiring, wallpaper and shared brand logo source.
- `SideDock.qml`: left/right side dock container.
- `DockButton.qml`: dock item visuals, tooltip, active/minimized/closed state.
- `Launcher.qml`: app launcher with search, categories and install status.
- `SettingsPanel.qml`: uNexus Settings, including language selector, shortcuts, help, theme/stats settings and About logo block.
- `GameSettingsPanel.qml`: GameMode, MangoHud and gaming launcher checks/Flatpak install actions.
- `FilesPanel.qml`: uNexus Files with places, breadcrumbs, sorting, multi-select, clipboard actions, context menu, keyboard shortcuts, previews and file actions.
- `FirstSetupPanel.qml`: first-run checklist and dependency guidance; still copies some manual install commands where privileged actions are not automated.
- `ContextMenu.qml`: desktop right-click menu.
- `LoginScreen.qml`: login flow using the official logo.
- `FpsOverlay.qml`: shell stats overlay.
- `DesignTokens.qml`: visual-language tokens for spacing, radius, typography, motion, surfaces, text, borders and status colors.
- `LiquidGlass.qml`: shared translucent/depth material.

Important C++ backends:

- `AppLauncher`: app detection, Flatpak detection, real Flatpak install start, launch/focus/close/maximize/move/minimize/restore, workspace state, MangoHud/GameMode wrappers, clipboard.
- `GameMode`: Game Mode state/toggle.
- `SystemInfo`: battery and network state.
- `SystemStats`: CPU/GPU/RAM/TEMP metrics.
- `UserSettings`: persistent theme, language, stats overlay, notification, shortcut and first setup preferences.
- `FileManager`: directory listing, common places, open, create folder, rename, copy, move, paste, preview metadata and trash.
- `GlobalShortcuts`: file-based shortcut command bridge used by Hyprland binds and `unexus-shell --shortcut`.

---

## What Already Exists

Core shell:

- Login screen with password `1234` or blank.
- Official wallpaper image layer plus animated geometric/particle lines.
- Shell starts in fullscreen through `Window.FullScreen` for Hyprland testing.
- Top bar clock/date/network/battery/Game Mode toggle.
- Notification center with a persistent setting to disable persistent notifications.
- Desktop context menu.
- Persistent theme, language, stats overlay, notification, shortcut and first setup preferences.
- Official uNexus logo integrated into desktop, login, Settings About and README.
- Official wallpaper set integrated into Qt resources and installed as runtime assets.
- Shared design tokens define spacing, borders, shadows, typography, motion and surfaces.
- Liquid Glass QML material is applied to docks, menus and notifications.
- Spring physics drive panel and dock interactions.
- Windows-like global shortcuts are bridged through Hyprland binds and `unexus-shell --shortcut`: `Super+S` launcher, `Super+I` Settings, `Super+G` Stats and `Super+Alt+G` Game Settings.
- Settings includes a shortcut editor, explicit apply buttons, restore defaults and a visible shortcut help panel.
- Current slogan: `Open Source. Linux Powered. Gamer Focused.`

Dock:

- Separate left system dock and right gaming dock.
- System side: uNexus Files, Browser, uNexus Settings, Terminal, First Setup.
- Gaming side: Steam, Lutris, Heroic, Bottles, Game Settings.
- Auto-hide side dock behavior.
- Original application icons are resolved when possible through icon names.
- Dock tooltips, hover animation and action menu.
- App states for closed/open/minimized or hidden.
- Internal panels no longer remain visually active after closing.
- Hover/active visual residue was reduced so closed apps stop looking stuck.

Launcher:

- Search and categories.
- Gaming launcher entries for Steam/Lutris/Heroic/Bottles.
- Native command and Flatpak detection.
- Flatpak fallback for gaming launchers.
- Copy Steam launch options: `mangohud gamemoderun %command%`.
- When Game Mode is active, gaming apps can launch with MangoHud/GameMode wrappers when tools exist.

Game/Setup:

- Game Settings panel checks MangoHud, GameModeRun and gaming launchers.
- Game Settings starts real Flatpak installs for Steam, Lutris, Heroic and Bottles through `AppLauncher.installFlatpak()`.
- First Setup checklist covers Flatpak, MangoHud, GameMode and gaming launchers.
- Pacman/tool installs still need manual/system-level handling.

Stats:

- Shell stats overlay shows CPU, GPU, TEMP and RAM.
- Missing GPU metrics show `N/A`.

uNexus Files:

- Embedded file manager panel, not a standalone process yet.
- Header title is `File Manager` / `Gerenciador de Arquivos`.
- Common places sidebar.
- Directory navigation.
- Breadcrumb navigation.
- Sorting by name, type, date and size.
- Multi-select with Ctrl/Shift style interaction.
- Right-click context menu works on rows and blank list space.
- Keyboard shortcuts for copy, cut, paste, select all, delete, open, rename and clear selection.
- Copy/cut/paste through `FileManager`.
- Preview/details pane for selected entries.
- Folder rows use a simpler folder visual and type label instead of huge `DIR` text.
- Open files through desktop services.
- Create folder.
- Rename item.
- Move selected items to trash through `gio trash`.

Localization:

- English is the source/fallback language.
- PT-BR localization is implemented.
- Language can be selected in uNexus Settings.
- `UserSettings.languageCode` persists `en` or `pt-BR`.
- QML uses `root.tr(...)`, `root.trAppMessage(...)` and `root.trLabelMessage(...)`.

Assets:

- Old screenshots/demo media with previous branding were removed.
- Official PNG logo variants are under `assets/logo`.
- Runtime QML uses `qrc:/UNexusShell/assets/logo/SF%20White.png` through `brandLogoSource`.
- README currently uses `assets/logo/SF%20White.png` in the centered hero.
- Official wallpapers under `assets/wallpapers`:
  - `unexus-core.png` is the default desktop wallpaper.
  - `particle-drift.png` is a particle-heavy identity option.
  - `aurora-ice.png` is a cooler geometric option.
  - `ember-circuit.png` is a warmer circuit/geometric option.
- `packages/unexus-shell/CMakeLists.txt` registers logo and wallpaper assets with Qt resources and installs wallpapers to `${CMAKE_INSTALL_DATADIR}/unexus/wallpapers`.
- `assets/logo/4.png` remains tracked as an older logo variant/resource fallback.
- `assets/logo/uNexus Logo Creation.pdf` may exist locally as an untracked design/source file; it should only be tracked if the owner decides to add source design files.

---

## Recent Commits

Latest known commits:

- `ba69d36 feat(assets): add unexus wallpaper set`
- `b2d71c9 feat(settings): add shortcut help panel`
- `da72947 feat(files): add more keyboard clipboard shortcuts`
- `34f2d70 feat(ui): formalize visual language tokens`
- `bbd6275 feat(settings): install launchers with flatpak actions`
- `92ba345 feat(packaging): harden unexus wayland session files`
- `8587879 Fix formatting issues in README.md`
- `369707a fix(files): anchor file list content area`
- `2d85c77 fix(files): keep file list below toolbar`
- `82e8f91 fix(files): avoid list overlay for context clicks`
- `6ad2e94 fix(ui): apply shortcuts explicitly and improve file hotkeys`
- `be5e7e6 fix(ui): constrain launcher and improve files context menu`

---

## Latest Updates To Remember

The most recent work focused on Stage 1 maturity: packaging/session reproducibility, visual language, real launcher installs, keyboard shortcuts, file-manager usability and first-screen identity.

- Project name is `uNexus`; old PED OS references should not return.
- Package/module naming uses `unexus-shell` and `UNexusShell`.
- Official logo PNGs are in `assets/logo`; newest transparent variants are `SF White.png` and `SF Black.png`.
- `Main.qml` exposes `brandLogoSource`, currently pointing to `qrc:/UNexusShell/assets/logo/SF%20White.png`, and uses it on the desktop/login/settings.
- `Main.qml` exposes `desktopWallpaperSource`, currently pointing to `qrc:/UNexusShell/assets/wallpapers/unexus-core.png`.
- Login and Settings About use the official logo. First Setup intentionally no longer shows a tiny logo badge.
- README uses `assets/logo/SF%20White.png` and no old screenshots.
- The first official wallpaper set exists and is packaged as both Qt resources and installed files.
- uNexus Files gained breadcrumbs, sorting, multi-select, copy/cut/paste, previews, delete confirmations, keyboard shortcuts, blank-space context-menu behavior and layout fixes.
- uNexus Files title is now `File Manager` / `Gerenciador de Arquivos`.
- uNexus Files folder rows are simpler and use a type label rather than oversized `DIR` text.
- Main shell starts fullscreen for Hyprland testing.
- The dock hover residue was reduced; active state bugs were previously tracked in `docs/issue-dock-active-hover-state.md`.
- Brand slogan is `Open Source. Linux Powered. Gamer Focused.`
- The DesignTokens system formalizes spacing, layout dimensions, radius, borders, surfaces, status colors, typography hierarchy, weights, line-height and semantic motion timings.
- LiquidGlass gives docks, menus and notifications a shared translucent depth material.
- Panel and dock transitions use spring physics for tactile motion; opacity/color stay on timed animations.
- Dock action menus include Open, Focus, Close, Maximize, Move and Minimize/Restore.
- The shell exposes workspace indicators and a future-facing window preview direction.
- Installer direction is a graphical Qt/QML double-click installer backed by native Arch packaging, with `setup.sh` kept for development/recovery.
- Game Settings starts real Flatpak installs for Steam, Lutris, Heroic and Bottles. Flathub setup/status still needs a better first-class flow.

---

## Known Gaps / Risks

- No full automated test/build validation was run on Windows.
- Real validation should happen on Arch + Hyprland.
- The Qt resource paths for `SF White.png` / `SF Black.png` should be validated on Arch after a clean build, especially because the filenames contain spaces and QML uses `%20`.
- Wallpaper resource/install paths should be validated on Arch after a clean install.
- Localization is currently a simple QML dictionary, not Qt `.ts/.qm` translation files.
- English strings are still the stable source keys, so changing English display text can break PT-BR lookup unless dictionary keys are updated too.
- uNexus Files is no longer only an MVP, but still needs standalone-window maturity, deeper previews and more robust edge-case handling.
- Some icons are still text/emoji fallbacks when the original app icon cannot be found.
- GameMode/MangoHud integration needs more real-game validation.
- Game Settings starts real Flatpak installs for known launcher IDs, but privileged pacman/tool installs are still not automated.
- The shell still relies heavily on Hyprland behavior through `hyprctl`.
- A graphical installer and bootable ISO do not exist yet.

---

## Most Important Next Work

Recommended next priorities:

1. Validate the latest Stage 1 shell on Arch + Hyprland:
   - Clean build from `packages/unexus-shell`.
   - Confirm `SF White.png` renders on desktop, login and Settings About.
   - Confirm `unexus-core.png` renders as the default wallpaper.
   - Confirm fullscreen startup behaves correctly.
   - Confirm Liquid Glass surfaces render on docks, menus and notifications.
   - Confirm spring panel/dock motion feels fast and not decorative.
   - Confirm global shortcuts open Launcher, Settings, Game Settings and stats overlay.
   - Confirm uNexus Files multi-select, copy/cut/paste, previews, context menu and trash confirmations on real Arch.

2. Build the first graphical `uNexus Installer` MVP:
   - Double-click friendly Qt/QML UI.
   - Use package/setup backends rather than asking users to run build commands.
   - Keep `setup.sh` as the local development/recovery installer.
   - Start with shell install/repair before full OS install.

3. Continue uNexus Files toward a real `unexus-files`:
   - Standalone window/app direction.
   - Better preview handlers.
   - More robust conflict handling for paste/move operations.
   - More keyboard navigation polish.
   - Better empty/error states.

4. Improve Settings and provisioning:
   - Better control center structure.
   - Per-user dock/file-manager behavior preferences.
   - Flathub setup/status and Flatpak remote detection.
   - Safer privileged-action strategy before automating pacman/system changes.
   - `unexusctl provision` with manifests and dry-run.

5. Validate gaming flow:
   - Steam install/open.
   - Real game launch with `mangohud gamemoderun %command%`.
   - GameMode service status.
   - MangoHud config/status.
   - Start the Game Library/per-game profile model.

6. Packaging and ISO foundation:
   - Package Qt/QML dependencies correctly.
   - Package runtime assets correctly.
   - Eventually create an `archiso` profile.

---

## Useful Commands On Arch

Build:

```bash
cd packages/unexus-shell
cmake -B build
cmake --build build
./build/unexus-shell
```

Clean rebuild:

```bash
cd packages/unexus-shell
rm -rf build
cmake -B build
cmake --build build
./build/unexus-shell
```

Install/reinstall local session:

```bash
sudo sh scripts/setup.sh
unexusctl doctor
unexusctl session-info
```

Check Hyprland clients:

```bash
hyprctl clients -j
```

Check MangoHud/GameMode:

```bash
command -v mangohud
command -v gamemoderun
```

Steam launch option:

```bash
mangohud gamemoderun %command%
```

---

## Current Documentation Files

- `README.md`: public overview, current state, recent feature status, stack and build quickstart.
- `CHANGELOG.md`: notable changes.
- `docs/architecture.md`: backend/QML architecture and component responsibilities.
- `docs/building.md`: build/run instructions, dependency notes and session install guidance.
- `docs/roadmap.md`: staged product/OS roadmap.
- `docs/design-tokens.md`: formal visual language for spacing, typography, surfaces, radius, motion and component sizing.
- `docs/liquid-glass.md`: current QML glass material and future compositor direction.
- `docs/installer-technology.md`: chosen graphical installer direction.
- `docs/contributing.md`: contribution guidance.
- `docs/issue-dock-active-hover-state.md`: issue writeup for the dock active/hover residue problem.

---

## Handoff Rule Of Thumb

When continuing this project, read this file first, then check:

```bash
git status --short
git log --oneline -8
```

If the user asks for implementation, make the change, validate with `git diff --check`, then stage and commit. Do not push unless the user explicitly asks for it.
