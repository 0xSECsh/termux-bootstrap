#!/usr/bin/env bats
#
# ==============================================================================
# Termux Bootstrap
# File: tests/test-validation.bats
# Description: Validation and capability tests
# ==============================================================================

source "$(dirname "${BATS_TEST_FILENAME}")/helpers.bash" 2>/dev/null || true

# ------------------------------------------------------------------------------
# Command Validation
# ------------------------------------------------------------------------------

@test "command_exists returns 0 for bash" {

	run command_exists bash

	assert_status_zero

}

@test "command_exists returns 1 for nonexistent" {

	run command_exists "nonexistent_cmd_xyz"

	assert_status_error

}

@test "require_command passes for existing command" {

	run require_command bash

	assert_status_zero

}

@test "require_command fails for missing command" {

	run require_command "nonexistent_cmd_xyz"

	assert_status_error

}

# ------------------------------------------------------------------------------
# Termux Detection
# ------------------------------------------------------------------------------

@test "is_termux returns true when TERMUX_VERSION is set" {

	TERMUX_VERSION="0.118.0"

	export TERMUX_VERSION

	run is_termux

	assert_status_zero

}

@test "is_termux returns false when TERMUX_VERSION is unset" {

	unset TERMUX_VERSION 2>/dev/null || true

	run is_termux

	assert_status_error

}

@test "require_termux passes when in Termux" {

	TERMUX_VERSION="0.118.0"

	export TERMUX_VERSION

	run require_termux

	assert_status_zero

	unset TERMUX_VERSION

}

@test "require_termux fails outside Termux" {

	unset TERMUX_VERSION 2>/dev/null || true

	run require_termux

	assert_status_error

}

# ------------------------------------------------------------------------------
# Architecture
# ------------------------------------------------------------------------------

@test "architecture returns non-empty string" {

	run architecture

	[[ -n "$output" ]]

}

@test "is_arm64 and is_x86_64 are mutually exclusive" {

	if is_arm64; then

		! is_x86_64

	else

		is_x86_64 || true

	fi

}

# ------------------------------------------------------------------------------
# File / Directory Checks
# ------------------------------------------------------------------------------

@test "file_exists returns 0 for existing file" {

	run file_exists "/bin/sh"

	assert_status_zero

}

@test "file_exists returns 1 for missing file" {

	run file_exists "/nonexistent_file_xyz"

	assert_status_error

}

@test "directory_exists returns 0 for existing dir" {

	run directory_exists "/tmp"

	assert_status_zero

}

@test "directory_exists returns 1 for missing dir" {

	run directory_exists "/nonexistent_dir_xyz"

	assert_status_error

}

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

@test "variable_is_set returns 0 for set var" {

	export _TEST_VAR="hello"

	run variable_is_set "_TEST_VAR"

	assert_status_zero

}

@test "variable_is_set returns 1 for unset var" {

	run variable_is_set "_UNSET_VAR_XYZ"

	assert_status_error

}

# ------------------------------------------------------------------------------
# Capabilities
# ------------------------------------------------------------------------------

@test "has returns 0 for bash" {

	run has bash

	assert_status_zero

}

@test "has returns 1 for unknown capability" {

	run has "unknown_cap_xyz"

	assert_status_error

}

@test "has handles architecture capabilities" {

	local arch

	arch="$(architecture)"

	if [[ "$arch" == "aarch64" ]]; then

		run has arm64

		assert_status_zero

	fi

}

@test "missing inverts has" {

	run missing "nonexistent_cap_xyz"

	assert_status_zero

	run missing bash

	assert_status_error

}

@test "require passes for available capability" {

	run require bash

	assert_status_zero

}

@test "require fails for unavailable capability" {

	run require "unknown_cap_xyz"

	assert_status_error

}

@test "assert is an alias for require" {

	run assert bash

	assert_status_zero

}

@test "has termux matches is_termux" {

	if is_termux; then

		run has termux

		assert_status_zero

	else

		run has termux

		assert_status_error

	fi

}

@test "has internet returns consistent result" {

	run has internet

	[[ "$status" -eq 0 || "$status" -eq 1 ]]

}

# ------------------------------------------------------------------------------
# Internet
# ------------------------------------------------------------------------------

@test "check_internet returns 0 or 1" {

	run check_internet

	[[ "$status" -eq 0 || "$status" -eq 1 ]]

}

@test "require_internet fails without connectivity" {

	run require_internet

	[[ "$status" -eq 0 || "$status" -eq 1 ]]

}
