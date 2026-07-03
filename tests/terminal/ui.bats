#!/usr/bin/env bats
# Tests: UI components

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "ui_box creates a box around message" {
	run ui_box "Hello"
	[[ "$status" -eq 0 ]]
	assert_output_contains "Hello"
}

@test "ui_section prints section header" {
	run ui_section "Test Section"
	[[ "$status" -eq 0 ]]
	assert_output_contains "Test Section"
}

@test "ui_success prints colored success" {
	run ui_success "Task completed"
	[[ "$status" -eq 0 ]]
}

@test "ui_warning prints colored warning" {
	run ui_warning "Be careful"
	[[ "$status" -eq 0 ]]
}

@test "ui_error prints colored error" {
	run ui_error "Something broke"
	[[ "$status" -eq 0 ]]
}

@test "ui_info prints colored info" {
	run ui_info "FYI"
	[[ "$status" -eq 0 ]]
}

@test "ui_key_value prints formatted pair" {
	run ui_key_value "Name" "Value"
	[[ "$status" -eq 0 ]]
	assert_output_contains "Name"
	assert_output_contains "Value"
}

@test "ui_bullet prints bullet point" {
	run ui_bullet "Item"
	[[ "$status" -eq 0 ]]
	assert_output_contains "Item"
}

@test "ui_numbered prints numbered item" {
	run ui_numbered 1 "First"
	[[ "$status" -eq 0 ]]
	assert_output_contains "1."
	assert_output_contains "First"
}

@test "ui_separator prints separator line" {
	run ui_separator
	[[ "$status" -eq 0 ]]
}

@test "ui_banner shows project banner" {
	run ui_banner
	[[ "$status" -eq 0 ]]
}

@test "ui_summary prints title with bullets" {
	run ui_summary "Summary" "Item1" "Item2"
	[[ "$status" -eq 0 ]]
	assert_output_contains "Summary"
	assert_output_contains "Item1"
}

@test "ui_menu prints menu options" {
	run ui_menu "Options" "A" "B" "C"
	[[ "$status" -eq 0 ]]
	assert_output_contains "Options"
	assert_output_contains "1)"
	assert_output_contains "2)"
	assert_output_contains "3)"
}

@test "ui_pause shows press enter prompt" {
	run ui_pause <<< ""
	[[ "$status" -eq 0 ]]
}
