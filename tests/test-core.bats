#!/usr/bin/env bats
#
# ==============================================================================
# Termux Bootstrap
# File: tests/test-core.bats
# Description: Core infrastructure tests (constants, errors, environment, version)
# ==============================================================================

source "$(dirname "${BATS_TEST_FILENAME}")/helpers.bash" 2>/dev/null || true

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

@test "PROJECT_NAME is defined" {

	[[ -n "$PROJECT_NAME" ]]

}

@test "PROJECT_VERSION is 0.1.0" {

	[[ "$PROJECT_VERSION" == "0.1.0" ]]

}

@test "PROJECT_SLUG is termux-bootstrap" {

	[[ "$PROJECT_SLUG" == "termux-bootstrap" ]]

}

@test "PROJECT_AUTHOR is defined" {

	[[ -n "$PROJECT_AUTHOR" ]]

}

@test "PROJECT_REPOSITORY is a URL" {

	[[ "$PROJECT_REPOSITORY" == https://* ]]

}

@test "Config directories are absolute paths" {

	[[ "$CONFIG_DIR" == /* ]]

	[[ "$CACHE_DIR" == /* ]]

	[[ "$DATA_DIR" == /* ]]

	[[ "$LOG_DIR" == /* ]]

	[[ "$BACKUP_DIR" == /* ]]

	[[ "$TEMP_DIR" == /* ]]

}

# ------------------------------------------------------------------------------
# Exit Codes
# ------------------------------------------------------------------------------

@test "EXIT_SUCCESS is 0" {

	[[ "$EXIT_SUCCESS" -eq 0 ]]

}

@test "EXIT_FAILURE is 1" {

	[[ "$EXIT_FAILURE" -eq 1 ]]

}

@test "EXIT_INVALID_ARGUMENT is 2" {

	[[ "$EXIT_INVALID_ARGUMENT" -eq 2 ]]

}

@test "EXIT_DEPENDENCY_ERROR is 3" {

	[[ "$EXIT_DEPENDENCY_ERROR" -eq 3 ]]

}

@test "EXIT_NETWORK_ERROR is 4" {

	[[ "$EXIT_NETWORK_ERROR" -eq 4 ]]

}

@test "EXIT_PERMISSION_ERROR is 5" {

	[[ "$EXIT_PERMISSION_ERROR" -eq 5 ]]

}

# ------------------------------------------------------------------------------
# Errors API
# ------------------------------------------------------------------------------

@test "die function exists" {

	type die

}

@test "die exits with error" {

	run die "Something went wrong"

	assert_status_error 1

}

@test "panic function exists" {

	type panic

}

@test "warn function exists" {

	type warn

}

@test "success function exists" {

	type success

}

@test "info function exists" {

	type info

}

@test "debug function exists" {

	type debug

}

# ------------------------------------------------------------------------------
# Assertions
# ------------------------------------------------------------------------------

@test "assert_file passes for existing file" {

	run assert_file "/bin/sh"

	assert_status_zero

}

@test "assert_file fails for missing file" {

	run assert_file "/nonexistent_file_xyz"

	assert_status_error

}

@test "assert_directory passes for existing directory" {

	run assert_directory "/tmp"

	assert_status_zero

}

@test "assert_directory fails for missing directory" {

	run assert_directory "/nonexistent_dir_xyz"

	assert_status_error

}

@test "assert_command passes for existing command" {

	run assert_command "bash"

	assert_status_zero

}

@test "assert_command fails for missing command" {

	run assert_command "nonexistent_command_xyz"

	assert_status_error

}

@test "assert_variable passes for set variable" {

	export TEST_VAR="hello"

	run assert_variable "TEST_VAR"

	assert_status_zero

}

@test "assert_variable fails for unset variable" {

	run assert_variable "_UNSET_VAR_XYZ_"

	assert_status_error

}

# ------------------------------------------------------------------------------
# Error Handlers
# ------------------------------------------------------------------------------

@test "on_interrupt exits with EXIT_INTERRUPTED" {

	run on_interrupt

	[[ "$status" -eq 130 ]]

}

@test "register_error_handlers is idempotent" {

	register_error_handlers

	register_error_handlers

}

# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

@test "initialize_environment is idempotent" {

	initialize_environment

	initialize_environment

	[[ "$ENVIRONMENT_INITIALIZED" == true ]]

}

@test "cleanup_temp_directory recreates temp dir" {

	local test_file="${TEMP_DIR}/cleanup_test"

	touch "$test_file" 2>/dev/null || true

	cleanup_temp_directory

	[[ -d "$TEMP_DIR" ]]

	[[ ! -f "$test_file" ]]

}

@test "validate_environment passes after initialization" {

	run validate_environment

	assert_status_zero

}

# ------------------------------------------------------------------------------
# Version Information
# ------------------------------------------------------------------------------

@test "show_version outputs project name" {

	run show_version

	assert_output_contains "$PROJECT_NAME"

}

@test "show_about outputs author" {

	run show_about

	assert_output_contains "$PROJECT_AUTHOR"

}

@test "show_banner outputs termux" {

	run show_banner

	assert_output_contains "Termux"

}

@test "show_info outputs version" {

	run show_info

	assert_output_contains "$PROJECT_VERSION"

}
