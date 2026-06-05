# uNexus Visual Language

uNexus uses a compact, gaming-first visual system. The shell should feel like a fast cockpit: dense enough for repeated use, clear enough for first boot, and polished without turning into a marketing page.

The source of truth is:

```text
packages/unexus-shell/qml/DesignTokens.qml
```

`Main.qml` exposes compatibility aliases such as `root.spaceMd`, `root.radiusLg`, `root.motionBase`, `root.surfaceRaised`, `root.textPrimary`, `root.rowHeight` and `root.textTitle`. Panels should prefer these root aliases so the shell can be tuned from one place.

## Principles

- **Compact by default**: system UI should conserve space and keep workflows close together.
- **Readable at laptop scale**: primary text must remain legible at 720p and compact Hyprland layouts.
- **Motion is feedback**: animations explain state changes, focus, launching, minimizing or hiding. They should not delay actions.
- **Glass is material, not decoration**: Liquid Glass is the elevated surface language for panels, menus, docks and notifications.
- **Accent means state**: active, focused, selected or actionable elements may use the theme accent. Passive chrome should use neutral surfaces.
- **No nested-card look**: sections are structured surfaces; cards are for repeated items, modals and framed tools only.

## Spacing

The spacing scale is based on small increments that fit dense desktop UI.

| Token | Value | Use |
|---|---:|---|
| `space.xxs` | 2 | hairline offsets, tiny icon adjustments |
| `space.xs` | 4 | tight internal separation |
| `space.sm` | 8 | default control grouping |
| `space.md` | 12 | row padding and icon/text spacing |
| `space.lg` | 16 | panel internals and labels |
| `space.xl` | 18 | dock/panel breathing room |
| `space.xxl` | 24 | large panel separation |
| `space.section` | 32 | major section separation |

Layout tokens define reusable shell dimensions: panel margins, control heights, row heights, toolbar height, sidebar width, preview width and dock item sizes. Use semantic layout tokens when a value describes a repeated UI role.

## Typography

Default UI font: `Exo 2`. Fallback: `Noto Sans`.

| Token | Size | Use |
|---|---:|---|
| `type.micro` | 9 | compact icon labels and metadata |
| `type.tiny` | 10 | chips, section captions, small statuses |
| `type.small` | 12 | secondary labels and compact buttons |
| `type.body` | 13 | normal panel rows |
| `type.ui` | 15 | prominent controls |
| `type.lg` | 16 | emphasized row text |
| `type.title` | 22 | panel titles |
| `type.display` | 28 | first-viewport shell identity moments |
| `type.hero` | 36 | login/boot identity only |

Typography rules:

- Use `type.title` for panel titles, not oversized display type.
- Use `type.tiny` or `type.small` for status chips and metadata.
- Keep letter spacing at `0` by default.
- Use `trackingSection` only for short uppercase section labels.
- Use `trackingBrand` only for the uNexus/SF identity mark.
- Prefer `weightSemibold` for labels and `weightBold` only for high-emphasis values.

## Motion

Motion tokens are named by intent, not only duration.

| Token | Duration | Use |
|---|---:|---|
| `motion.instant` | 60ms | press feedback and micro-state changes |
| `motion.quick` | 90ms | hover and chip transitions |
| `motion.base` | 140ms | normal fade out and simple state changes |
| `motion.expressive` | 180ms | panel fade in and visible UI response |
| `motion.entrance` | 240ms | rare first appearance or setup moments |

Semantic motion aliases:

- `hover`: hover color/opacity changes.
- `press`: click feedback.
- `fadeIn` and `fadeOut`: opacity only.
- `panelIn` and `panelOut`: panel visibility transitions.
- `dockReveal` and `dockHide`: dock auto-hide or reveal motion.

Spring rules:

- Use spring motion for position, scale and size.
- Use timed animations for opacity and color.
- Do not spring opacity.
- Panel movement uses `panelSpring`, `panelDamping` and `panelEpsilon`.
- Dock item resizing and active indicators use `dockSpring`, `dockDamping` and `dockEpsilon`.
- Control press/bounce uses `controlSpring` and `controlDamping`.

## Surfaces

Surface roles:

| Token | Use |
|---|---|
| `surface.base` | main shell panel base |
| `surface.panel` | deep panel background |
| `surface.raised` | rows, controls and individual repeated items |
| `surface.hover` | hover state |
| `surface.strongHover` | selected or strong hover state |
| `surface.field` | inputs and path fields |
| `surface.elevated` | framed tool areas |

Border roles:

- `border.subtle`: quiet separation.
- `border.muted`: normal panel/control border.
- `border.strong`: focused or high-contrast borders.
- `border.focus`: focus/active border width.

## Radius

- `radius.sm` and `radius.md`: rows, buttons, chips and fields.
- `radius.lg` and `radius.xl`: panels and framed tools.
- `radius.dock`: side dock shell.
- `radius.pill`: chips and indicators only.

Cards should stay at `8px` radius or less unless they are a panel shell, dock shell or glass material.

## Component Rules

- Toolbars use `toolbarHeight` and `space.sm` gaps.
- Normal rows use `rowHeight`; dense rows use `denseRowHeight`.
- Primary controls use `controlHeight` or `compactControlHeight`.
- Sidebars use `sidebarWidth` or `sidebarWidthCompact`.
- File previews use `previewWidth` until the file manager gets a responsive split-view system.
- Use icon buttons for common actions when an icon exists; text buttons are for clear commands.
- Avoid visible instructional copy inside the app. Controls should be self-evident through labels, states and placement.

## Themes

Theme colors still live in `Main.qml` because they are selected at runtime. The token layer defines neutral structure; themes provide accent, background and glow.

A theme should change mood without changing component layout. Do not create theme-specific spacing, typography or motion.

## Migration Rule

When touching a panel, replace nearby hardcoded spacing, motion or type values only if the change is local and low-risk. Do not do broad mechanical churn just to use tokens.
