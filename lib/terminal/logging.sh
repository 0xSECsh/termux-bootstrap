#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: lib/logging.sh
# Description: Logging Framework
# ==============================================================================

: "${LOG_DIR:?}"
: "${LOG_FILE:?}"
: "${EXIT_FAILURE:?}"

# ------------------------------------------------------------------------------
# Internal Helpers
# ------------------------------------------------------------------------------

_create_log_directory() {

	mkdir -p "$LOG_DIR"

}

_timestamp() {

	date +"%Y-%m-%d %H:%M:%S"

}

_write_log() {

	local level="$1"
	shift

	printf "[%s] [%s] %s\n" \
		"$(_timestamp)" \
		"$level" \
		"$*" >>"$LOG_FILE"

}

_caller_info() {

	local frame=1

	caller "$frame" | awk '{print $2 " at line " $1}'

}

_format_message() {

	local level="$1"
	local prefix="$2"
	local message="$3"
	local context="${4:-}"

	local formatted="${prefix} ${message}"

	if [[ -n "$context" ]]; then
		formatted="${formatted} [${context}]"
	fi

	printf "%s\n" "$formatted"

}

# ------------------------------------------------------------------------------
# Public Logging API
# ------------------------------------------------------------------------------

log_info() {

	local message="$1"
	local context="${2:-}"

	colorize "$BLUE" "$(_format_message "INFO" "[INFO]" "$message" "$context")"

	_write_log "INFO" "$message" "$context"

}

log_success() {

	local message="$1"
	local context="${2:-}"

	colorize "$GREEN" "$(_format_message "SUCCESS" "[ OK ]" "$message" "$context")"

	_write_log "SUCCESS" "$message" "$context"

}

log_warning() {

	local message="$1"
	local context="${2:-}"

	colorize "$YELLOW" "$(_format_message "WARNING" "[WARN]" "$message" "$context")"

	_write_log "WARNING" "$message" "$context"

}

log_error() {

	local message="$1"
	local context="${2:-}"

	local caller
	caller="$(_caller_info)"

	colorize "$RED" "$(_format_message "ERROR" "[FAIL]" "$message" "${context:-caller: ${caller}}")"

	_write_log "ERROR" "$message" "${context:-caller: ${caller}}"

}

log_debug() {

	[[ "${LOG_LEVEL:-INFO}" == "DEBUG" ]] || return 0

	local message="$1"
	local context="${2:-}"

	local caller
	caller="$(_caller_info)"

	colorize "$MAGENTA" "$(_format_message "DEBUG" "[DEBUG]" "$message" "${context:-caller: ${caller}}")"

	_write_log "DEBUG" "$message" "${context:-caller: ${caller}}"

}

# ------------------------------------------------------------------------------
# Structured Logging
# ------------------------------------------------------------------------------

log_error_with_cause() {

	local message="$1"
	local cause="$2"
	local context="${3:-}"

	log_error "$message (caused by: ${cause})" "$context"

}

log_fatal() {

	local message="$1"
	local context="${2:-}"

	log_error "$message" "$context"

	exit "$EXIT_FAILURE"

}

# ------------------------------------------------------------------------------
# Progress & Status Logging
# ------------------------------------------------------------------------------

log_start() {

	local task="$1"
	local context="${2:-}"

	log_info "Starting: ${task}" "$context"

}

log_finish() {

	local task="$1"
	local context="${2:-}"

	log_success "Finished: ${task}" "$context"

}

log_skip() {

	local task="$1"
	local reason="$2"
	local context="${3:-}"

	log_warning "Skipping: ${task} (reason: ${reason})" "$context"

}

# ------------------------------------------------------------------------------
# Legacy Fatal
# ------------------------------------------------------------------------------

fatal() {

	log_fatal "$@"

}
