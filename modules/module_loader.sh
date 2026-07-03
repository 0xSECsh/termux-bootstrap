#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap: Module Loader
# ==============================================================================
#
# Dynamic module loading with lazy initialization, dependency validation,
# and safe imports. Follows the load_library pattern from common.sh.
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Internal State
# ------------------------------------------------------------------------------

_MODULE_LOADER_LOADED=""
_MODULE_LOADER_SOURCED=""
_MODULE_LOADER_RAN=""

# ------------------------------------------------------------------------------
# Module Loading
# ------------------------------------------------------------------------------

load_module() {
        local category="$1"
        local module="$2"

        [[ -z "$category" || -z "$module" ]] && return 1

        local key="${category}/${module}"

        case "$_MODULE_LOADER_LOADED" in
                *"|${key}|"*) return 0 ;;
        esac

        local module_file="${PACKAGES_DIR:-${LIB_DIR}/../packages}/${category}/${module}.sh"

        if [[ ! -f "$module_file" ]]; then
                log_warning "Module not found: ${key}"
                return 1
        fi

        case "$_MODULE_LOADER_SOURCED" in
                *"|${key}|"*)
                        ;;
                *)
                        # shellcheck disable=SC1090
                        source "$module_file"
                        _MODULE_LOADER_SOURCED="${_MODULE_LOADER_SOURCED}|${key}|"
                        ;;
        esac

        local sanitized="${module//-/_}"
        local func_name="install_${category}_${sanitized}"

        if ! declare -F "$func_name" >/dev/null 2>&1; then
                log_warning "Module '${key}' has no install function: ${func_name}"
                _MODULE_LOADER_LOADED="${_MODULE_LOADER_LOADED}|${key}|"
                return 0
        fi

        case "$_MODULE_LOADER_RAN" in
                *"|${key}|"*)
                        ;;
                *)
                        ui_section "Module: ${key}"

                        if ! "$func_name"; then
                                log_error "Module '${key}' install function failed"
                                return 1
                        fi

                        _MODULE_LOADER_RAN="${_MODULE_LOADER_RAN}|${key}|"
                        ;;
        esac

        _MODULE_LOADER_LOADED="${_MODULE_LOADER_LOADED}|${key}|"
        return 0
}

# ------------------------------------------------------------------------------
# Dependency Validation
# ------------------------------------------------------------------------------

require_module() {
        local category="$1"
        local module="$2"
        local strict="${3:-true}"

        [[ -z "$category" || -z "$module" ]] && return 1

        local key="${category}/${module}"

        case "$_MODULE_LOADER_LOADED" in
                *"|${key}|"*) return 0 ;;
        esac

        local deps
        deps="$(module_deps "$category" "$module")"

        if [[ -n "$deps" ]]; then
                local dep
                local IFS=' '
                for dep in $deps; do
                        [[ -z "$dep" ]] && continue

                        local dep_cat dep_mod
                        if [[ "$dep" == *"/"* ]]; then
                                dep_cat="${dep%%/*}"
                                dep_mod="${dep#*/}"
                        else
                                dep_cat="${category}"
                                dep_mod="${dep}"
                        fi

                        if ! load_module "$dep_cat" "$dep_mod"; then
                                if [[ "$strict" == true ]]; then
                                        log_error "Failed to load dependency: ${dep_cat}/${dep_mod} for ${key}"
                                        return 1
                                fi
                                log_warning "Optional dependency failed: ${dep_cat}/${dep_mod} for ${key}"
                        fi
                done
        fi

        load_module "$category" "$module"
}

# ------------------------------------------------------------------------------
# Module State
# ------------------------------------------------------------------------------

module_loaded() {
        local category="$1"
        local module="$2"

        [[ -z "$category" || -z "$module" ]] && return 1

        local key="${category}/${module}"
        case "$_MODULE_LOADER_LOADED" in
                *"|${key}|"*) return 0 ;;
        esac
        return 1
}

module_sourced() {
        local category="$1"
        local module="$2"

        [[ -z "$category" || -z "$module" ]] && return 1

        local key="${category}/${module}"
        case "$_MODULE_LOADER_SOURCED" in
                *"|${key}|"*) return 0 ;;
        esac
        return 1
}

module_ran() {
        local category="$1"
        local module="$2"

        [[ -z "$category" || -z "$module" ]] && return 1

        local key="${category}/${module}"
        case "$_MODULE_LOADER_RAN" in
                *"|${key}|"*) return 0 ;;
        esac
        return 1
}

module_loaded_list() {
        local IFS='|'
        local entries=()
        read -ra entries <<<"$_MODULE_LOADER_LOADED"
        unset IFS

        local entry
        for entry in "${entries[@]}"; do
                [[ -n "$entry" ]] && printf '%s\n' "$entry"
        done
}

module_loaded_count() {
        local count=0
        local IFS='|'
        local entries=()
        read -ra entries <<<"$_MODULE_LOADER_LOADED"
        unset IFS

        local entry
        for entry in "${entries[@]}"; do
                [[ -n "$entry" ]] && ((count++))
        done

        printf '%d\n' "$count"
}

# ------------------------------------------------------------------------------
# Dependency Resolution
# ------------------------------------------------------------------------------

_module_resolve_deps() {
        local category="$1"
        local module="$2"
        local resolved="${3:-}"
        local visiting="${4:-}"

        local key="${category}/${module}"

        [[ "$resolved" == *"|$key|"* ]] && return 0
        [[ "$visiting" == *"|$key|"* ]] && return 0

        visiting="${visiting}|${key}|"

        local deps
        deps="$(module_deps "$category" "$module")"

        if [[ -n "$deps" ]]; then
                local dep
                local IFS=' '
                for dep in $deps; do
                        [[ -z "$dep" ]] && continue

                        local dep_cat dep_mod
                        if [[ "$dep" == *"/"* ]]; then
                                dep_cat="${dep%%/*}"
                                dep_mod="${dep#*/}"
                        else
                                dep_cat="${category}"
                                dep_mod="${dep}"
                        fi

                        # Capture the recursion's accumulated result instead of
                        # letting its final printf leak into our stdout (which
                        # produced duplicate entries). The child appends its own
                        # key before returning, so no manual append is needed.
                        resolved="$(_module_resolve_deps "$dep_cat" "$dep_mod" "$resolved" "$visiting")"
                done
        fi

        if [[ "$resolved" != *"|$key|"* ]]; then
                resolved="${resolved}|${key}|"
        fi

        printf '%s' "$resolved"
        return 0
}

resolve_module_deps() {
        local category="$1"
        local module="$2"

        [[ -z "$category" || -z "$module" ]] && return 1

        local resolved
        resolved="$(_module_resolve_deps "$category" "$module")"

        local entries=()
        local IFS='|'
        read -ra entries <<<"$resolved"
        unset IFS

        local entry
        for entry in "${entries[@]}"; do
                [[ -z "$entry" ]] && continue
                printf '%s\n' "$entry"
        done
}
