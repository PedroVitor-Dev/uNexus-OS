#!/usr/bin/env sh
set -eu

version_root="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_root="$(CDPATH= cd -- "$version_root/../.." && pwd)"
profile_src="$version_root/profile"
build_root="$version_root/.work"
profile_build="$build_root/profile"
package_build="$build_root/package"
repo_dir="$build_root/repo"
work_dir="$version_root/work"
out_dir="$version_root/out"
pkgver="0.1.0"
build_user="${SUDO_USER:-}"

log() {
    printf '[uNexus ISO 0.0.3] %s\n' "$*"
}

need_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf '[uNexus ISO 0.0.3] missing command: %s\n' "$1" >&2
        exit 1
    fi
}

if [ "$(id -u)" -ne 0 ]; then
    printf '[uNexus ISO 0.0.3] run as root: sudo sh ISO/0.0.3/build-iso.sh\n' >&2
    exit 1
fi

if [ -z "$build_user" ] || [ "$build_user" = "root" ]; then
    printf '[uNexus ISO 0.0.3] run through sudo from a regular user so makepkg can run without root\n' >&2
    exit 1
fi

need_command mkarchiso
need_command makepkg
need_command repo-add
need_command runuser
need_command rsync
need_command tar

rm -rf "$build_root"
mkdir -p "$package_build" "$repo_dir"
chown -R "$build_user:$build_user" "$build_root"

log "building local uNexus package"
runuser -u "$build_user" -- rsync -a "$repo_root/packaging/arch/PKGBUILD.iso" "$package_build/PKGBUILD"
tar \
    --exclude '.git' \
    --exclude 'ISO/*/.work' \
    --exclude 'ISO/*/work' \
    --exclude 'ISO/*/out' \
    --exclude '**/build' \
    --exclude '**/.qt' \
    -C "$repo_root" \
    -czf "$package_build/unexus-shell-${pkgver}.tar.gz" \
    --transform "s|^|unexus-shell-${pkgver}/|" \
    .
chown "$build_user:$build_user" "$package_build/unexus-shell-${pkgver}.tar.gz"

(
    cd "$package_build"
    runuser -u "$build_user" -- makepkg -f --noconfirm --nodeps
)
cp "$package_build"/*.pkg.tar.* "$repo_dir/"
(
    cd "$repo_dir"
    repo-add unexus-local.db.tar.gz ./*.pkg.tar.*
)

log "preparing profile"
mkdir -p "$profile_build/airootfs/opt"
mkdir -p "$work_dir" "$out_dir"

rsync -a "$profile_src/" "$profile_build/"
install -d -m 0755 "$profile_build/unexus-local"
rsync -a "$repo_dir/" "$profile_build/unexus-local/"
install -d -m 0755 "$profile_build/airootfs/var/cache/pacman/pkg"
cp "$repo_dir"/*.pkg.tar.* "$profile_build/airootfs/var/cache/pacman/pkg/"
cat >> "$profile_build/pacman.conf" <<EOF

[unexus-local]
SigLevel = Optional TrustAll
Server = file://$profile_build/unexus-local
EOF
rsync -a \
    --exclude '.git' \
    --exclude 'ISO/*/.work' \
    --exclude 'ISO/*/work' \
    --exclude 'ISO/*/out' \
    --exclude '**/build' \
    --exclude '**/.qt' \
    "$repo_root/" "$profile_build/airootfs/opt/unexus-os/"

chmod +x "$profile_build/airootfs/root/customize_airootfs.sh"

log "building ISO"
mkarchiso -v -w "$work_dir" -o "$out_dir" "$profile_build"

log "done: $out_dir"
