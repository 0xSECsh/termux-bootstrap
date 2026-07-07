#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: commands/module.sh
# Description: Module command
# ==============================================================================

cmd_module() {
        local subcmd="${1:-list}"
        shift || true

        case "$subcmd" in
                list)
                        cmd_module_list "$@"
                        ;;
                install)
                        cmd_module_install "$@"
                        ;;
                remove)
                        cmd_module_remove "$@"
                        ;;
                info)
                        cmd_module_info "$@"
                        ;;
                -h | --help)
                        cat <<'EOF'
Usage: bootstrap module <subcommand> [options]

Subcommands:
  list      List available modules
  install   Install a module
  remove    Remove a module
  info      Show module information
  -h, --help  Show this help
EOF
                        ;;
                *)
                        log_error "Unknown module subcommand: ${subcmd}"
                        return "$EXIT_INVALID_ARGUMENT"
                        ;;
        esac
}

cmd_module_list() {
        local filter_category="${1:-}"

        if [[ -n "$filter_category" ]]; then
                module_list "$filter_category"
        else
                module_list
        fi
}

cmd_module_install() {
        local module="${1:-}"
        [[ -z "$module" ]] && {
                log_error "Module name required (e.g., core/base)"
                return "$EXIT_INVALID_ARGUMENT"
        }

        local category module_name
        if [[ "$module" == *"/"* ]]; then
                category="${module%%/*}"
                module_name="${module#*/}"
        else
                log_error "Invalid module format: ${module} (expected category/module)"
                return "$EXIT_INVALID_ARGUMENT"
        fi

        if ! module_exists "$category" "$module_name"; then
                log_error "Module not found: ${category}/${module_name}"
                return "$EXIT_FAILURE"
        fi

        installer_install_module "$category" "$module_name"
}

cmd_module_remove() {
        local module="${1:-}"
        [[ -z "$module" ]] && {
                log_error "Module name required (e.g., core/base)"
                return "$EXIT_INVALID_ARGUMENT"
        }

        local category module_name
        if [[ "$module" == *"/"* ]]; then
                category="${module%%/*}"
                module_name="${module#*/}"
        else
                log_error "Invalid module format: ${module} (expected category/module)"
                return "$EXIT_INVALID_ARGUMENT"
        fi

        if ! module_exists "$category" "$module_name"; then
                log_error "Module not found: ${category}/${module_name}"
                return "$EXIT_FAILURE"
        fi

        local sanitized="${module_name//-/_}"
        local func_name="install_${category}_${sanitized}"

        # Source the module file to get the package list
        local module_file="${PACKAGES_DIR:-${LIB_DIR}/../packages}/${category}/${module_name}.sh"
        if [[ -f "$module_file" ]]; then
                # shellcheck disable=SC1090
                source "$module_file"
        fi

        log_info "Module ${category}/${module_name} marked for removal."
        log_info "Packages installed by this module should be removed individually."
}

cmd_module_info() {
        local module="${1:-}"
        [[ -z "$module" ]] && {
                log_error "Module name required (e.g., core/base)"
                return "$EXIT_INVALID_ARGUMENT"
        }

        local category module_name
        if [[ "$module" == *"/"* ]]; then
                category="${module%%/*}"
                module_name="${module#*/}"
        else
                log_error "Invalid module format: ${module} (expected category/module)"
                return "$EXIT_INVALID_ARGUMENT"
        fi

        if ! module_exists "$category" "$module_name"; then
                log_error "Module not found: ${category}/${module_name}"
                return "$EXIT_FAILURE"
        fi

        module_info "$category" "$module_name"
}
