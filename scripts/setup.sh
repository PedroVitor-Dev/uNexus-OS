#!/usr/bin/env sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
build_dir="${repo_root}/packages/unexus-shell/build"
prefix="${PREFIX:-/usr}"
install_home="$HOME"

if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ] && command -v getent >/dev/null 2>&1; then
    install_home="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
fi

state_home="${XDG_STATE_HOME:-$install_home/.local/state}"
install_log="${state_home}/unexus/logs/install.log"

log() {
    printf '[uNexus setup] %s\n' "$*"
}

need_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf '[uNexus setup] missing required command: %s\n' "$1" >&2
        exit 1
    fi
}

run_logged() {
    log "$*"
    if "$@" >> "$install_log" 2>&1; then
        return 0
    fi

    printf '[uNexus setup] command failed: %s\n' "$*" >&2
    printf '[uNexus setup] see log: %s\n' "$install_log" >&2
    if command -v tail >/dev/null 2>&1; then
        tail -n 40 "$install_log" >&2 || true
    fi
    exit 1
}

log "checking build tools"
need_command cmake
mkdir -p "$(dirname "$install_log")"
if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ] && command -v chown >/dev/null 2>&1; then
    chown -R "$SUDO_USER" "$(dirname "$(dirname "$install_log")")" 2>/dev/null || true
fi
log "install log: $install_log"

run_logged cmake -S "${repo_root}/packages/unexus-shell" -B "$build_dir" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$prefix"

run_logged cmake --build "$build_dir"

run_logged cmake --install "$build_dir"

log "initializing user state"
if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ] && command -v sudo >/dev/null 2>&1; then
    if [ -x "${prefix}/bin/unexusctl" ]; then
        sudo -u "$SUDO_USER" "${prefix}/bin/unexusctl" init >/dev/null
    else
        sudo -u "$SUDO_USER" sh "${repo_root}/scripts/unexusctl.sh" init >/dev/null
    fi
else
    if command -v unexusctl >/dev/null 2>&1; then
        unexusctl init >/dev/null
    elif [ -x "${prefix}/bin/unexusctl" ]; then
        "${prefix}/bin/unexusctl" init >/dev/null
    else
        sh "${repo_root}/scripts/unexusctl.sh" init >/dev/null
    fi
fi

log "validating installation"
if command -v unexus-doctor >/dev/null 2>&1; then
    run_logged env PREFIX="$prefix" unexus-doctor
else
    run_logged env PREFIX="$prefix" sh "${repo_root}/scripts/unexus-doctor.sh"
fi

if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ] && command -v chown >/dev/null 2>&1; then
    chown -R "$SUDO_USER" "$(dirname "$(dirname "$install_log")")" 2>/dev/null || true
fi

log "done"
