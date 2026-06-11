#!/usr/bin/env sh
set -eu

version_root="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
default_iso="$version_root/out/unexus-os-0.0.1-x86_64.iso"

usage() {
    cat <<EOF
Usage: sudo sh ISO/0.0.1/write-usb.sh /dev/sdX [path/to.iso]

Writes the uNexus OS ISO to a whole USB block device.
This erases the target device completely.

Examples:
  lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS
  sudo sh ISO/0.0.1/write-usb.sh /dev/sdb
  sudo sh ISO/0.0.1/write-usb.sh /dev/sdb ISO/0.0.1/out/unexus-os-0.0.1-x86_64.iso
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

target="${1:-}"
iso="${2:-$default_iso}"

if [ -z "$target" ]; then
    usage >&2
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    printf '[uNexus USB] run as root: sudo sh ISO/0.0.1/write-usb.sh %s\n' "$target" >&2
    exit 1
fi

if [ ! -f "$iso" ]; then
    printf '[uNexus USB] ISO not found: %s\n' "$iso" >&2
    printf '[uNexus USB] build it first: sudo sh ISO/0.0.1/build-iso.sh\n' >&2
    exit 1
fi

if [ ! -b "$target" ]; then
    printf '[uNexus USB] target is not a block device: %s\n' "$target" >&2
    exit 1
fi

target_type="$(lsblk -dnro TYPE "$target" 2>/dev/null || true)"
if [ "$target_type" != "disk" ]; then
    printf '[uNexus USB] target must be the whole disk, not a partition: %s\n' "$target" >&2
    exit 1
fi

printf '[uNexus USB] ISO: %s\n' "$iso"
printf '[uNexus USB] target device:\n'
lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS "$target"
printf '\n[uNexus USB] This will erase all data on %s.\n' "$target"
printf '[uNexus USB] Type WRITE to continue: '
read answer

if [ "$answer" != "WRITE" ]; then
    printf '[uNexus USB] cancelled\n'
    exit 1
fi

printf '[uNexus USB] unmounting mounted partitions under %s\n' "$target"
for mountpoint in $(lsblk -nrpo MOUNTPOINTS "$target" | tr ' ' '\n' | sed '/^$/d'); do
    umount "$mountpoint"
done

printf '[uNexus USB] writing image\n'
dd if="$iso" of="$target" bs=4M status=progress conv=fsync
sync

printf '[uNexus USB] done. You can now boot from %s.\n' "$target"
