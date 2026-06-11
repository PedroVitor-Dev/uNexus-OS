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

The generated image is written to:

```text
ISO/0.0.1/out/
```

If the build host is missing archiso tools:

```sh
sudo pacman -S archiso rsync
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

## What 0.0.1 Includes

- Arch Linux live base
- Hyprland Wayland session
- uNexus shell installed from this repository
- Live `unexus` user with password `unexus`
- Autologin on tty1
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
