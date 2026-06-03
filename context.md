# uNexus Project Context

Last updated: 2026-06-03

This file is a handoff note for another AI/chat/dev session. It captures the current technical context, recent decisions, user preferences, completed work and the most important next steps.

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
- Current working machine for Codex may be Windows, but real build/test should happen on the user's Arch + Hyprland PC.

---

## User Workflow Preferences

Important preferences from the project owner:

- Do not try to compile on Windows. This local environment may not have CMake/Qt configured.
- The user tests on Arch + Hyprland after pulling changes.
- Do not update docs unless the user explicitly asks.
- Do not `git push`; stage and commit locally, then tell the user so they can push from VS Code.
- Keep implementation moving; make practical, repo-consistent changes.
- Preserve unrelated user changes if the worktree is dirty.

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
| `assets` | Screenshots/demo media |
| `scripts` | Helper scripts |

Important QML files:

- `Main.qml`: owns shell orchestration, theme, localization, app metadata, dock actions and panel wiring.
- `SideDock.qml`: left/right side dock container.
- `DockButton.qml`: dock item visuals, tooltip, active/minimized state.
- `Launcher.qml`: app launcher with search, categories and install status.
- `SettingsPanel.qml`: uNexus Settings, including language selector and theme/stats settings.
- `GameSettingsPanel.qml`: GameMode, MangoHud and gaming launcher checks.
- `FilesPanel.qml`: uNexus Files MVP.
- `FirstSetupPanel.qml`: first-run checklist and copied install commands.
- `ContextMenu.qml`: desktop right-click menu.
- `LoginScreen.qml`: login flow.
- `FpsOverlay.qml`: shell stats overlay.

Important C++ backends:

- `AppLauncher`: app detection, Flatpak detection, launch/focus/close, MangoHud/GameMode wrappers, clipboard.
- `GameMode`: Game Mode state/toggle.
- `SystemInfo`: battery and network state.
- `SystemStats`: CPU/GPU/RAM/TEMP metrics.
- `UserSettings`: persistent theme, language, stats overlay and first setup state.
- `FileManager`: directory listing, common places, open, create folder, rename, trash.

---

## What Already Exists

Core shell:

- Login screen with password `1234` or blank.
- Animated geometric wallpaper and top bar.
- Top bar clock/date/network/battery/Game Mode toggle.
- Notification center.
- Desktop context menu.
- Persistent theme and stats overlay preferences.

Dock:

- Separate left system dock and right gaming dock.
- System side: uNexus Files, Browser, uNexus Settings, Terminal, First Setup.
- Gaming side: Steam, Lutris, Heroic, Bottles, Game Settings.
- Auto-hide side dock behavior.
- Original application icons are resolved when possible through icon names.
- Dock tooltips and action menu.
- App states for closed/open/minimized or hidden.
- Internal panels no longer remain visually active after closing.

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
- Common places sidebar.
- Directory navigation.
- Open files through desktop services.
- Create folder.
- Rename item.
- Move item to trash through `gio trash`.

Localization:

- English is the source/fallback language.
- PT-BR localization is implemented.
- Language can be selected in uNexus Settings.
- `UserSettings.languageCode` persists `en` or `pt-BR`.
- QML uses `root.tr(...)`, `root.trAppMessage(...)` and `root.trLabelMessage(...)`.

---

## Recent Commits

- `b119e2f feat(shell): add pt-br localization`
- `3da4335 fix(dock): recalculate internal app state`
- `9d7d4af fix(dock): clear internal panel state`
- `9113bea feat(dock): add app window states`
- `dbb81b7 feat(files): add uNexus files mvp`
- `a3761db feat(dock): extract side dock components`
- `5300a24 feat(dock): polish side dock behavior`
- `21ad426 docs: expand roadmap into detailed product plan`

---

## Latest Updates To Remember

The most recent work added project-wide PT-BR localization:

- `UserSettings` gained `languageCode`.
- `SettingsPanel.qml` gained language selection.
- `Main.qml` owns the current translation dictionary and helper functions.
- Main shell, dock, launcher, settings, game settings, first setup, uNexus Files, context menu, login and stats overlay now route visible text through localization helpers.

Docs were then updated to reflect:

- uNexus Files MVP.
- Dock open/minimized/closed state work.
- PT-BR localization.
- Arch + Hyprland as the real test target.
- Windows as editing-only in this workflow.

---

## Known Gaps / Risks

- No full automated test/build validation was run on Windows.
- Real validation should happen on Arch + Hyprland.
- Localization is currently a simple QML dictionary, not Qt `.ts/.qm` translation files.
- English strings are still the stable source keys, so changing English display text can break PT-BR lookup unless dictionary keys are updated too.
- uNexus Files is an MVP and does not yet have copy/cut/paste, sorting, breadcrumbs, preview, delete confirmation or multi-select.
- Some icons are still text/emoji fallbacks when the original app icon cannot be found.
- GameMode/MangoHud integration needs more real-game validation.
- Install flows copy commands; they do not yet run privileged or Flatpak installs directly.
- The shell still relies heavily on Hyprland behavior through `hyprctl`.

---

## Most Important Next Work

Recommended next priorities:

1. Test the PT-BR selector on Arch + Hyprland:
   - Open uNexus Settings.
   - Switch to Português.
   - Confirm dock, launcher, panels, notifications and uNexus Files update.
   - Restart shell and confirm language persists.

2. Continue uNexus Files toward a real `unexus-files`:
   - Breadcrumb navigation.
   - Sorting by name/type/date/size.
   - Copy/cut/paste.
   - Delete/trash confirmations.
   - Multi-select.
   - Preview pane or details pane.
   - Keyboard navigation.

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
   - `.desktop` entry.
   - Hyprland session file.
   - Arch `PKGBUILD`.
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
- `docs/contributing.md`: contribution guidance.

---

## Handoff Rule Of Thumb

When continuing this project, read this file first, then check:

```bash
git status --short
git log --oneline -8
```

If the user asks for implementation, make the change, validate with `git diff --check`, then stage and commit locally. Do not push unless the user explicitly changes the workflow.
