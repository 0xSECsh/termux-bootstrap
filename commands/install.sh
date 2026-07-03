#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: commands/install.sh
# Description: Install command
# ==============================================================================

cmd_install() {
        local profile=""
        local module=""
        local all=false
        local dry_run=false

        while [[ $# -gt 0 ]]; do
                case "$1" in
                        -p | --profile)
                                [[ $# -lt 2 ]] && {
                                        log_error "Missing profile name"
                                        return "$EXIT_INVALID_ARGUMENT"
                                }
                                profile="$2"
                                shift 2
                                ;;
                        -m | --module)
                                [[ $# -lt 2 ]] && {
                                        log_error "Missing module name"
                                        return "$EXIT_INVALID_ARGUMENT"
                                }
                                module="$2"
                                shift 2
                                ;;
                        -a | --all)
                                all=true
                                shift
                                ;;
                        -d | --dry-run)
                                dry_run=true
                                shift
                                ;;
                        -h | --help)
                                cat <<'EOF'
Usage: bootstrap install [options]

Options:
  -p, --profile <name>    Install a profile
  -m, --module <name>     Install a module (category/module)
  -a, --all               Install everything (full profile)
  -d, --dry-run           Simulate installation without changes
  -h, --help              Show this help
EOF
                                return 0
                                ;;
                        *)
                                log_error "Unknown option: $1"
                                return "$EXIT_INVALID_ARGUMENT"
                                ;;
                esac
        done

        # Enable dry-run if requested
        if [[ "$dry_run" == true ]]; then
                installer_set_dry_run true
        fi

        if [[ "$all" == true ]]; then
                ui_header "Full Installation"
                log_info "Installing full profile..."
                if ! installer_install_profile "full"; then
                        log_error "Full installation failed"
                        return "$EXIT_FAILURE"
                fi
                log_success "Full installation complete"
                return 0
        fi

        if [[ -n "$profile" ]]; then
                ui_header "Profile Installation"
                if ! profile_exists "$profile"; then
                        log_error "Profile not found: ${profile}"
                        return "$EXIT_FAILURE"
                fi
                log_info "Installing profile: ${profile}"
                if ! installer_install_profile "$profile"; then
                        log_error "Profile installation failed: ${profile}"
                        return "$EXIT_FAILURE"
                fi
                log_success "Profile installed: ${profile}"
                return 0
        fi

        if [[ -n "$module" ]]; then
                ui_header "Module Installation"
                if [[ "$module" != *"/"* ]]; then
                        log_error "Invalid module format: ${module} (expected category/module)"
                        return "$EXIT_INVALID_ARGUMENT"
                fi
                local category="${module%%/*}"
                local module_name="${module#*/}"
                if ! module_exists "$category" "$module_name"; then
                        log_error "Module not found: ${module}"
                        return "$EXIT_FAILURE"
                fi
                log_info "Installing module: ${module}"
                if ! installer_install_module "$category" "$module_name"; then
                        log_error "Module installation failed: ${module}"
                        return "$EXIT_FAILURE"
                fi
                log_success "Module installed: ${module}"
                return 0
        fi

        log_error "Nothing to install. Use --profile, --module, or --all"
        dispatch_help
        return "$EXIT_INVALID_ARGUMENT"
}
