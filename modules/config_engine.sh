#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap: Configuration Engine
# ==============================================================================
#
# Reusable configuration management: read, write, validate, and merge config
# files. Supports both file-based and key-value configuration formats.
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Internal State
# ------------------------------------------------------------------------------

_CONFIG_ENGINE_READY=false
_CONFIG_LIST=""
_CONFIG_INFO=""

# Path mapping: app_name -> destination pattern
# Pattern uses {home} as placeholder for $HOME
_CONFIG_PATH_MAP="zsh:{home}/.zshrc|git:{home}/.gitconfig|tmux:{home}/.tmux.conf|nvim:{home}/.config/nvim/{file}|micro:{home}/.config/micro/{file}|fastfetch:{home}/.config/fastfetch/{file}"

# ------------------------------------------------------------------------------
# Registry Initialization
# ------------------------------------------------------------------------------

_config_engine_init() {
	[[ "$_CONFIG_ENGINE_READY" == true ]] && return 0

	local base_dir="${CONFIGS_DIR:-${LIB_DIR}/../configs}"
	[[ -d "$base_dir" ]] || return 1

	local app_name file_name file_path key desc
	_CONFIG_LIST=""
	_CONFIG_INFO=""

	for app_dir in "$base_dir"/*/; do
		[[ -d "$app_dir" ]] || continue
		app_name="$(basename "$app_dir")"

		for file_path in "$app_dir"* "$app_dir".*; do
			[[ -f "$file_path" ]] || continue
			file_name="$(basename "$file_path")"

			key="${app_name}/${file_name}"
			desc="$(_config_extract_description "$file_path")"

			_CONFIG_LIST="${_CONFIG_LIST}${key}|"
			_CONFIG_INFO="${_CONFIG_INFO}${key}=${desc}|"
		done
	done

	_CONFIG_ENGINE_READY=true
	return 0
}

# ------------------------------------------------------------------------------
# Metadata Extraction
# ------------------------------------------------------------------------------

_config_extract_description() {
	local file="$1"
	local line

	while IFS= read -r line; do
		case "$line" in
		"#"*Description:*)
			printf '%s' "${line#*: }"
			return 0
			;;
		esac
	done < "$file"

	printf '%s' "(no description)"
	return 0
}

# ------------------------------------------------------------------------------
# Path Resolution
# ------------------------------------------------------------------------------

config_resolve_path() {
	local app_name="$1"
	local filename="$2"

	[[ -z "$app_name" || -z "$filename" ]] && return 1

	local entry map_app map_pattern
	local IFS='|'
	local entries=()

	read -ra entries <<< "$_CONFIG_PATH_MAP"
	unset IFS

	for entry in "${entries[@]}"; do
		[[ -z "$entry" ]] && continue
		map_app="${entry%%:*}"
		map_pattern="${entry#*:}"

		if [[ "$map_app" == "$app_name" ]]; then
			local result="$map_pattern"
			result="${result//\{home\}/$HOME}"
			result="${result//\{file\}/$filename}"
			printf '%s' "$result"
			return 0
		fi
	done

	printf '%s' "${HOME}/.config/${app_name}/${filename}"
	return 0
}

# ------------------------------------------------------------------------------
# Public API: Registry
# ------------------------------------------------------------------------------

config_exists() {
	local app_name="$1"
	local filename="$2"

	[[ -z "$app_name" || -z "$filename" ]] && return 1

	local key="${app_name}/${filename}"

	_config_engine_init

	[[ "$_CONFIG_LIST" == *"${key}|"* ]] && return 0

	local source_file="${CONFIGS_DIR:-${LIB_DIR}/../configs}/${app_name}/${filename}"
	[[ -f "$source_file" ]] && return 0

	return 1
}

config_list() {
	_config_engine_init || return 1

	local entries=()
	local entry
	local IFS='|'
	read -ra entries <<< "$_CONFIG_LIST"
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
		desc="$(_config_engine_get_desc "$key")"
		printf '%-30s %s\n' "$key" "-- $desc"
	done

	return 0
}

_config_engine_get_desc() {
	local target="$1"
	local entry key desc
	local IFS='|'
	local entries=()

	read -ra entries <<< "$_CONFIG_INFO"
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

config_count() {
	_config_engine_init || return 1

	local count=0
	local IFS='|'
	local entries=()

	read -ra entries <<< "$_CONFIG_LIST"
	unset IFS

	for entry in "${entries[@]}"; do
		[[ -n "$entry" ]] && ((count++))
	done

	printf '%d\n' "$count"
}

# ------------------------------------------------------------------------------
# Public API: Read
# ------------------------------------------------------------------------------

config_read() {
	local app_name="$1"
	local filename="$2"

	[[ -z "$app_name" || -z "$filename" ]] && return 1

	local source_file="${CONFIGS_DIR:-${LIB_DIR}/../configs}/${app_name}/${filename}"
	[[ -f "$source_file" ]] || return 1

	cat "$source_file"
}

config_read_key() {
	local app_name="$1"
	local filename="$2"
	local key="$3"

	[[ -z "$app_name" || -z "$filename" || -z "$key" ]] && return 1

	local source_file="${CONFIGS_DIR:-${LIB_DIR}/../configs}/${app_name}/${filename}"
	[[ -f "$source_file" ]] || return 1

	local section=""
	local current_section=""
	local line
	local IFS=' '

	while IFS= read -r line; do
		line="${line##[[:space:]]}"

		case "$line" in
		"["*"]")
			current_section="${line#\[}"
			current_section="${current_section%\]}"
			;;
		"" | "#"* | ";"*)
			continue
			;;
		*)
			local k="${line%%=*}"
			k="${k##[[:space:]]}"
			k="${k%%[[:space:]]}"

			local full_key
			if [[ -n "$current_section" ]]; then
				full_key="${current_section}.${k}"
			else
				full_key="$k"
			fi

			if [[ "$full_key" == "$key" ]]; then
				local value="${line#*=}"
				value="${value##[[:space:]]}"
				value="${value%%[[:space:]]}"
				value="${value#\"}"
				value="${value%\"}"
				printf '%s' "$value"
				return 0
			fi
			;;
		esac
	done < "$source_file"

	return 0
}

# ------------------------------------------------------------------------------
# Public API: Write
# ------------------------------------------------------------------------------

config_write() {
	local app_name="$1"
	local filename="$2"
	local content="$3"

	[[ -z "$app_name" || -z "$filename" ]] && return 1

	local user_file
	user_file="$(config_resolve_path "$app_name" "$filename")"
	[[ -z "$user_file" ]] && return 1

	local user_dir
	user_dir="$(dirname "$user_file")"

	if [[ ! -d "$user_dir" ]]; then
		mkdir -p "$user_dir" || return 1
	fi

	printf '%s\n' "$content" > "$user_file"
	return 0
}

config_write_key() {
	local app_name="$1"
	local filename="$2"
	local key="$3"
	local value="$4"

	[[ -z "$app_name" || -z "$filename" || -z "$key" || -z "$value" ]] && return 1

	local user_file
	user_file="$(config_resolve_path "$app_name" "$filename")"
	[[ -z "$user_file" ]] && return 1

	local user_dir
	user_dir="$(dirname "$user_file")"

	if [[ ! -d "$user_dir" ]]; then
		mkdir -p "$user_dir" || return 1
	fi

	local found=false
	local tmp_file
	tmp_file="$(mktemp)"

	if [[ -f "$user_file" ]]; then
		local line
		while IFS= read -r line; do
			case "$line" in
			"${key} ="* | "${key}="*)
				printf '%s = %s\n' "$key" "$value" >> "$tmp_file"
				found=true
				;;
			*)
				printf '%s\n' "$line" >> "$tmp_file"
				;;
			esac
		done < "$user_file"
	fi

	if [[ "$found" == false ]]; then
		printf '%s = %s\n' "$key" "$value" >> "$tmp_file"
	fi

	mv "$tmp_file" "$user_file"
	return 0
}

# ------------------------------------------------------------------------------
# Public API: Validate
# ------------------------------------------------------------------------------

config_validate() {
	local app_name="$1"
	local filename="$2"

	[[ -z "$app_name" || -z "$filename" ]] && return 1

	local source_file="${CONFIGS_DIR:-${LIB_DIR}/../configs}/${app_name}/${filename}"
	local user_file
	local errors=0

	[[ -f "$source_file" ]] || {
		log_error "Source config not found: ${app_name}/${filename}"
		return 1
	}

	user_file="$(config_resolve_path "$app_name" "$filename")"

	if [[ -n "$user_file" ]] && [[ -f "$user_file" ]]; then
		if ! [[ -r "$user_file" ]]; then
			log_error "User config not readable: ${user_file}"
			((errors++))
		fi

		if ! [[ -w "$user_file" ]]; then
			log_warning "User config not writable: ${user_file}"
		fi
	fi

	local dir
	dir="$(dirname "$source_file")"
	if ! [[ -d "$dir" ]]; then
		log_error "Config directory not found: ${dir}"
		((errors++))
	fi

	if [[ "$errors" -gt 0 ]]; then
		return 1
	fi

	return 0
}

config_validate_all() {
	_config_engine_init || return 1

	local total=0
	local valid=0
	local key app_name filename

	local IFS='|'
	local entries=()
	read -ra entries <<< "$_CONFIG_LIST"
	unset IFS

	for entry in "${entries[@]}"; do
		[[ -z "$entry" ]] && continue
		app_name="${entry%%/*}"
		filename="${entry#*/}"
		((total++))

		if config_validate "$app_name" "$filename" >/dev/null 2>&1; then
			((valid++))
		fi
	done

	printf '%d/%d configs valid\n' "$valid" "$total"
	[[ "$valid" -eq "$total" ]]
}

