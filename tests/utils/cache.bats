#!/usr/bin/env bats
# Tests: Cache utility functions

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "cache_initialize creates cache directory" {
	rm -rf "$CACHE_DIR"
	cache_initialize
	[[ -d "$CACHE_DIR" ]]
}

@test "cache_path returns correct path" {
	local path
	path="$(cache_path "mykey")"
	[[ "$path" == "${CACHE_DIR}/mykey.cache" ]]
}

@test "cache_set creates cache file" {
	cache_set "testkey" "testvalue"
	assert_file_exists "${CACHE_DIR}/testkey.cache"
}

@test "cache_get retrieves stored value" {
	cache_set "gettest" "stored_value"
	run cache_get "gettest"
	[[ "$output" == "stored_value" ]]
}

@test "cache_get fails for missing key" {
	run cache_get "nonexistent_key"
	[[ "$status" -eq 1 ]]
}

@test "cache_exists returns 0 for existing key" {
	cache_set "existstest" "value"
	cache_exists "existstest"
}

@test "cache_exists returns 1 for missing key" {
	! cache_exists "missing"
}

@test "cache_delete removes cache file" {
	cache_set "deletetest" "value"
	cache_delete "deletetest"
	assert_file_not_exists "${CACHE_DIR}/deletetest.cache"
}

@test "cache_clear removes all cache files" {
	cache_set "a" "1"
	cache_set "b" "2"
	cache_clear
	local count
	count="$(ls "${CACHE_DIR}"/*.cache 2>/dev/null | wc -l | tr -d ' ')"
	[[ "$count" -eq 0 ]]
}

@test "cache_size returns 0 for empty cache" {
	cache_clear 2>/dev/null || true
	run cache_size
	[[ "$output" == "0" ]]
}

@test "cache_age returns epoch for existing cache" {
	cache_set "agetest" "value"
	local age
	age="$(cache_age "agetest")"
	[[ "$age" =~ ^[0-9]+$ ]]
	[[ "$age" -gt 1000000000 ]]
}

@test "cache_age fails for missing key" {
	run cache_age "missing_age"
	[[ "$status" -eq 1 ]]
}

@test "cache_expired returns true for missing key" {
	cache_expired "missing" 3600
	[[ "$?" -eq 0 ]]
}

@test "cache_expired returns false for fresh cache" {
	cache_set "freshtest" "value"
	! cache_expired "freshtest" 3600
}

@test "cache_list lists all cached keys" {
	cache_clear 2>/dev/null || true
	cache_set "listkey1" "val1"
	cache_set "listkey2" "val2"
	local result
	result="$(cache_list | sort)"
	[[ "$result" == *"listkey1.cache"* ]]
	[[ "$result" == *"listkey2.cache"* ]]
}

@test "cache_set with multiple arguments" {
	cache_set "multikey" "arg1" "arg2" "arg3"
	run cache_get "multikey"
	[[ "$output" == "arg1 arg2 arg3" ]]
}

@test "cache_remember returns cached value without re-executing" {
	cache_set "remembertest" "cached_value"
	local result
	result="$(cache_remember "remembertest" 3600 echo "should not run")"
	[[ "$result" == "cached_value" ]]
}

@test "cache_remember executes callback on cache miss" {
	cache_delete "remember_miss" 2>/dev/null || true
	local result
	result="$(cache_remember "remember_miss" 3600 echo "fresh_value")"
	[[ "$result" == "fresh_value" ]]
}
