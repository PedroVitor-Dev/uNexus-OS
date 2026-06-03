# Dock icon keeps active background after internal panel closes

## Summary

The dock icon for internal apps, especially **uNexus Files**, keeps the active accent background after the panel is closed. Visually, it looks like the app is still active/open even though the internal panel is no longer visible.

This is not the regular hover background from `DockButton.qml`:

```qml
color: dockMouseArea.containsMouse ? "#2a2a2a" : "transparent"
```

The visible stuck background appears to come from the active accent overlay:

```qml
Rectangle {
    color: dockButton.accentColor
    opacity: dockButton.active && !dockButton.closed ? 0.08 : 0.0
}
```

So the issue is likely that `dockButton.active` remains `true`, meaning `appState` is still resolving to `"active"` or `"running"` after the internal panel closes.

## Environment

- OS target: Arch Linux
- Compositor: Hyprland
- Shell: `unexus-shell`
- UI: Qt6/QML
- Relevant components:
  - `packages/unexus-shell/qml/Main.qml`
  - `packages/unexus-shell/qml/SideDock.qml`
  - `packages/unexus-shell/qml/DockButton.qml`
  - `packages/unexus-shell/qml/FilesPanel.qml`
  - `packages/unexus-shell/qml/SettingsPanel.qml`
  - `packages/unexus-shell/qml/GameSettingsPanel.qml`
  - `packages/unexus-shell/qml/FirstSetupPanel.qml`

## Steps To Reproduce

1. Start `unexus-shell` on Arch + Hyprland.
2. Open the side dock.
3. Click **uNexus Files**.
4. Confirm the uNexus Files panel opens and the dock icon becomes active.
5. Close uNexus Files using the panel close button or by clicking outside the panel.
6. Reopen/observe the dock.

## Actual Behavior

The uNexus Files dock icon still shows the active accent background after the panel is closed.

The panel itself is no longer visible, but the dock icon still looks active/open.

## Expected Behavior

After closing uNexus Files:

- the internal panel should set its dock state to closed;
- `DockButton.appState` should resolve to `"closed"`;
- `dockButton.active` should become `false`;
- the accent background opacity should return to `0.0`;
- only the normal hover background should appear when the mouse is actually over the icon.

## Current Implementation Notes

Internal panels expose:

```qml
property bool dockActive: false
```

Since this is a QML property, it automatically provides a `dockActiveChanged` signal.

`Main.qml` listens to panel state changes and increments state versions:

```qml
onDockActiveChanged: {
    root.panelStateVersion++
    root.dockStateVersion++
}
```

Internal app state is currently derived through `Main.qml` and passed into `SideDock.qml` / `DockButton.qml` as an override.

Recent attempted fix:

- pass `appStateVersion` explicitly into `SideDock.stateFor(...)`;
- pass that value through to `Main.internalDockState(...)`;
- use it to force delegate binding reevaluation.

That did not resolve the stuck active background in real testing.

## Suspected Cause

This may still be a QML binding invalidation problem, or the active state may be coming from a different path than expected.

Possibilities to investigate:

- `dockActive` is not being set to `false` in every close path.
- `hideAnim` / delayed visibility changes are leaving state temporarily or permanently active.
- `DockButton.appStateOverride` is not receiving `"closed"` when expected.
- `DockButton.appState` is falling back to process/window detection even for an internal app.
- An internal app object does not have `internalAction` as expected at runtime.
- The active background is being triggered by `"running"` for an internal app, even though internal apps should never use process fallback.

## Debug Suggestions

Add temporary logs around:

```qml
console.log("panel dockActive", unexusFiles.dockActive)
console.log("panelStateVersion", root.panelStateVersion)
console.log("internalDockState", app.internalAction, state)
console.log("dock appStateOverride", app.label, appStateOverride)
console.log("dock appState", app.label, appState)
console.log("dock active", app.label, active)
```

Suggested places:

- `FilesPanel.show()`
- `FilesPanel.hide()`
- `Main.internalDockState(...)`
- `SideDock.stateFor(...)`
- `DockButton.onAppStateChanged`
- `DockButton.onActiveChanged`

## Acceptance Criteria

- Closing uNexus Files returns its dock icon to the closed visual state.
- Closing uNexus Settings, Game Settings and First Setup does the same.
- External apps still show correct states:
  - active/open;
  - minimized/hidden;
  - closed.
- Hover background still works only while hovering.
- The active accent background only appears while the app/panel is actually open or running.

## Extra Context

This bug has been reproduced after the dock state refactor and after adding explicit state version propagation. The likely fix should focus on making the internal panel state source fully declarative/reactive or directly binding each internal dock app to the corresponding panel's `dockActive` property instead of routing through generic JavaScript functions.
