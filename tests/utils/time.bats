#!/usr/bin/env bats
# Tests: Time utility functions

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "timestamp returns formatted date string" {
	run timestamp
	[[ "$status" -eq 0 ]]
	[[ -n "$output" ]]
	# Should match YYYY-MM-DD HH:MM:SS format
	[[ "$output" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]
}

@test "epoch returns numeric timestamp" {
	run epoch
	[[ "$status" -eq 0 ]]
	[[ "$output" =~ ^[0-9]+$ ]]
	[[ "$output" -gt 1000000000 ]]
}

@test "epoch increases over time" {
	local e1 e2
	e1="$(epoch)"
	e2="$(epoch)"
	[[ "$e2" -ge "$e1" ]]
}
