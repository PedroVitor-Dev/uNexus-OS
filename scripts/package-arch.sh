#!/usr/bin/env sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
pkgbuild_dir="${repo_root}/packaging/arch"
out_dir="${repo_root}/dist/arch"
repo_name="unexus"
make_repo=1

usage() {
    cat <<EOF
Usage: sh scripts/package-arch.sh [options]

Options:
  --out-dir DIR     Output directory (default: dist/arch)
  --repo-name NAME  Pacman repository database name (default: unexus)
  --no-repo         Only build the package; do not run repo-add
  -h, --help        Show this help

Outputs:
  DIR/packages/*.pkg.tar.*
  DIR/repo/NAME.db.tar.gz
EOF
}

die() {
    printf '[uNexus package] %s\n' "$*" >&2
    exit 1
}

log() {
    printf '[uNexus package] %s\n' "$*"
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --out-dir)
            [ "$#" -ge 2 ] || die "--out-dir requires a directory"
            out_dir="$2"
            shift 2
            ;;
        --repo-name)
            [ "$#" -ge 2 ] || die "--repo-name requires a name"
            repo_name="$2"
            shift 2
            ;;
        --no-repo)
            make_repo=0
            shift
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

if ! command -v makepkg >/dev/null 2>&1; then
    die "makepkg was not found. Run this on Arch with pacman/base-devel installed."
fi

if [ "$make_repo" -eq 1 ] && ! command -v repo-add >/dev/null 2>&1; then
    die "repo-add was not found. Install pacman or run with --no-repo."
fi

pkg_dest="$out_dir/packages"
src_dest="$out_dir/sources"
repo_dest="$out_dir/repo"

mkdir -p "$pkg_dest" "$src_dest" "$repo_dest"

log "building Arch package"
cd "$pkgbuild_dir"
PKGDEST="$pkg_dest" SRCDEST="$src_dest" makepkg -sf

package_count=0
for package_file in "$pkg_dest"/*.pkg.tar.*; do
    [ -e "$package_file" ] || continue
    case "$package_file" in
        *.sig) continue ;;
    esac
    package_count=$((package_count + 1))
done

if [ "$package_count" -eq 0 ]; then
    die "makepkg finished but no package was found in $pkg_dest"
fi

if [ "$make_repo" -eq 1 ]; then
    log "publishing local pacman repository"
    for package_file in "$pkg_dest"/*.pkg.tar.*; do
        [ -e "$package_file" ] || continue
        case "$package_file" in
            *.sig) continue ;;
        esac
        cp "$package_file" "$repo_dest/"
    done
    (
        cd "$repo_dest"
        repo-add "${repo_name}.db.tar.gz" ./*.pkg.tar.*
    )
fi

log "packages: $pkg_dest"
if [ "$make_repo" -eq 1 ]; then
    log "repository: $repo_dest/${repo_name}.db.tar.gz"
fi
