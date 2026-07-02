#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: lib/core/dispatcher.sh
# Description: CLI command dispatcher
# ==============================================================================

COMMANDS_DIR="${LIB_DIR}/../commands"
# shellcheck disable=SC2034
PACKAGES_DIR="${LIB_DIR}/../packages"

# Supported commands
declare -gA COMMANDS=(
	[help]="help"
	[version]="version"
	[doctor]="doctor"
	[install]="install"
	[update]="update"
	[module]="module"
	[profile]="profile"
	[config]="config"
	[list]="list"
)

# ------------------------------------------------------------------------------
# Command Loading
# ------------------------------------------------------------------------------

load_command() {
	local cmd="$1"

	local cmd_file="${COMMANDS_DIR}/${cmd}.sh"

	if [[ ! -f "$cmd_file" ]]; then
		log_error "Command not found: ${cmd}"
		return 1
	fi

	# shellcheck disable=SC1090
	source "$cmd_file"
}

# ------------------------------------------------------------------------------
# Dispatcher
# ------------------------------------------------------------------------------

dispatch() {
	local cmd="${1:-help}"
	shift || true

	if [[ -z "${COMMANDS[$cmd]+x}" ]]; then
		log_error "Unknown command: $cmd"
		dispatch_help
		return "$EXIT_INVALID_ARGUMENT"
	fi

	load_command "$cmd"

	local func_name="cmd_${cmd}"

	if ! declare -F "$func_name" >/dev/null 2>&1; then
		log_error "Command handler not found: ${func_name}"
		return "$EXIT_DEPENDENCY"
	fi

	"$func_name" "$@"
}

# ------------------------------------------------------------------------------
# Built-in Help
# ------------------------------------------------------------------------------

dispatch_help() {
	cat <<EOF
Termux Bootstrap - Professional CLI Framework

Usage: bootstrap <command> [options]

Commands:
  help       Show this help message
  version    Show version information
  doctor     Run system diagnostics
  install    Install packages, profiles, or modules
  update     Update packages and framework
  module     Manage development modules
  profile    Manage installation profiles
  config     Manage configuration
  list       List available profiles, modules, or packages

Global Options:
  --verbose, -v    Enable verbose output
  --debug, -d      Enable debug output
  --help, -h       Show help for command

Examples:
  bootstrap help
  bootstrap doctor
  bootstrap install --profile developer
  bootstrap profile list
  bootstrap module install python
  bootstrap config get editor

Run 'bootstrap <command> --help' for command-specific help.
EOF
}

# ------------------------------------------------------------------------------
# Profile Functions (delegated to profile_loader.sh and profile_registry.sh)
# ------------------------------------------------------------------------------

list_profiles() {
	profile_list
}

install_profile() {
	load_profile "$@"
}

install_all_profiles() {
	load_profile "full"
}