#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: terminal/terminal.sh
# Description: Terminal utility functions
# ==============================================================================

# ------------------------------------------------------------------------------
# Terminal Information
# ------------------------------------------------------------------------------

terminal_width() {

	tput cols 2>/dev/null || echo 80

}

terminal_height() {

	tput lines 2>/dev/null || echo 24

}

terminal_size() {

	printf "%sx%s\n" "$(terminal_width)" "$(terminal_height)"

}

# ------------------------------------------------------------------------------
# Screen
# ------------------------------------------------------------------------------

terminal_clear() {

	clear

}

terminal_reset() {

	reset

}

# ------------------------------------------------------------------------------
# Cursor
# ------------------------------------------------------------------------------

cursor_hide() {

	tput civis 2>/dev/null

}

cursor_show() {

	tput cnorm 2>/dev/null

}

cursor_save() {

	tput sc 2>/dev/null

}

cursor_restore() {

	tput rc 2>/dev/null

}

cursor_home() {

	tput home 2>/dev/null

}

cursor_move() {

	local row="$1"
	local column="$2"

	tput cup "$row" "$column" 2>/dev/null

}

# ------------------------------------------------------------------------------
# Line Operations
# ------------------------------------------------------------------------------

clear_line() {

	printf "\r\033[K"

}

clear_screen_from_cursor() {

	printf "\033[J"

}

clear_screen_to_cursor() {

	printf "\033[1J"

}

# ------------------------------------------------------------------------------
# Cursor Position
# ------------------------------------------------------------------------------

move_up() {

	local lines="${1:-1}"

	tput cuu "$lines"

}

move_down() {

	local lines="${1:-1}"

	tput cud "$lines"

}

move_left() {

	local columns="${1:-1}"

	tput cub "$columns"

}

move_right() {

	local columns="${1:-1}"

	tput cuf "$columns"

}

# ------------------------------------------------------------------------------
# Terminal Title
# ------------------------------------------------------------------------------

set_terminal_title() {

	local title="$1"

	printf "\033]0;%s\007" "$title"

}

# ------------------------------------------------------------------------------
# Bell
# ------------------------------------------------------------------------------

terminal_beep() {

	printf "\a"

}

# ------------------------------------------------------------------------------
# Alternate Screen
# ------------------------------------------------------------------------------

enter_alternate_screen() {

	tput smcup 2>/dev/null

}

leave_alternate_screen() {

	tput rmcup 2>/dev/null

}

# ------------------------------------------------------------------------------
# Terminal State
# ------------------------------------------------------------------------------

is_interactive_terminal() {

	[[ -t 1 ]]

}

supports_unicode() {

	[[ "${LANG:-}" =~ UTF-8|utf8 ]]

}

supports_truecolor() {

	[[ "${COLORTERM:-}" == "truecolor" ]]

}

supports_mouse() {

	[[ -n "${TERM:-}" ]]

}

# ------------------------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------------------------

restore_terminal() {

	cursor_show

	leave_alternate_screen

}

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------

initialize_terminal() {

	[[ "${TERMINAL_INITIALIZED:-false}" == true ]] && return 0

	[[ -n "${BATS_VERSION:-}" ]] && {
		TERMINAL_INITIALIZED=true
		return 0
	}

	trap restore_terminal EXIT

	TERMINAL_INITIALIZED=true

	export TERMINAL_INITIALIZED

}
