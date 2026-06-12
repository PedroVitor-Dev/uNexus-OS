#!/usr/bin/env sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
default_iso="$repo_root/ISO/0.0.1/out/unexus-os-0.0.1-x86_64.iso"
iso_path="$default_iso"
timeout_seconds="${UNEXUS_ISO_TEST_TIMEOUT:-300}"
run_bios=1
run_uefi=1
keep_logs=0

usage() {
    cat <<EOF
Usage: sh scripts/test-iso-vm.sh [options]

Options:
  --iso PATH       ISO image to boot (default: ISO/0.0.1/out/unexus-os-0.0.1-x86_64.iso)
  --timeout SEC   Seconds to wait for each VM smoke marker (default: 300)
  --bios-only     Test only legacy BIOS boot
  --uefi-only     Test only UEFI boot
  --keep-logs     Keep serial logs under /tmp
  -h, --help      Show this help

The test boots the live ISO in QEMU and waits for UNEXUS_SMOKE_OK on the VM serial port.
EOF
}

log() {
    printf '[uNexus ISO test] %s\n' "$*"
}

die() {
    printf '[uNexus ISO test] %s\n' "$*" >&2
    exit 1
}

need_command() {
    command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
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

cleanup_vm() {
    pid="$1"
    if kill -0 "$pid" >/dev/null 2>&1; then
        kill "$pid" >/dev/null 2>&1 || true
        sleep 1
    fi
    if kill -0 "$pid" >/dev/null 2>&1; then
        kill -9 "$pid" >/dev/null 2>&1 || true
    fi
    wait "$pid" >/dev/null 2>&1 || true
}

wait_for_marker() {
    mode="$1"
    pid="$2"
    serial_log="$3"
    deadline=$(( $(date +%s) + timeout_seconds ))

    while kill -0 "$pid" >/dev/null 2>&1; do
        if grep -q "UNEXUS_SMOKE_OK" "$serial_log" 2>/dev/null; then
            log "$mode boot passed"
            cleanup_vm "$pid"
            return 0
        fi

        if grep -q "UNEXUS_SMOKE_FAIL" "$serial_log" 2>/dev/null; then
            cleanup_vm "$pid"
            printf '%s\n' "----- $mode serial log -----" >&2
            tail -n 120 "$serial_log" >&2 || true
            die "$mode boot failed smoke checks"
        fi

        if [ "$(date +%s)" -ge "$deadline" ]; then
            cleanup_vm "$pid"
            printf '%s\n' "----- $mode serial log -----" >&2
            tail -n 120 "$serial_log" >&2 || true
            die "$mode boot timed out after ${timeout_seconds}s"
        fi

        sleep 2
    done

    printf '%s\n' "----- $mode serial log -----" >&2
    tail -n 120 "$serial_log" >&2 || true
    die "$mode VM exited before the smoke marker appeared"
}

run_vm() {
    mode="$1"
    serial_log="$2"
    shift 2

    : > "$serial_log"
    log "starting $mode VM"
    "$@" &
    vm_pid="$!"
    wait_for_marker "$mode" "$vm_pid" "$serial_log"
}

while [ "$#" -gt 0 ]; do
    case "$1" in
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
        --bios-only)
            run_bios=1
            run_uefi=0
            shift
            ;;
        --uefi-only)
            run_bios=0
            run_uefi=1
            shift
            ;;
        --keep-logs)
            keep_logs=1
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
[ -f "$iso_path" ] || die "ISO not found: $iso_path"

need_command qemu-system-x86_64
need_command grep
need_command tail

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/unexus-iso-test.XXXXXX")"
if [ "$keep_logs" -eq 0 ]; then
    trap 'rm -rf "$tmp_dir"' EXIT INT TERM
else
    trap 'log "kept logs in: $tmp_dir"' EXIT
fi

if [ "$run_bios" -eq 1 ]; then
    bios_serial="$tmp_dir/bios-serial.log"
    run_vm "BIOS" "$bios_serial" \
        qemu-system-x86_64 \
        -machine "pc,accel=kvm:tcg" \
        -m 2048 \
        -smp 2 \
        -cdrom "$iso_path" \
        -boot d \
        -no-reboot \
        -display none \
        -serial "file:$bios_serial" \
        -nic user,model=e1000
fi

if [ "$run_uefi" -eq 1 ]; then
    ovmf_code="$(find_ovmf_code || true)"
    [ -n "$ovmf_code" ] || die "OVMF firmware not found; install edk2-ovmf or run with --bios-only"

    uefi_serial="$tmp_dir/uefi-serial.log"
    run_vm "UEFI" "$uefi_serial" \
        qemu-system-x86_64 \
        -machine "q35,accel=kvm:tcg" \
        -m 2048 \
        -smp 2 \
        -drive "if=pflash,format=raw,readonly=on,file=$ovmf_code" \
        -cdrom "$iso_path" \
        -boot d \
        -no-reboot \
        -display none \
        -serial "file:$uefi_serial" \
        -nic user,model=e1000
fi

log "all requested ISO VM tests passed"
