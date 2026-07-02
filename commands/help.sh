#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap: Help Command
# ==============================================================================

cmd_help() {
	local command=""
	local show_all=false

	while [[ $# -gt 0 ]]; do
		case "$1" in
		-a | --all)
			show_all=true
			shift
			;;
		-h | --help)
			colorize "${BOLD}" "Usage: bootstrap help [options]"
			printf "\n"
			colorize "${BOLD}" "Options:"
			ui_bullet "-a, --all    Show detailed help for all commands"
			ui_bullet "-h, --help   Show this help"
			return 0
			;;
		*)
			command="$1"
			shift
			;;
		esac
	done

	# Command-specific help
	if [[ -n "$command" ]]; then
		local cmd_file="${COMMANDS_DIR}/${command}.sh"
		if [[ -f "$cmd_file" ]]; then
			# Source and call command with --help
			# shellcheck disable=SC1090
			source "$cmd_file"
			local func_name="cmd_${command}"
			if declare -F "$func_name" >/dev/null 2>&1; then
				"$func_name" --help
				return 0
			fi
		fi
		log_error "Unknown command: ${command}"
		return "$EXIT_INVALID_ARGUMENT"
	fi

	# Banner
	ui_banner

	# Usage
	ui_section "Usage"
	ui_bullet "bootstrap <command> [options]"
	ui_bullet "bootstrap help [command]"

	# Commands
	ui_section "Available Commands"

	local cmd_name
	local cmd_file
	local cmd_description

	for cmd_name in $(printf '%s\n' "${!COMMANDS[@]}" | sort); do
		cmd_file="${COMMANDS_DIR}/${cmd_name}.sh"

		if [[ -f "$cmd_file" ]]; then
			cmd_description=$(grep -m1 -E "^# (Description|Termux Bootstrap:)" "$cmd_file" 2>/dev/null | sed 's/^# Description: //; s/^# Termux Bootstrap: //')
		fi

		ui_key_value "  ${cmd_name}" "${cmd_description:-No description}"

		# Show detailed usage when --all is specified
		if [[ "$show_all" == true ]] && [[ -f "$cmd_file" ]]; then
			local func_name="cmd_${cmd_name}"
			if declare -F "$func_name" >/dev/null 2>&1; then
				printf "\n"
				"$func_name" --help 2>/dev/null | sed 's/^/    /'
				printf "\n"
			fi
		fi
	done

	# Global Options
	ui_section "Global Options"
	ui_key_value "  --verbose, -v" "Enable verbose output"
	ui_key_value "  --debug, -d"   "Enable debug output"
	ui_key_value "  --help, -h"    "Show help for command"
	ui_key_value "  --version, -V" "Show version information"

	# Examples
	ui_section "Examples"
	ui_bullet "bootstrap help"
	ui_bullet "bootstrap doctor"
	ui_bullet "bootstrap install --profile developer"
	ui_bullet "bootstrap profile list"
	ui_bullet "bootstrap module install python"
	ui_bullet "bootstrap config get editor"

	# Additional Info
	ui_section "Additional Information"
	ui_bullet "Run 'bootstrap <command> --help' for command-specific help"
	ui_bullet "Project: ${PROJECT_NAME:-Termux Bootstrap}"
	ui_bullet "Version: ${PROJECT_VERSION:-unknown}"
	ui_bullet "Author:  ${PROJECT_AUTHOR:-unknown}"

	printf "\n"
}
