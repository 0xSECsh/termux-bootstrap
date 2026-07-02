#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap: Config Command
# ==============================================================================

# ------------------------------------------------------------------------------
# Command Entry Point
# ------------------------------------------------------------------------------

cmd_config() {
	local subcmd="${1:-show}"
	shift || true

	case "$subcmd" in
	show)
		cmd_config_show "$@"
		;;
	list)
		cmd_config_list "$@"
		;;
	edit)
		cmd_config_edit "$@"
		;;
	reset)
		cmd_config_reset "$@"
		;;
	-h | --help)
		_config_help
		;;
	*)
		log_error "Unknown config subcommand: ${subcmd}"
		return "$EXIT_INVALID_ARGUMENT"
		;;
	esac
}

# ------------------------------------------------------------------------------
# Config List - List available config files
# ------------------------------------------------------------------------------

cmd_config_list() {
	local config_dir="${CONFIGS_DIR}"

	if ! directory_exists "$config_dir"; then
		log_error "Config directory not found: ${config_dir}"
		return "$EXIT_FAILURE"
	fi

	ui_section "Available Configuration Files"

	local found=false
	local app_name app_dir app_file

	for app_dir in "$config_dir"/*/; do
		[[ -d "$app_dir" ]] || continue
		app_name="$(basename "$app_dir")"

		local app_file
		for app_file in "$app_dir".* "$app_dir"*; do
			[[ -f "$app_file" ]] || continue
			local filename
			filename="$(basename "$app_file")"

			ui_bullet "${app_name}/${filename}"
			found=true
		done
	done

	if [[ "$found" == false ]]; then
		log_info "No configuration files found."
	fi

	printf "\n"
}

# ------------------------------------------------------------------------------
# Config Show - Display current configuration
# ------------------------------------------------------------------------------

cmd_config_show() {
	local config_dir="${CONFIGS_DIR}"

	if ! directory_exists "$config_dir"; then
		log_error "Config directory not found: ${config_dir}"
		return "$EXIT_FAILURE"
	fi

	ui_section "Configuration Files"

	local found=false
	local app_name app_dir app_file user_file status

	for app_dir in "$config_dir"/*/; do
		[[ -d "$app_dir" ]] || continue
		app_name="$(basename "$app_dir")"

		local app_file
		for app_file in "$app_dir".* "$app_dir"*; do
			[[ -f "$app_file" ]] || continue
			local filename
			filename="$(basename "$app_file")"

			user_file="$(_get_user_config_path "$app_name" "$filename")"

			if [[ -n "$user_file" ]] && [[ -f "$user_file" ]]; then
				if diff -q "$app_file" "$user_file" >/dev/null 2>&1; then
					status="installed (up to date)"
				else
					status="installed (modified)"
				fi
			else
				status="not installed"
			fi

			ui_key_value "  ${app_name}/${filename}" "$status"
			found=true
		done
	done

	if [[ "$found" == false ]]; then
		log_info "No configuration files found."
	fi

	printf "\n"
}

# ------------------------------------------------------------------------------
# Config Edit - Open config file in editor
# ------------------------------------------------------------------------------

	cmd_config_edit() {
	local target="${1:-}"
	local editor="${EDITOR:-${DEFAULT_EDITOR}}"

	if [[ -z "$target" ]] || [[ "$target" == "-h" ]] || [[ "$target" == "--help" ]]; then
		cat <<'EOF'
Usage: bootstrap config edit <app/filename>

Open a configuration file in your default editor.

Arguments:
  <app/filename>    Config file in format: app/filename
                    Examples: zsh/.zshrc, git/.gitconfig

Options:
  -h, --help        Show this help

Examples:
  bootstrap config edit zsh/.zshrc
  bootstrap config edit git/.gitconfig
EOF
		if [[ -z "$target" ]]; then
			return "$EXIT_INVALID_ARGUMENT"
		fi
		return 0
	fi

	local app_name filename
	app_name="$(dirname "$target" | cut -d'/' -f1)"
	filename="$(basename "$target")"

	if [[ "$target" == *"/"* ]]; then
		app_name="$(echo "$target" | cut -d'/' -f1)"
		filename="$(echo "$target" | cut -d'/' -f2)"
	else
		log_error "Usage: config edit <app/filename>"
		log_info "Example: config edit zsh/.zshrc"
		return "$EXIT_INVALID_ARGUMENT"
	fi

	local user_file
	user_file="$(_get_user_config_path "$app_name" "$filename")"

	if [[ -z "$user_file" ]]; then
		log_error "Cannot determine config path for: ${target}"
		return "$EXIT_FAILURE"
	fi

	# Create directory if needed
	local user_dir
	user_dir="$(dirname "$user_file")"
	create_directory "$user_dir"

	# Copy default if file doesn't exist
	if [[ ! -f "$user_file" ]]; then
		local source_file="${CONFIGS_DIR}/${app_name}/${filename}"
		if [[ -f "$source_file" ]]; then
			copy_file "$source_file" "$user_file"
			log_info "Created default config: ${user_file}"
		else
			log_warning "No default config found for: ${target}"
			touch "$user_file"
		fi
	fi

	log_info "Opening: ${user_file}"
	"$editor" "$user_file"
}

