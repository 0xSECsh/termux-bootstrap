#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: lib/core/cli.sh
# Description: CLI argument parser and dispatcher
# ==============================================================================

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

PACKAGES_DIR="${LIB_DIR}/../packages"

PROFILE_DIR="${PACKAGES_DIR}/profiles"

readonly PACKAGES_DIR
readonly PROFILE_DIR

# ------------------------------------------------------------------------------
# Usage
# ------------------------------------------------------------------------------

show_usage() {

        show_help_header

        cat <<EOF
Options:

  --help                 Show this help message
  --version              Show version information
  --about                Show project information
  --doctor               Run system diagnostics
  --profile <name>       Install a specific profile
  --all                  Install all profiles
  --list                 List available profiles
  --verbose              Enable verbose output
  --debug                Enable debug output

EOF

}

# ------------------------------------------------------------------------------
# Profile Listing
# ------------------------------------------------------------------------------

list_profiles() {

        local profiles

        if ! directory_exists "$PROFILE_DIR"; then

                log_error "Profile directory not found: ${PROFILE_DIR}"

                return 1

        fi

        profiles=("$PROFILE_DIR"/*.sh)

        if [[ ${#profiles[@]} -eq 0 ]] || [[ ! -f "${profiles[0]}" ]]; then

                log_info "No profiles available."

                return 0

        fi

        ui_section "Available Profiles"

        local profile

        for profile in "${profiles[@]}"; do

                profile="$(basename "$profile" .sh)"

                ui_bullet "$profile"

        done

        printf "\n"

}

# ------------------------------------------------------------------------------
# Doctor Checks
# ------------------------------------------------------------------------------

_run_check() {

        local label="$1"

        local func="$2"

        if $func; then

                ui_success "$label"

        else

                ui_error "$label"

        fi

}

_run_capability() {

        local label="$1"

        if has "$label"; then

                ui_success "${label}"

        else

                ui_warning "${label}"

        fi

}

run_doctor() {

        show_banner

        ui_section "System Information"

        system_summary

        ui_section "Health Checks"

        _run_check "Termux environment" is_termux

        _run_check "Internet connectivity" check_internet

        ui_separator

        local checks=(

                pkg git curl wget

                python node

                bash zsh

                micro nano vim nvim

                jq tmux fastfetch tree

        )

        local check

        for check in "${checks[@]}"; do

                _run_capability "$check"

        done

        ui_separator

        local storage_avail

        storage_avail="$(get_storage_available)"

        ui_key_value "Storage available" "$storage_avail"

        ui_key_value "Termux version" "$(get_termux_version)"

        ui_key_value "Android SDK" "$(get_android_sdk)"

        printf "\n"

}

# ------------------------------------------------------------------------------
# Module Loader
# ------------------------------------------------------------------------------

load_module() {

        local category="$1"

        local module="$2"

        local module_file="${PACKAGES_DIR}/${category}/${module}.sh"

        if [[ ! -f "$module_file" ]]; then

                log_warning "Module not found: ${category}/${module}"

                return 1

        fi

        # shellcheck disable=SC1090
        source "$module_file"

        local sanitized

        sanitized="${module//-/_}"

        local func_name="install_${category}_${sanitized}"

        if ! declare -F "$func_name" >/dev/null 2>&1; then

                log_warning "Module '${category}/${module}' has no install function"

                return 0

        fi

        ui_section "Module: ${category}/${module}"

        "$func_name"

}

# ------------------------------------------------------------------------------
# Profile Installation
# ------------------------------------------------------------------------------

_available_profiles() {

        local profiles=()

        local file

        if ! directory_exists "$PROFILE_DIR"; then

                printf "%s\n" "${profiles[@]}"

                return

        fi

        for file in "$PROFILE_DIR"/*.sh; do

                [[ -f "$file" ]] || continue

                profiles+=("$(basename "$file" .sh)")

        done

        printf "%s\n" "${profiles[@]}"

}

_install_profile() {

        local name="$1"

        local profile_file="${PROFILE_DIR}/${name}.sh"

        local func_name="install_profile_${name}"

        if [[ ! -f "$profile_file" ]]; then

                log_error "Profile not found: ${name}"

                return 1

        fi

        # shellcheck disable=SC1090
        source "$profile_file"

        if ! declare -F "$func_name" >/dev/null 2>&1; then

                log_warning "Profile '${name}' has no install function yet"

                return 0

        fi

        ui_section "Installing: ${name}"

        "$func_name"

}

install_profile() {

        local name="$1"

        if [[ -z "$name" ]]; then

                log_error "No profile specified."

                return 1

        fi

        _install_profile "$name"

}

install_all_profiles() {

        _install_profile full

}

# ------------------------------------------------------------------------------
# Argument Parser
# ------------------------------------------------------------------------------

parse_cli() {

        local action=""
        local action_arg=""

        if [[ $# -eq 0 ]]; then

                show_usage

                return 0

        fi

        while [[ $# -gt 0 ]]; do

                case "$1" in

                        --help)

                                show_usage

                                return 0
                                ;;

                        --version)

                                show_version

                                return 0
                                ;;

                        --about)

                                show_about

                                return 0
                                ;;

                        --doctor)

                                action="doctor"
                                ;;

                        --list)

                                action="list"
                                ;;

                        --all)

                                action="all"
                                ;;

                        --profile)

                                shift

                                if [[ $# -eq 0 ]] || [[ "$1" == --* ]]; then

                                        log_error "Missing profile name after --profile."

                                        return "$EXIT_INVALID_ARGUMENT"

                                fi

                                action="profile"
                                action_arg="$1"
                                ;;

                        --verbose | --debug)

                                # shellcheck disable=SC2034
                                LOG_LEVEL="DEBUG"
                                ;;

                        --*)

                                log_error "Unknown option: $1"

                                show_usage

                                return "$EXIT_INVALID_ARGUMENT"
                                ;;

                        *)

                                log_error "Unexpected argument: $1"

                                show_usage

                                return "$EXIT_INVALID_ARGUMENT"
                                ;;

                esac

                shift

        done

        case "$action" in

                doctor)

                        run_doctor
                        ;;

                list)

                        list_profiles
                        ;;

                all)

                        install_all_profiles
                        ;;

                profile)

                        install_profile "$action_arg"
                        ;;

                *)

                        show_usage
                        ;;

        esac

}
