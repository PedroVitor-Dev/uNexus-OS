#!/usr/bin/env sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
target_disk=""
target_user="unexus"
target_hostname="unexus-os"
target_timezone="UTC"
target_locale="en_US.UTF-8"
target_keymap="us"
filesystem="btrfs"
confirm=""
dry_run=1
install_gaming_launchers=0
configure_bootloader=1
work_mount="/mnt/unexus-install"
log_file="/tmp/unexus-os-install.log"

usage() {
    cat <<EOF
Usage: sudo sh scripts/install-os.sh --target /dev/sdX [options]

Options:
  --target DISK          Whole disk to erase and install to, for example /dev/sda
  --username NAME        User to create (default: unexus)
  --hostname NAME        Hostname for the installed system (default: unexus-os)
  --timezone ZONE        Timezone, for example America/Fortaleza (default: UTC)
  --locale LOCALE        Locale to enable (default: en_US.UTF-8)
  --keymap KEYMAP        Console keymap (default: us)
  --filesystem TYPE      Root filesystem: btrfs or ext4 (default: btrfs)
  --gaming-launchers     Install Steam, Lutris, Heroic and Bottles Flatpaks after base install
  --execute              Actually write to disk; without this the script only prints the plan
  --confirm TEXT         Required with --execute. Must match: ERASE-AND-INSTALL
  -h, --help             Show this help

Password input:
  Set UNEXUS_USER_PASSWORD and optionally UNEXUS_ROOT_PASSWORD in the environment,
  or run from an interactive terminal and the script will prompt without echo.

This installer erases the selected whole disk and creates a UEFI systemd-boot install.
EOF
}

log() {
    printf '[uNexus OS install] %s\n' "$*"
}

die() {
    printf '[uNexus OS install] %s\n' "$*" >&2
    exit 1
}

need_command() {
    command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

run() {
    log "$*"
    "$@" >> "$log_file" 2>&1
}

part_prefix() {
    case "$1" in
        *[0-9]) printf '%sp' "$1" ;;
        *) printf '%s' "$1" ;;
    esac
}

is_whole_disk() {
    disk="$1"
    if [ -b "$disk" ]; then
        type="$(lsblk -dn -o TYPE "$disk" 2>/dev/null || true)"
        [ "$type" = "disk" ]
        return
    fi

    disk_name="${disk##*/}"
    type="$(lsblk -dn -o NAME,TYPE 2>/dev/null | awk -v name="$disk_name" '$1 == name { print $2; exit }')"
    [ "$type" = "disk" ]
}

validate_name() {
    value="$1"
    label="$2"
    case "$value" in
        ''|*[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-]*)
            die "$label contains unsupported characters: $value"
            ;;
    esac
}

