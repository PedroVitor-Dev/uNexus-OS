#!/usr/bin/env sh
set -eu

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
cache_home="${XDG_CACHE_HOME:-$HOME/.cache}"
state_home="${XDG_STATE_HOME:-$HOME/.local/state}"

config_dir="${config_home}/unexus"
data_dir="${data_home}/unexus"
cache_dir="${cache_home}/unexus"
state_dir="${state_home}/unexus"
log_dir="${state_dir}/logs"
backup_dir="${state_dir}/backups"
session_log="${log_dir}/session.log"
doctor_log="${log_dir}/doctor.log"
install_log="${log_dir}/install.log"
update_log="${log_dir}/update.log"
qt_settings_dir="${config_home}/uNexus"
qt_settings_file="${qt_settings_dir}/unexus-shell.conf"
system_state_dir="${UNEXUS_SYSTEM_STATE_DIR:-/var/lib/unexus}"
driver_state_dir="${system_state_dir}/driver-wizard"
driver_pending_file="${driver_state_dir}/pending"
driver_confirmed_file="${driver_state_dir}/confirmed"
driver_log="${driver_state_dir}/driver-wizard.log"
driver_rollback_service="unexus-driver-rollback.service"

usage() {
    cat <<EOF
uNexus control utility

Usage:
  unexusctl init
  unexusctl paths
  unexusctl doctor
  unexusctl session-info
  unexusctl reset-settings
  unexusctl open-config
  unexusctl logs
  unexusctl backup
  unexusctl rollback [backup-name]
  unexusctl driver-plan
  unexusctl driver-apply --yes
  unexusctl driver-confirm [--boot]
  unexusctl driver-rollback [--boot]
  unexusctl update --yes
  unexusctl version
EOF
}

ensure_dirs() {
    mkdir -p "$config_dir" "$data_dir" "$cache_dir" "$state_dir" "$log_dir" "$backup_dir"
}

timestamp() {
    date +%Y%m%d-%H%M%S 2>/dev/null || printf now
}

repo_root() {
    if git -C . rev-parse --show-toplevel >/dev/null 2>&1; then
        git -C . rev-parse --show-toplevel
        return 0
    fi

    if [ -d "$HOME/uNexus-OS/.git" ]; then
        printf '%s\n' "$HOME/uNexus-OS"
        return 0
    fi

    return 1
}

copy_path() {
    source_path="$1"
    target_path="$2"

    if [ -d "$source_path" ]; then
        mkdir -p "$(dirname "$target_path")"
        cp -R "$source_path" "$target_path"
    elif [ -f "$source_path" ]; then
        mkdir -p "$(dirname "$target_path")"
        cp "$source_path" "$target_path"
    fi
}

print_paths() {
    ensure_dirs
    printf 'config:        %s\n' "$config_dir"
    printf 'data:          %s\n' "$data_dir"
    printf 'cache:         %s\n' "$cache_dir"
    printf 'state:         %s\n' "$state_dir"
    printf 'logs:          %s\n' "$log_dir"
    printf 'session log:   %s\n' "$session_log"
    printf 'doctor log:    %s\n' "$doctor_log"
    printf 'install log:   %s\n' "$install_log"
    printf 'update log:    %s\n' "$update_log"
    printf 'backups:       %s\n' "$backup_dir"
    printf 'Qt settings:   %s\n' "$qt_settings_file"
}

run_doctor() {
    ensure_dirs

    if ! command -v unexus-doctor >/dev/null 2>&1; then
        printf 'unexus-doctor was not found in PATH.\n' >&2
        return 1
    fi

    if unexus-doctor > "$doctor_log" 2>&1; then
        cat "$doctor_log"
        return 0
    fi

    cat "$doctor_log" >&2
    return 1
}

