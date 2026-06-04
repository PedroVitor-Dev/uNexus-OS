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
session_log="${log_dir}/session.log"
doctor_log="${log_dir}/doctor.log"
install_log="${log_dir}/install.log"
qt_settings_dir="${config_home}/uNexus"
qt_settings_file="${qt_settings_dir}/unexus-shell.conf"

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
EOF
}

ensure_dirs() {
    mkdir -p "$config_dir" "$data_dir" "$cache_dir" "$state_dir" "$log_dir"
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
    help|--help|-h)
        usage
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac
