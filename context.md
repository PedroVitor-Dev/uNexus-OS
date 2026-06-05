# uNexus Project Context

Last updated: 2026-06-04

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
- Current Codex machine may be Windows, but real build/test should happen on the user's Arch + Hyprland PC.

---

## User Workflow Preferences

Important preferences from the project owner:

- Do not try to compile on Windows. This local environment may not have CMake/Qt configured.
- The user tests on Arch + Hyprland after pulling changes.
- Do not update docs unless the user explicitly asks.
- The user has allowed `git push` during the current project flow. When a task says "a cada uma concluida da push", commit and push after each completed item.
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
| App launch | `QProcess`, Flatpak fallback |
| Game helpers | GameMode, MangoHud |
| File actions | `FileManager`, `QDesktopServices`, `gio trash` |
| Assets | Qt resources loaded from `assets/logo` |
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
| `scripts` | Helper scripts |

Important QML files:

- `Main.qml`: owns shell orchestration, theme, localization, app metadata, dock actions, panel wiring and shared brand logo source.
- `SideDock.qml`: left/right side dock container.
- `DockButton.qml`: dock item visuals, tooltip, active/minimized/closed state.
- `Launcher.qml`: app launcher with search, categories and install status.
- `SettingsPanel.qml`: uNexus Settings, including language selector, theme/stats settings and About logo block.
- `GameSettingsPanel.qml`: GameMode, MangoHud and gaming launcher checks.
- `FilesPanel.qml`: uNexus Files with places, breadcrumbs, sorting, multi-select, clipboard actions, previews and file actions.
- `FirstSetupPanel.qml`: first-run checklist and copied install commands.
- `ContextMenu.qml`: desktop right-click menu.
- `LoginScreen.qml`: login flow using the official logo.
- `FpsOverlay.qml`: shell stats overlay.

Important C++ backends:

- `AppLauncher`: app detection, Flatpak detection, launch/focus/close/maximize/move/minimize/restore, workspace state, MangoHud/GameMode wrappers, clipboard.
- `GameMode`: Game Mode state/toggle.
- `SystemInfo`: battery and network state.
- `SystemStats`: CPU/GPU/RAM/TEMP metrics.
- `UserSettings`: persistent theme, language, stats overlay and first setup state.
- `FileManager`: directory listing, common places, open, create folder, rename, copy, move, paste, preview metadata and trash.

---

## What Already Exists

Core shell:

- Login screen with password `1234` or blank.
- Animated geometric wallpaper and top bar.
- Shell starts in fullscreen through `Window.FullScreen` for Hyprland testing.
- Top bar clock/date/network/battery/Game Mode toggle.
- Notification center.
- Desktop context menu.
- Persistent theme, language, stats overlay and first setup preferences.
- Official uNexus logo integrated into desktop, login, Settings About and README.
- Shared design tokens define spacing, borders, shadows, typography, motion and surfaces.
- Liquid Glass QML material is applied to docks, menus and notifications.
- Spring physics drive panel and dock interactions.
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
- First Setup checklist covers Flatpak, MangoHud, GameMode and gaming launchers.
- Install commands are copied to clipboard instead of run directly.

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
- Official PNG logo variants were added under `assets/logo`.
- Runtime QML uses `qrc:/UNexusShell/assets/logo/SF%20White.png` through `brandLogoSource`.
- README currently uses `assets/logo/SF%20White.png` in the centered hero.
- `assets/logo/4.png` remains tracked as an older logo variant/resource fallback.
- `assets/logo/uNexus Logo Creation.pdf` may exist locally as an untracked design/source file; it was intentionally left out of the last UI commit unless the owner decides to track it.

---

## Recent Commits

Latest known commits:

- `5448361 feat(ui): add spring motion physics`
- `fb7829d feat(ui): introduce liquid glass material`
- `87a895c feat(files): add keyboard clipboard shortcuts`
- `f65b624 feat(ui): add design token system`
- `2191307 docs(installer): choose graphical installer direction`
- `7367f91 feat(shell): refine window actions and workspaces`
- `70af886 feat(files): add multi-select clipboard and previews`
- `ec4e324 docs(ui): update unexus slogan`
- `e0cb143 feat(ui): use transparent sf logo assets`
- `23937d0 docs: refresh unexus project context`
- `d4f47a2 feat(ui): integrate official uNexus logo assets`
- `0d10a86 fix(files): rename panel title`
- `6cb7314 feat(files): add breadcrumbs and sorting`
- `5037416 docs: simplify readme hero`
- `3b0be70 fix(dock): reset stuck icon hover state`
- `6503bd1 chore: rename remaining unexus placeholders`
- `7689bb9 refactor: rename project to unexus`
- `2efb0c6 docs: add dock active state issue`
- `d93f5da fix(dock): make internal state reactive`

