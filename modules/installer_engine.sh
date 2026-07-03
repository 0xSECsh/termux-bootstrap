#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap: Installer Engine
# ==============================================================================
#
# Orchestrates module and profile installation with dependency resolution,
# ordered execution, progress reporting, rollback support, logging, and
# dry-run mode.
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Internal State
# ------------------------------------------------------------------------------

_INSTALLER_DRY_RUN=false
_INSTALLER_ROLLBACK_ENABLED=true
_INSTALLER_ROLLBACK_STACK=""
_INSTALLER_INSTALLED_PACKAGES=""
_INSTALLER_CURRENT_PHASE=""
_INSTALLER_TOTAL_STEPS=0
_INSTALLER_CURRENT_STEP=0

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

installer_set_dry_run() {
        _INSTALLER_DRY_RUN="${1:-true}"
}

installer_is_dry_run() {
        [[ "$_INSTALLER_DRY_RUN" == true ]]
}

installer_set_rollback() {
        _INSTALLER_ROLLBACK_ENABLED="${1:-true}"
}

# ------------------------------------------------------------------------------
# Rollback Support
# ------------------------------------------------------------------------------

_installer_rollback_push() {
        local action="$1"
        local target="$2"

        [[ "$_INSTALLER_ROLLBACK_ENABLED" == true ]] || return 0

        _INSTALLER_ROLLBACK_STACK="${action}:${target}|${_INSTALLER_ROLLBACK_STACK}"
}

_installer_rollback_pop() {
        [[ -z "$_INSTALLER_ROLLBACK_STACK" ]] && return 1

        local entry="${_INSTALLER_ROLLBACK_STACK%%|*}"
        _INSTALLER_ROLLBACK_STACK="${_INSTALLER_ROLLBACK_STACK#*|}"

        local action="${entry%%:*}"
        local target="${entry#*:}"

        printf '%s %s' "$action" "$target"
}

_installer_rollback_execute() {
        [[ "$_INSTALLER_ROLLBACK_ENABLED" == true ]] || return 0
        [[ -z "$_INSTALLER_ROLLBACK_STACK" ]] && return 0

        log_info "Executing rollback..."

        local action target result
        while result="$(_installer_rollback_pop)"; do
                [[ -z "$result" ]] && continue
                action="${result%% *}"
                target="${result#* }"

                case "$action" in
                        remove_package)
                                if [[ "$_INSTALLER_DRY_RUN" == true ]]; then
                                        log_info "[dry-run] Would remove package: ${target}"
                                else
                                        log_info "Rolling back package: ${target}"
                                        pkg_remove "$target" 2>/dev/null || true
                                fi
                                ;;
                        restore_file)
                                if [[ "$_INSTALLER_DRY_RUN" == true ]]; then
                                        log_info "[dry-run] Would restore file: ${target}"
                                else
                                        log_info "Rolling back file: ${target}"
                                        if [[ -f "${target}.bak" ]]; then
                                                mv "${target}.bak" "$target"
                                        fi
                                fi
                                ;;
                        remove_directory)
                                if [[ "$_INSTALLER_DRY_RUN" == true ]]; then
                                        log_info "[dry-run] Would remove directory: ${target}"
                                else
                                        log_info "Rolling back directory: ${target}"
                                        rm -rf "$target" 2>/dev/null || true
                                fi
                                ;;
                        *)
                                log_warning "Unknown rollback action: ${action}"
                                ;;
                esac
        done

        log_success "Rollback complete"
}

# ------------------------------------------------------------------------------
# Package Tracking
# ------------------------------------------------------------------------------

_installer_track_package() {
        local package="$1"

        case "$_INSTALLER_INSTALLED_PACKAGES" in
                *"|${package}|"*) return 0 ;;
        esac

        _INSTALLER_INSTALLED_PACKAGES="${_INSTALLER_INSTALLED_PACKAGES}|${package}|"
}

_installer_is_package_tracked() {
        local package="$1"

        case "$_INSTALLER_INSTALLED_PACKAGES" in
                *"|${package}|"*) return 0 ;;
        esac
        return 1
}

# Record a package that was just installed so a later failure can roll it back.
# Called from the packages.sh wrappers (guarded by declare -F) after a real
# install succeeds. No-op during dry-run.
installer_record_installed_package() {
        local package="$1"

        [[ -z "$package" ]] && return 0
        [[ "$_INSTALLER_DRY_RUN" == true ]] && return 0

        _installer_is_package_tracked "$package" && return 0

        _installer_track_package "$package"
        _installer_rollback_push "remove_package" "$package"
}

