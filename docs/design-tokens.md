# Design Tokens

uNexus uses QML design tokens as the first layer of the visual system.

The source of truth is:

```text
packages/unexus-shell/qml/DesignTokens.qml
```

`Main.qml` exposes compatibility aliases such as `root.spaceMd`, `root.radiusLg`, `root.motionBase`, `root.surfaceRaised` and `root.textPrimary`. Existing panels should continue using those root aliases so the whole shell can be tuned from one place.

The token system is now the default visual contract for Launcher, Settings, Game Settings, First Setup, Files, docks, menus and notifications.

## Token Groups

| Group | Purpose |
|---|---|
| `fontFamily` | Default UI font |
| `space` | Spacing scale |
| `layout` | Panel margins, breakpoints and multi-monitor offsets |
| `radius` | Border radius scale |
| `border` | Border widths and neutral border colors |
| `motion` | Animation timing scale |
| `type` | Font size scale |
| `surface` | Base, panel, raised and hover surfaces |
| `text` | Primary, secondary and muted text colors |
| `status` | Success, warning, danger, info and idle colors |
| `shadow` | Shared shadow colors |

## Rules

- Prefer `root` token aliases in QML panels.
- Add a new token only when at least two surfaces or components need it.
- Keep motion fast and functional; avoid decorative delays.
- Use spring motion for position, scale and size changes. Keep opacity on short timed fades.
- Use semantic colors for state and status instead of hardcoded one-off colors.
- Theme-specific accent colors still live in `Main.qml` because they are selected at runtime.

## Spring Motion

The shell exposes spring values from `DesignTokens.qml` through `root.motionPanelSpring`, `root.motionPanelDamping`, `root.motionDockSpring`, `root.motionDockDamping` and related aliases.

Use them for transitions that should feel physical:

- panel entrance and dismissal;
- dock hover size changes;
- dock click bounce;
- minimized/running indicators.

Avoid springing opacity. A spring on alpha usually reads as flicker instead of weight.

## Relationship To Liquid Glass

Liquid Glass uses the same accent, radius, border, surface and shadow language exposed by the token layer. That keeps glass surfaces from becoming a separate visual style: they are the elevated material form of the same uNexus system.