# ------------------------------------------------------------------------------
# Public API: Merge
# ------------------------------------------------------------------------------

config_merge() {
	local app_name="$1"
	local filename="$2"
	local overwrite="${3:-false}"

	[[ -z "$app_name" || -z "$filename" ]] && return 1

	local source_file="${CONFIGS_DIR:-${LIB_DIR}/../configs}/${app_name}/${filename}"
	local user_file

	[[ -f "$source_file" ]] || {
		log_error "Source config not found: ${app_name}/${filename}"
		return 1
	}

	user_file="$(config_resolve_path "$app_name" "$filename")"
	[[ -z "$user_file" ]] && return 1

	local user_dir
	user_dir="$(dirname "$user_file")"

	if [[ ! -d "$user_dir" ]]; then
		mkdir -p "$user_dir" || return 1
	fi

	if [[ ! -f "$user_file" ]]; then
		cp "$source_file" "$user_file"
		log_info "Created: ${user_file}"
		return 0
	fi

	if diff -q "$source_file" "$user_file" >/dev/null 2>&1; then
		log_info "Already up to date: ${app_name}/${filename}"
		return 0
	fi

	if [[ "$overwrite" == true ]]; then
		cp "$source_file" "$user_file"
		log_success "Overwritten: ${user_file}"
	else
		local merged_file
		merged_file="$(mktemp)"
		local changes=0

		local line
		while IFS= read -r line; do
			if grep -qF "$line" "$user_file" 2>/dev/null; then
				printf '%s\n' "$line" >> "$merged_file"
			else
				printf '%s\n' "$line" >> "$merged_file"
				((changes++))
			fi
		done < "$source_file"

		if [[ "$changes" -gt 0 ]]; then
			cp "$user_file" "${user_file}.bak"
		 mv "$merged_file" "$user_file"
			log_success "Merged ${changes} new lines into ${user_file}"
		else
			rm -f "$merged_file"
			log_info "No changes to merge: ${app_name}/${filename}"
		fi
	fi

	return 0
}

