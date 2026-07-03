#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap: Profile Registry
# ==============================================================================
#
# Dynamic profile discovery and metadata extraction.
# Scans packages/profiles/ directory to build a registry of available profiles.
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Internal State
# ------------------------------------------------------------------------------

_PROFILE_REGISTRY_READY=false
_PROFILE_LIST=""
_PROFILE_INFO=""
_PROFILE_MODULES=""

# ------------------------------------------------------------------------------
# Registry Initialization
# ------------------------------------------------------------------------------

_profile_registry_init() {
        [[ "$_PROFILE_REGISTRY_READY" == true ]] && return 0

        local base_dir="${PACKAGES_DIR:-${LIB_DIR}/../packages}"
        local profile_dir="${base_dir}/profiles"
        [[ -d "$profile_dir" ]] || return 1

        local file name key desc modules
        _PROFILE_LIST=""
        _PROFILE_INFO=""
        _PROFILE_MODULES=""

        for file in "$profile_dir"/*.sh; do
                [[ -f "$file" ]] || continue
                name="$(basename "$file" .sh)"
                key="$name"
                desc="$(_profile_extract_description "$file")"
                modules="$(_profile_extract_modules "$file")"

                _PROFILE_LIST="${_PROFILE_LIST}${key}|"
                _PROFILE_INFO="${_PROFILE_INFO}${key}=${desc}|"
                _PROFILE_MODULES="${_PROFILE_MODULES}${key}=${modules}|"
        done

        _PROFILE_REGISTRY_READY=true
        return 0
}

# ------------------------------------------------------------------------------
# Metadata Extraction
# ------------------------------------------------------------------------------

_profile_extract_description() {
        local file="$1"
        local line

        while IFS= read -r line; do
                case "$line" in
                        "# Description:"*)
                                printf '%s' "${line#\# Description: }"
                                return 0
                                ;;
                esac
        done <"$file"

        printf '%s' "(no description)"
        return 0
}

_profile_extract_modules() {
        local file="$1"
        local in_install=false
        local modules=()
        local line func_name

        func_name="$(grep -m1 'install_profile_[a-z_]*()' "$file" 2>/dev/null | sed 's/() {//')"

        [[ -z "$func_name" ]] && return 0

        while IFS= read -r line; do
                if [[ "$line" =~ ^${func_name}\(\) ]]; then
                        in_install=true
                        continue
                fi

                if [[ "$in_install" == true ]]; then
                        [[ "$line" == "}" ]] && break
                        line="${line#"${line%%[![:space:]]*}"}"
                        line="${line%"${line##*[![:space:]]}"}"
                        [[ "$line" == "load_module"* ]] || continue
                        line="${line#load_module }"
                        line="${line#"${line%%[![:space:]]*}"}"
                        line="${line%"${line##*[![:space:]]}"}"
                        [[ -n "$line" ]] && modules+=("$line")
                fi
        done <"$file"

        local IFS=','
        printf '%s' "${modules[*]+"${modules[*]}"}"
}

# ------------------------------------------------------------------------------
# Public API
# ------------------------------------------------------------------------------

profile_exists() {
        local name="$1"

        [[ -z "$name" ]] && return 1

        _profile_registry_init

        [[ "$_PROFILE_LIST" == *"${name}|"* ]] && return 0

        local profile_file="${PACKAGES_DIR:-${LIB_DIR}/../packages}/profiles/${name}.sh"
        [[ -f "$profile_file" ]] && return 0

        return 1
}

profile_list() {
        _profile_registry_init || return 1

        local entries=()
        local entry
        local IFS='|'
        read -ra entries <<<"$_PROFILE_LIST"
        unset IFS

        local sorted=()
        for entry in "${entries[@]}"; do
                [[ -z "$entry" ]] && continue
                sorted+=("$entry")
        done

        local IFS=$'\n'
        mapfile -t sorted < <(printf '%s\n' "${sorted[@]}" | sort)
        unset IFS

        local key desc
        for key in "${sorted[@]}"; do
                desc="$(_profile_registry_get_desc "$key")"
                printf '%-20s %s\n' "$key" "-- $desc"
        done

        return 0
}

_profile_registry_get_desc() {
        local target="$1"
        local entry key desc
        local IFS='|'
        local entries=()

        read -ra entries <<<"$_PROFILE_INFO"
        unset IFS

        for entry in "${entries[@]}"; do
                [[ -z "$entry" ]] && continue
                key="${entry%%=*}"
                desc="${entry#*=}"
                if [[ "$key" == "$target" ]]; then
                        printf '%s' "$desc"
                        return 0
                fi
        done

        printf '%s' "(no description)"
        return 0
}

_profile_registry_get_modules() {
        local target="$1"
        local entry key modules
        local IFS='|'
        local entries=()

        read -ra entries <<<"$_PROFILE_MODULES"
        unset IFS

        for entry in "${entries[@]}"; do
                [[ -z "$entry" ]] && continue
                key="${entry%%=*}"
                modules="${entry#*=}"
                if [[ "$key" == "$target" ]]; then
                        printf '%s' "$modules"
                        return 0
                fi
        done

        return 0
}

profile_modules() {
        local name="$1"

        [[ -z "$name" ]] && return 1

        _profile_registry_init
        _profile_registry_get_modules "$name"
}

profile_info() {
        local name="$1"

        [[ -z "$name" ]] && return 1

        local profile_file desc modules func_name
        local profile_dir="${PACKAGES_DIR:-${LIB_DIR}/../packages}/profiles"

        _profile_registry_init

        profile_file="${profile_dir}/${name}.sh"
        [[ -f "$profile_file" ]] || return 1

        desc="$(_profile_registry_get_desc "$name")"
        modules="$(_profile_registry_get_modules "$name")"
        func_name="install_profile_${name}"

        printf 'Profile:      %s\n' "$name"
        printf 'Description:  %s\n' "$desc"
        printf 'Function:     %s\n' "$func_name"
        printf 'File:         %s\n' "$profile_file"
        printf 'Modules:      %s\n' "${modules:-none}"

        return 0
}

profile_count() {
        _profile_registry_init || return 1

        local count=0
        local IFS='|'
        local entries=()

        read -ra entries <<<"$_PROFILE_LIST"
        unset IFS

        for entry in "${entries[@]}"; do
                [[ -n "$entry" ]] && ((count++))
        done

        printf '%d\n' "$count"
}
