#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: commands/doctor.sh
# Description: Doctor command - system diagnostics
# ==============================================================================

cmd_doctor() {
	local verbose=false

	while [[ $# -gt 0 ]]; do
		case "$1" in
		-v | --verbose)
			verbose=true
			shift
			;;
		-h | --help)
			cat <<'EOF'
Usage: bootstrap doctor [options]

Run system diagnostics to verify the environment is ready.

Options:
  -v, --verbose    Show detailed output
  -h, --help       Show this help
EOF
			return 0
			;;
		*)
			log_error "Unknown option: $1"
			return "$EXIT_INVALID_ARGUMENT"
			;;
		esac
	done

	ui_header "System Diagnostics"

	local total=0
	local passed=0
	local warnings=0
	local failed=0

	# --- Environment ---
	_check_environment total passed warnings failed

	# --- System Info ---
	_check_system total passed warnings failed "$verbose"

	# --- Internet ---
	_check_internet total passed warnings failed

	# --- Storage ---
	_check_storage total passed warnings failed "$verbose"

	# --- Required Commands ---
	_check_command total passed warnings failed "pkg" "Package manager"
	_check_command total passed warnings failed "curl" "HTTP client"
	_check_command total passed warnings failed "git" "Version control"
	_check_command total passed warnings failed "bash" "Shell"
	_check_command total passed warnings failed "jq" "JSON processor"
	_check_command total passed warnings failed "tar" "Archive utility"
	_check_command total passed warnings failed "unzip" "Archive utility"

	# --- Summary ---
	newline
	separator
	_print_summary "$total" "$passed" "$warnings" "$failed"
	separator
	newline

	# Return failure if any check failed
	if [[ "$failed" -gt 0 ]]; then
		return "$EXIT_FAILURE"
	fi

	return 0
}

# ------------------------------------------------------------------------------
# Check: Environment
# ------------------------------------------------------------------------------

_check_environment() {
	local -n _total=$1
	local -n _passed=$2
	local -n _warnings=$3
	local -n _failed=$4

	((total++))

	if is_termux; then
		ui_success "Termux environment detected"
		((passed++))
	else
		ui_warning "Not running in Termux"
		((warnings++))
	fi
}

# ------------------------------------------------------------------------------
# Check: System Info
# ------------------------------------------------------------------------------

_check_system() {
	local -n _total=$1
	local -n _passed=$2
	local -n _warnings=$3
	local -n _failed=$4
	local verbose="$5"

	local arch
	arch="$(get_architecture)"

	local android_version
	android_version="$(get_android_version)"

	local manufacturer
	manufacturer="$(get_device_manufacturer)"

	local model
	model="$(get_device_model)"

	ui_section "System Information"

	ui_key_value "Architecture" "$arch"

	if [[ -n "$android_version" ]]; then
		ui_key_value "Android" "$android_version"
	fi

	if [[ -n "$manufacturer" ]]; then
		ui_key_value "Manufacturer" "$manufacturer"
	fi

	if [[ -n "$model" ]]; then
		ui_key_value "Model" "$model"
	fi

	ui_key_value "Kernel" "$(get_kernel)"

	if [[ "$verbose" == true ]]; then
		ui_key_value "CPU" "$(get_cpu)"
		ui_key_value "CPU Cores" "$(get_cpu_cores)"
		ui_key_value "Memory" "$(get_memory_total)"
		ui_key_value "Shell" "$(get_shell)"
	fi
}

# ------------------------------------------------------------------------------
# Check: Internet
# ------------------------------------------------------------------------------

_check_internet() {
	local -n _total=$1
	local -n _passed=$2
	local -n _warnings=$3
	local -n _failed=$4

	((total++))

	ui_section "Network"

	if check_internet; then
		ui_success "Internet connectivity"
		((passed++))
	else
		ui_error "No internet connectivity"
		((failed++))
	fi
}

# ------------------------------------------------------------------------------
# Check: Storage
# ------------------------------------------------------------------------------

_check_storage() {
	local -n _total=$1
	local -n _passed=$2
	local -n _warnings=$3
	local -n _failed=$4
	local verbose="$5"

	((total++))

	ui_section "Storage"

	local available
	available="$(get_storage_available)"

	local total_storage
	total_storage="$(get_storage_total)"

	ui_key_value "Total" "$total_storage"
	ui_key_value "Available" "$available"

	# Warn if less than 1GB available
	local available_kb
	available_kb="$(df -k "$HOME" | awk 'NR==2 {print $4}')"

	if [[ -n "$available_kb" ]] && [[ "$available_kb" -lt 1048576 ]]; then
		ui_warning "Low storage space (< 1 GB free)"
		((warnings++))
	else
		ui_success "Storage OK"
		((passed++))
	fi
}

# ------------------------------------------------------------------------------
# Check: Command
# ------------------------------------------------------------------------------

_check_command() {
	local -n _total=$1
	local -n _passed=$2
	local -n _warnings=$3
	local -n _failed=$4
	local cmd="$5"
	local description="$6"

	((total++))

	if command_exists "$cmd"; then
		ui_success "${cmd} - ${description}"
		((passed++))
	else
		ui_error "${cmd} - ${description} (not found)"
		((failed++))
	fi
}

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------

_print_summary() {
	local total="$1"
	local passed="$2"
	local warnings="$3"
	local failed="$4"

	newline
	ui_section "Summary"

	ui_key_value "Total checks" "$total"
	ui_key_value "Passed" "$passed"

	if [[ "$warnings" -gt 0 ]]; then
		ui_key_value "Warnings" "$warnings"
	fi

	if [[ "$failed" -gt 0 ]]; then
		ui_key_value "Failed" "$failed"
	fi

	newline

	if [[ "$failed" -eq 0 ]] && [[ "$warnings" -eq 0 ]]; then
		ui_success "All checks passed. System is ready."
	elif [[ "$failed" -eq 0 ]]; then
		ui_warning "Passed with warnings. Review recommendations above."
	else
		ui_error "Some checks failed. Please fix the issues above."
	fi
}