config_merge_all() {
	local overwrite="${1:-false}"
	_config_engine_init || return 1

	local key app_name filename

	local IFS='|'
	local entries=()
	read -ra entries <<< "$_CONFIG_LIST"
	unset IFS

	for entry in "${entries[@]}"; do
		[[ -z "$entry" ]] && continue
		app_name="${entry%%/*}"
		filename="${entry#*/}"
		config_merge "$app_name" "$filename" "$overwrite"
	done
}

# ------------------------------------------------------------------------------
# Public API: Status
# ------------------------------------------------------------------------------

config_status() {
	local app_name="$1"
	local filename="$2"

	[[ -z "$app_name" || -z "$filename" ]] && return 1

	local source_file="${CONFIGS_DIR:-${LIB_DIR}/../configs}/${app_name}/${filename}"
	local user_file
	local status

	[[ -f "$source_file" ]] || {
		printf '%s\n' "missing"
		return 1
	}

	user_file="$(config_resolve_path "$app_name" "$filename")"

	if [[ -z "$user_file" ]] || [[ ! -f "$user_file" ]]; then
		printf '%s\n' "not_installed"
		return 0
	fi

	if diff -q "$source_file" "$user_file" >/dev/null 2>&1; then
		printf '%s\n' "up_to_date"
	else
		printf '%s\n' "modified"
	fi

	return 0
}

config_info() {
	local app_name="$1"
	local filename="$2"

	[[ -z "$app_name" || -z "$filename" ]] && return 1

	local source_file="${CONFIGS_DIR:-${LIB_DIR}/../configs}/${app_name}/${filename}"
	local user_file desc status
	local key="${app_name}/${filename}"

	_config_engine_init

	[[ -f "$source_file" ]] || return 1

	desc="$(_config_engine_get_desc "$key")"
	user_file="$(config_resolve_path "$app_name" "$filename")"
	status="$(config_status "$app_name" "$filename")"

	printf 'Config:       %s\n' "$key"
	printf 'Description:  %s\n' "$desc"
	printf 'Source:       %s\n' "$source_file"
	printf 'Destination:  %s\n' "${user_file:-unknown}"
	printf 'Status:       %s\n' "$status"

	return 0
}
