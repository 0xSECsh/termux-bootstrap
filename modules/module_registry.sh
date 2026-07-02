#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap: Module Registry
# ==============================================================================
#
# Dynamic module discovery and metadata extraction.
# Scans packages/ directory to build a registry of available modules.
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Internal State
# ------------------------------------------------------------------------------

_MODULE_REGISTRY_READY=false
_MODULE_LIST=""
_MODULE_INFO=""
_MODULE_DEPS=""

# ------------------------------------------------------------------------------
# Registry Initialization
# ------------------------------------------------------------------------------

_module_registry_init() {
	[[ "$_MODULE_REGISTRY_READY" == true ]] && return 0

	local base_dir="${PACKAGES_DIR:-${LIB_DIR}/../packages}"
	[[ -d "$base_dir" ]] || return 1

	local cat_dir cat_name mod_file mod_name key desc deps
	_MODULE_LIST=""
	_MODULE_INFO=""
	_MODULE_DEPS=""

	for cat_dir in "$base_dir"/*/; do
		[[ -d "$cat_dir" ]] || continue
		cat_name="$(basename "$cat_dir")"
		[[ "$cat_name" == "profiles" ]] && continue

		for mod_file in "$cat_dir"/*.sh; do
			[[ -f "$mod_file" ]] || continue
			mod_name="$(basename "$mod_file" .sh)"

			key="${cat_name}/${mod_name}"
			desc="$(_module_extract_description "$mod_file")"
			deps="$(_module_extract_dependencies "$mod_file")"

			_MODULE_LIST="${_MODULE_LIST}${key}|"
			_MODULE_INFO="${_MODULE_INFO}${key}=${desc}|"
			_MODULE_DEPS="${_MODULE_DEPS}${key}=${deps}|"
		done
	done

	_MODULE_REGISTRY_READY=true
	return 0
}

# ------------------------------------------------------------------------------
# Metadata Extraction
# ------------------------------------------------------------------------------

_module_extract_description() {
	local file="$1"
	local line

	while IFS= read -r line; do
		case "$line" in
		"# Description:"*)
			printf '%s' "${line#\# Description: }"
			return 0
			;;
		esac
	done < "$file"

	printf '%s' "(no description)"
	return 0
}

_module_extract_dependencies() {
	local file="$1"
	local line

	while IFS= read -r line; do
		case "$line" in
		"# Depends:"*)
			printf '%s' "${line#\# Depends: }"
			return 0
			;;
		esac
	done < "$file"

	return 0
}

_module_extract_packages() {
	local file="$1"
	local in_install=false
	local packages=()
	local line func_name

	func_name="$(grep -m1 'install_[a-z_]*()' "$file" 2>/dev/null | sed 's/() {//')"

	[[ -z "$func_name" ]] && return 0

	while IFS= read -r line; do
		if [[ "$line" =~ ^${func_name}\(\) ]]; then
			in_install=true
			continue
		fi

		if [[ "$in_install" == true ]]; then
			[[ "$line" == "}" ]] && break
			[[ "$line" =~ ^[[:space:]]*\\$ ]] && continue
			[[ "$line" =~ ^[[:space:]]*pkg_install ]] && continue

			line="${line##[[:space:]]}"
			line="${line%%[[:space:]]}"
			line="${line%%\\*}"
			line="${line##[[:space:]]}"
			line="${line%%[[:space:]]}"
			[[ -n "$line" ]] && packages+=("$line")
		fi
	done < "$file"

	printf '%s ' "${packages[@]+"${packages[@]}"}"
}

# ------------------------------------------------------------------------------
# Public API
# ------------------------------------------------------------------------------

module_exists() {
	local category="$1"
	local module="$2"

	[[ -z "$category" || -z "$module" ]] && return 1

	local key="${category}/${module}"

	[[ "$_MODULE_LIST" == *"${key}|"* ]] && return 0

	local module_file="${PACKAGES_DIR:-${LIB_DIR}/../packages}/${category}/${module}.sh"
	[[ -f "$module_file" ]] && return 0

	return 1
}

module_deps() {
	local category="$1"
	local module="$2"

	[[ -z "$category" || -z "$module" ]] && return 1

	_module_registry_init

	local key="${category}/${module}"
	_module_registry_get_deps "$key"
}

module_list() {
	local filter_category="${1:-}"

	_module_registry_init || return 1

	local entries=()
	local entry
	local IFS='|'
	read -ra entries <<< "$_MODULE_LIST"
	unset IFS

	local sorted=()
	for entry in "${entries[@]}"; do
		[[ -z "$entry" ]] && continue
		if [[ -n "$filter_category" ]]; then
			[[ "${entry%%/*}" == "$filter_category" ]] || continue
		fi
		sorted+=("$entry")
	done

	local IFS=$'\n'
	mapfile -t sorted < <(printf '%s\n' "${sorted[@]}" | sort)
	unset IFS

	local key desc
	for key in "${sorted[@]}"; do
		desc="$(_module_registry_get_desc "$key")"
		printf '%-40s %s\n' "$key" "-- $desc"
	done

	return 0
}

_module_registry_get_desc() {
	local target="$1"
	local entry key desc
	local IFS='|'
	local entries=()

	read -ra entries <<< "$_MODULE_INFO"
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

_module_registry_get_deps() {
	local target="$1"
	local entry key deps
	local IFS='|'
	local entries=()

	read -ra entries <<< "$_MODULE_DEPS"
	unset IFS

	for entry in "${entries[@]}"; do
		[[ -z "$entry" ]] && continue
		key="${entry%%=*}"
		deps="${entry#*=}"
		if [[ "$key" == "$target" ]]; then
			printf '%s' "$deps"
			return 0
		fi
	done

	return 0
}

module_info() {
	local category="$1"
	local module="$2"

	[[ -z "$category" || -z "$module" ]] && return 1

	local key="${category}/${module}"
	local module_file desc deps func_name sanitized packages

	_module_registry_init

	module_file="${PACKAGES_DIR:-${LIB_DIR}/../packages}/${category}/${module}.sh"
	[[ -f "$module_file" ]] || return 1

	desc="$(_module_registry_get_desc "$key")"
	deps="$(_module_registry_get_deps "$key")"
	sanitized="${module//-/_}"
	func_name="install_${category}_${sanitized}"
	packages="$(_module_extract_packages "$module_file")"

	printf 'Module:       %s/%s\n' "$category" "$module"
	printf 'Description:  %s\n' "$desc"
	printf 'Function:     %s\n' "$func_name"
	printf 'File:         %s\n' "$module_file"
	printf 'Dependencies: %s\n' "${deps:-none}"
	printf 'Packages:     %s\n' "${packages:-none}"

	return 0
}

module_categories() {
	_module_registry_init || return 1

	local categories=""
	local entry key cat_name
	local IFS='|'
	local entries=()

	read -ra entries <<< "$_MODULE_LIST"
	unset IFS

	for entry in "${entries[@]}"; do
		[[ -z "$entry" ]] && continue
		key="${entry%%/*}"
		if [[ "$categories" != *"${key} "* ]] && [[ "$categories" != *" ${key}"* ]] && [[ "$categories" != "${key}" ]]; then
			categories="${categories:+${categories} }${key}"
		fi
	done

	echo "$categories" | tr ' ' '\n' | sort
	return 0
}

module_count() {
	_module_registry_init || return 1

	local count=0
	local IFS='|'
	local entries=()

	read -ra entries <<< "$_MODULE_LIST"
	unset IFS

	for entry in "${entries[@]}"; do
		[[ -n "$entry" ]] && ((count++))
	done

	printf '%d\n' "$count"
}
