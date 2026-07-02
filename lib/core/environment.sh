#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: core/environment.sh
# Description: Environment initialization and preparation
# ==============================================================================

: "${CONFIG_DIR:?}"
: "${CONFIGS_DIR:?}"
: "${CACHE_DIR:?}"
: "${DATA_DIR:?}"
: "${LOG_DIR:?}"
: "${BACKUP_DIR:?}"
: "${TEMP_DIR:?}"
: "${LOG_FILE:?}"
: "${ERROR_LOG:?}"

# ------------------------------------------------------------------------------
# Directory Initialization
# ------------------------------------------------------------------------------

initialize_directories() {

	create_directory "$CONFIG_DIR"
	create_directory "$CACHE_DIR"
	create_directory "$DATA_DIR"
	create_directory "$LOG_DIR"
	create_directory "$BACKUP_DIR"
	create_directory "$TEMP_DIR"

}

# ------------------------------------------------------------------------------
# Log Initialization
# ------------------------------------------------------------------------------

initialize_logs() {

	create_file "$LOG_FILE"
	create_file "$ERROR_LOG"

}

# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------

initialize_environment_variables() {

	export TERM="xterm-256color"

	export LANG="${LANG:-en_US.UTF-8}"

	export LC_ALL="${LC_ALL:-en_US.UTF-8}"

}

# ------------------------------------------------------------------------------
# Temporary Directory
# ------------------------------------------------------------------------------

cleanup_temp_directory() {

	[[ -n "$TEMP_DIR" && "$TEMP_DIR" != "/" ]] || return 1

	[[ -d "$TEMP_DIR" ]] && rm -rf -- "$TEMP_DIR"

	create_directory "$TEMP_DIR"

}

# ------------------------------------------------------------------------------
# Runtime Information
# ------------------------------------------------------------------------------

show_environment() {

	log_info "Project      : ${PROJECT_NAME}"
	log_info "Version      : ${PROJECT_VERSION}"
	log_info "Config Dir   : ${CONFIG_DIR}"
	log_info "Cache Dir    : ${CACHE_DIR}"
	log_info "Data Dir     : ${DATA_DIR}"
	log_info "Log Dir      : ${LOG_DIR}"
	log_info "Temp Dir     : ${TEMP_DIR}"

}

# ------------------------------------------------------------------------------
# Validation
# ------------------------------------------------------------------------------

validate_environment() {

	assert_directory "$CONFIG_DIR"
	assert_directory "$CACHE_DIR"
	assert_directory "$DATA_DIR"
	assert_directory "$LOG_DIR"
	assert_directory "$TEMP_DIR"

}

# ------------------------------------------------------------------------------
# Bootstrap Initialization
# ------------------------------------------------------------------------------

initialize_environment() {

	[[ "${ENVIRONMENT_INITIALIZED:-false}" == true ]] && return 0

	initialize_directories

	initialize_logs

	initialize_environment_variables

	cleanup_temp_directory

	validate_environment

	setup_temp_cleanup_trap

	ENVIRONMENT_INITIALIZED=true

	export ENVIRONMENT_INITIALIZED

}
