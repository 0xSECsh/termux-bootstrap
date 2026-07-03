#!/usr/bin/env bats
# Tests: Progress bar

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "progress_draw draws with correct percentage" {
	run progress_draw 1 4 "Working"
	[[ "$status" -eq 0 ]]
	assert_output_contains "25%"
}

@test "progress_draw shows 100% when complete" {
	run progress_draw 4 4 "Done"
	[[ "$status" -eq 0 ]]
	assert_output_contains "100%"
}

@test "progress_draw shows 0% at start" {
	run progress_draw 0 4 "Starting"
	[[ "$status" -eq 0 ]]
	assert_output_contains "0%"
}

@test "progress_draw handles single item" {
	run progress_draw 1 1 "Only"
	[[ "$status" -eq 0 ]]
	assert_output_contains "100%"
}

@test "progress_finish prints newline" {
	run progress_finish
	[[ "$status" -eq 0 ]]
}

@test "progress_run runs through tasks" {
	run progress_run 3 "Task1" "Task2" "Task3"
	[[ "$status" -eq 0 ]]
}