# ------------------------------------------------------------------------------
# Progress Reporting
# ------------------------------------------------------------------------------

_installer_progress_start() {
        local total="$1"
        local description="$2"

        _INSTALLER_TOTAL_STEPS="$total"
        _INSTALLER_CURRENT_STEP=0

        ui_section "$description"
}

_installer_progress_step() {
        local message="$1"

        ((_INSTALLER_CURRENT_STEP++)) || true
        progress_draw "$_INSTALLER_CURRENT_STEP" "$_INSTALLER_TOTAL_STEPS" "$message"
}

_installer_progress_finish() {
        progress_finish
}

# ------------------------------------------------------------------------------
# Module Installation
# ------------------------------------------------------------------------------

installer_install_module() {
        local category="$1"
        local module="$2"
        local force="${3:-false}"

        [[ -z "$category" || -z "$module" ]] && return 1

        local key="${category}/${module}"

        # Check if already installed
        if [[ "$force" != true ]] && module_loaded "$category" "$module" 2>/dev/null; then
                log_skip "$key" "already installed"
                return 0
        fi

        # Resolve dependencies
        local deps
        deps="$(resolve_module_deps "$category" "$module" 2>/dev/null)"

        local dep_list=()
        local IFS=$'\n'
        if [[ -n "$deps" ]]; then
                while IFS= read -r dep; do
                        [[ -z "$dep" ]] && continue
                        dep_list+=("$dep")
                done <<<"$deps"
        fi
        unset IFS

        # Add the module itself
        local found=false
        for dep in "${dep_list[@]}"; do
                if [[ "$dep" == "$key" ]]; then
                        found=true
                        break
                fi
        done
        [[ "$found" == false ]] && dep_list+=("$key")

        local total=${#dep_list[@]}

        if [[ "$total" -eq 0 ]]; then
                log_warning "No modules to install: ${key}"
                return 0
        fi

        # Progress reporting
        _installer_progress_start "$total" "Installing: ${key}"

        local dep_cat dep_mod
        for dep in "${dep_list[@]}"; do
                dep_cat="${dep%%/*}"
                dep_mod="${dep#*/}"

                _installer_progress_step "$dep"

                if [[ "$_INSTALLER_DRY_RUN" == true ]]; then
                        log_info "[dry-run] Would install module: ${dep}"
                else
                        if ! load_module "$dep_cat" "$dep_mod"; then
                                _installer_progress_finish
                                log_error "Failed to install module: ${dep}"
                                _installer_rollback_execute
                                return 1
                        fi
                fi
        done

        _installer_progress_finish
        log_success "Installed: ${key}"
        return 0
}

# ------------------------------------------------------------------------------
# Profile Installation
# ------------------------------------------------------------------------------

installer_install_profile() {
        local name="$1"
        local force="${2:-false}"

        [[ -z "$name" ]] && return 1

        # Check if profile exists
        if ! profile_exists "$name" 2>/dev/null; then
                log_error "Profile not found: ${name}"
                return 1
        fi

        # Check if already installed
        if [[ "$force" != true ]] && profile_loaded "$name" 2>/dev/null; then
                log_skip "profile/${name}" "already installed"
                return 0
        fi

        # Get profile modules
        local modules
        modules="$(profile_modules "$name" 2>/dev/null)"

        local module_list=()
        if [[ -n "$modules" ]]; then
                local IFS=','
                for mod in $modules; do
                        [[ -z "$mod" ]] && continue
                        module_list+=("$mod")
                done
                unset IFS
        fi

        local total=${#module_list[@]}

        if [[ "$total" -eq 0 ]]; then
                log_warning "No modules found for profile: ${name}"
                return 0
        fi

        # Progress reporting
        _installer_progress_start "$total" "Installing profile: ${name}"

        local mod category module_name
        for mod in "${module_list[@]}"; do
                category="${mod%% *}"
                module_name="${mod#* }"

                _installer_progress_step "${category}/${module_name}"

                if [[ "$_INSTALLER_DRY_RUN" == true ]]; then
                        log_info "[dry-run] Would install module: ${category}/${module_name}"
                else
                        if ! load_module "$category" "$module_name"; then
                                _installer_progress_finish
                                log_error "Failed to install module: ${category}/${module_name}"
                                _installer_rollback_execute
                                return 1
                        fi
                fi
        done

        _installer_progress_finish
        log_success "Installed profile: ${name}"
        if [[ "$_INSTALLER_DRY_RUN" != true ]]; then
                _PROFILE_LOADER_LOADED="${_PROFILE_LOADER_LOADED}|${name}|"
        fi
        return 0
}

# ------------------------------------------------------------------------------
# Batch Installation
# ------------------------------------------------------------------------------

installer_install_batch() {
        local modules=("$@")

        [[ ${#modules[@]} -eq 0 ]] && return 1

        # Resolve all dependencies first
        local all_deps=""
        local mod category module_name

        for mod in "${modules[@]}"; do
                if [[ "$mod" == *"/"* ]]; then
                        category="${mod%%/*}"
                        module_name="${mod#*/}"
                else
                        log_error "Invalid module format: ${mod} (expected category/module)"
                        return 1
                fi

                local deps
                deps="$(resolve_module_deps "$category" "$module_name" 2>/dev/null)"
                if [[ -n "$deps" ]]; then
                        all_deps="${all_deps}${deps}"$'\n'
                fi
                all_deps="${all_deps}${category}/${module_name}"$'\n'
        done

        # Deduplicate and sort
        local unique_deps
        unique_deps="$(printf '%s' "$all_deps" | sort -u | grep -v '^$')"

        local total
        total="$(printf '%s' "$unique_deps" | grep -c '[^[:space:]]')"

        if [[ "$total" -eq 0 ]]; then
                log_warning "No modules to install"
                return 0
        fi

        # Progress reporting
        _installer_progress_start "$total" "Installing batch"

        local dep_cat dep_mod
        while IFS= read -r dep; do
                [[ -z "$dep" ]] && continue

                dep_cat="${dep%%/*}"
                dep_mod="${dep#*/}"

                _installer_progress_step "$dep"

                if [[ "$_INSTALLER_DRY_RUN" == true ]]; then
                        log_info "[dry-run] Would install module: ${dep}"
                else
                        if ! load_module "$dep_cat" "$dep_mod"; then
                                _installer_progress_finish
                                log_error "Failed to install module: ${dep}"
                                _installer_rollback_execute
                                return 1
                        fi
                fi
        done <<<"$unique_deps"

        _installer_progress_finish
        log_success "Batch installation complete"
        return 0
}

# ------------------------------------------------------------------------------
# Dry-run Preview
# ------------------------------------------------------------------------------

installer_preview() {
        local modules=("$@")

        [[ ${#modules[@]} -eq 0 ]] && return 1

        local saved_dry_run="$_INSTALLER_DRY_RUN"
        _INSTALLER_DRY_RUN=true

        ui_section "Dry-run Preview"

        for mod in "${modules[@]}"; do
                if [[ "$mod" == *"/"* ]]; then
                        local category="${mod%%/*}"
                        local module_name="${mod#*/}"
                        installer_install_module "$category" "$module_name"
                else
                        installer_install_profile "$mod"
                fi
        done

        _INSTALLER_DRY_RUN="$saved_dry_run"
}

# ------------------------------------------------------------------------------
# State Queries
# ------------------------------------------------------------------------------

installer_is_dry_run_enabled() {
        [[ "$_INSTALLER_DRY_RUN" == true ]]
}

installer_rollback_stack_empty() {
        [[ -z "$_INSTALLER_ROLLBACK_STACK" ]]
}

installer_installed_packages() {
        local IFS='|'
        local entries=()
        read -ra entries <<<"$_INSTALLER_INSTALLED_PACKAGES"
        unset IFS

        local entry
        for entry in "${entries[@]}"; do
                [[ -n "$entry" ]] && printf '%s\n' "$entry"
        done
}

installer_installed_count() {
        local count=0
        local IFS='|'
        local entries=()
        read -ra entries <<<"$_INSTALLER_INSTALLED_PACKAGES"
        unset IFS

        local entry
        for entry in "${entries[@]}"; do
                [[ -n "$entry" ]] && ((count++))
        done

        printf '%d\n' "$count"
}

# ------------------------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------------------------

installer_reset() {
        _INSTALLER_DRY_RUN=false
        _INSTALLER_ROLLBACK_ENABLED=true
        _INSTALLER_ROLLBACK_STACK=""
        _INSTALLER_INSTALLED_PACKAGES=""
        _INSTALLER_CURRENT_PHASE=""
        _INSTALLER_TOTAL_STEPS=0
        _INSTALLER_CURRENT_STEP=0
}
