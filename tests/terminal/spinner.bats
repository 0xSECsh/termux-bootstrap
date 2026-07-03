#!/usr/bin/env bats
# Tests: Spinner

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "spinner_start starts animation" {
	spinner_start "Testing"
	[[ -n "$SPINNER_PID" ]]
	spinner_stop
}

@test "spinner_stop stops animation" {
	spinner_start "Test"
	spinner_stop
	[[ -z "$SPINNER_PID" ]]
}

@test "spinner_success stops and prints success" {
	spinner_start "Test"
	run spinner_success "Completed"
	[[ "$status" -eq 0 ]]
	spinner_stop 2>/dev/null || true
}

@test "spinner_warning stops and prints warning" {
	spinner_start "Test"
	run spinner_warning "Caution"
	[[ "$status" -eq 0 ]]
}

@test "spinner_error stops and prints error" {
	spinner_start "Test"
	run spinner_error "Failed"
	[[ "$status" -eq 0 ]]
}

@test "spinner_info stops and prints info" {
	spinner_start "Test"
	run spinner_info "Info"
	[[ "$status" -eq 0 ]]
}

@test "spinner_run executes command with spinner" {
	run spinner_run "Test command" true
	[[ "$status" -eq 0 ]]
}

@test "spinner_run shows error on failure" {
	run spinner_run "Test fail" false
	[[ "$status" -eq 1 ]]
}

@test "spinner_start does nothing when already running" {
	spinner_start "First"
	local pid1="$SPINNER_PID"
	spinner_start "Second"
	[[ "$SPINNER_PID" == "$pid1" ]]
	spinner_stop
}
