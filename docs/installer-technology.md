# Installer Technology

uNexus should feel installable like a consumer OS: the user double-clicks an installer, follows a visual flow, and gets a working system or application without learning build commands.

## Decision

Use a graphical uNexus Installer as the user-facing installer experience for shell installation and repair.

The installer should be a Qt/QML app that wraps native Linux installation backends:

- `pacman` / Arch packages for system-level uNexus components;
- Flatpak for user applications where sandboxed app delivery makes sense;
- `scripts/setup.sh` only as the development and recovery fallback;
- `scripts/install-os.sh` as the guarded native disk-install backend for the live ISO;
- the existing `ISO/0.0.2` Archiso profile as the current live image foundation;
- Calamares as a future option, not the current integrated installer.

In short: graphical shell installer first, native package/backend scripts underneath, and a future graphical disk flow on top of the current native installer backend.

## Why

- The target experience is closer to Windows: double-click, confirm, install, launch.
- uNexus still needs native system integration for sessions, binaries, helper scripts and Hyprland behavior.
- `pacman` gives clean install, upgrade, dependency and uninstall behavior behind the scenes.
- A Qt/QML installer can match the uNexus visual language instead of exposing terminal commands.
- Flatpak can provide a friendly app-install path for common desktop/gaming applications.

## Installer Layers

| Layer | Technology | Purpose |
|---|---|---|
| User-facing app installer | Qt/QML uNexus Installer | Double-click visual shell install, repair, diagnostics and removal flow |
| Package backend | Arch `PKGBUILD` / `makepkg` / `pacman -U` | Proper install, upgrade and uninstall on Arch |
| Application backend | Flatpak / Flathub | Friendly install path for user apps |
| Development install | `scripts/setup.sh` | Fast local install from a cloned repository |
| Live OS image | `ISO/0.0.2` / Archiso | Current bootable uNexus OS live image |
| Full OS installer backend | `scripts/install-os.sh` | Guarded UEFI/systemd-boot disk installation from the live environment |
| Future graphical disk installer | Qt/QML disk flow or Calamares | User-facing disk installation without terminal commands |

## Non-goals For Now

- AppImage is not the main backend because uNexus is a shell/session, not only a portable app.
- Flatpak is not the backend for shell/session files because compositor integration needs host-level install.
- Debian/RPM packages can be added later after the Arch target is solid.

## Near-term Implementation Plan

1. Keep hardening `packaging/arch/PKGBUILD` and package metadata.
2. Add a release packaging script that outputs a `.pkg.tar.zst`.
3. Continue improving the existing Qt/QML `unexus-installer` app with clearer install, repair, diagnostics and uninstall flows.
4. Keep `pkexec` as the graphical privilege boundary for shell install/repair actions.
5. Maintain `.desktop` entries for shell and installer launch.
6. Keep `sudo sh scripts/setup.sh` documented for development and repair.
7. Harden `ISO/0.0.2` with boot polish, hardware validation, hosted downloads and clearer recovery behavior.
8. Wrap `scripts/install-os.sh` in a graphical disk installation flow, or replace that layer with Calamares once the partitioning/user/bootloader UX is ready.
