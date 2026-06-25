# Distro Implementation Status

This tracks the pasted "Shell to real gaming distro" guide against the current repository.

Status legend:

- `[x]` Done in the repository.
- `[~]` Partially done or implemented but not validated on the target host.
- `[ ]` Not implemented yet.

## Checklist

| Guide step | Status | Repository state |
|---|---:|---|
| Package `unexus-shell` as an Arch package | `[x]` | `packaging/arch/PKGBUILD` builds the shell and installer through CMake. `scripts/package-arch.sh` now emits package artifacts under `dist/arch/packages`. |
| Publish a simple pacman repository | `[x]` | `scripts/package-arch.sh` can create `dist/arch/repo/unexus.db.tar.gz` with `repo-add`; `ISO/0.0.2/build-iso.sh` also creates a temporary `unexus-local` repo during ISO builds. |
| Create a custom archiso profile | `[x]` | `ISO/0.0.2/profile` is the current live ISO profile. It includes uNexus branding, boot modes, package list, pacman config and live-system customization. |
| Add Hyprland, Qt, gaming runtime and `unexus-shell` to ISO packages | `[x]` | `ISO/0.0.2/profile/packages.x86_64` includes Hyprland, Qt6, Flatpak, GameMode, MangoHud, Vulkan, fonts, icons and `unexus-shell`. |
| Rename ISO identity | `[x]` | `profiledef.sh` sets `iso_name=unexus-os`, `iso_label=UNEXUS_002`, uNexus publisher/application metadata and `install_dir=unexus`. |
| Start the uNexus session automatically in the live ISO | `[x]` | The live image installs `uNexus` session files and uses the session wrapper/recovery flow instead of a plain Hyprland-only desktop. |
| Plug the installer from the live ISO | `[x]` | `scripts/install-os.sh` is installed as `unexus-install-os`; `unexus-installer` has a minimal Qt/QML disk install UI that calls the guarded backend through `pkexec`. |
| Build ISO | `[x]` | `sudo sh ISO/0.0.2/build-iso.sh` builds the package, creates a local repo and runs `mkarchiso`. |
| Test ISO in VM | `[~]` | `scripts/test-iso-vm.sh` and `scripts/validate-iso-release.sh` exist. Current checked-in test result is blocked on Windows because `sh`/QEMU are unavailable. A passing Arch/QEMU result is still needed. |
| Test installed system in VM | `[~]` | Disk installer backend exists, but a destructive install/reboot VM result is not checked in yet. |
| Test hardware | `[ ]` | Hardware validation reports are not checked in yet. |
| GPU driver manager | `[x]` | Settings has a Hardware section, GPU detection, recommended-driver mapping and a rollback-aware Driver Wizard. |

## Current Next Required Runs

Run on the Arch build/test host:

```sh
sudo pacman -S base-devel cmake git ninja pacman-contrib archiso qemu-full edk2-ovmf
sh scripts/package-arch.sh
sudo sh ISO/0.0.2/build-iso.sh
sh scripts/test-iso-vm.sh --uefi-only --timeout 300
```

After a successful run, add or update a file under `docs/test-results/YYYYMMDD-qemu.md` with the ISO path, command, serial marker and final pass/fail result.
