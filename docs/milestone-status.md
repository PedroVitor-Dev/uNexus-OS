# uNexus Installation Milestone Status

This document tracks the near-term installation plan against the current repository state.

Status legend:

- `[x]` Done in the repository.
- `[~]` Partially done, usable but not complete.
- `[ ]` Not implemented yet.

## Summary

| Planned window | Milestone | Status | Current state |
|---|---|---:|---|
| Week 1-2 | Create `PKGBUILD` for `unexus-shell` and CMake install target | `[x]` | `packaging/arch/PKGBUILD` builds through CMake and `packages/unexus-shell/CMakeLists.txt` installs binaries, sessions, desktop entries, scripts, assets and systemd service files. |
| Week 2-3 | Integrate Calamares in the ISO with partitioning, user creation and bootloader | `[~]` | Calamares is not integrated. A guarded native backend exists in `scripts/install-os.sh`, and `unexus-installer` now has a minimal Qt/QML disk-install UI for previewing and executing that backend. |
| Week 3-4 | Create `.desktop` entry and uNexus session file | `[x]` | Shell and installer desktop entries exist under `packaging/linux`; `uNexus` and `uNexus Recovery` session files are installed to `wayland-sessions`. |
| Week 4-5 | Test install in VM first, then real hardware | `[~]` | QEMU smoke-test scripts and release validation exist. `docs/test-results/20260615-qemu.md` records the current attempted UEFI run, blocked on Windows before VM startup because `sh` is unavailable. |
| Week 5-6 | First Setup Panel appears on first login after install | `[x]` | `Main.qml` opens `FirstSetupPanel` after login when `userSettings.firstSetupCompleted` is false; provisioning seeds first-setup defaults. |

## Detailed Notes

### Week 1-2: Package and CMake Install

Status: `[x]`

Evidence:

- `packaging/arch/PKGBUILD`
- `packaging/arch/PKGBUILD.iso`
- `packages/unexus-shell/CMakeLists.txt`

Implemented:

- Builds `unexus-shell` and `unexus-installer`.
- Installs `unexus-shell`, `unexus-installer`, `unexus-session`, `unexus-recovery-session`, `unexus-recovery-menu`, `unexusctl`, `unexus-doctor` and `unexus-install-os`.
- Installs application `.desktop` files, display-manager session entries, icon/wallpaper assets and `unexus-driver-rollback.service`.

Still needed:

- Run a clean `makepkg` validation on a fresh Arch VM and record the result.
- Add a release packaging helper that emits a final `.pkg.tar.zst` artifact for publishing.

### Week 2-3: Calamares or Disk Installer

Status: `[~]`

Evidence:

- `scripts/install-os.sh`
- `scripts/provision-system.sh`
- `packages/unexus-installer`
- `ISO/0.0.2/README.md`

Implemented:

- Native guarded disk installer backend with dry-run by default.
- Whole-disk UEFI install path with GPT, EFI partition, root partition, `pacstrap`, `fstab`, locale/timezone/keymap/hostname/user setup and systemd-boot.
- Optional offline package-cache install from the live ISO.
- System provisioning for Hyprland session, Flatpak/Flathub, GameMode/MangoHud and gaming launchers.

Not implemented:

- Calamares is not integrated in the ISO.
- Minimal graphical disk-install controls exist in `unexus-installer` and call `scripts/install-os.sh` through `pkexec`.
- No graphical disk picker or advanced partitioning review yet.
- No GRUB path yet; current supported bootloader path is systemd-boot.
- No checked-in automated destructive install test result yet.

### Week 3-4: Desktop Entry and Session File

Status: `[x]`

Evidence:

- `packaging/linux/io.github.PedroVitorDev.uNexusShell.desktop`
- `packaging/linux/io.github.PedroVitorDev.uNexusInstaller.desktop`
- `packaging/linux/unexus.desktop`
- `packaging/linux/unexus-recovery.desktop`
- `packaging/linux/unexus-session`
- `packaging/linux/unexus-recovery-session`

Implemented:

- Display managers can show `uNexus` and `uNexus Recovery`.
- The normal session generates a live Hyprland config, starts the Polkit agent when available and launches `unexus-shell`.
- The recovery session opens the TUI recovery menu.
- The normal session opens recovery automatically when the shell crashes.

Still needed:

- Validate the session entries across at least SDDM and one additional display manager, or document SDDM as the only supported target for now.

### Week 4-5: VM and Real Hardware Testing

Status: `[~]`

Evidence:

- `scripts/test-iso-vm.sh`
- `scripts/validate-iso-release.sh`
- `ISO/0.0.2/profile/airootfs/usr/local/bin/unexus-live-smoke-test`

Implemented:

- QEMU BIOS and UEFI smoke-test script.
- Release validation script with static checks, optional ISO rebuild, checksums and VM tests.
- Live smoke marker checks for session files, services and `unexus-doctor`.

Still needed:

- Run and record a successful QEMU BIOS/UEFI pass for the current commit on an Arch host.
- Run and record a full install test in a disposable VM.
- Run and record hardware validation on at least one AMD/Intel and one NVIDIA path before calling the ISO safe for testers.

### Week 5-6: First Setup After Install

Status: `[x]`

Evidence:

- `packages/unexus-shell/qml/Main.qml`
- `packages/unexus-shell/qml/FirstSetupPanel.qml`
- `packages/unexus-shell/src/usersettings.cpp`
- `scripts/provision-system.sh`

Implemented:

- First Setup opens after login when `firstSetupCompleted` is false.
- The panel checks network/defaults, Flatpak, MangoHud, GameMode and common launchers.
- Settings can reopen First Setup later.
- Provisioning writes first-setup defaults from installer options.

Still needed:

- Add a pre-desktop readiness gate if the desired UX is to block the desktop until essential post-install checks complete.
- Add automated UI coverage for the first-login path.
