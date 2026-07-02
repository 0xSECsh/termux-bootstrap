#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: commands/module.sh
# Description: Module command
# ==============================================================================

cmd_module() {
	local subcmd="${1:-list}"
	shift || true

	case "$subcmd" in
	list)
		cmd_module_list "$@"
		;;
	install)
		cmd_module_install "$@"
		;;
	remove)
		cmd_module_remove "$@"
		;;
	info)
		cmd_module_info "$@"
		;;
	-h | --help)
		cat <<'EOF'
Usage: bootstrap module <subcommand> [options]

Subcommands:
  list      List available modules
  install   Install a module
  remove    Remove a module
  info      Show module information
  -h, --help  Show this help
EOF
		;;
	*)
		log_error "Unknown module subcommand: ${subcmd}"
		return "$EXIT_INVALID_ARGUMENT"
		;;
	esac
}

cmd_module_list() {
	log_info "Available modules:"
	# Categories
	local categories=(core development cybersecurity ai)
	for cat in "${categories[@]}"; do
		local cat_dir="${LIB_DIR}/../packages/${cat}"
		[[ -d "$cat_dir" ]] || continue
		log_info "  ${cat}:"
		for mod_file in "${cat_dir}"/*.sh; do
			[[ -f "$mod_file" ]] || continue
			local mod_name
			mod_name="$(basename "$mod_file" .sh)"
			log_info "    ${mod_name}"
		done
	done
}

cmd_module_install() {
	local module="${1:-}"
	[[ -z "$module" ]] && { log_error "Module name required"; return "$EXIT_INVALID_ARGUMENT"; }
	log_info "Installing module: ${module} (not yet implemented)"
}

cmd_module_remove() {
	local module="${1:-}"
	[[ -z "$module" ]] && { log_error "Module name required"; return "$EXIT_INVALID_ARGUMENT"; }
	log_info "Removing module: ${module} (not yet implemented)"
}

cmd_module_info() {
	local module="${1:-}"
	[[ -z "$module" ]] && { log_error "Module name required"; return "$EXIT_INVALID_ARGUMENT"; }
	log_info "Module info: ${module} (not yet implemented)"
}