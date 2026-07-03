#!/usr/bin/env bats
# Tests: Doctor command - system diagnostics

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup

	# Source the doctor command
	source "${BATS_TEST_DIRNAME}/../../commands/doctor.sh"
}

teardown() {
	common_teardown
}

# ------------------------------------------------------------------------------
# cmd_doctor — help and flags
# ------------------------------------------------------------------------------

@test "cmd_doctor --help shows usage text" {
	run cmd_doctor --help
	assert_success
	assert_output_contains "Usage: bootstrap doctor"
	assert_output_contains "--verbose"
}

@test "cmd_doctor --verbose runs without error" {
	mock_has_termux
	run cmd_doctor --verbose
	assert_success
}

@test "cmd_doctor with unknown option returns error" {
	run cmd_doctor --bogus
	assert_failure "$EXIT_INVALID_ARGUMENT"
	assert_output_contains "Unknown option: --bogus"
}

# ------------------------------------------------------------------------------
# cmd_doctor — full run (various scenarios)
# ------------------------------------------------------------------------------

@test "cmd_doctor succeeds when everything is fine" {
	mock_has_termux
	run cmd_doctor
	assert_success
	assert_output_contains "All checks passed"
}

@test "cmd_doctor warns when not in Termux" {
	mock_has_not_termux
	run cmd_doctor
	assert_success
	assert_output_contains "Not running in Termux"
	assert_output_contains "Passed with warnings"
}

@test "cmd_doctor fails when internet is unavailable" {
	mock_has_termux
	mock_command ping --exit 1
	run cmd_doctor
	assert_failure
	assert_output_contains "No internet connectivity"
}

@test "cmd_doctor fails when required command is missing" {
	mock_has_termux
	# Remove jq from mock path
	local removed_path
	while IFS= read -r -d '' f; do
		rm "$f"
		removed_path="$f"
	done < <(find "$MOCK_DIR" -name 'jq' -print0 2>/dev/null || true)
	run cmd_doctor
	assert_failure
	assert_output_contains "jq"
	assert_output_contains "not found"
}

@test "cmd_doctor warns when storage is low" {
	mock_has_termux
	# Mock df to return low available space
	mock_command df --stdout "Filesystem     1K-blocks    Used Available Use% Mounted on
/dev/loop0      5000000 4500000    500000  90% /home"
	run cmd_doctor
	assert_success
	assert_output_contains "Low storage space"
	assert_output_contains "Passed with warnings"
}

@test "cmd_doctor shows summary counters" {
	mock_has_termux
	mock_command ping --exit 1
	run cmd_doctor
	assert_failure
	assert_output_contains "Total checks"
	assert_output_contains "Passed"
	assert_output_contains "Failed"
	assert_output_contains "Some checks failed"
}

# ------------------------------------------------------------------------------
# _check_environment
# ------------------------------------------------------------------------------

@test "_check_environment passes in Termux" {
	mock_has_termux
	run _check_environment total passed warnings failed
	assert_success
	assert_output_contains "Termux environment detected"
}

@test "_check_environment warns outside Termux" {
	mock_has_not_termux
	run _check_environment total passed warnings failed
	assert_success
	assert_output_contains "Not running in Termux"
}

# ------------------------------------------------------------------------------
# _check_system
# ------------------------------------------------------------------------------

@test "_check_system always passes and outputs system info" {
	mock_has_termux
	run _check_system total passed warnings failed false
	assert_success
	assert_output_contains "System Information"
	assert_output_contains "Architecture"
	assert_output_contains "Kernel"
}

@test "_check_system verbose mode includes extra fields" {
	mock_has_termux
	run _check_system total passed warnings failed true
	assert_success
	assert_output_contains "CPU"
	assert_output_contains "CPU Cores"
	assert_output_contains "Memory"
	assert_output_contains "Shell"
}

# ------------------------------------------------------------------------------
# _check_internet
# ------------------------------------------------------------------------------

@test "_check_internet passes when ping succeeds" {
	mock_command ping --exit 0
	run _check_internet total passed warnings failed
	assert_success
	assert_output_contains "Internet connectivity"
}

@test "_check_internet fails when ping fails" {
	mock_command ping --exit 1
	run _check_internet total passed warnings failed
	assert_output_contains "No internet connectivity"
}

# ------------------------------------------------------------------------------
# _check_storage
# ------------------------------------------------------------------------------

@test "_check_storage passes with sufficient space" {
	mock_command df --stdout "Filesystem     1K-blocks    Used Available Use% Mounted on
/dev/loop0      5000000 1000000  4000000  20% /home"
	run _check_storage total passed warnings failed false
	assert_success
	assert_output_contains "Storage OK"
}

@test "_check_storage warns with low space" {
	mock_command df --stdout "Filesystem     1K-blocks    Used Available Use% Mounted on
/dev/loop0      5000000 4500000   500000  90% /home"
	run _check_storage total passed warnings failed false
	assert_success
	assert_output_contains "Low storage space"
}

# ------------------------------------------------------------------------------
# _check_command
# ------------------------------------------------------------------------------

@test "_check_command passes for existing command" {
	run _check_command total passed warnings failed "bash" "Shell"
	assert_success
	assert_output_contains "bash"
	assert_output_contains "Shell"
}

@test "_check_command fails for missing command" {
	run _check_command total passed warnings failed "_nonexistent_cmd_xyz_" "Test"
	assert_output_contains "_nonexistent_cmd_xyz_"
	assert_output_contains "not found"
}

# ------------------------------------------------------------------------------
# _print_summary
# ------------------------------------------------------------------------------

@test "_print_summary shows all pass message" {
	run _print_summary 10 10 0 0
	assert_success
	assert_output_contains "All checks passed"
}

@test "_print_summary shows warnings message" {
	run _print_summary 10 9 1 0
	assert_success
	assert_output_contains "Passed with warnings"
}

@test "_print_summary shows failure message" {
	run _print_summary 10 8 1 1
	assert_success
	assert_output_contains "Some checks failed"
}

@test "_print_summary omits warnings section when zero" {
	run _print_summary 10 10 0 0
	assert_output_not_contains "Warnings"
}

@test "_print_summary omits failed section when zero" {
	run _print_summary 10 10 0 0
	assert_output_not_contains "Failed"
}

@test "_print_summary shows warning count when present" {
	run _print_summary 10 5 5 0
	assert_output_contains "Warnings"
}

@test "_print_summary shows failure count when present" {
	run _print_summary 10 5 3 2
	assert_output_contains "Failed"
}
