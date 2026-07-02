#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: lib/utils/temp.sh
# Description: Secure temporary file and directory handling
# ==============================================================================

: "${TEMP_DIR:?}"

# ------------------------------------------------------------------------------
# Secure Temporary Directory Creation
# ------------------------------------------------------------------------------

create_secure_temp_dir() {

	local prefix="${1:-${PROJECT_SLUG}}"
	local temp_dir

	temp_dir="$(mktemp -d -p "${TEMP_DIR}" "${prefix}.XXXXXX")" || die "Failed to create secure temp directory"

	printf "%s\n" "$temp_dir"

}

# ------------------------------------------------------------------------------
# Secure Temporary File Creation
# ------------------------------------------------------------------------------

create_secure_temp_file() {

	local prefix="${1:-${PROJECT_SLUG}}"
	local temp_file

	temp_file="$(mktemp -p "${TEMP_DIR}" "${prefix}.XXXXXX")" || die "Failed to create secure temp file"

	printf "%s\n" "$temp_file"

}

# ------------------------------------------------------------------------------
# Safe Temporary File Operations
# ------------------------------------------------------------------------------

write_temp_file() {

	local content="$1"
	local prefix="${2:-${PROJECT_SLUG}}"

	local temp_file
	temp_file="$(create_secure_temp_file "$prefix")"

	printf "%s\n" "$content" >"$temp_file" || die "Failed to write temp file: ${temp_file}"

	printf "%s\n" "$temp_file"

}

read_temp_file() {

	local file="$1"

	[[ -f "$file" ]] || die "Temp file not found: ${file}"

	cat "$file"

}

# ------------------------------------------------------------------------------
# Atomic Write Pattern
# ------------------------------------------------------------------------------

atomic_write() {

	local target="$1"
	local content="$2"

	local temp_file
	temp_file="$(create_secure_temp_file "atomic")"

	printf "%s\n" "$content" >"$temp_file" || die "Failed to write atomic temp file"

	mv -- "$temp_file" "$target" || die "Failed to atomically write: ${target}"

}

# ------------------------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------------------------

cleanup_temp_file() {

	local file="$1"

	[[ -n "$file" ]] || return 0

	[[ "$file" == "${TEMP_DIR}"* ]] || {
		log_warning "Refusing to delete file outside temp dir: ${file}"
		return 1
	}

	[[ -f "$file" ]] && rm -f -- "$file"

}

cleanup_temp_dir() {

	local dir="$1"

	[[ -n "$dir" ]] || return 0

	[[ "$dir" == "${TEMP_DIR}"* ]] || {
		log_warning "Refusing to delete directory outside temp dir: ${dir}"
		return 1
	}

	[[ -d "$dir" ]] && rm -rf -- "$dir"

}

# ------------------------------------------------------------------------------
# Secure Cleanup with Verification
# ------------------------------------------------------------------------------

secure_cleanup_temp() {

	local path="$1"

	[[ -n "$path" ]] || return 0

	[[ "$path" == "${TEMP_DIR}"* ]] || {
		log_error "Path traversal attempt blocked: ${path}"
		return 1
	}

	if [[ -f "$path" ]]; then

		shred -u "$path" 2>/dev/null || rm -f -- "$path"

	elif [[ -d "$path" ]]; then

		find "$path" -type f -exec shred -u {} + 2>/dev/null || true

		rm -rf -- "$path"

	fi

}

# ------------------------------------------------------------------------------
# Context Manager Pattern
# ------------------------------------------------------------------------------

with_temp_dir() {

	local prefix="${1:-${PROJECT_SLUG}}"
	local callback="${2:-}"

	local temp_dir
	temp_dir="$(create_secure_temp_dir "$prefix")"

	if [[ -n "$callback" ]]; then

		(cd "$temp_dir" && eval "$callback")

		local exit_code=$?

		secure_cleanup_temp "$temp_dir"

		return $exit_code

	else

		printf "%s\n" "$temp_dir"

	fi

}

with_temp_file() {

	local prefix="${1:-${PROJECT_SLUG}}"
	local content="${2:-}"
	local callback="${3:-}"

	local temp_file
	temp_file="$(create_secure_temp_file "$prefix")"

	[[ -n "$content" ]] && printf "%s\n" "$content" >"$temp_file"

	if [[ -n "$callback" ]]; then

		eval "$callback" "$temp_file"

		local exit_code=$?

		secure_cleanup_temp "$temp_file"

		return $exit_code

	else

		printf "%s\n" "$temp_file"

	fi

}

# ------------------------------------------------------------------------------
# Cleanup Registration
# ------------------------------------------------------------------------------

declare -ag TEMP_CLEANUP_STACK=()

register_temp_cleanup() {

	local path="$1"

	TEMP_CLEANUP_STACK+=("$path")

}

run_temp_cleanup() {

	local path

	for path in "${TEMP_CLEANUP_STACK[@]}"; do

		secure_cleanup_temp "$path"

	done

	TEMP_CLEANUP_STACK=()

}

# ------------------------------------------------------------------------------
# Trap Handler
# ------------------------------------------------------------------------------

setup_temp_cleanup_trap() {

	[[ "${TEMP_CLEANUP_TRAP_SET:-false}" == true ]] && return 0

	trap 'run_temp_cleanup' EXIT INT TERM

	TEMP_CLEANUP_TRAP_SET=true

	export TEMP_CLEANUP_TRAP_SET

}