validate_timezone() {
    value="$1"
    case "$value" in
        ''|/*|*..*|*[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._+-/]*)
            die "timezone contains unsupported characters: $value"
            ;;
    esac

    [ -f "/usr/share/zoneinfo/$value" ] || die "timezone not found: $value"
}

validate_user_name() {
    value="$1"
    case "$value" in
        ''|*[!abcdefghijklmnopqrstuvwxyz0123456789_-]*|[!abcdefghijklmnopqrstuvwxyz_]*)
            die "username must start with a lowercase letter or underscore and contain only lowercase letters, numbers, _ or -"
            ;;
    esac
}

read_secret() {
    prompt="$1"
    if [ ! -t 0 ]; then
        return 1
    fi

    printf '%s' "$prompt" >&2
    stty -echo
    IFS= read -r secret
    stty echo
    printf '\n' >&2
    printf '%s\n' "$secret"
}

cleanup_mounts() {
    if mountpoint -q "$work_mount/boot" 2>/dev/null; then
        umount -R "$work_mount/boot" >/dev/null 2>&1 || true
    fi
    if mountpoint -q "$work_mount" 2>/dev/null; then
        umount -R "$work_mount" >/dev/null 2>&1 || true
    fi
}

write_chroot_script() {
    root_part="$1"
    esp_part="$2"
    script_path="$work_mount/root/unexus-chroot-install.sh"

    cat > "$script_path" <<EOF
#!/usr/bin/env sh
set -eu

ln -sf "/usr/share/zoneinfo/$target_timezone" /etc/localtime
hwclock --systohc

sed -i 's/^#\($target_locale UTF-8\)/\1/' /etc/locale.gen
if ! grep -q '^$target_locale UTF-8' /etc/locale.gen; then
    printf '%s UTF-8\n' '$target_locale' >> /etc/locale.gen
fi
locale-gen
printf 'LANG=%s\n' '$target_locale' > /etc/locale.conf
printf 'KEYMAP=%s\n' '$target_keymap' > /etc/vconsole.conf
printf '%s\n' '$target_hostname' > /etc/hostname

cat > /etc/hosts <<HOSTS
127.0.0.1 localhost
::1 localhost
127.0.1.1 $target_hostname.localdomain $target_hostname
HOSTS

if ! id '$target_user' >/dev/null 2>&1; then
    useradd -m -G wheel,audio,video,storage,input -s /bin/bash '$target_user'
fi

printf '%%wheel ALL=(ALL:ALL) ALL\n' > /etc/sudoers.d/10-unexus-wheel
chmod 0440 /etc/sudoers.d/10-unexus-wheel

systemctl enable NetworkManager.service
systemctl enable systemd-timesyncd.service
systemctl enable sddm.service

bootctl install

root_uuid="\$(blkid -s UUID -o value '$root_part')"
cat > /boot/loader/loader.conf <<LOADER
default unexus-linux.conf
timeout 3
console-mode max
editor no
LOADER

cat > /boot/loader/entries/unexus-linux.conf <<ENTRY
title   uNexus OS
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options root=UUID=\$root_uuid rw quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0
ENTRY

UNEXUS_TARGET_USER='$target_user' \\
UNEXUS_INSTALL_GAMING_LAUNCHERS='$install_gaming_launchers' \\
UNEXUS_CONFIGURE_BOOTLOADER='$configure_bootloader' \\
PREFIX=/usr \\
sh /opt/unexus-os/scripts/install-system.sh
EOF

    chmod 0700 "$script_path"
    printf '%s\n' "$script_path"
}

set_passwords() {
    user_password="${UNEXUS_USER_PASSWORD:-}"
    root_password="${UNEXUS_ROOT_PASSWORD:-}"

    if [ -z "$user_password" ]; then
        user_password="$(read_secret "Password for $target_user: " || true)"
    fi
    [ -n "$user_password" ] || die "user password is required"

    if [ -z "$root_password" ]; then
        root_password="$user_password"
    fi

    printf '%s:%s\nroot:%s\n' "$target_user" "$user_password" "$root_password" |
        arch-chroot "$work_mount" chpasswd >> "$log_file" 2>&1
}

install_system() {
    prefix="$(part_prefix "$target_disk")"
    esp_part="${prefix}1"
    root_part="${prefix}2"

    : > "$log_file"
    trap cleanup_mounts EXIT INT TERM

    run wipefs -af "$target_disk"
    run sgdisk --zap-all "$target_disk"
    run sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"uNexus EFI" "$target_disk"
    run sgdisk -n 2:0:0 -t 2:8304 -c 2:"uNexus Root" "$target_disk"
    run partprobe "$target_disk"
    sleep 2

    run mkfs.fat -F32 -n UNEXUS_EFI "$esp_part"
    if [ "$filesystem" = "btrfs" ]; then
        run mkfs.btrfs -f -L UNEXUS_ROOT "$root_part"
    else
        run mkfs.ext4 -F -L UNEXUS_ROOT "$root_part"
    fi

    run mkdir -p "$work_mount"
    run mount "$root_part" "$work_mount"
    run mkdir -p "$work_mount/boot"
    run mount "$esp_part" "$work_mount/boot"

    run pacstrap -K "$work_mount" \
        base linux linux-firmware sof-firmware amd-ucode intel-ucode sudo networkmanager sddm \
        btrfs-progs dosfstools efibootmgr git cmake ninja base-devel rsync \
        hyprland qt6-base qt6-declarative qt6-imageformats qt6-svg qt6-wayland \
        mesa mesa-utils vulkan-intel vulkan-radeon vulkan-tools \
        pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber \
        polkit polkit-kde-agent xdg-desktop-portal xdg-desktop-portal-hyprland xdg-utils \
        flatpak gamemode mangohud ffmpeg poppler pciutils \
        kitty alacritty firefox fish zsh nano neovim btop htop less man-db \
        noto-fonts noto-fonts-emoji ttf-dejavu ttf-liberation \
        adwaita-icon-theme breeze-icons hicolor-icon-theme papirus-icon-theme \
        plymouth

    genfstab -U "$work_mount" >> "$work_mount/etc/fstab"
    run mkdir -p "$work_mount/opt/unexus-os"
    run rsync -a \
        --exclude '.git' \
        --exclude 'ISO/0.0.1/.work' \
        --exclude 'ISO/0.0.1/work' \
        --exclude 'ISO/0.0.1/out' \
        --exclude '**/build' \
        --exclude '**/.qt' \
        "$repo_root/" "$work_mount/opt/unexus-os/"

    chroot_script="$(write_chroot_script "$root_part" "$esp_part")"
    run arch-chroot "$work_mount" sh "/root/$(basename "$chroot_script")"
    set_passwords

    cleanup_mounts
    trap - EXIT INT TERM
    log "done; install log: $log_file"
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --target)
            [ "$#" -ge 2 ] || die "--target requires a disk"
            target_disk="$2"
            shift 2
            ;;
        --username)
            [ "$#" -ge 2 ] || die "--username requires a value"
            target_user="$2"
            shift 2
            ;;
        --hostname)
            [ "$#" -ge 2 ] || die "--hostname requires a value"
            target_hostname="$2"
            shift 2
            ;;
        --timezone)
            [ "$#" -ge 2 ] || die "--timezone requires a value"
            target_timezone="$2"
            shift 2
            ;;
        --locale)
            [ "$#" -ge 2 ] || die "--locale requires a value"
            target_locale="$2"
            shift 2
            ;;
        --keymap)
            [ "$#" -ge 2 ] || die "--keymap requires a value"
            target_keymap="$2"
            shift 2
            ;;
        --filesystem)
            [ "$#" -ge 2 ] || die "--filesystem requires btrfs or ext4"
            filesystem="$2"
            shift 2
            ;;
        --gaming-launchers)
            install_gaming_launchers=1
            shift
            ;;
        --execute)
            dry_run=0
            shift
            ;;
        --confirm)
            [ "$#" -ge 2 ] || die "--confirm requires text"
            confirm="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "unknown option: $1"
            ;;
    esac
