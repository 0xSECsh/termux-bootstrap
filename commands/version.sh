#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap: Version Command
# ==============================================================================

cmd_version() {
	local show_about=false
	local show_build=false

	while [[ $# -gt 0 ]]; do
		case "$1" in
		-a | --about)
			show_about=true
			shift
			;;
		-b | --build)
			show_build=true
			shift
			;;
		-h | --help)
			colorize "${BOLD}" "Usage: bootstrap version [options]"
			printf "\n"
			colorize "${BOLD}" "Options:"
			ui_bullet "-a, --about      Show project information"
			ui_bullet "-b, --build      Show build and system info"
			ui_bullet "-h, --help       Show this help"
			return 0
			;;
		*)
			log_error "Unknown option: $1"
			return "$EXIT_INVALID_ARGUMENT"
			;;
		esac
	done

	# Default: show version only
	if [[ "$show_about" == false ]] && [[ "$show_build" == false ]]; then
		show_version
		return 0
	fi

	# About information
	if [[ "$show_about" == true ]]; then
		show_banner
		show_about
		return 0
	fi

	# Build information
	if [[ "$show_build" == true ]]; then
		show_build_info
		return 0
	fi
}
