#!/usr/bin/env bats
# Tests: Random utility

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "random_string generates string of default length" {
	local str
	str="$(random_string)"
	[[ "${#str}" -eq 16 ]]
}

@test "random_string generates string of specified length" {
	local str
	str="$(random_string 32)"
	[[ "${#str}" -eq 32 ]]
}

@test "random_string generates string of length 0" {
	local str
	str="$(random_string 0)"
	[[ "${#str}" -eq 0 ]]
}

@test "random_string contains only alphanumeric characters" {
	local str
	str="$(random_string 1000)"
	[[ "$str" =~ ^[A-Za-z0-9]+$ ]]
}

@test "random_string produces different values" {
	local s1 s2
	s1="$(random_string 32)"
	s2="$(random_string 32)"
	[[ "$s1" != "$s2" ]]
}

@test "random_string handles very long strings" {
	local str
	str="$(random_string 5000)"
	[[ "${#str}" -eq 5000 ]]
}
