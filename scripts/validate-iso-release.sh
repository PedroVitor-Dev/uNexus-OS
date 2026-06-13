#!/usr/bin/env sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
iso_path="$repo_root/ISO/0.0.1/out/unexus-os-0.0.1-x86_64.iso"
default_report_dir="$repo_root/ISO/0.0.1/out/release-checks"
report_dir="${UNEXUS_RELEASE_REPORT_DIR:-$default_report_dir}"
report_file=""
build_iso=0
run_vm=1
require_vm=0
timeout_seconds="${UNEXUS_ISO_TEST_TIMEOUT:-300}"

usage() {
    cat <<EOF
Usage: sh scripts/validate-iso-release.sh [options]

Options:
  --build          Build the ISO before validating it
  --iso PATH       ISO image to validate (default: ISO/0.0.1/out/unexus-os-0.0.1-x86_64.iso)
  --timeout SEC    VM smoke test timeout per boot mode (default: 300)
  --no-vm          Skip QEMU smoke tests
  --require-vm     Fail if QEMU/OVMF smoke tests cannot run
  -h, --help       Show this help

The script performs release-gate checks, writes checksums and stores a report
under ISO/0.0.1/out/release-checks/.
EOF
}

log() {
    printf '[uNexus release] %s\n' "$*"
}

die() {
    printf '[uNexus release] %s\n' "$*" >&2
    exit 1
}

need_command() {
    command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

append_report() {
    printf '%s\n' "$*" >> "$report_file"
}

run_step() {
    name="$1"
    shift

    log "$name"
    append_report "## $name"
    if "$@" >> "$report_file" 2>&1; then
        append_report "status=passed"
        append_report ""
        return 0
    fi

    append_report "status=failed"
    append_report ""
    die "$name failed; see $report_file"
}

warn_step() {
    name="$1"
    detail="$2"

    log "$name: $detail"
    append_report "## $name"
    append_report "status=skipped"
    append_report "$detail"
    append_report ""
}

find_ovmf_code() {
    for path in \
        /usr/share/edk2-ovmf/x64/OVMF_CODE.4m.fd \
        /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
        /usr/share/OVMF/x64/OVMF_CODE.4m.fd \
        /usr/share/OVMF/x64/OVMF_CODE.fd \
        /usr/share/ovmf/x64/OVMF_CODE.fd \
        /usr/share/qemu/OVMF_CODE.fd; do
        if [ -r "$path" ]; then
            printf '%s\n' "$path"
            return 0
        fi
    done

    return 1
}

static_checks() {
    git -C "$repo_root" diff --check
    sh -n "$repo_root/ISO/0.0.1/build-iso.sh"
    sh -n "$repo_root/scripts/test-iso-vm.sh"
    sh -n "$repo_root/scripts/install-os.sh"
    sh -n "$repo_root/ISO/0.0.1/profile/airootfs/root/customize_airootfs.sh"
    sh -n "$repo_root/ISO/0.0.1/profile/airootfs/usr/local/bin/unexus-live-boot-mode"
    sh -n "$repo_root/ISO/0.0.1/profile/airootfs/usr/local/bin/unexus-live-smoke-test"
}

build_project() {
    cmake --build "$repo_root/packages/unexus-shell/build"
}

build_image() {
    if [ "$(id -u)" -eq 0 ]; then
        sh "$repo_root/ISO/0.0.1/build-iso.sh"
        return
    fi

    if command -v sudo >/dev/null 2>&1; then
        sudo sh "$repo_root/ISO/0.0.1/build-iso.sh"
        return
    fi

    die "ISO build requires root or sudo"
}

iso_checks() {
    [ -f "$iso_path" ] || die "ISO not found: $iso_path"
    [ -s "$iso_path" ] || die "ISO is empty: $iso_path"
    file "$iso_path"
    ls -lh "$iso_path"
}

write_checksums() {
    checksum_dir="$(dirname "$iso_path")"
    checksum_file="$checksum_dir/SHA256SUMS"
    if [ ! -w "$checksum_dir" ]; then
        checksum_file="$report_dir/SHA256SUMS"
    fi
    (
        cd "$(dirname "$iso_path")"
        sha256sum "$(basename "$iso_path")" > "$checksum_file"
        cat "$checksum_file"
    )
}

vm_checks() {
    if [ "$run_vm" -eq 0 ]; then
        warn_step "VM smoke tests" "disabled by --no-vm"
        return 0
    fi

    if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
        if [ "$require_vm" -eq 1 ]; then
            die "qemu-system-x86_64 not found"
        fi
        warn_step "VM smoke tests" "qemu-system-x86_64 not found"
        return 0
    fi

    if find_ovmf_code >/dev/null 2>&1; then
        run_step "VM smoke tests BIOS and UEFI" sh "$repo_root/scripts/test-iso-vm.sh" --iso "$iso_path" --timeout "$timeout_seconds"
    else
        if [ "$require_vm" -eq 1 ]; then
            die "OVMF firmware not found"
        fi
        run_step "VM smoke test BIOS" sh "$repo_root/scripts/test-iso-vm.sh" --iso "$iso_path" --timeout "$timeout_seconds" --bios-only
        warn_step "VM smoke test UEFI" "OVMF firmware not found; install edk2-ovmf"
    fi
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --build)
            build_iso=1
            shift
            ;;
        --iso)
            [ "$#" -ge 2 ] || die "--iso requires a path"
            iso_path="$2"
            shift 2
            ;;
        --timeout)
            [ "$#" -ge 2 ] || die "--timeout requires seconds"
            timeout_seconds="$2"
            shift 2
            ;;
        --no-vm)
            run_vm=0
            shift
            ;;
        --require-vm)
            require_vm=1
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

case "$timeout_seconds" in
    *[!0-9]*|'') die "--timeout must be a positive integer" ;;
esac
[ "$timeout_seconds" -gt 0 ] || die "--timeout must be greater than zero"

need_command git
need_command sh
need_command file
need_command sha256sum
need_command cmake

if ! mkdir -p "$report_dir" 2>/dev/null; then
    report_dir="${TMPDIR:-/tmp}/unexus-release-checks"
    mkdir -p "$report_dir"
fi
report_file="$report_dir/release-$(date +%Y%m%d-%H%M%S).log"

append_report "# uNexus ISO release validation"
append_report "date=$(date -Is 2>/dev/null || date)"
append_report "git_commit=$(git -C "$repo_root" rev-parse --short HEAD 2>/dev/null || printf unknown)"
append_report "iso=$iso_path"
append_report ""

run_step "Static checks" static_checks
run_step "CMake build" build_project

if [ "$build_iso" -eq 1 ]; then
    run_step "ISO build" build_image
else
    warn_step "ISO build" "skipped; pass --build to rebuild before validation"
fi

run_step "ISO artifact checks" iso_checks
run_step "SHA256 checksums" write_checksums
vm_checks

append_report "# result=passed"
log "release validation passed"
log "report: $report_file"
