#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: commands/profile.sh
# Description: Profile command
# ==============================================================================

cmd_profile() {
	local subcmd="${1:-list}"
	shift || true

	case "$subcmd" in
	list)
		cmd_profile_list "$@"
		;;
	install)
		cmd_profile_install "$@"
		;;
	remove)
		cmd_profile_remove "$@"
		;;
	info)
		cmd_profile_info "$@"
		;;
	-h | --help)
		cat <<'EOF'
Usage: bootstrap profile <subcommand> [options]

Subcommands:
  list      List available profiles
  install   Install a profile
  remove    Remove a profile
  info      Show profile information
  -h, --help  Show this help
EOF
		;;
	*)
		log_error "Unknown profile subcommand: ${subcmd}"
		return "$EXIT_INVALID_ARGUMENT"
		;;
	esac
}

cmd_profile_list() {
	local profile_dir="${LIB_DIR}/../packages/profiles"
	[[ -d "$profile_dir" ]] || { log_error "Profile directory not found"; return 1; }

	log_info "Available profiles:"
	for profile_file in "${profile_dir}"/*.sh; do
		[[ -f "$profile_file" ]] || continue
		local profile_name
		profile_name="$(basename "$profile_file" .sh)"
		log_info "  ${profile_name}"
	done
}

cmd_profile_install() {
	local profile="${1:-}"
	[[ -z "$profile" ]] && { log_error "Profile name required"; return "$EXIT_INVALID_ARGUMENT"; }
	log_info "Installing profile: ${profile} (not yet implemented)"
}

cmd_profile_remove() {
	local profile="${1:-}"
	[[ -z "$profile" ]] && { log_error "Profile name required"; return "$EXIT_INVALID_ARGUMENT"; }
	log_info "Removing profile: ${profile} (not yet implemented)"
}

cmd_profile_info() {
	local profile="${1:-}"
	[[ -z "$profile" ]] && { log_error "Profile name required"; return "$EXIT_INVALID_ARGUMENT"; }
	log_info "Profile info: ${profile} (not yet implemented)"
}