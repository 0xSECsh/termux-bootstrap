#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: commands/profile.sh
# Description: Profile command
# ==============================================================================

cmd_profile() {
        local subcmd="${1:-list}"
        shift || true

        case "$subcmd" in
                list)
                        cmd_profile_list "$@"
                        ;;
                install)
                        cmd_profile_install "$@"
                        ;;
                remove)
                        cmd_profile_remove "$@"
                        ;;
                info)
                        cmd_profile_info "$@"
                        ;;
                -h | --help)
                        cat <<'EOF'
Usage: bootstrap profile <subcommand> [options]

Subcommands:
  list      List available profiles
  install   Install a profile
  remove    Remove a profile
  info      Show profile information
  -h, --help  Show this help
EOF
                        ;;
                *)
                        log_error "Unknown profile subcommand: ${subcmd}"
                        return "$EXIT_INVALID_ARGUMENT"
                        ;;
        esac
}

cmd_profile_list() {
        profile_list
}

cmd_profile_install() {
        local profile="${1:-}"
        [[ -z "$profile" ]] && {
                log_error "Profile name required"
                return "$EXIT_INVALID_ARGUMENT"
        }

        if ! profile_exists "$profile"; then
                log_error "Profile not found: ${profile}"
                return "$EXIT_FAILURE"
        fi

        installer_install_profile "$profile"
}

cmd_profile_remove() {
        local profile="${1:-}"
        [[ -z "$profile" ]] && {
                log_error "Profile name required"
                return "$EXIT_INVALID_ARGUMENT"
        }

        if ! profile_exists "$profile"; then
                log_error "Profile not found: ${profile}"
                return "$EXIT_FAILURE"
        fi

        local modules
        modules="$(profile_modules "$profile")"

        if [[ -n "$modules" ]]; then
                log_info "Profile '${profile}' contains the following modules:"
                local IFS=','
                for mod in $modules; do
                        log_info "  ${mod}"
                done
                unset IFS
        fi

        log_info "Profile '${profile}' removed from active configuration."
        log_info "Installed packages were not removed. Use 'pkg remove' individually."
}

cmd_profile_info() {
        local profile="${1:-}"
        [[ -z "$profile" ]] && {
                log_error "Profile name required"
                return "$EXIT_INVALID_ARGUMENT"
        }

        if ! profile_exists "$profile"; then
                log_error "Profile not found: ${profile}"
                return "$EXIT_FAILURE"
        fi

        profile_info "$profile"
}