done

[ -n "$target_disk" ] || die "--target is required"
need_command lsblk
is_whole_disk "$target_disk" || die "target must be a whole block disk: $target_disk"
validate_user_name "$target_user"
validate_name "$target_hostname" "hostname"
validate_name "$target_keymap" "keymap"
validate_name "$target_locale" "locale"
validate_timezone "$target_timezone"

case "$filesystem" in
    btrfs|ext4) ;;
    *) die "--filesystem must be btrfs or ext4" ;;
esac

log "install plan"
log "  disk:       $target_disk"
log "  user:       $target_user"
log "  hostname:   $target_hostname"
log "  timezone:   $target_timezone"
log "  locale:     $target_locale"
log "  keymap:     $target_keymap"
log "  filesystem: $filesystem"
log "  launchers:  $install_gaming_launchers"
log "  mountpoint: $work_mount"
log "  log file:   $log_file"

if [ "$dry_run" -eq 1 ]; then
    log "dry run only; add --execute --confirm ERASE-AND-INSTALL to erase and install"
    exit 0
fi

[ "$confirm" = "ERASE-AND-INSTALL" ] || die "refusing to erase disk without --confirm ERASE-AND-INSTALL"
[ "$(id -u)" -eq 0 ] || die "run as root"
[ -b "$target_disk" ] || die "target block device is not accessible: $target_disk"

need_command sgdisk
need_command wipefs
need_command partprobe
need_command mkfs.fat
need_command pacstrap
need_command genfstab
need_command arch-chroot
need_command rsync

if [ "$filesystem" = "btrfs" ]; then
    need_command mkfs.btrfs
else
    need_command mkfs.ext4
fi

install_system
