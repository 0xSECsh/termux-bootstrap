#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap: List Command
# ==============================================================================

cmd_list() {
        local what=""
        local category=""
        local verbose=false

        while [[ $# -gt 0 ]]; do
                case "$1" in
                        profiles | modules | installed)
                                what="$1"
                                shift
                                ;;
                        -c | --category)
                                [[ $# -lt 2 ]] && {
                                        log_error "Missing category name"
                                        return "$EXIT_INVALID_ARGUMENT"
                                }
                                category="$2"
                                shift 2
                                ;;
                        -v | --verbose)
                                verbose=true
                                shift
                                ;;
                        -h | --help)
                                colorize "${BOLD}" "Usage: bootstrap list <what> [options]"
                                printf "\n"
                                colorize "${BOLD}" "What:"
                                ui_bullet "profiles     List available profiles"
                                ui_bullet "modules      List available modules"
                                ui_bullet "installed    List installed packages"
                                printf "\n"
                                colorize "${BOLD}" "Options:"
                                ui_bullet "-c, --category <name>  Filter modules by category"
                                ui_bullet "-v, --verbose          Show detailed information"
                                ui_bullet "-h, --help             Show this help"
                                return 0
                                ;;
                        *)
                                log_error "Unknown option: $1"
                                return "$EXIT_INVALID_ARGUMENT"
                                ;;
                esac
        done

        # Default to profiles if no argument given
        [[ -z "$what" ]] && what="profiles"

        case "$what" in
                profiles)
                        _list_profiles
                        ;;
                modules)
                        _list_modules "$category" "$verbose"
                        ;;
                installed)
                        _list_installed "$verbose"
                        ;;
        esac
}

# ------------------------------------------------------------------------------
# List Profiles
# ------------------------------------------------------------------------------

_list_profiles() {
        if ! directory_exists "$PROFILE_DIR"; then
                log_error "Profile directory not found: ${PROFILE_DIR}"
                return "$EXIT_FAILURE"
        fi

        local profiles=()
        local profile_file

        for profile_file in "$PROFILE_DIR"/*.sh; do
                [[ -f "$profile_file" ]] || continue
                profiles+=("$(basename "$profile_file" .sh)")
        done

        if [[ ${#profiles[@]} -eq 0 ]]; then
                log_info "No profiles available."
                return 0
        fi

        ui_section "Available Profiles"

        local profile
        while IFS= read -r profile; do
                ui_bullet "$profile"
        done < <(printf '%s\n' "${profiles[@]}" | sort)

        printf "\n"
}

# ------------------------------------------------------------------------------
# List Modules
# ------------------------------------------------------------------------------

_list_modules() {
        local filter_category="$1"
        local verbose="$2"

        local base_dir="${PACKAGES_DIR}"

        ui_section "Available Modules"

        local found=false
        local cat_dir cat_name mod_file mod_name

        if [[ -n "$filter_category" ]]; then
                # List modules from specific category
                cat_dir="${base_dir}/${filter_category}"
                if ! directory_exists "$cat_dir"; then
                        log_error "Category not found: ${filter_category}"
                        return "$EXIT_FAILURE"
                fi

                cat_name="$filter_category"
                for mod_file in "$cat_dir"/*.sh; do
                        [[ -f "$mod_file" ]] || continue
                        mod_name="$(basename "$mod_file" .sh)"

                        if [[ "$verbose" == true ]]; then
                                ui_key_value "  ${cat_name}/${mod_name}" "$mod_file"
                        else
                                ui_bullet "${cat_name}/${mod_name}"
                        fi

                        found=true
                done
        else
                # List all modules from all categories
                for cat_dir in "$base_dir"/*/; do
                        [[ -d "$cat_dir" ]] || continue
                        cat_name="$(basename "$cat_dir")"

                        # Skip profiles directory
                        [[ "$cat_name" == "profiles" ]] && continue

                        for mod_file in "$cat_dir"/*.sh; do
                                [[ -f "$mod_file" ]] || continue
                                mod_name="$(basename "$mod_file" .sh)"

                                if [[ "$verbose" == true ]]; then
                                        ui_key_value "  ${cat_name}/${mod_name}" "$mod_file"
                                else
                                        ui_bullet "${cat_name}/${mod_name}"
                                fi

                                found=true
                        done
                done
        fi

        if [[ "$found" == false ]]; then
                log_info "No modules found."
        fi

        printf "\n"
}

# ------------------------------------------------------------------------------
# List Installed
# ------------------------------------------------------------------------------

_list_installed() {
        local verbose="$1"

        ui_section "Installed Packages"

        # Check for pkg (Termux package manager)
        if command_exists pkg; then
                ui_info "Package manager: pkg"
                if [[ "$verbose" == true ]]; then
                        log_info "Listing installed packages..."
                        pkg list-installed 2>/dev/null | head -20
                fi
        else
                ui_warning "Package manager: not available (pkg not found)"
        fi

        printf "\n"
}
