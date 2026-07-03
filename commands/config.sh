#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap: Config Command
# ==============================================================================

# ------------------------------------------------------------------------------
# Command Entry Point
# ------------------------------------------------------------------------------

cmd_config() {
        local subcmd="${1:-show}"
        shift || true

        case "$subcmd" in
                show)
                        cmd_config_show "$@"
                        ;;
                list)
                        cmd_config_list "$@"
                        ;;
                edit)
                        cmd_config_edit "$@"
                        ;;
                reset)
                        cmd_config_reset "$@"
                        ;;
                validate)
                        cmd_config_validate "$@"
                        ;;
                merge)
                        cmd_config_merge "$@"
                        ;;
                -h | --help)
                        _config_help
                        ;;
                *)
                        log_error "Unknown config subcommand: ${subcmd}"
                        return "$EXIT_INVALID_ARGUMENT"
                        ;;
        esac
}

# ------------------------------------------------------------------------------
# Config List - List available config files
# ------------------------------------------------------------------------------

cmd_config_list() {
        ui_section "Available Configuration Files"

        local count
        count="$(config_count)"

        if [[ "$count" -eq 0 ]]; then
                log_info "No configuration files found."
                return 0
        fi

        config_list
        printf "\n"
}

# ------------------------------------------------------------------------------
# Config Show - Display current configuration
# ------------------------------------------------------------------------------

cmd_config_show() {
        ui_section "Configuration Files"

        local config_list_output
        config_list_output="$(config_list)"

        if [[ -z "$config_list_output" ]]; then
                log_info "No configuration files found."
                return 0
        fi

        local app_name filename status
        while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                app_name="${line%%/*}"
                filename="${line#*/}"
                filename="${filename%% *}"
                status="$(config_status "$app_name" "$filename")"
                ui_key_value "  ${app_name}/${filename}" "$status"
        done <<<"$config_list_output"

        printf "\n"
}

# ------------------------------------------------------------------------------
# Config Edit - Open config file in editor
# ------------------------------------------------------------------------------

cmd_config_edit() {
        local target="${1:-}"
        local editor="${EDITOR:-${DEFAULT_EDITOR}}"

        if [[ -z "$target" ]] || [[ "$target" == "-h" ]] || [[ "$target" == "--help" ]]; then
                cat <<'EOF'
Usage: bootstrap config edit <app/filename>

Open a configuration file in your default editor.

Arguments:
  <app/filename>    Config file in format: app/filename
                    Examples: zsh/.zshrc, git/.gitconfig

Options:
  -h, --help        Show this help

Examples:
  bootstrap config edit zsh/.zshrc
  bootstrap config edit git/.gitconfig
EOF
                if [[ -z "$target" ]]; then
                        return "$EXIT_INVALID_ARGUMENT"
                fi
                return 0
        fi

        local app_name filename
        if [[ "$target" == *"/"* ]]; then
                app_name="$(printf "%s\n" "$target" | cut -d'/' -f1)"
                filename="$(echo "$target" | cut -d'/' -f2)"
        else
                log_error "Usage: config edit <app/filename>"
                log_info "Example: config edit zsh/.zshrc"
                return "$EXIT_INVALID_ARGUMENT"
        fi

        local user_file
        user_file="$(config_resolve_path "$app_name" "$filename")"

        if [[ -z "$user_file" ]]; then
                log_error "Cannot determine config path for: ${target}"
                return "$EXIT_FAILURE"
        fi

        # Create directory if needed
        local user_dir
        user_dir="$(dirname "$user_file")"
        create_directory "$user_dir"

        # Copy default if file doesn't exist
        if [[ ! -f "$user_file" ]]; then
                local source_file="${CONFIGS_DIR}/${app_name}/${filename}"
                if [[ -f "$source_file" ]]; then
                        copy_file "$source_file" "$user_file"
                        log_info "Created default config: ${user_file}"
                else
                        log_warning "No default config found for: ${target}"
                        touch "$user_file"
                fi
        fi

        log_info "Opening: ${user_file}"
        "$editor" "$user_file"
}

# ------------------------------------------------------------------------------
# Config Reset - Restore config to defaults
# ------------------------------------------------------------------------------

