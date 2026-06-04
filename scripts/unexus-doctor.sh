#!/usr/bin/env sh
set -eu

failures=0
warnings=0

info() {
    printf '[uNexus doctor] %s\n' "$*"
}

ok() {
    printf '[OK] %s\n' "$*"
}

warn() {
    warnings=$((warnings + 1))
    printf '[WARN] %s\n' "$*" >&2
}

fail() {
    failures=$((failures + 1))
    printf '[FAIL] %s\n' "$*" >&2
}

need_command() {
    name="$1"
    required="${2:-required}"
    installed_path="${3:-}"

    if command -v "$name" >/dev/null 2>&1; then
        ok "$name found"
    elif [ -n "$installed_path" ] && [ -x "$installed_path" ]; then
        ok "$name installed at $installed_path"
    elif [ "$required" = "required" ]; then
        fail "$name not found"
    else
        warn "$name not found"
    fi
}

need_file() {
    path="$1"
    label="$2"

    if [ -f "$path" ]; then
        ok "$label installed at $path"
    else
        fail "$label missing at $path"
    fi
}

need_dir() {
    path="$1"
    label="$2"

    if [ -d "$path" ]; then
        ok "$label exists at $path"
    else
        warn "$label missing at $path"
    fi
}

prefix="${PREFIX:-/usr}"
bindir="${prefix}/bin"
datadir="${prefix}/share"
target_home="$HOME"

if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ] && command -v getent >/dev/null 2>&1; then
    target_home="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
fi

config_home="${XDG_CONFIG_HOME:-$target_home/.config}"
data_home="${XDG_DATA_HOME:-$target_home/.local/share}"
cache_home="${XDG_CACHE_HOME:-$target_home/.cache}"
state_home="${XDG_STATE_HOME:-$target_home/.local/state}"

info "checking install prefix: $prefix"

need_command Hyprland required
need_command unexus-shell required "${bindir}/unexus-shell"
need_command unexusctl required "${bindir}/unexusctl"
need_command flatpak optional
need_command gamemoderun optional
need_command mangohud optional

terminal_found=0
for terminal in foot kitty alacritty wezterm konsole gnome-terminal xterm; do
    if command -v "$terminal" >/dev/null 2>&1; then
        ok "fallback terminal found: $terminal"
        terminal_found=1
        break
    fi
done

if [ "$terminal_found" -eq 0 ]; then
    warn "no fallback terminal found for recovery sessions"
fi

need_file "${bindir}/unexus-session" "uNexus session launcher"
need_file "${bindir}/unexus-recovery-session" "uNexus recovery launcher"
need_file "${datadir}/wayland-sessions/unexus.desktop" "uNexus display-manager session"
need_file "${datadir}/wayland-sessions/unexus-recovery.desktop" "uNexus recovery display-manager session"

need_dir "${config_home}/unexus" "uNexus config directory"
need_dir "${data_home}/unexus" "uNexus data directory"
need_dir "${cache_home}/unexus" "uNexus cache directory"
need_dir "${state_home}/unexus" "uNexus state directory"

if [ "$failures" -gt 0 ]; then
    info "doctor finished with $failures failure(s) and $warnings warning(s)"
    exit 1
fi

info "doctor finished with 0 failures and $warnings warning(s)"
