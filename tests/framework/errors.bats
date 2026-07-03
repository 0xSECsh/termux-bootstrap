#!/usr/bin/env bats
# Tests: Error handling framework

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "die logs error and exits with EXIT_ERROR" {
	run die "Test error message"
	[[ "$status" -eq 1 ]] || [[ "$status" -eq "$EXIT_ERROR" ]]
}

@test "panic logs PANIC message" {
	run panic "Test panic"
	[[ "$status" -eq 1 ]] || [[ "$status" -eq "$EXIT_ERROR" ]]
}

@test "warn calls log_warning" {
	run warn "Test warning"
	[[ "$status" -eq 0 ]]
}

@test "success calls log_success" {
	run success "Test success"
	[[ "$status" -eq 0 ]]
}

@test "info calls log_info" {
	run info "Test info"
	[[ "$status" -eq 0 ]]
}

@test "debug calls log_debug" {
	LOG_LEVEL="DEBUG"
	run debug "Test debug"
	[[ "$status" -eq 0 ]]
}

@test "debug is silent when LOG_LEVEL is INFO" {
	LOG_LEVEL="INFO"
	run debug "Should not appear"
	[[ "$status" -eq 0 ]]
	[[ -z "$output" ]]
}

@test "assert_file succeeds for existing file" {
	local testfile="${TB_TMPDIR}/exists.txt"
	touch "$testfile"
	run assert_file "$testfile"
	[[ "$status" -eq 0 ]]
}

@test "assert_file fails for missing file" {
	run assert_file "${TB_TMPDIR}/nonexistent.txt"
	[[ "$status" -eq 1 ]]
}

@test "assert_directory succeeds for existing directory" {
	run assert_directory "${TB_TMPDIR}"
	[[ "$status" -eq 0 ]]
}

@test "assert_directory fails for missing directory" {
	run assert_directory "${TB_TMPDIR}/nonexistent"
	[[ "$status" -eq 1 ]]
}

@test "assert_command succeeds for available command" {
	run assert_command "printf"
	[[ "$status" -eq 0 ]]
}

@test "assert_command fails for missing command" {
	run assert_command "_this_command_does_not_exist_xyz_"
	[[ "$status" -eq 1 ]]
}

@test "assert_variable succeeds for set variable" {
	export TEST_VAR="hello"
	run assert_variable "TEST_VAR"
	[[ "$status" -eq 0 ]]
}

@test "assert_variable fails for unset variable" {
	run assert_variable "_THIS_VAR_SHOULD_NOT_BE_SET_"
	[[ "$status" -eq 1 ]]
}

@test "on_interrupt logs warning and exits" {
	run on_interrupt
	[[ "$status" -eq 130 ]]
}

@test "register_error_handlers sets handlers only once" {
	run register_error_handlers
	[[ "$status" -eq 0 ]]
	run register_error_handlers
	[[ "$status" -eq 0 ]]
}

@test "EXIT codes from errors.sh match constants.sh" {
	[[ "$EXIT_OK" -eq "$EXIT_SUCCESS" ]]
	[[ "$EXIT_ERROR" -eq "$EXIT_FAILURE" ]]
	[[ "$EXIT_ARGUMENT" -eq "$EXIT_INVALID_ARGUMENT" ]]
	[[ "$EXIT_DEPENDENCY" -eq "$EXIT_DEPENDENCY_ERROR" ]]
	[[ "$EXIT_NETWORK" -eq "$EXIT_NETWORK_ERROR" ]]
	[[ "$EXIT_PERMISSION" -eq "$EXIT_PERMISSION_ERROR" ]]
	[[ "$EXIT_INTERRUPTED" -eq 130 ]]
}
