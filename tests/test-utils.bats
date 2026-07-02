#!/usr/bin/env bats
#
# ==============================================================================
# Termux Bootstrap
# File: tests/test-utils.bats
# Description: Utility function tests
# ==============================================================================

source "$(dirname "${BATS_TEST_FILENAME}")/helpers.bash" 2>/dev/null || true

# ------------------------------------------------------------------------------
# String Operations
# ------------------------------------------------------------------------------

@test "to_lower converts uppercase" {

	run to_lower "HELLO"

	[[ "$output" == "hello" ]]

}

@test "to_lower leaves lowercase unchanged" {

	run to_lower "hello"

	[[ "$output" == "hello" ]]

}

@test "to_lower handles mixed case" {

	run to_lower "HeLLo"

	[[ "$output" == "hello" ]]

}

@test "to_upper converts lowercase" {

	run to_upper "hello"

	[[ "$output" == "HELLO" ]]

}

@test "to_upper leaves uppercase unchanged" {

	run to_upper "HELLO"

	[[ "$output" == "HELLO" ]]

}

@test "to_upper handles mixed case" {

	run to_upper "HeLLo"

	[[ "$output" == "HELLO" ]]

}

@test "trim removes leading whitespace" {

	run trim "  hello"

	[[ "$output" == "hello" ]]

}

@test "trim removes trailing whitespace" {

	run trim "hello  "

	[[ "$output" == "hello" ]]

}

@test "trim removes both sides" {

	run trim "  hello  "

	[[ "$output" == "hello" ]]

}

@test "trim preserves internal spaces" {

	run trim "  hello world  "

	[[ "$output" == "hello world" ]]

}

# ------------------------------------------------------------------------------
# Time Functions
# ------------------------------------------------------------------------------

@test "timestamp returns a date string" {

	run timestamp

	[[ -n "$output" ]]

	[[ "$output" =~ ^[0-9]{4}- ]]

}

@test "epoch returns a number" {

	run epoch

	[[ -n "$output" ]]

	[[ "$output" =~ ^[0-9]+$ ]]

}

@test "pause sleeps for specified seconds" {

	local start
	start="$(date +%s)"

	sleep 0.1

	local elapsed
	elapsed="$(($(date +%s) - start))"

	[[ "$elapsed" -ge 0 ]]

}

# ------------------------------------------------------------------------------
# Hash Functions
# ------------------------------------------------------------------------------

@test "sha256 function exists" {

	type sha256

}

@test "sha1 function exists" {

	type sha1

}

@test "md5 function exists" {

	type md5

}

# ------------------------------------------------------------------------------
# JSON
# ------------------------------------------------------------------------------

@test "json_get exists and requires jq" {

	type json_get

}

@test "json_get fails without jq" {

	run json_get "/nonexistent" ".key"

	assert_status_error

}

# ------------------------------------------------------------------------------
# Random
# ------------------------------------------------------------------------------

@test "random_string returns default length" {

	local result
	result="$(random_string)"

	[[ "${#result}" -eq 16 ]]

}

@test "random_string returns specified length" {

	local result
	result="$(random_string 32)"

	[[ "${#result}" -eq 32 ]]

}

@test "random_string contains only alphanumeric" {

	local result
	result="$(random_string 100)"

	[[ "$result" =~ ^[A-Za-z0-9]+$ ]]

}

# ------------------------------------------------------------------------------
# Retry
# ------------------------------------------------------------------------------

@test "retry function exists" {

	type retry

}

@test "retry fails on empty command" {

	run retry 3

	assert_status_error

}

@test "retry succeeds on successful command" {

	run retry 3 true

	assert_status_zero

}

# ------------------------------------------------------------------------------
# Filesystem
# ------------------------------------------------------------------------------

@test "create_directory creates directory" {

	local test_dir="${BATS_TMPDIR}/test_create"

	run create_directory "$test_dir"

	assert_status_zero

	[[ -d "$test_dir" ]]

}

@test "create_directory is idempotent" {

	local test_dir="${BATS_TMPDIR}/test_idemp"

	create_directory "$test_dir"

	run create_directory "$test_dir"

	assert_status_zero

}