session_info() {
    ensure_dirs
    printf 'XDG session type: %s\n' "${XDG_SESSION_TYPE:-unknown}"
    printf 'Current desktop:  %s\n' "${XDG_CURRENT_DESKTOP:-unknown}"
    printf 'Runtime dir:      %s\n' "${XDG_RUNTIME_DIR:-unset}"
    printf 'Shell binary:     '
    if command -v unexus-shell >/dev/null 2>&1; then
        command -v unexus-shell
    else
        printf 'missing\n'
    fi
    printf 'Session binary:   '
    if command -v unexus-session >/dev/null 2>&1; then
        command -v unexus-session
    else
        printf 'missing\n'
    fi
    printf 'Recovery binary:  '
    if command -v unexus-recovery-session >/dev/null 2>&1; then
        command -v unexus-recovery-session
    else
        printf 'missing\n'
    fi
    printf 'Session log:      %s\n' "$session_log"
}

reset_settings() {
    ensure_dirs
    stamp="$(date +%Y%m%d-%H%M%S 2>/dev/null || printf now)"
    moved=0

    if [ -f "$qt_settings_file" ]; then
        mv "$qt_settings_file" "${qt_settings_file}.bak-${stamp}"
        printf 'Moved Qt settings to %s\n' "${qt_settings_file}.bak-${stamp}"
        moved=1
    fi

    if [ -f "${config_dir}/settings.json" ]; then
        mv "${config_dir}/settings.json" "${config_dir}/settings.json.bak-${stamp}"
        printf 'Moved uNexus settings to %s\n' "${config_dir}/settings.json.bak-${stamp}"
        moved=1
    fi

    if [ "$moved" -eq 0 ]; then
        printf 'No settings files found to reset.\n'
    fi
}

open_config() {
    ensure_dirs

    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$config_dir" >/dev/null 2>&1 &
        printf 'Opening %s\n' "$config_dir"
    else
        printf '%s\n' "$config_dir"
    fi
}

show_logs() {
    ensure_dirs
    printf 'session: %s\n' "$session_log"
    printf 'doctor:  %s\n' "$doctor_log"
    printf 'install: %s\n' "$install_log"
    printf 'update:  %s\n' "$update_log"
}

create_backup() {
    ensure_dirs
    name="backup-$(timestamp)"
    target="${backup_dir}/${name}"
    mkdir -p "$target"

    copy_path "$config_dir" "${target}/config/unexus"
    copy_path "$qt_settings_file" "${target}/config/uNexus/unexus-shell.conf"

    {
        printf 'created=%s\n' "$name"
        printf 'config_dir=%s\n' "$config_dir"
        printf 'qt_settings_file=%s\n' "$qt_settings_file"
    } > "${target}/manifest"

    printf '%s\n' "$target"
}

latest_backup() {
    if [ ! -d "$backup_dir" ]; then
        return 1
    fi

    # POSIX-friendly enough for timestamped names.
    ls -1 "$backup_dir" 2>/dev/null | sort | tail -n 1
}

run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
        return $?
    fi

    if command -v pkexec >/dev/null 2>&1; then
        pkexec "$0" "$@"
        return $?
    fi

    if command -v sudo >/dev/null 2>&1; then
        sudo "$0" "$@"
        return $?
    fi

    printf 'Root privileges are required for this command.\n' >&2
    return 1
}

gpu_lspci_line() {
    if ! command -v lspci >/dev/null 2>&1; then
        return 1
    fi

    lspci -mm -nn 2>/dev/null | awk '
        /VGA compatible controller|3D controller|Display controller/ {
            line=tolower($0)
            if (line ~ /nvidia/) {
                print
                found=1
                exit
            }
            if (!first) {
                first=$0
            }
        }
        END {
            if (!found && first) {
                print first
            }
        }
    '
}

gpu_lspci_all() {
    if ! command -v lspci >/dev/null 2>&1; then
        return 1
    fi

    lspci -mm -nn 2>/dev/null | awk '/VGA compatible controller|3D controller|Display controller/ { print }'
}

gpu_vendor_id() {
    line="$(gpu_lspci_line || true)"
    printf '%s\n' "$line" | sed -n 's/.*\[\([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]\):[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]\].*/\1/p' | tr '[:upper:]' '[:lower:]'
}

