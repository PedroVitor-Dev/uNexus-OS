#!/usr/bin/env sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
pkgbuild_dir="${repo_root}/packaging/arch"

if ! command -v makepkg >/dev/null 2>&1; then
    echo "makepkg was not found. Run this on Arch with pacman/base-devel installed." >&2
    exit 1
fi

cd "$pkgbuild_dir"
makepkg -sf
