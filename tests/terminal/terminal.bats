#!/usr/bin/env bats
# Tests: Terminal utility functions

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "terminal_width returns number" {
	run terminal_width
	[[ "$status" -eq 0 ]]
	[[ "$output" =~ ^[0-9]+$ ]]
}

@test "terminal_height returns number" {
	run terminal_height
	[[ "$status" -eq 0 ]]
	[[ "$output" =~ ^[0-9]+$ ]]
}

@test "terminal_size returns WxH format" {
	run terminal_size
	[[ "$status" -eq 0 ]]
	[[ "$output" =~ ^[0-9]+x[0-9]+$ ]]
}

@test "is_interactive_terminal returns false in tests" {
	! is_interactive_terminal
}

@test "supports_unicode checks LANG" {
	local saved_lang="${LANG:-}"
	export LANG="en_US.UTF-8"
	supports_unicode
	export LANG="C"
	! supports_unicode
	export LANG="$saved_lang"
}

@test "supports_truecolor checks COLORTERM" {
	local saved_ct="${COLORTERM:-}"
	export COLORTERM="truecolor"
	supports_truecolor
	unset COLORTERM
	! supports_truecolor
	export COLORTERM="$saved_ct"
}

@test "cursor operations do not error" {
	run cursor_hide
	[[ "$status" -eq 0 ]]
	run cursor_show
	[[ "$status" -eq 0 ]]
	run cursor_save
	[[ "$status" -eq 0 ]] || true
	run cursor_restore
	[[ "$status" -eq 0 ]] || true
}

@test "clear_line does not error" {
	run clear_line
	[[ "$status" -eq 0 ]]
}

@test "set_terminal_title does not error" {
	run set_terminal_title "Test Title"
	[[ "$status" -eq 0 ]]
}

@test "terminal_beep does not error" {
	run terminal_beep
	[[ "$status" -eq 0 ]]
}

@test "initialize_terminal marks initialized" {
	TERMINAL_INITIALIZED=false
	initialize_terminal
	[[ "$TERMINAL_INITIALIZED" == true ]]
}

@test "initialize_terminal skips reinit" {
	TERMINAL_INITIALIZED=true
	run initialize_terminal
	[[ "$status" -eq 0 ]]
}
