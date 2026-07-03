#!/usr/bin/env bats
# Tests: Colors and terminal formatting

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "print outputs string" {
	run print "Hello World"
	[[ "$status" -eq 0 ]]
	[[ "$output" == "Hello World" ]]
}

@test "colorize applies color codes" {
	run colorize "$GREEN" "Green text"
	[[ "$status" -eq 0 ]]
	# Should contain the text
	assert_output_contains "Green text"
}

@test "colorize works without color support" {
	run colorize "Plain text"
	[[ "$status" -eq 0 ]]
	assert_output_contains "Plain text"
}

@test "title prints formatted title" {
	run title "Section Title"
	[[ "$status" -eq 0 ]]
	assert_output_contains "Section Title"
}

@test "subtitle prints bold text" {
	run subtitle "Bold subtitle"
	[[ "$status" -eq 0 ]]
	assert_output_contains "Bold subtitle"
}

@test "separator prints line" {
	run separator
	[[ "$status" -eq 0 ]]
}

@test "newline prints blank line" {
	run newline
	[[ "$status" -eq 0 ]]
}

@test "color constants are defined" {
	# Color constants may be empty when terminal doesn't support colors
	# Just verify they are declared (not unbound)
	[[ -v RESET ]]
	[[ -v RED ]]
	[[ -v GREEN ]]
	[[ -v YELLOW ]]
	[[ -v BLUE ]]
	[[ -v MAGENTA ]]
	[[ -v CYAN ]]
	[[ -v BOLD ]]
}

@test "COLOR_SUPPORT is a boolean" {
	[[ "$COLOR_SUPPORT" == true ]] || [[ "$COLOR_SUPPORT" == false ]]
}