recommended_driver_packages() {
    vendor_id="$(gpu_vendor_id || true)"
    gpu_line="$(gpu_lspci_line || true)"
    probe="$(printf '%s %s' "$vendor_id" "$gpu_line" | tr '[:upper:]' '[:lower:]')"

    case "$vendor_id:$probe" in
        10de:*|*:nvidia*)
            printf '%s\n' "nvidia-dkms nvidia-utils lib32-nvidia-utils"
            ;;
        1002:*|1022:*|*:amd*|*:"advanced micro devices"*)
            printf '%s\n' "mesa vulkan-radeon lib32-mesa lib32-vulkan-radeon"
            ;;
        8086:*|*:intel*)
            printf '%s\n' "mesa vulkan-intel intel-media-driver lib32-mesa"
            ;;
        *virtio*|*vmware*|*virtualbox*)
            printf '%s\n' "mesa vulkan-swrast"
            ;;
        *)
            return 1
            ;;
    esac
}

installed_packages() {
    if command -v pacman >/dev/null 2>&1; then
        pacman -Qq 2>/dev/null || true
    fi
}

driver_plan() {
    gpu_line="$(gpu_lspci_line || true)"
    gpu_all="$(gpu_lspci_all || true)"
    packages="$(recommended_driver_packages || true)"

    printf 'GPU: %s\n' "${gpu_line:-unknown}"
    printf 'Vendor ID: %s\n' "$(gpu_vendor_id || printf unknown)"
    if [ "$(printf '%s\n' "$gpu_all" | sed '/^$/d' | wc -l)" -gt 1 ]; then
        printf 'Hybrid GPU: detected; discrete GPU is prioritized when NVIDIA is present\n'
    fi
    if command -v mokutil >/dev/null 2>&1 && mokutil --sb-state 2>/dev/null | grep -qi enabled; then
        printf 'Secure Boot: enabled; DKMS modules may require signing\n'
    else
        printf 'Secure Boot: not detected or disabled\n'
    fi
    if [ -n "$packages" ]; then
        printf 'Recommended packages: %s\n' "$packages"
        printf 'Rollback: enabled through %s\n' "$driver_rollback_service"
        return 0
    fi

    printf 'Recommended packages: unknown\n'
    printf 'Rollback: unavailable until the GPU vendor is identified\n'
    return 1
}

driver_apply_root() {
    confirm="${1:-}"
    if [ "$confirm" != "--yes" ] && [ "$confirm" != "-y" ]; then
        printf 'Driver switching can change kernel graphics modules.\n' >&2
        printf 'Run: unexusctl driver-apply --yes\n' >&2
        return 2
    fi

    if ! command -v pacman >/dev/null 2>&1; then
        printf 'pacman was not found; driver switching is only implemented for Arch-based uNexus builds.\n' >&2
        return 1
    fi

    packages="$(recommended_driver_packages || true)"
    if [ -z "$packages" ]; then
        printf 'Could not map this GPU to a supported driver package set.\n' >&2
        return 1
    fi

    mkdir -p "$driver_state_dir"
    chmod 1777 "$driver_state_dir" 2>/dev/null || true
    installed_packages > "${driver_state_dir}/packages-before"
    printf '%s\n' "$packages" > "${driver_state_dir}/packages-target"
    gpu_lspci_line > "${driver_state_dir}/gpu" 2>/dev/null || true
    rm -f "$driver_confirmed_file"

    {
        printf '[uNexus Driver Wizard] started=%s\n' "$(date -Is 2>/dev/null || date)"
        printf '[uNexus Driver Wizard] gpu=%s\n' "$(cat "${driver_state_dir}/gpu" 2>/dev/null || printf unknown)"
        printf '[uNexus Driver Wizard] target=%s\n' "$packages"
    } > "$driver_pending_file"

    {
        printf '[uNexus Driver Wizard] installing target packages: %s\n' "$packages"
        pacman -S --needed --noconfirm $packages
        if command -v mkinitcpio >/dev/null 2>&1; then
            mkinitcpio -P
        fi
        if command -v systemctl >/dev/null 2>&1; then
            systemctl enable "$driver_rollback_service"
        fi
    } > "$driver_log" 2>&1 || {
        printf 'Driver switch failed. See %s\n' "$driver_log" >&2
        return 1
    }

    printf 'Driver switch staged. Reboot, then uNexus will confirm the next boot automatically.\n'
    printf 'If uNexus does not come back, %s rolls back the staged packages.\n' "$driver_rollback_service"
}