cmd_config_reset() {
        local target="${1:-}"

        if [[ -z "$target" ]] || [[ "$target" == "-h" ]] || [[ "$target" == "--help" ]]; then
                cat <<'EOF'
Usage: bootstrap config reset <app/filename>

Reset a configuration file to its default value.

Arguments:
  <app/filename>    Config file in format: app/filename
                    Examples: zsh/.zshrc, git/.gitconfig

Options:
  -h, --help        Show this help

Examples:
  bootstrap config reset zsh/.zshrc
  bootstrap config reset git/.gitconfig
EOF
                if [[ -z "$target" ]]; then
                        return "$EXIT_INVALID_ARGUMENT"
                fi
                return 0
        fi

        local app_name filename
        if [[ "$target" == *"/"* ]]; then
                app_name="$(printf "%s\n" "$target" | cut -d'/' -f1)"
                filename="$(echo "$target" | cut -d'/' -f2)"
        else
                log_error "Usage: config reset <app/filename>"
                log_info "Example: config reset zsh/.zshrc"
                return "$EXIT_INVALID_ARGUMENT"
        fi

        local source_file="${CONFIGS_DIR}/${app_name}/${filename}"
        local user_file
        user_file="$(config_resolve_path "$app_name" "$filename")"

        if [[ ! -f "$source_file" ]]; then
                log_error "Default config not found: ${source_file}"
                return "$EXIT_FAILURE"
        fi

        if [[ -z "$user_file" ]]; then
                log_error "Cannot determine config path for: ${target}"
                return "$EXIT_FAILURE"
        fi

        # Backup existing if present
        if [[ -f "$user_file" ]]; then
                backup_file "$user_file"
                log_info "Backed up: ${user_file}.bak"
        fi

        # Create directory if needed
        local user_dir
        user_dir="$(dirname "$user_file")"
        create_directory "$user_dir"

        # Copy default config
        copy_file "$source_file" "$user_file"
        log_success "Reset config: ${user_file}"
}

# ------------------------------------------------------------------------------
# Config Validate - Validate configuration files
# ------------------------------------------------------------------------------

cmd_config_validate() {
        local target="${1:-}"

        if [[ "$target" == "-h" ]] || [[ "$target" == "--help" ]]; then
                cat <<'EOF'
Usage: bootstrap config validate [app/filename]

Validate configuration files. If no target is specified, validates all.

Arguments:
  <app/filename>    Config file in format: app/filename (optional)

Options:
  -h, --help        Show this help

Examples:
  bootstrap config validate
  bootstrap config validate zsh/.zshrc
EOF
                return 0
        fi

        if [[ -n "$target" ]]; then
                local app_name filename
                if [[ "$target" == *"/"* ]]; then
                        app_name="$(printf "%s\n" "$target" | cut -d'/' -f1)"
                        filename="$(echo "$target" | cut -d'/' -f2)"
                else
                        log_error "Usage: config validate <app/filename>"
                        return "$EXIT_INVALID_ARGUMENT"
                fi

                if config_validate "$app_name" "$filename"; then
                        log_success "Config valid: ${target}"
                else
                        log_error "Config invalid: ${target}"
                        return "$EXIT_FAILURE"
                fi
        else
                ui_section "Validating Configuration Files"
                config_validate_all
        fi
}

# ------------------------------------------------------------------------------
# Config Merge - Merge user config with defaults
# ------------------------------------------------------------------------------

cmd_config_merge() {
        local target="${1:-}"
        local overwrite=false

        if [[ "$target" == "-h" ]] || [[ "$target" == "--help" ]]; then
                cat <<'EOF'
Usage: bootstrap config merge [app/filename] [--overwrite]

Merge default configuration with user configuration.

Arguments:
  <app/filename>    Config file in format: app/filename (optional)

Options:
  --overwrite       Overwrite user config with defaults
  -h, --help        Show this help

Examples:
  bootstrap config merge
  bootstrap config merge zsh/.zshrc
  bootstrap config merge git/.gitconfig --overwrite
EOF
                return 0
        fi

        # Check for --overwrite flag
        for arg in "$@"; do
                if [[ "$arg" == "--overwrite" ]]; then
                        overwrite=true
                fi
        done

        if [[ -n "$target" ]] && [[ "$target" != "--overwrite" ]]; then
                local app_name filename
                if [[ "$target" == *"/"* ]]; then
                        app_name="$(printf "%s\n" "$target" | cut -d'/' -f1)"
                        filename="$(echo "$target" | cut -d'/' -f2)"
                else
                        log_error "Usage: config merge <app/filename>"
                        return "$EXIT_INVALID_ARGUMENT"
                fi

                config_merge "$app_name" "$filename" "$overwrite"
        else
                ui_section "Merging Configuration Files"
                config_merge_all "$overwrite"
        fi
}

# ------------------------------------------------------------------------------
# Help
# ------------------------------------------------------------------------------

_config_help() {
        cat <<'EOF'
Usage: bootstrap config <subcommand> [options]

Manage configuration files for installed applications.

Subcommands:
  list              List available configuration files
  show              Show current configuration status
  edit <file>       Open a configuration file in editor
  reset <file>      Reset a configuration file to defaults
  validate [file]   Validate configuration files
  merge [file]      Merge user config with defaults

Arguments:
  <file>            Config file in format: app/filename
                    Examples: zsh/.zshrc, git/.gitconfig

Options:
  --overwrite       Overwrite user config with defaults (for merge)
  -h, --help        Show help for command

Examples:
  bootstrap config show
  bootstrap config edit zsh/.zshrc
  bootstrap config reset git/.gitconfig
  bootstrap config validate
  bootstrap config merge zsh/.zshrc --overwrite
EOF
}