# ------------------------------------------------------------------------------
# Config Reset - Restore config to defaults
# ------------------------------------------------------------------------------

	cmd_config_reset() {
	local target="${1:-}"

	if [[ -z "$target" ]] || [[ "$target" == "-h" ]] || [[ "$target" == "--help" ]]; then
		cat <<'EOF'
Usage: bootstrap config reset <app/filename>

Reset a configuration file to its default value.

Arguments:
  <app/filename>    Config file in format: app/filename
                    Examples: zsh/.zshrc, git/.gitconfig

Options:
  -h, --help        Show this help

Examples:
  bootstrap config reset zsh/.zshrc
  bootstrap config reset git/.gitconfig
EOF
		if [[ -z "$target" ]]; then
			return "$EXIT_INVALID_ARGUMENT"
		fi
		return 0
	fi

	local app_name filename
	if [[ "$target" == *"/"* ]]; then
		app_name="$(echo "$target" | cut -d'/' -f1)"
		filename="$(echo "$target" | cut -d'/' -f2)"
	else
		log_error "Usage: config reset <app/filename>"
		log_info "Example: config reset zsh/.zshrc"
		return "$EXIT_INVALID_ARGUMENT"
	fi

	local source_file="${CONFIGS_DIR}/${app_name}/${filename}"
	local user_file
	user_file="$(_get_user_config_path "$app_name" "$filename")"

	if [[ ! -f "$source_file" ]]; then
		log_error "Default config not found: ${source_file}"
		return "$EXIT_FAILURE"
	fi

	if [[ -z "$user_file" ]]; then
		log_error "Cannot determine config path for: ${target}"
		return "$EXIT_FAILURE"
	fi

	# Backup existing if present
	if [[ -f "$user_file" ]]; then
		backup_file "$user_file"
		log_info "Backed up: ${user_file}.bak"
	fi

	# Create directory if needed
	local user_dir
	user_dir="$(dirname "$user_file")"
	create_directory "$user_dir"

	# Copy default config
	copy_file "$source_file" "$user_file"
	log_success "Reset config: ${user_file}"
}

# ------------------------------------------------------------------------------
# Help
# ------------------------------------------------------------------------------

_config_help() {
	cat <<'EOF'
Usage: bootstrap config <subcommand> [options]

Manage configuration files for installed applications.

Subcommands:
  list            List available configuration files
  show            Show current configuration status
  edit <file>     Open a configuration file in editor
  reset <file>    Reset a configuration file to defaults

Arguments:
  <file>          Config file in format: app/filename
                  Examples: zsh/.zshrc, git/.gitconfig

Options:
  -h, --help      Show this help

Examples:
  bootstrap config show
  bootstrap config edit zsh/.zshrc
  bootstrap config reset git/.gitconfig
EOF
}

# ------------------------------------------------------------------------------
# Helper: Get user config path
# ------------------------------------------------------------------------------

_get_user_config_path() {
	local app_name="$1"
	local filename="$2"

	case "$app_name" in
	zsh)
		if [[ "$filename" == ".zshrc" ]]; then
			echo "${HOME}/.zshrc"
		fi
		;;
	git)
		if [[ "$filename" == ".gitconfig" ]]; then
			echo "${HOME}/.gitconfig"
		fi
		;;
	tmux)
		if [[ "$filename" == ".tmux.conf" ]]; then
			echo "${HOME}/.tmux.conf"
		fi
		;;
	nvim)
		echo "${HOME}/.config/nvim/${filename}"
		;;
	micro)
		echo "${HOME}/.config/micro/settings.json"
		;;
	fastfetch)
		echo "${HOME}/.config/fastfetch/${filename}"
		;;
	*)
		echo "${HOME}/.config/${app_name}/${filename}"
		;;
	esac
}