driver_confirm_root() {
    mkdir -p "$driver_state_dir" 2>/dev/null || true
    if [ ! -f "$driver_pending_file" ]; then
        printf 'No pending driver switch found.\n'
        return 0
    fi

    {
        printf '[uNexus Driver Wizard] confirmed=%s\n' "$(date -Is 2>/dev/null || date)"
        printf '[uNexus Driver Wizard] mode=%s\n' "${1:-manual}"
    } > "$driver_confirmed_file"

    rm -f "$driver_pending_file" 2>/dev/null || true
    if [ "$(id -u)" -eq 0 ] && command -v systemctl >/dev/null 2>&1; then
        systemctl disable "$driver_rollback_service" >/dev/null 2>&1 || true
    fi

    printf 'Driver switch confirmed.\n'
}

driver_rollback_root() {
    boot_mode="${1:-}"
    if [ "$boot_mode" = "--boot" ]; then
        sleep "${UNEXUS_DRIVER_ROLLBACK_DELAY:-180}"
    fi

    if [ ! -f "$driver_pending_file" ]; then
        printf 'No pending driver switch found.\n'
        return 0
    fi

    if [ -f "$driver_confirmed_file" ]; then
        rm -f "$driver_pending_file" "$driver_confirmed_file"
        if command -v systemctl >/dev/null 2>&1; then
            systemctl disable "$driver_rollback_service" >/dev/null 2>&1 || true
        fi
        printf 'Driver switch was already confirmed.\n'
        return 0
    fi

    if ! command -v pacman >/dev/null 2>&1; then
        printf 'pacman was not found; cannot roll back driver packages.\n' >&2
        return 1
    fi

    packages_to_remove=""
    if [ -f "${driver_state_dir}/packages-target" ]; then
        for package in $(cat "${driver_state_dir}/packages-target"); do
            if ! grep -qx "$package" "${driver_state_dir}/packages-before" 2>/dev/null; then
                packages_to_remove="${packages_to_remove} ${package}"
            fi
        done
    fi

    {
        printf '[uNexus Driver Wizard] rollback=%s\n' "$(date -Is 2>/dev/null || date)"
        if [ -n "$packages_to_remove" ]; then
            printf '[uNexus Driver Wizard] removing staged packages:%s\n' "$packages_to_remove"
            pacman -Rns --noconfirm $packages_to_remove
        else
            printf '[uNexus Driver Wizard] target packages were already installed; no package removal needed.\n'
        fi
        if command -v mkinitcpio >/dev/null 2>&1; then
            mkinitcpio -P
        fi
        rm -f "$driver_pending_file" "$driver_confirmed_file"
        if command -v systemctl >/dev/null 2>&1; then
            systemctl disable "$driver_rollback_service" >/dev/null 2>&1 || true
        fi
    } >> "$driver_log" 2>&1

    printf 'Driver rollback finished. See %s\n' "$driver_log"
}

