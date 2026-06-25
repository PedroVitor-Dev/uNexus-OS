#!/usr/bin/env bash
set -euo pipefail

log() {
    printf '[uNexus ISO customize] %s\n' "$*"
}

live_user="unexus"

log "creating live user"
if ! id "$live_user" >/dev/null 2>&1; then
    useradd -m -G wheel,audio,video,storage,input -s /bin/bash "$live_user"
fi

printf 'root:unexus\n%s:unexus\n' "$live_user" | chpasswd

log "uNexus shell package is installed by pacstrap"
sed -i '/^\[unexus-local\]/,$d' /etc/pacman.conf
log "configuring Plymouth boot splash"
if command -v plymouth-set-default-theme >/dev/null 2>&1; then
    plymouth-set-default-theme unexus || true
fi

log "configuring live defaults"
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
printf 'LANG=en_US.UTF-8\n' > /etc/locale.conf
printf 'KEYMAP=us\n' > /etc/vconsole.conf

log "initializing live user state"
if command -v unexusctl >/dev/null 2>&1; then
    su - "$live_user" -c 'unexusctl init' || true
fi

log "configuring live session autostart"
install -d -m 0755 "/home/$live_user"
cat > "/home/$live_user/.bash_profile" <<'EOF'
if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec unexus-live-boot-mode
fi
EOF
chown "$live_user:$live_user" "/home/$live_user/.bash_profile"
chmod 0644 "/home/$live_user/.bash_profile"

log "enabling live services"
systemctl enable NetworkManager.service
systemctl enable systemd-timesyncd.service
systemctl enable getty@tty1.service
systemctl enable unexus-live-smoke-test.service
systemctl mask systemd-firstboot.service

if command -v flatpak >/dev/null 2>&1; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
fi

log "keeping pacman package cache for offline installation"
rm -rf /tmp/*
