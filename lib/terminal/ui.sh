#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: terminal/ui.sh
# Description: User Interface components
# ==============================================================================

: "${BOLD:-}"
: "${CYAN:-}"
: "${GREEN:-}"
: "${YELLOW:-}"
: "${RED:-}"
: "${BLUE:-}"

# ------------------------------------------------------------------------------
# Boxes
# ------------------------------------------------------------------------------

ui_box() {

	local message="$1"

	local width=$((${#message} + 4))

	printf "┌"

	printf "%${width}s" "" | tr " " "─"

	printf "┐\n"

	printf "│  %s  │\n" "$message"

	printf "└"

	printf "%${width}s" "" | tr " " "─"

	printf "┘\n"

}

# ------------------------------------------------------------------------------
# Headers
# ------------------------------------------------------------------------------

ui_header() {

	local title="$1"

	terminal_clear

	separator

	title "$title"

	separator

}

ui_section() {

	local title="$1"

	printf "\n"

	colorize "${BOLD}${CYAN}" "$title"

	separator

}

# ------------------------------------------------------------------------------
# Questions
# ------------------------------------------------------------------------------

ui_confirm() {

	local message="$1"

	local answer

	while true; do

		printf "%s [y/N]: " "$message"

		read -r answer

		case "${answer,,}" in

		y | yes)

			return 0
			;;

		"" | n | no)

			return 1
			;;

		*)

			colorize "$YELLOW" "Please answer yes or no."

			;;

		esac

	done

}

ui_pause() {

	printf "\nPress ENTER to continue..."

	read -r

}

# ------------------------------------------------------------------------------
# Menus
# ------------------------------------------------------------------------------

ui_menu() {

	local title="$1"

	shift

	ui_section "$title"

	local index=1

	local option

	for option in "$@"; do

		printf " %2d) %s\n" "$index" "$option"

		((index++))

	done

	printf "\n"

}

ui_select() {

	local prompt="${1:-Select an option}"

	local choice

	printf "%s: " "$prompt"

	read -r choice

	printf "%s" "$choice"

}

# ------------------------------------------------------------------------------
# Status
# ------------------------------------------------------------------------------

ui_success() {

	colorize "$GREEN" "✔ $1"

}

ui_warning() {

	colorize "$YELLOW" "⚠ $1"

}

ui_error() {

	colorize "$RED" "✖ $1"

}

ui_info() {

	colorize "$BLUE" "➜ $1"

}

# ------------------------------------------------------------------------------
# Tables
# ------------------------------------------------------------------------------

ui_key_value() {

	printf "%-20s : %s\n" "$1" "$2"

}

ui_separator() {

	separator

}

# ------------------------------------------------------------------------------
# Lists
# ------------------------------------------------------------------------------

ui_bullet() {

	printf " • %s\n" "$1"

}

ui_numbered() {

	printf "%2d. %s\n" "$1" "$2"

}

# ------------------------------------------------------------------------------
# Banner Wrapper
# ------------------------------------------------------------------------------

ui_banner() {

	show_banner

}

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------

ui_summary() {

	local title="$1"

	shift

	printf "\n"

	ui_section "$title"

	local item

	for item in "$@"; do

		ui_bullet "$item"

	done

	printf "\n"

}