restore_backup() {
    ensure_dirs
    requested="${1:-}"

    if [ -z "$requested" ]; then
        requested="$(latest_backup || true)"
    fi

    if [ -z "$requested" ]; then
        printf 'No backups found.\n' >&2
        return 1
    fi

    case "$requested" in
        */*) backup_path="$requested" ;;
        *) backup_path="${backup_dir}/${requested}" ;;
    esac

    if [ ! -d "$backup_path" ]; then
        printf 'Backup not found: %s\n' "$backup_path" >&2
        return 1
    fi

    current_backup="$(create_backup)"
    printf 'Current settings backed up to %s\n' "$current_backup"

    if [ -d "${backup_path}/config/unexus" ]; then
        rm -rf "$config_dir"
        mkdir -p "$(dirname "$config_dir")"
        cp -R "${backup_path}/config/unexus" "$config_dir"
        printf 'Restored %s\n' "$config_dir"
    fi

    if [ -f "${backup_path}/config/uNexus/unexus-shell.conf" ]; then
        mkdir -p "$qt_settings_dir"
        cp "${backup_path}/config/uNexus/unexus-shell.conf" "$qt_settings_file"
        printf 'Restored %s\n' "$qt_settings_file"
    fi
}

print_version() {
    ensure_dirs
    printf 'uNexus control:  unexusctl\n'
    printf 'Shell binary:    '
    if command -v unexus-shell >/dev/null 2>&1; then
        command -v unexus-shell
    else
        printf 'missing\n'
    fi

    if root_path="$(repo_root 2>/dev/null)"; then
        printf 'Repository:      %s\n' "$root_path"
        printf 'Git commit:      '
        git -C "$root_path" rev-parse --short HEAD 2>/dev/null || printf 'unknown\n'
        printf 'Git branch:      '
        git -C "$root_path" branch --show-current 2>/dev/null || printf 'unknown\n'
    else
        printf 'Repository:      not found\n'
    fi
}

run_update() {
    confirm="${1:-}"
    ensure_dirs

    if [ "$confirm" != "--yes" ] && [ "$confirm" != "-y" ]; then
        printf 'Update builds and installs uNexus from the current Git repository.\n' >&2
        printf 'Run: unexusctl update --yes\n' >&2
        return 2
    fi

    if ! root_path="$(repo_root 2>/dev/null)"; then
        printf 'Could not find uNexus repository. Run this from the repo or keep it at ~/uNexus-OS.\n' >&2
        return 1
    fi

    if ! command -v git >/dev/null 2>&1; then
        printf 'git was not found.\n' >&2
        return 1
    fi

    backup_path="$(create_backup)"
    printf 'Backup created: %s\n' "$backup_path"

    {
        printf '[uNexus update] repo: %s\n' "$root_path"
        printf '[uNexus update] before: '
        git -C "$root_path" rev-parse --short HEAD
        git -C "$root_path" pull --ff-only
        printf '[uNexus update] after: '
        git -C "$root_path" rev-parse --short HEAD
        if command -v sudo >/dev/null 2>&1; then
            sudo sh "${root_path}/scripts/setup.sh"
        else
            sh "${root_path}/scripts/setup.sh"
        fi
    } > "$update_log" 2>&1 || {
        printf 'Update failed. See log: %s\n' "$update_log" >&2
        if command -v tail >/dev/null 2>&1; then
            tail -n 40 "$update_log" >&2 || true
        fi
        return 1
    }

    cat "$update_log"
}

command_name="${1:-help}"

case "$command_name" in
    init)
        ensure_dirs
        print_paths
        ;;
    paths)
        print_paths
        ;;
    doctor)
        run_doctor
        ;;
    session-info)
        session_info
        ;;
    reset-settings|reset)
        reset_settings
        ;;
    open-config)
        open_config
        ;;
    logs)
        show_logs
        ;;
    backup)
        create_backup
        ;;
    rollback)
        shift || true
        restore_backup "${1:-}"
        ;;
    driver-plan)
        driver_plan
        ;;
    driver-apply)
        shift || true
        if [ "$(id -u)" -eq 0 ]; then
            driver_apply_root "${1:-}"
        else
            run_as_root driver-apply "${1:-}"
        fi
        ;;
    driver-confirm)
        shift || true
        if [ "${1:-}" = "--boot" ]; then
            driver_confirm_root "${1:-}"
        elif [ "$(id -u)" -eq 0 ]; then
            driver_confirm_root "${1:-}"
        else
            run_as_root driver-confirm "${1:-}"
        fi
        ;;
    driver-rollback)
        shift || true
        if [ "$(id -u)" -eq 0 ]; then
            driver_rollback_root "${1:-}"
        else
            run_as_root driver-rollback "${1:-}"
        fi
        ;;
    update)
        shift || true
        run_update "${1:-}"
        ;;
    version)
        print_version
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac
