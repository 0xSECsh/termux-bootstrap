#!/usr/bin/env bats
# Tests: Library loader (load_library from common.sh)

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "load_library loads a file successfully" {
	local lib="${TB_TMPDIR}/testlib.sh"
	echo "TEST_LIB_LOADED=true" > "$lib"
	load_library "$lib"
	[[ "$TEST_LIB_LOADED" == true ]]
}

@test "load_library prevents double loading" {
	local lib="${TB_TMPDIR}/doubletest.sh"
	echo "DOUBLE_COUNT=\$((DOUBLE_COUNT+1))" > "$lib"
	export DOUBLE_COUNT=0
	load_library "$lib"
	load_library "$lib"
	[[ "$DOUBLE_COUNT" -eq 1 ]]
}

@test "load_library handles missing file gracefully" {
	run load_library "/tmp/does_not_exist_abc123.sh"
	[[ "$status" -ne 0 ]]
}

@test "LOADED_LIBRARIES tracks all loaded files" {
	[[ "${#LOADED_LIBRARIES[@]}" -gt 0 ]]
}
