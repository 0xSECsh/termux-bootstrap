#!/usr/bin/env bats
# Tests: String utility functions

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "to_lower converts uppercase to lowercase" {
	run to_lower "HELLO WORLD"
	[[ "$output" == "hello world" ]]
}

@test "to_lower handles mixed case" {
	run to_lower "Hello World"
	[[ "$output" == "hello world" ]]
}

@test "to_lower handles empty string" {
	run to_lower ""
	[[ "$output" == "" ]]
}

@test "to_lower handles numbers and symbols" {
	run to_lower "ABC123!@#"
	[[ "$output" == "abc123!@#" ]]
}

@test "to_upper converts lowercase to uppercase" {
	run to_upper "hello world"
	[[ "$output" == "HELLO WORLD" ]]
}

@test "to_upper handles mixed case" {
	run to_upper "Hello World"
	[[ "$output" == "HELLO WORLD" ]]
}

@test "to_upper handles empty string" {
	run to_upper ""
	[[ "$output" == "" ]]
}

@test "trim removes leading whitespace" {
	run trim "   hello"
	[[ "$output" == "hello" ]]
}

@test "trim removes trailing whitespace" {
	run trim "hello   "
	[[ "$output" == "hello" ]]
}

@test "trim removes both leading and trailing whitespace" {
	run trim "   hello world   "
	[[ "$output" == "hello world" ]]
}

@test "trim handles tabs" {
	run trim $'\t\thello\t\t'
	[[ "$output" == "hello" ]]
}

@test "trim handles empty string" {
	run trim ""
	[[ "$output" == "" ]]
}

@test "trim handles string with only spaces" {
	run trim "     "
	[[ "$output" == "" ]]
}

@test "trim preserves internal spaces" {
	run trim "  hello   world  "
	[[ "$output" == "hello   world" ]]
}

@test "to_lower and to_upper are inverses" {
	local original="Test String 123"
	local lower
	lower="$(to_lower "$original")"
	local upper
	upper="$(to_upper "$lower")"
	[[ "$upper" == "${original^^}" ]]
}
