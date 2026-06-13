# uNexus OS ISO 0.0.1

This is the first bootable ISO profile for uNexus OS.

It is an Archiso-based live image that boots into a `unexus` live user, starts Hyprland, and launches the uNexus shell through `unexus-session`.

Project website: <https://unexus-os.vercel.app>

## Build

Run on Arch Linux:

```sh
cd ~/uNexus-OS
sudo sh ISO/0.0.1/build-iso.sh
```

The build script first creates a local `unexus-shell` Arch package from the current checkout, publishes it in a temporary local pacman repository and lets Archiso install that package through `packages.x86_64`. The live image still carries the repository under `/opt/unexus-os` for repair, development and disk installation scripts, but the shell is no longer compiled during `customize_airootfs.sh`.

The generated image is written to:

```text
ISO/0.0.1/out/
```

## VM Smoke Test

After building the image, boot it in QEMU and wait for the live system smoke marker:

```sh
sh scripts/test-iso-vm.sh
```

The test runs legacy BIOS and UEFI boots when QEMU and OVMF firmware are installed. On Arch Linux:

```sh
sudo pacman -S qemu-full edk2-ovmf
```

For quick BIOS-only validation:

```sh
sh scripts/test-iso-vm.sh --bios-only
```

## Release Validation

Before publishing an ISO, run the release gate:

```sh
sh scripts/validate-iso-release.sh --build
```

This runs static checks, rebuilds the project, optionally builds the ISO, writes `SHA256SUMS` and runs QEMU smoke tests when QEMU is available. Reports are stored under:

```text
ISO/0.0.1/out/release-checks/
```

If `out/` is not writable by the current user, reports and fallback checksums are written to `/tmp/unexus-release-checks/`.

Use `--require-vm` when a release must fail if BIOS/UEFI VM smoke tests cannot run.

## Boot Recovery Modes

The ISO boot menu includes additional recovery entries:

- `uNexus OS 0.0.1` boots the normal live session.
- `Safe Graphics` keeps kernel modesetting available, avoids proprietary NVIDIA modules and starts uNexus with software rendering hints.
- `Recovery` opens the text recovery menu on tty1 without depending on Hyprland.
- `Doctor` runs `uNexus Doctor`, writes `~/.local/state/unexus/logs/live-doctor.log`, then opens the recovery menu.
- `Rollback Settings` rolls back the latest uNexus settings backup, or resets settings when no backup can be restored, then opens the recovery menu.

If the build host is missing archiso tools:

```sh
sudo pacman -S archiso base-devel rsync
```

## Write to USB

Find the USB disk:

```sh
lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS
```

Write the generated ISO to the whole USB device, not a partition:

```sh
sudo sh ISO/0.0.1/write-usb.sh /dev/sdX
```

Replace `/dev/sdX` with the correct USB disk. The script shows the target with `lsblk` and requires typing `WRITE` before erasing it.

## Install to Disk

The first native disk installer backend is available as a guarded script. Preview the plan first:

```sh
sudo sh scripts/install-os.sh --target /dev/sdX --username pedro --timezone America/Fortaleza
```

Run the destructive install only after confirming the target is the whole disk you want to erase:

```sh
sudo sh scripts/install-os.sh --target /dev/sdX --username pedro --timezone America/Fortaleza --execute --confirm ERASE-AND-INSTALL
```

The script creates a GPT UEFI install with a 1 GiB EFI system partition, a root partition, `pacstrap`, `fstab`, locale/timezone/hostname/user setup, systemd-boot and uNexus provisioning.

The installer defaults to automatic package source selection. When the live ISO carries `/var/cache/pacman/pkg`, it installs from that cache without using network mirrors:

```sh
sudo sh scripts/install-os.sh --target /dev/sdX --username pedro --timezone America/Fortaleza --offline --execute --confirm ERASE-AND-INSTALL
```

Use `--online` to force repository downloads instead.

## What 0.0.1 Includes

- Arch Linux live base
- Hyprland Wayland session
- uNexus shell installed from this repository
- Live `unexus` user with password `unexus`
- Autologin on tty1
- Normal, safe graphics, recovery, doctor and rollback boot modes
- Pacman package cache retained for offline disk installs
- First setup defaults for language, timezone, keyboard, updates and gaming essentials
- NetworkManager, PipeWire, Polkit and XDG portals
- Qt6 runtime/build stack
- GameMode, MangoHud and Vulkan tools
- Flatpak ready for Flathub
- Graphical Polkit authentication agent
- Papirus, Breeze, Adwaita and hicolor icon themes
- Qt SVG/imageformat plugins for app icons and image previews
- Noto, emoji, DejaVu and Liberation fonts
- GTK/Qt session defaults for dark styling and cursor consistency
- Fonts and disk maintenance tools for live recovery work
- Kitty, Neovim, btop and common recovery tools

## Notes

This is a bootable live ISO foundation, not the final graphical disk installer.

Brave remains the default browser target in the shell/session integration. The live ISO keeps the browser layer packageable, but bundling Brave directly requires a binary package source or an AUR build pipeline during ISO creation.
