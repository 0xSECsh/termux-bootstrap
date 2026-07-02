#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: commands/install.sh
# Description: Install command
# ==============================================================================

cmd_install() {
	local profile=""
	local module=""
	local all=false

	while [[ $# -gt 0 ]]; do
		case "$1" in
		-p | --profile)
			[[ $# -lt 2 ]] && { log_error "Missing profile name"; return "$EXIT_INVALID_ARGUMENT"; }
			profile="$2"
			shift 2
			;;
		-m | --module)
			[[ $# -lt 2 ]] && { log_error "Missing module name"; return "$EXIT_INVALID_ARGUMENT"; }
			module="$2"
			shift 2
			;;
		-a | --all)
			all=true
			shift
			;;
		-h | --help)
			cat <<'EOF'
Usage: bootstrap install [options]

Options:
  -p, --profile <name>    Install a profile
  -m, --module <name>     Install a module
  -a, --all               Install everything (full profile)
  -h, --help              Show this help
EOF
			return 0
			;;
		*)
			log_error "Unknown option: $1"
			return "$EXIT_INVALID_ARGUMENT"
			;;
		esac
	done

	if [[ "$all" == true ]]; then
		log_info "Installing full profile..."
		# TODO: implement full install
		return 0
	fi

	if [[ -n "$profile" ]]; then
		log_info "Installing profile: ${profile}"
		# TODO: implement profile install
		return 0
	fi

	if [[ -n "$module" ]]; then
		log_info "Installing module: ${module}"
		# TODO: implement module install
		return 0
	fi

	log_error "Nothing to install. Use --profile, --module, or --all"
	dispatch_help
	return "$EXIT_INVALID_ARGUMENT"
}