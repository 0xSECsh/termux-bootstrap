#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: core/errors.sh
# Description: Error handling framework
# ==============================================================================

# ------------------------------------------------------------------------------
# Exit Codes
#
# Alias from constants.sh — values are identical, names differ for API clarity.
# EXIT_INTERRUPTED is unique to this file.
# ------------------------------------------------------------------------------

readonly EXIT_OK="${EXIT_SUCCESS:-0}"
readonly EXIT_ERROR="${EXIT_FAILURE:-1}"
readonly EXIT_ARGUMENT="${EXIT_INVALID_ARGUMENT:-2}"
readonly EXIT_DEPENDENCY="${EXIT_DEPENDENCY_ERROR:-3}"
readonly EXIT_NETWORK="${EXIT_NETWORK_ERROR:-4}"
readonly EXIT_PERMISSION="${EXIT_PERMISSION_ERROR:-5}"
readonly EXIT_INTERRUPTED=130

export \
	EXIT_OK \
	EXIT_ERROR \
	EXIT_ARGUMENT \
	EXIT_DEPENDENCY \
	EXIT_NETWORK \
	EXIT_PERMISSION \
	EXIT_INTERRUPTED

# ------------------------------------------------------------------------------
# Internal Helpers
# ------------------------------------------------------------------------------

_stacktrace() {

	local frame=0
	local max_frames=100

	echo

	log_error "Stack trace:"

	while [[ $frame -lt $max_frames ]] && caller "$frame"; do
		((frame++))
	done

}

# ------------------------------------------------------------------------------
# Public API
# ------------------------------------------------------------------------------

die() {

	local message="$1"

	log_error "$message"

	exit "$EXIT_ERROR"

}

panic() {

	local message="$1"

	log_error "PANIC: ${message}"

	_stacktrace

	exit "$EXIT_ERROR"

}

warn() {

	log_warning "$1"

}

success() {

	log_success "$1"

}

info() {

	log_info "$1"

}

debug() {

	log_debug "$1"

}

# ------------------------------------------------------------------------------
# Assertions
# ------------------------------------------------------------------------------

assert_file() {

	local file="$1"

	[[ -f "$file" ]] || die "File not found: ${file}"

}

assert_directory() {

	local directory="$1"

	[[ -d "$directory" ]] || die "Directory not found: ${directory}"

}

assert_command() {

	local command="$1"

	command_exists "$command" || die "Command not found: ${command}"

}

assert_capability() {

	local capability="$1"

	has "$capability" || die "Missing capability: ${capability}"

}

assert_variable() {

	local variable="$1"

	[[ -n "${!variable:-}" ]] || die "Variable not set: ${variable}"

}

# ------------------------------------------------------------------------------
# Traps
# ------------------------------------------------------------------------------

on_interrupt() {

	warn "Execution interrupted."

	exit "$EXIT_INTERRUPTED"

}

on_error() {

	local exit_code="$?"

	panic "Unexpected error (exit code: ${exit_code})"

}

register_error_handlers() {

	[[ "${ERROR_HANDLERS_REGISTERED:-false}" == true ]] && return 0

	[[ -n "${BATS_VERSION:-}" ]] && return 0

	trap on_interrupt INT TERM

	trap on_error ERR

	ERROR_HANDLERS_REGISTERED=true

	export ERROR_HANDLERS_REGISTERED

}
