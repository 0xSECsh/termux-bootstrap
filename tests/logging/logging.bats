#!/usr/bin/env bats
# Tests: Logging framework

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "log_info prints info message" {
	run log_info "Test info message"
	[[ "$status" -eq 0 ]]
	assert_output_contains "[INFO]"
	assert_output_contains "Test info message"
}

@test "log_info writes to log file" {
	log_info "Persistent info" >/dev/null 2>&1 || true
	assert_file_exists "$LOG_FILE"
	assert_file_contains "$LOG_FILE" "Persistent info"
}

@test "log_success prints success message" {
	run log_success "Test success"
	[[ "$status" -eq 0 ]]
	assert_output_contains "[ OK ]"
}

@test "log_success writes to log file" {
	log_success "Persistent success" >/dev/null 2>&1 || true
	assert_file_contains "$LOG_FILE" "Persistent success"
}

@test "log_warning prints warning message" {
	run log_warning "Test warning"
	[[ "$status" -eq 0 ]]
	assert_output_contains "[WARN]"
	assert_output_contains "Test warning"
}

@test "log_warning writes to log file" {
	log_warning "Persistent warning" >/dev/null 2>&1 || true
	assert_file_contains "$LOG_FILE" "Persistent warning"
}

@test "log_error prints error message with caller info" {
	run log_error "Test error"
	[[ "$status" -eq 0 ]]
	assert_output_contains "[FAIL]"
	assert_output_contains "Test error"
}

@test "log_error writes to log file" {
	log_error "Persistent error" >/dev/null 2>&1 || true
	assert_file_contains "$LOG_FILE" "Persistent error"
}

@test "log_debug is silent at default LOG_LEVEL" {
	run log_debug "Should not appear"
	[[ -z "$output" ]]
}

@test "log_debug works when LOG_LEVEL=DEBUG" {
	LOG_LEVEL="DEBUG"
	run log_debug "Debug message"
	assert_output_contains "[DEBUG]"
	assert_output_contains "Debug message"
}

@test "log_debug writes to log file at DEBUG level" {
	LOG_LEVEL="DEBUG"
	log_debug "Debug persist" >/dev/null 2>&1 || true
	assert_file_contains "$LOG_FILE" "Debug persist"
}

@test "log_fatal logs error and exits" {
	run log_fatal "Fatal error"
	[[ "$status" -eq 1 ]]
}

@test "log_error_with_cause includes cause" {
	run log_error_with_cause "Operation failed" "Network timeout"
	assert_output_contains "Operation failed"
	assert_output_contains "Network timeout"
}

@test "log_start logs info with Starting prefix" {
	run log_start "Some task"
	assert_output_contains "Starting: Some task"
}

@test "log_finish logs success with Finished prefix" {
	run log_finish "Some task"
	assert_output_contains "Finished: Some task"
}

@test "log_skip logs warning with reason" {
	run log_skip "Some task" "Already done"
	assert_output_contains "Skipping: Some task"
	assert_output_contains "Already done"
}

@test "fatal is an alias for log_fatal" {
	run fatal "Fatal via alias"
	[[ "$status" -eq 1 ]]
}

@test "log messages are timestamped in log file" {
	log_info "Timestamp check" >/dev/null 2>&1 || true
	local line
	line="$(grep "Timestamp check" "$LOG_FILE" 2>/dev/null || true)"
	[[ -n "$line" ]]
	# Should start with timestamp pattern [YYYY-MM-DD HH:MM:SS]
	[[ "$line" == "["* ]]
}

@test "logging supports context parameter" {
	run log_info "Context test" "my-context"
	assert_output_contains "my-context"
}
