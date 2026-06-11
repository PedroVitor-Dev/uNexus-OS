# Installer Technology

uNexus should feel installable like a consumer OS: the user double-clicks an installer, follows a visual flow, and gets a working system or application without learning build commands.

## Decision

Use a graphical uNexus Installer as the user-facing installer experience.

The installer should be a Qt/QML app that wraps native Linux installation backends:

- `pacman` / Arch packages for system-level uNexus components;
- Flatpak for user applications where sandboxed app delivery makes sense;
- `scripts/setup.sh` only as the development and recovery fallback;
- the existing `ISO/0.0.1` Archiso profile as the live image foundation;
- Calamares or the native graphical installer later for installing the full uNexus OS onto disk.

In short: graphical installer first, native package backend underneath.

## Why

- The target experience is closer to Windows: double-click, confirm, install, launch.
- uNexus still needs native system integration for sessions, binaries, helper scripts and Hyprland behavior.
- `pacman` gives clean install, upgrade, dependency and uninstall behavior behind the scenes.
- A Qt/QML installer can match the uNexus visual language instead of exposing terminal commands.
- Flatpak can provide a friendly app-install path for common desktop/gaming applications.

## Installer Layers

| Layer | Technology | Purpose |
|---|---|---|
| User-facing app installer | Qt/QML uNexus Installer | Double-click visual install flow |
| Package backend | Arch `PKGBUILD` / `makepkg` / `pacman -U` | Proper install, upgrade and uninstall on Arch |
| Application backend | Flatpak / Flathub | Friendly install path for user apps |
| Development install | `scripts/setup.sh` | Fast local install from a cloned repository |
| Live OS image | `ISO/0.0.1` / Archiso | Bootable uNexus OS live image |
| Full OS installer | Calamares or native installer | Disk installation from the live environment |

## Non-goals For Now

- AppImage is not the main backend because uNexus is a shell/session, not only a portable app.
- Flatpak is not the backend for shell/session files because compositor integration needs host-level install.
- Debian/RPM packages can be added later after the Arch target is solid.

## Near-term Implementation Plan

1. Harden `packaging/arch/PKGBUILD` and package metadata.
2. Add a release packaging script that outputs a `.pkg.tar.zst`.
3. Build a Qt/QML `unexus-installer` app with install, repair, update and uninstall flows.
4. Use `pkexec` for privilege escalation instead of asking users to run terminal commands.
5. Add `.desktop` entries so the installer can be launched by double-click.
6. Keep `sudo sh scripts/setup.sh` documented for development and repair.
7. Harden `ISO/0.0.1` with boot polish, hardware validation, hosted downloads and clearer recovery behavior.
8. Add Calamares or native disk installation once the shell session, recovery session and provisioning flows are mature.
