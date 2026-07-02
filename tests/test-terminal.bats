#!/usr/bin/env bats
#
# ==============================================================================
# Termux Bootstrap
# File: tests/test-terminal.bats
# Description: Terminal and logging tests
# ==============================================================================

source "$(dirname "${BATS_TEST_FILENAME}")/helpers.bash" 2>/dev/null || true

LOG_LEVEL="DEBUG"
export LOG_LEVEL

# ------------------------------------------------------------------------------
# Color Support
# ------------------------------------------------------------------------------

@test "color constants are defined" {

	if [[ "$COLOR_SUPPORT" == true ]]; then

		[[ -n "$RESET" ]]

		[[ -n "$RED" ]]

		[[ -n "$GREEN" ]]

		[[ -n "$YELLOW" ]]

		[[ -n "$BLUE" ]]

		[[ -n "$MAGENTA" ]]

		[[ -n "$CYAN" ]]

	fi

}

@test "colorize wraps text" {

	run colorize "$RED" "test"

	assert_output_contains "test"

}

@test "title output is non-empty" {

	run title "Test Title"

	[[ -n "$output" ]]

}

@test "subtitle output is non-empty" {

	run subtitle "Test Subtitle"

	[[ -n "$output" ]]

}

@test "separator output is non-empty" {

	run separator

	[[ -n "$output" ]]

}

# ------------------------------------------------------------------------------
# Logging API
# ------------------------------------------------------------------------------

@test "log_info outputs message" {

	run log_info "info test"

	assert_output_contains "info test"

}

@test "log_success outputs message" {

	run log_success "success test"

	assert_output_contains "success test"

}

@test "log_warning outputs message" {

	run log_warning "warning test"

	assert_output_contains "warning test"

}

@test "log_error outputs message" {

	run log_error "error test"

	assert_output_contains "error test"

}

@test "log_debug outputs message when LOG_LEVEL=DEBUG" {

	LOG_LEVEL="DEBUG"

	run log_debug "debug test"

	assert_output_contains "debug test"

}

@test "log_debug returns early when LOG_LEVEL=INFO" {

	LOG_LEVEL="INFO"

	run log_debug "should not appear"

	[[ -z "$output" ]]

	LOG_LEVEL="DEBUG"

}

@test "fatal exits with failure" {

	run fatal "fatal error"

	assert_status_error 1

	assert_output_contains "fatal error"

}

@test "_write_log writes to log file" {

	local before

	before="$(wc -l <"$LOG_FILE" 2>/dev/null || echo 0)"

	_write_log "TEST" "log entry"

	local after

	after="$(wc -l <"$LOG_FILE" 2>/dev/null || echo 0)"

	[[ "$after" -gt "$before" ]]

}

@test "_timestamp returns a valid date" {

	run _timestamp

	[[ -n "$output" ]]

}

# ------------------------------------------------------------------------------
# UI Components
# ------------------------------------------------------------------------------

@test "ui_banner shows banner" {

	run ui_banner

	[[ -n "$output" ]]

}

@test "ui_section outputs title" {

	run ui_section "Section Test"

	assert_output_contains "Section Test"

}

@test "ui_bullet outputs bullet" {

	run ui_bullet "item"

	assert_output_contains "item"

}

@test "ui_key_value formats correctly" {

	run ui_key_value "Key" "Value"

	assert_output_contains "Value"

}

@test "ui_summary outputs title and items" {

	run ui_summary "Summary Title" "item1" "item2"

	assert_output_contains "Summary Title"

	assert_output_contains "item1"

	assert_output_contains "item2"

}

# ------------------------------------------------------------------------------
# Spinner
# ------------------------------------------------------------------------------

@test "spinner_start and spinner_stop work" {

	spinner_start "working"

	spinner_stop

	[[ -z "$SPINNER_PID" ]]

}

@test "spinner_start is idempotent" {

	spinner_start "task"

	local pid="$SPINNER_PID"

	spinner_start "task"

	[[ "$SPINNER_PID" == "$pid" ]]

	spinner_stop

}

@test "spinner_run executes command" {

	run spinner_run "Running echo" "echo" "hello"

	[[ "$status" -eq 0 ]]

}

# ------------------------------------------------------------------------------
# Progress
# ------------------------------------------------------------------------------

@test "progress_draw displays percentage" {

	run progress_draw 50 100 "test"

	assert_output_contains "50%"

}

@test "progress_run iterates items" {

	run progress_run "echo" "item1" "item2"

	[[ "$status" -eq 0 ]]

}
