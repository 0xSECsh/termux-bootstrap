#!/usr/bin/env bats
# Tests: CLI command dispatcher

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "dispatch with no arguments shows help" {
	SOURCE_DATE_EPOCH=0
	run dispatch
	[[ "$status" -eq 0 ]]
	assert_output_contains "bootstrap <command>"
}

@test "dispatch help shows help text" {
	run dispatch help
	[[ "$status" -eq 0 ]]
	assert_output_contains "bootstrap <command>"
	assert_output_contains "Available Commands"
	assert_output_contains "help"
	assert_output_contains "version"
}

@test "dispatch version shows version" {
	run dispatch version
	[[ "$status" -eq 0 ]]
	assert_output_contains "$PROJECT_NAME"
	assert_output_contains "$PROJECT_VERSION"
}

@test "dispatch with unknown command fails" {
	run dispatch nonexistent
	[[ "$status" -eq "$EXIT_INVALID_ARGUMENT" ]]
}

@test "dispatch help lists all registered commands" {
	run dispatch help
	for cmd in help version doctor install update module profile config list; do
		assert_output_contains "$cmd"
	done
}

@test "COMMANDS array contains all expected commands" {
	[[ -n "${COMMANDS[help]}" ]]
	[[ -n "${COMMANDS[version]}" ]]
	[[ -n "${COMMANDS[doctor]}" ]]
	[[ -n "${COMMANDS[install]}" ]]
	[[ -n "${COMMANDS[update]}" ]]
	[[ -n "${COMMANDS[module]}" ]]
	[[ -n "${COMMANDS[profile]}" ]]
	[[ -n "${COMMANDS[config]}" ]]
	[[ -n "${COMMANDS[list]}" ]]
}

@test "load_command handles missing command" {
	run load_command "nonexistent_cmd"
	[[ "$status" -eq 1 ]]
}

@test "dispatch_help displays usage information" {
	run dispatch_help
	[[ "$status" -eq 0 ]]
	assert_output_contains "Usage: bootstrap"
	assert_output_contains "Commands:"
}

@test "list_profiles delegates to profile_list" {
	run list_profiles
	# Should not crash - either returns 0 (even if no profiles)
	[[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "dispatch config loads and runs config command" {
	run dispatch config
	# config with no args defaults to "show"
	[[ "$status" -eq 0 ]]
}

@test "dispatch config list shows available configs" {
	run dispatch config list
	[[ "$status" -eq 0 ]]
}

@test "dispatch doctor runs diagnostics" {
	run dispatch doctor
	[[ "$status" -eq 0 ]]
}

@test "dispatch install with --help shows help" {
	run dispatch install --help
	[[ "$status" -eq 0 ]]
	assert_output_contains "Usage: bootstrap install"
}

@test "dispatch list profiles lists profiles" {
	export PROFILE_DIR="${TB_TMPDIR}/profiles"
	mkdir -p "$PROFILE_DIR"
	run dispatch list profiles
	[[ "$status" -eq 0 ]]
}

@test "dispatch list modules lists modules" {
	run dispatch list modules
	[[ "$status" -eq 0 ]]
}

@test "dispatch list with invalid option fails" {
	run dispatch list --invalid-option
	[[ "$status" -eq "$EXIT_INVALID_ARGUMENT" ]]
}

@test "dispatch update runs update command" {
	run dispatch update
	[[ "$status" -eq 0 ]]
}
