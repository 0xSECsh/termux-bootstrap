#!/usr/bin/env bats
# Tests: Validation helpers

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "command_exists returns 0 for existing command" {
	command_exists "bash"
	[[ "$?" -eq 0 ]]
}

@test "command_exists returns 1 for missing command" {
	! command_exists "_nonexistent_cmd_xyz_"
}

@test "command_exists handles empty argument" {
	! command_exists ""
}

@test "require_command succeeds for existing command" {
	run require_command "bash"
	[[ "$status" -eq 0 ]]
}

@test "require_command fails for missing command" {
	run require_command "_nonexistent_cmd_"
	[[ "$status" -eq 1 ]]
}

@test "is_termux returns true when TERMUX_VERSION is set" {
	export TERMUX_VERSION="0.118.0"
	is_termux
	[[ "$?" -eq 0 ]]
}

@test "is_termux returns false when TERMUX_VERSION is unset" {
	unset TERMUX_VERSION
	! is_termux
}

@test "require_termux fails outside termux" {
	unset TERMUX_VERSION
	run require_termux
	[[ "$status" -eq 1 ]]
}

@test "is_android checks for /system directory" {
	# In test environment, /system may not exist
	! is_android
}

@test "architecture returns system architecture" {
	run architecture
	[[ "$status" -eq 0 ]]
	[[ -n "$output" ]]
}

@test "is_arm64 checks for aarch64" {
	SYSTEM_ARCH="aarch64"
	is_arm64
	SYSTEM_ARCH="x86_64"
	! is_arm64
}

@test "is_x86_64 checks for x86_64" {
	SYSTEM_ARCH="x86_64"
	is_x86_64
	SYSTEM_ARCH="aarch64"
	! is_x86_64
}

@test "file_exists returns 0 for existing file" {
	local f="${TB_TMPDIR}/exist.txt"
	touch "$f"
	file_exists "$f"
	[[ "$?" -eq 0 ]]
}

@test "file_exists returns 1 for missing file" {
	! file_exists "${TB_TMPDIR}/missing.txt"
}

@test "directory_exists returns 0 for existing directory" {
	directory_exists "${TB_TMPDIR}"
}

@test "directory_exists returns 1 for missing directory" {
	! directory_exists "${TB_TMPDIR}/missingdir"
}

@test "variable_is_set returns 0 for set variable" {
	export TEST_VAR="hello"
	variable_is_set "TEST_VAR"
}

@test "variable_is_set returns 1 for unset variable" {
	! variable_is_set "_UNSET_VAR_12345_"
}

@test "check_internet returns 0 when ping succeeds" {
	run check_internet
	[[ "$status" -eq 0 ]]
}

@test "require_internet fails when no internet" {
	# Mock ping to fail
	mock_command ping --exit 1
	run require_internet
	[[ "$status" -eq 1 ]]
}

@test "confirm prompts for input" {
	# confirm reads from stdin, so we test by piping input
	# Confirm function: read -rp "$1 [y/N]: " answer; [[ "$answer" =~ ^[Yy]$ ]]
	# Directly test the underlying logic without stdin
	run confirm "Continue?" <<< "y"
	[[ "$status" -eq 0 ]]
	run confirm "Continue?" <<< "n"
	[[ "$status" -eq 1 ]]
}
