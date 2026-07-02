#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap: Profile Loader
# ==============================================================================
#
# Profile execution with deduplication. Profiles orchestrate modules via
# load_module — they must never install packages directly.
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Internal State
# ------------------------------------------------------------------------------

_PROFILE_LOADER_LOADED=""
_PROFILE_LOADER_SOURCED=""
_PROFILE_LOADER_RAN=""

# ------------------------------------------------------------------------------
# Profile Loading
# ------------------------------------------------------------------------------

load_profile() {
	local name="$1"

	[[ -z "$name" ]] && return 1

	case "$_PROFILE_LOADER_LOADED" in
	*"|${name}|"*) return 0 ;;
	esac

	local profile_dir="${PACKAGES_DIR:-${LIB_DIR}/../packages}/profiles"
	local profile_file="${profile_dir}/${name}.sh"

	if [[ ! -f "$profile_file" ]]; then
		log_warning "Profile not found: ${name}"
		return 1
	fi

	case "$_PROFILE_LOADER_SOURCED" in
	*"|${name}|"*)
		;;
	*)
		# shellcheck disable=SC1090
		source "$profile_file"
		_PROFILE_LOADER_SOURCED="${_PROFILE_LOADER_SOURCED}|${name}|"
		;;
	esac

	local func_name="install_profile_${name}"

	if ! declare -F "$func_name" >/dev/null 2>&1; then
		log_warning "Profile '${name}' has no install function: ${func_name}"
		_PROFILE_LOADER_LOADED="${_PROFILE_LOADER_LOADED}|${name}|"
		return 0
	fi

	case "$_PROFILE_LOADER_RAN" in
	*"|${name}|"*)
		;;
	*)
		ui_section "Profile: ${name}"

		if ! "$func_name"; then
			log_error "Profile '${name}' install function failed"
			return 1
		fi

		_PROFILE_LOADER_RAN="${_PROFILE_LOADER_RAN}|${name}|"
		;;
	esac

	_PROFILE_LOADER_LOADED="${_PROFILE_LOADER_LOADED}|${name}|"
	return 0
}

# ------------------------------------------------------------------------------
# Profile State
# ------------------------------------------------------------------------------

profile_loaded() {
	local name="$1"

	[[ -z "$name" ]] && return 1

	case "$_PROFILE_LOADER_LOADED" in
	*"|${name}|"*) return 0 ;;
	esac
	return 1
}

profile_sourced() {
	local name="$1"

	[[ -z "$name" ]] && return 1

	case "$_PROFILE_LOADER_SOURCED" in
	*"|${name}|"*) return 0 ;;
	esac
	return 1
}

profile_ran() {
	local name="$1"

	[[ -z "$name" ]] && return 1

	case "$_PROFILE_LOADER_RAN" in
	*"|${name}|"*) return 0 ;;
	esac
	return 1
}

profile_loaded_list() {
	local IFS='|'
	local entries=()
	read -ra entries <<< "$_PROFILE_LOADER_LOADED"
	unset IFS

	local entry
	for entry in "${entries[@]}"; do
		[[ -n "$entry" ]] && printf '%s\n' "$entry"
	done
}

profile_loaded_count() {
	local count=0
	local IFS='|'
	local entries=()
	read -ra entries <<< "$_PROFILE_LOADER_LOADED"
	unset IFS

	local entry
	for entry in "${entries[@]}"; do
		[[ -n "$entry" ]] && ((count++))
	done

	printf '%d\n' "$count"
}
