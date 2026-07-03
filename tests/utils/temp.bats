#!/usr/bin/env bats
# Tests: Temporary file/directory utilities

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "create_secure_temp_dir creates directory in TEMP_DIR" {
	local dir
	dir="$(create_secure_temp_dir)"
	[[ -d "$dir" ]]
	[[ "$dir" == "${TEMP_DIR}/"* ]]
	rm -rf "$dir"
}

@test "create_secure_temp_dir creates directory with custom prefix" {
	local dir
	dir="$(create_secure_temp_dir "myapp")"
	[[ -d "$dir" ]]
	[[ "$(basename "$dir")" == "myapp."* ]]
	rm -rf "$dir"
}

@test "create_secure_temp_file creates file in TEMP_DIR" {
	local file
	file="$(create_secure_temp_file)"
	[[ -f "$file" ]]
	[[ "$file" == "${TEMP_DIR}/"* ]]
	rm -f "$file"
}

@test "write_temp_file creates file with content" {
	local file
	file="$(write_temp_file "test content")"
	[[ -f "$file" ]]
	[[ "$(cat "$file")" == "test content" ]]
	rm -f "$file"
}

@test "read_temp_file reads file content" {
	local file
	file="$(write_temp_file "readable content")"
	run read_temp_file "$file"
	[[ "$output" == "readable content" ]]
	rm -f "$file"
}

@test "read_temp_file fails for missing file" {
	run read_temp_file "${TEMP_DIR}/nonexistent"
	[[ "$status" -eq 1 ]]
}

@test "atomic_write writes content atomically" {
	local target="${TB_TMPDIR}/atomic_target.txt"
	atomic_write "$target" "atomic content"
	[[ -f "$target" ]]
	[[ "$(cat "$target")" == "atomic content" ]]
}

@test "cleanup_temp_file removes file in TEMP_DIR" {
	local file
	file="$(create_secure_temp_file)"
	cleanup_temp_file "$file"
	[[ ! -f "$file" ]]
}

@test "cleanup_temp_file refuses to delete outside TEMP_DIR" {
	local outside="${TB_TMPDIR}/outside.txt"
	touch "$outside"
	run cleanup_temp_file "$outside"
	[[ "$status" -eq 1 ]]
	[[ -f "$outside" ]]
}

@test "cleanup_temp_dir removes directory in TEMP_DIR" {
	local dir
	dir="$(create_secure_temp_dir)"
	cleanup_temp_dir "$dir"
	[[ ! -d "$dir" ]]
}

@test "cleanup_temp_dir refuses to delete outside TEMP_DIR" {
	local outside="${TB_TMPDIR}/outside_dir"
	mkdir -p "$outside"
	run cleanup_temp_dir "$outside"
	[[ "$status" -eq 1 ]]
	[[ -d "$outside" ]]
}

@test "register_temp_cleanup adds to cleanup stack" {
	local file="${TEMP_DIR}/cleanup_test.txt"
	touch "$file"
	register_temp_cleanup "$file"
	[[ "${#TEMP_CLEANUP_STACK[@]}" -gt 0 ]]
}

@test "run_temp_cleanup cleans all registered paths" {
	local file="${TEMP_DIR}/stack_clean.txt"
	touch "$file"
	register_temp_cleanup "$file"
	run_temp_cleanup
	[[ ! -f "$file" ]]
	[[ "${#TEMP_CLEANUP_STACK[@]}" -eq 0 ]]
}

@test "with_temp_dir creates and cleans up directory" {
	with_temp_dir "test" "[[ -d \"\$1\" ]]"
	:
}

@test "with_temp_file creates and cleans up file" {
	with_temp_file "test" "content" "[[ -f \"\$1\" ]]"
	:
}

@test "secure_cleanup_temp blocks path traversal" {
	run secure_cleanup_temp "/etc/passwd"
	[[ "$status" -eq 1 ]]
}

@test "secure_cleanup_temp cleans files safely" {
	local file="${TEMP_DIR}/secure_clean.txt"
	touch "$file"
	run secure_cleanup_temp "$file"
	[[ "$status" -eq 0 ]]
	[[ ! -f "$file" ]]
}

@test "setup_temp_cleanup_trap sets up trap only once" {
	local saved_bats="${BATS_VERSION:-}"
	unset BATS_VERSION
	TEMP_CLEANUP_TRAP_SET=false
	setup_temp_cleanup_trap
	[[ "$TEMP_CLEANUP_TRAP_SET" == true ]]
	setup_temp_cleanup_trap
	[[ "$TEMP_CLEANUP_TRAP_SET" == true ]]
	export BATS_VERSION="$saved_bats"
}