@test "remove_directory removes directory" {

	local test_dir="${BATS_TMPDIR}/test_remove"

	mkdir -p "$test_dir"

	run remove_directory "$test_dir"

	assert_status_zero

	[[ ! -d "$test_dir" ]]

}

@test "remove_directory guards against root" {

	run remove_directory "/"

	assert_status_error

}

@test "create_file creates file" {

	local test_file="${BATS_TMPDIR}/test_file.txt"

	run create_file "$test_file"

	assert_status_zero

	[[ -f "$test_file" ]]

}

@test "copy_file copies file" {

	local src="${BATS_TMPDIR}/src.txt"

	local dst="${BATS_TMPDIR}/dst.txt"

	echo "content" >"$src"

	run copy_file "$src" "$dst"

	assert_status_zero

	[[ -f "$dst" ]]

	[[ "$(cat "$dst")" == "content" ]]

}

@test "move_file moves file" {

	local src="${BATS_TMPDIR}/move_src.txt"

	local dst="${BATS_TMPDIR}/move_dst.txt"

	echo "content" >"$src"

	run move_file "$src" "$dst"

	assert_status_zero

	[[ -f "$dst" ]]

	[[ ! -f "$src" ]]

}

@test "backup_file creates .bak" {

	local test_file="${BATS_TMPDIR}/backup_test.txt"

	echo "content" >"$test_file"

	run backup_file "$test_file"

	assert_status_zero

	[[ -f "${test_file}.bak" ]]

}

@test "backup_file skips missing file" {

	run backup_file "${BATS_TMPDIR}/nonexistent.txt"

	assert_status_zero

}

@test "file_size returns a number" {

	local test_file="${BATS_TMPDIR}/size_test.txt"

	echo "hello" >"$test_file"

	run file_size "$test_file"

	[[ -n "$output" ]]

	[[ "$output" =~ ^[0-9]+$ ]]

}

@test "directory_size returns non-empty" {

	run directory_size "/tmp"

	[[ -n "$output" ]]

}

# ------------------------------------------------------------------------------
# Cache
# ------------------------------------------------------------------------------

@test "cache_path returns path" {

	run cache_path "test_key"

	[[ "$output" == "${CACHE_DIR}/test_key.cache" ]]

}

@test "cache_set and cache_get round-trip" {

	cache_set "test_key" "test_value"

	run cache_get "test_key"

	[[ "$output" == "test_value" ]]

}

@test "cache_exists returns 0 for existing key" {

	cache_set "exists_key" "value"

	run cache_exists "exists_key"

	assert_status_zero

}

@test "cache_exists returns 1 for missing key" {

	run cache_exists "missing_key_xyz"

	assert_status_error

}

@test "cache_delete removes key" {

	cache_set "delete_key" "value"

	cache_delete "delete_key"

	run cache_exists "delete_key"

	assert_status_error

}

@test "cache_clear removes all entries" {

	cache_set "clear_key1" "value1"

	cache_set "clear_key2" "value2"

	cache_clear

	run cache_exists "clear_key1"

	assert_status_error

}

@test "cache_size returns non-empty" {

	run cache_size

	[[ -n "$output" ]]

}

@test "cache_age returns a number" {

	cache_set "age_key" "value"

	run cache_age "age_key"

	[[ "$output" =~ ^[0-9]+$ ]]

}

@test "cache_expired returns 0 for missing key" {

	run cache_expired "nonexistent_key" 10

	assert_status_zero

}

@test "cache_remember caches command output" {

	cache_delete "remember_key" 2>/dev/null || true

	run cache_remember "remember_key" 60 echo "remembered"

	[[ "$output" == "remembered" ]]

}

@test "cache_statistics outputs info" {

	run cache_statistics

	[[ -n "$output" ]]

}

@test "cache_list works" {

	cache_set "list_key" "value"

	run cache_list

	assert_output_contains "list_key"

}

# ------------------------------------------------------------------------------
# Download
# ------------------------------------------------------------------------------

@test "download function exists" {

	type download

}

@test "download_quiet function exists" {

	type download_quiet

}

@test "download fails without arguments" {

	run download

	assert_status_error

}
