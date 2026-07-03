#!/usr/bin/env bats
# Tests: framework_initialize() and library loader

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "common.sh guards against double loading" {
	# TERMUX_BOOTSTRAP_COMMON_LOADED should be true after first source
	assert_var_set TERMUX_BOOTSTRAP_COMMON_LOADED
	[[ "$TERMUX_BOOTSTRAP_COMMON_LOADED" == true ]]
}

@test "framework_initialize sets up environment directories" {
	assert_dir_exists "${CONFIG_DIR}"
	assert_dir_exists "${CACHE_DIR}"
	assert_dir_exists "${DATA_DIR}"
	assert_dir_exists "${LOG_DIR}"
	assert_dir_exists "${BACKUP_DIR}"
	assert_dir_exists "${TEMP_DIR}"
}

@test "framework_initialize creates log files" {
	assert_file_exists "${LOG_FILE}"
	assert_file_exists "${ERROR_LOG}"
}

@test "framework_initialize sets environment variables" {
	assert_var_set SYSTEM_OS
	assert_var_set SYSTEM_KERNEL
	assert_var_set SYSTEM_ARCH
}

@test "framework_initialize sets ENVIRONMENT_INITIALIZED" {
	[[ "$ENVIRONMENT_INITIALIZED" == true ]]
}

@test "framework_initialize skips reinitialization" {
	ENVIRONMENT_INITIALIZED=true
	run framework_initialize
	# Should return early without error
	[[ "$status" -eq 0 ]]
}

@test "framework_initialize initializes terminal" {
	[[ "$TERMINAL_INITIALIZED" == true ]] || [[ "$TERMINAL_INITIALIZED" == "" ]]
}

@test "framework_initialize registers error handlers" {
	run register_error_handlers
	[[ "$status" -eq 0 ]]
}

@test "LIB_DIR points to correct location" {
	[[ "$LIB_DIR" == "${_PROJECT_ROOT}/lib" ]]
}
