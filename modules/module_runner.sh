#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap: Module Runner
# ==============================================================================
#
# Execution lifecycle for modules — install, remove, upgrade, verify.
# Wraps module_loader and installer_engine with lifecycle tracking.
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Internal State
# ------------------------------------------------------------------------------

_RUNNER_INSTALLED=""
_RUNNER_REMOVED=""
_RUNNER_UPGRADED=""

# ------------------------------------------------------------------------------
# Module Installation
# ------------------------------------------------------------------------------

run_module_install() {
        local category="$1"
        local module="$2"

        [[ -z "$category" || -z "$module" ]] && return 1

        local key="${category}/${module}"

        case "$_RUNNER_INSTALLED" in
                *"|${key}|"*) return 0 ;;
        esac

        if ! installer_install_module "$category" "$module"; then
                log_error "Failed to install module: ${key}"
                return 1
        fi

        _RUNNER_INSTALLED="${_RUNNER_INSTALLED}|${key}|"
        return 0
}

# ------------------------------------------------------------------------------
# Module Removal
# ------------------------------------------------------------------------------

run_module_remove() {
        local category="$1"
        local module="$2"

        [[ -z "$category" || -z "$module" ]] && return 1

        local key="${category}/${module}"

        # Check for module-level uninstall function
        local sanitized="${module//-/_}"
        local uninstall_fn="uninstall_${category}_${sanitized}"

        if declare -F "$uninstall_fn" >/dev/null 2>&1; then
                ui_section "Removing: ${key}"
                if ! "$uninstall_fn"; then
                        log_error "Module removal function failed: ${key}"
                        return 1
                fi
        else
                log_info "Module '${key}' has no uninstall function — skipping"
        fi

        case "$_RUNNER_REMOVED" in
                *"|${key}|"*) ;;
                *)
                        _RUNNER_REMOVED="${_RUNNER_REMOVED}|${key}|"
                        ;;
        esac

        log_success "Removed: ${key}"
        return 0
}

# ------------------------------------------------------------------------------
# Module Upgrade
# ------------------------------------------------------------------------------

run_module_upgrade() {
        local category="$1"
        local module="$2"

        [[ -z "$category" || -z "$module" ]] && return 1

        local key="${category}/${module}"

        case "$_RUNNER_UPGRADED" in
                *"|${key}|"*) return 0 ;;
        esac

        ui_section "Upgrading: ${key}"

        # Remove then re-install
        if module_loaded "$category" "$module" 2>/dev/null; then
                run_module_remove "$category" "$module"
        fi

        _RUNNER_REMOVED="${_RUNNER_REMOVED//\|${key}\|/|}"

        if ! installer_install_module "$category" "$module" force; then
                log_error "Failed to upgrade module: ${key}"
                return 1
        fi

        _RUNNER_UPGRADED="${_RUNNER_UPGRADED}|${key}|"
        log_success "Upgraded: ${key}"
        return 0
}

# ------------------------------------------------------------------------------
# Module Verification
# ------------------------------------------------------------------------------

run_module_verify() {
        local category="$1"
        local module="$2"

        [[ -z "$category" || -z "$module" ]] && return 1

        local key="${category}/${module}"
        local errors=0

        ui_section "Verifying: ${key}"

        # Check 1: Module file exists
        local module_file="${PACKAGES_DIR:-${LIB_DIR}/../packages}/${category}/${module}.sh"
        if [[ ! -f "$module_file" ]]; then
                ui_error "Module file not found: ${module_file}"
                return 1
        fi
        ui_success "Module file: ${module_file}"

        # Check 2: Install function exists
        local sanitized="${module//-/_}"
        local install_fn="install_${category}_${sanitized}"
        if ! grep -q "^${install_fn}()" "$module_file" 2>/dev/null; then
                ui_warning "No install function: ${install_fn}"
                ((errors++)) || true
        fi
        ui_success "Install function: ${install_fn}"

        # Check 3: Module is loaded
        if module_loaded "$category" "$module" 2>/dev/null; then
                ui_success "Module loaded"
        else
                ui_warning "Module not loaded"
                ((errors++)) || true
        fi

        if [[ "$errors" -gt 0 ]]; then
                ui_warning "Module '${key}' has ${errors} issue(s)"
                return 1
        fi

        ui_success "Module '${key}' verified OK"
        return 0
}
