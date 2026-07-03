#!/usr/bin/env bats
# Tests: Filesystem utility functions

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "create_directory creates a directory" {
	local dir="${TB_TMPDIR}/testdir"
	create_directory "$dir"
	[[ -d "$dir" ]]
}

@test "create_directory handles existing directory" {
	local dir="${TB_TMPDIR}/existing"
	mkdir -p "$dir"
	run create_directory "$dir"
	[[ "$status" -eq 0 ]]
	[[ -d "$dir" ]]
}

@test "create_directory creates nested directories" {
	local dir="${TB_TMPDIR}/a/b/c/d"
	create_directory "$dir"
	[[ -d "$dir" ]]
}

@test "remove_directory removes a directory" {
	local dir="${TB_TMPDIR}/toremove"
	mkdir -p "$dir"
	remove_directory "$dir"
	[[ ! -d "$dir" ]]
}

@test "remove_directory refuses to remove root" {
	run remove_directory "/"
	[[ "$status" -eq 1 ]]
}

@test "remove_directory refuses to remove empty string" {
	run remove_directory ""
	[[ "$status" -eq 1 ]]
}

@test "create_file creates a file with parent directories" {
	local file="${TB_TMPDIR}/nested/dir/testfile.txt"
	create_file "$file"
	[[ -f "$file" ]]
}

@test "create_file creates parent directories" {
	local file="${TB_TMPDIR}/newparent/test.txt"
	create_file "$file"
	[[ -d "$(dirname "$file")" ]]
}

@test "copy_file copies a file" {
	local src="${TB_TMPDIR}/source.txt"
	local dst="${TB_TMPDIR}/dest.txt"
	echo "hello" > "$src"
	copy_file "$src" "$dst"
	[[ -f "$dst" ]]
	[[ "$(cat "$dst")" == "hello" ]]
}

@test "move_file moves a file" {
	local src="${TB_TMPDIR}/move_src.txt"
	local dst="${TB_TMPDIR}/move_dst.txt"
	echo "moveme" > "$src"
	move_file "$src" "$dst"
	[[ ! -f "$src" ]]
	[[ -f "$dst" ]]
	[[ "$(cat "$dst")" == "moveme" ]]
}

@test "backup_file creates backup with .bak extension" {
	local file="${TB_TMPDIR}/config.txt"
	echo "original" > "$file"
	backup_file "$file"
	[[ -f "${file}.bak" ]]
	[[ "$(cat "${file}.bak")" == "original" ]]
}

@test "backup_file does nothing for missing file" {
	local file="${TB_TMPDIR}/nonexistent.txt"
	run backup_file "$file"
	[[ "$status" -eq 0 ]]
	[[ ! -f "${file}.bak" ]]
}

@test "file_size returns file size in bytes" {
	local file="${TB_TMPDIR}/size_test.txt"
	printf "12345" > "$file"
	local size
	size="$(file_size "$file")"
	[[ "$size" -gt 0 ]]
}

@test "file_size handles empty file" {
	local file="${TB_TMPDIR}/empty.txt"
	touch "$file"
	local size
	size="$(file_size "$file")"
	[[ "$size" -eq 12345 ]]
}

@test "directory_size returns size (non-empty)" {
	local dir="${TB_TMPDIR}/dirtest"
	mkdir -p "$dir"
	echo "data" > "${dir}/file.txt"
	run directory_size "$dir"
	[[ "$status" -eq 0 ]]
}
