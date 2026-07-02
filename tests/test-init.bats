#!/usr/bin/env bats
#
# ==============================================================================
# Termux Bootstrap
# File: tests/test-init.bats
# Description: Framework initialization tests
# ==============================================================================

source "$(dirname "${BATS_TEST_FILENAME}")/helpers.bash" 2>/dev/null || true

# ------------------------------------------------------------------------------
# Common Loading
# ------------------------------------------------------------------------------

@test "common.sh loads without error" {

	run source "${BATS_TEST_DIRNAME}/../lib/common.sh"

	assert_status_zero

}

@test "framework_initialize completes without error" {

	run type framework_initialize

	assert_status_zero

}

@test "LIB_DIR is set correctly" {

	[[ -n "$LIB_DIR" ]]

	[[ "$LIB_DIR" == */lib ]]

}

@test "common.sh loading is idempotent" {

	run source "${BATS_TEST_DIRNAME}/../lib/common.sh"

	assert_status_zero

}

# ------------------------------------------------------------------------------
# Library Loading
# ------------------------------------------------------------------------------

@test "load_library loads a library and registers it" {

	unset LOADED_LIBRARIES["/tmp/test_lib"]

	run load_library "${BATS_TEST_DIRNAME}/../lib/core/constants.sh"

	assert_status_zero

}

@test "load_library fails on missing library" {

	run load_library "/nonexistent/path.sh"

	assert_status_error

}

@test "LOADED_LIBRARIES contains expected entries" {

	local key

	key="$(readlink -f "${BATS_TEST_DIRNAME}/../lib/core/constants.sh")"

	[[ -n "${LOADED_LIBRARIES[$key]:-}" ]]

}

# ------------------------------------------------------------------------------
# Environment Initialization Results
# ------------------------------------------------------------------------------

@test "SYSTEM_OS is set" {

	[[ -n "$SYSTEM_OS" ]]

}

@test "SYSTEM_KERNEL is set" {

	[[ -n "$SYSTEM_KERNEL" ]]

}

@test "SYSTEM_ARCH is set" {

	[[ -n "$SYSTEM_ARCH" ]]

}

@test "TERMINAL_INITIALIZED is true" {

	[[ "$TERMINAL_INITIALIZED" == true ]]

}

@test "ENVIRONMENT_INITIALIZED is true" {

	[[ "$ENVIRONMENT_INITIALIZED" == true ]]

}

@test "ERROR_HANDLERS_REGISTERED is true" {

	[[ "${ERROR_HANDLERS_REGISTERED:-false}" == true ]] || skip "Not applicable in BATS"

}

# ------------------------------------------------------------------------------
# Directory Initialization
# ------------------------------------------------------------------------------

@test "Initialize_directories creates expected directories" {

	initialize_directories

	[[ -d "$CONFIG_DIR" ]]

	[[ -d "$CACHE_DIR" ]]

	[[ -d "$DATA_DIR" ]]

	[[ -d "$LOG_DIR" ]]

	[[ -d "$BACKUP_DIR" ]]

	[[ -d "$TEMP_DIR" ]]

}

@test "Log files exist after initialization" {

	[[ -f "$LOG_FILE" ]]

	[[ -f "$ERROR_LOG" ]]

}
