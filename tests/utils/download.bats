#!/usr/bin/env bats
# Tests: Download utilities

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "download requires output path" {
	run download "https://example.com/file"
	[[ "$status" -eq 1 ]]
}

@test "download calls curl with correct args" {
	local output="${TB_TMPDIR}/downloaded.txt"
	run download "https://example.com/file" "$output"
	[[ "$status" -eq 0 ]]
}

@test "download_quiet calls curl silently" {
	local output="${TB_TMPDIR}/quiet.txt"
	run download_quiet "https://example.com/file" "$output"
	[[ "$status" -eq 0 ]]
}

@test "download handles URL without scheme" {
	local output="${TB_TMPDIR}/noscheme.txt"
	run download "example.com/file" "$output"
	[[ "$status" -eq 0 ]]
}