---

## Latest Updates To Remember

The most recent work focused on visual-system maturity, real file-manager behavior and better Hyprland window control:

- Project name is now `uNexus`; old PED OS references should not return.
- Package/module naming uses `unexus-shell` and `UNexusShell`.
- Official logo PNGs are in `assets/logo`; newest transparent variants are `SF White.png` and `SF Black.png`.
- `Main.qml` exposes `brandLogoSource`, currently pointing to `qrc:/UNexusShell/assets/logo/SF%20White.png`, and uses it on the desktop/login/settings.
- Login and Settings About use the official logo. First Setup intentionally no longer shows a tiny logo badge.
- `CMakeLists.txt` registers the brand asset with Qt resources.
- README now uses `assets/logo/SF%20White.png` instead of old screenshots.
- Old screenshot/demo files were removed from tracked assets.
- uNexus Files gained breadcrumbs and sorting.
- uNexus Files gained multi-select, copy/cut/paste, previews, delete confirmations and keyboard shortcuts.
- uNexus Files title is now `File Manager` / `Gerenciador de Arquivos`.
- uNexus Files folder rows are simpler and use a type label rather than oversized `DIR` text.
- Main shell starts fullscreen for Hyprland testing.
- The dock hover residue was reduced; active state bugs were previously tracked in `docs/issue-dock-active-hover-state.md`.
- Brand slogan was changed everywhere visible to `Open Source. Linux Powered. Gamer Focused.`
- The first DesignTokens system now centralizes spacing, radius, borders, surfaces, status colors, typography and motion.
- LiquidGlass now gives docks, menus and notifications a shared translucent depth material.
- Panel and dock transitions use spring physics for tactile motion.
- Dock action menus now include Open, Focus, Close, Maximize, Move and Minimize/Restore.
- The shell exposes workspace indicators and a future-facing window preview direction.
- Installer direction is a graphical Qt/QML double-click installer backed by native Arch packaging, with `setup.sh` kept for development/recovery.

---

## Known Gaps / Risks

- No full automated test/build validation was run on Windows.
- Real validation should happen on Arch + Hyprland.
- The Qt resource paths for `SF White.png` / `SF Black.png` should be validated on Arch after a clean build, especially because the filenames contain spaces and QML uses `%20`.
- Localization is currently a simple QML dictionary, not Qt `.ts/.qm` translation files.
- English strings are still the stable source keys, so changing English display text can break PT-BR lookup unless dictionary keys are updated too.
- uNexus Files is no longer only an MVP, but still needs standalone-window maturity, deeper previews and more robust edge-case handling.
- Some icons are still text/emoji fallbacks when the original app icon cannot be found.
- GameMode/MangoHud integration needs more real-game validation.
- Install flows copy commands; they do not yet run privileged or Flatpak installs directly.
- The shell still relies heavily on Hyprland behavior through `hyprctl`.

---

## Most Important Next Work

Recommended next priorities:

1. Validate the latest visual-system and Files changes on Arch + Hyprland:
   - Clean build from `packages/unexus-shell`.
   - Confirm `SF White.png` renders on desktop, login and Settings About.
   - Confirm fullscreen startup behaves correctly.
   - Confirm Liquid Glass surfaces render on docks, menus and notifications.
   - Confirm spring panel/dock motion feels fast and not decorative.
   - Confirm uNexus Files multi-select, copy/cut/paste, previews and trash confirmations on real Arch.

2. Continue uNexus Files toward a real `unexus-files`:
   - Standalone window/app direction.
   - Better preview handlers.
   - More robust conflict handling for paste/move operations.
   - More keyboard navigation polish.
   - Better empty/error states.

3. Improve Settings:
   - Better control center structure.
   - Per-user dock behavior preferences.
   - Reset settings action.
   - More complete dependency health checks.

4. Validate gaming flow:
   - Steam install/open.
   - Real game launch with `mangohud gamemoderun %command%`.
   - GameMode service status.
   - MangoHud config/status.

5. Packaging foundation:
   - Graphical double-click installer MVP.
   - Package Qt/QML dependencies correctly.
   - Keep `setup.sh` as the local development/recovery installer.
   - Eventually `archiso`.

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

- `README.md`: public overview, current state, features, stack and build quickstart.
- `CHANGELOG.md`: notable changes.
- `docs/architecture.md`: backend/QML architecture and component responsibilities.
- `docs/building.md`: build/run instructions and dependency notes.
- `docs/roadmap.md`: staged product/OS roadmap.
- `docs/design-tokens.md`: shared visual language and motion token rules.
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

If the user asks for implementation, make the change, validate with `git diff --check`, then stage and commit. Push when the current task flow asks for it or when the user has explicitly allowed pushes.
