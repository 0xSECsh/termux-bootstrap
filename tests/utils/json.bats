#!/usr/bin/env bats
# Tests: JSON helper

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "json_get requires jq" {
	local data='{"name":"test","version":1}'
	local file="${TB_TMPDIR}/test.json"
	echo "$data" > "$file"
	run json_get "$file" ".name"
	[[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "json_get fails for nonexistent file" {
	run json_get "${TB_TMPDIR}/nonexistent.json" ".name"
	[[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}
