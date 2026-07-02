#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: terminal/spinner.sh
# Description: Terminal spinner animation
# ==============================================================================

: "${GREEN:-}"
: "${YELLOW:-}"
: "${RED:-}"
: "${BLUE:-}"

# ------------------------------------------------------------------------------
# Spinner Configuration
# ------------------------------------------------------------------------------

readonly SPINNER_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

SPINNER_PID=""

SPINNER_DELAY=0.08

# ------------------------------------------------------------------------------
# Internal Spinner
# ------------------------------------------------------------------------------

_spinner() {

	local message="$1"
	local frame=0

	cursor_hide

	while true; do

		printf "\r%s %s" \
			"${SPINNER_FRAMES[$frame]}" \
			"$message"

		frame=$(((frame + 1) % ${#SPINNER_FRAMES[@]}))

		sleep "$SPINNER_DELAY"

	done

}

# ------------------------------------------------------------------------------
# Start Spinner
# ------------------------------------------------------------------------------

spinner_start() {

	[[ -z "$SPINNER_PID" ]] || return 0

	local message="${1:-Working...}"

	_spinner "$message" &

	SPINNER_PID=$!

}

# ------------------------------------------------------------------------------
# Stop Spinner
# ------------------------------------------------------------------------------

spinner_stop() {

	if [[ -n "$SPINNER_PID" ]]; then

		kill "$SPINNER_PID" >/dev/null 2>&1 || true

		wait "$SPINNER_PID" 2>/dev/null || true

		SPINNER_PID=""

		clear_line

		cursor_show

	fi

}

# ------------------------------------------------------------------------------
# Success
# ------------------------------------------------------------------------------

spinner_success() {

	local message="${1:-Done}"

	spinner_stop

	colorize "$GREEN" "✔ ${message}"

}

# ------------------------------------------------------------------------------
# Warning
# ------------------------------------------------------------------------------

spinner_warning() {

	local message="${1:-Warning}"

	spinner_stop

	colorize "$YELLOW" "⚠ ${message}"

}

# ------------------------------------------------------------------------------
# Error
# ------------------------------------------------------------------------------

spinner_error() {

	local message="${1:-Failed}"

	spinner_stop

	colorize "$RED" "✖ ${message}"

}

# ------------------------------------------------------------------------------
# Info
# ------------------------------------------------------------------------------

spinner_info() {

	local message="${1:-Info}"

	spinner_stop

	colorize "$BLUE" "➜ ${message}"

}

# ------------------------------------------------------------------------------
# Execute Command
# ------------------------------------------------------------------------------

spinner_run() {

	local message="$1"

	shift

	spinner_start "$message"

	"$@"

	local status=$?

	if [[ $status -eq 0 ]]; then

		spinner_success "$message"

	else

		spinner_error "$message"

	fi

	return "$status"

}
