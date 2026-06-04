#!/usr/bin/env sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
build_dir="${repo_root}/packages/unexus-shell/build"
prefix="${PREFIX:-/usr}"

log() {
    printf '[uNexus setup] %s\n' "$*"
}

need_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf '[uNexus setup] missing required command: %s\n' "$1" >&2
        exit 1
    fi
}

log "checking build tools"
need_command cmake

log "configuring shell"
cmake -S "${repo_root}/packages/unexus-shell" -B "$build_dir" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$prefix"

log "building shell"
cmake --build "$build_dir"

log "installing files into $prefix"
cmake --install "$build_dir"

log "validating installation"
if command -v unexus-doctor >/dev/null 2>&1; then
    PREFIX="$prefix" unexus-doctor
else
    PREFIX="$prefix" sh "${repo_root}/scripts/unexus-doctor.sh"
fi

log "done"
