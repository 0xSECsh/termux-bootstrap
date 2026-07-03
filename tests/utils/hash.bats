#!/usr/bin/env bats
# Tests: Hash utility functions

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "sha256 produces consistent output" {
	local file="${TB_TMPDIR}/hash_input.txt"
	echo "test data" > "$file"
	local h1 h2
	h1="$(sha256 "$file")"
	h2="$(sha256 "$file")"
	[[ -n "$h1" ]]
	[[ "$h1" == "$h2" ]]
}

@test "sha256 produces 64-character hex string" {
	local file="${TB_TMPDIR}/hash_len.txt"
	echo "length test" > "$file"
	local hash
	hash="$(sha256 "$file")"
	[[ "${#hash}" -eq 64 ]]
	[[ "$hash" =~ ^[a-f0-9]+$ ]]
}

@test "sha256 differs for different files" {
	local f1="${TB_TMPDIR}/hash_a.txt"
	local f2="${TB_TMPDIR}/hash_b.txt"
	echo "content A" > "$f1"
	echo "content B" > "$f2"
	local h1 h2
	h1="$(sha256 "$f1")"
	h2="$(sha256 "$f2")"
	[[ "$h1" != "$h2" ]]
}

@test "sha1 produces consistent output" {
	local file="${TB_TMPDIR}/sha1_input.txt"
	echo "sha1 test" > "$file"
	local h1 h2
	h1="$(sha1 "$file")"
	h2="$(sha1 "$file")"
	[[ -n "$h1" ]]
	[[ "$h1" == "$h2" ]]
}

@test "sha1 produces 40-character hex string" {
	local file="${TB_TMPDIR}/sha1_len.txt"
	echo "sha1 length" > "$file"
	local hash
	hash="$(sha1 "$file")"
	[[ "${#hash}" -eq 40 ]]
	[[ "$hash" =~ ^[a-f0-9]+$ ]]
}

@test "md5 produces consistent output" {
	local file="${TB_TMPDIR}/md5_input.txt"
	echo "md5 test" > "$file"
	local h1 h2
	h1="$(md5 "$file")"
	h2="$(md5 "$file")"
	[[ -n "$h1" ]]
	[[ "$h1" == "$h2" ]]
}

@test "md5 produces 32-character hex string" {
	local file="${TB_TMPDIR}/md5_len.txt"
	echo "md5 length" > "$file"
	local hash
	hash="$(md5 "$file")"
	[[ "${#hash}" -eq 32 ]]
	[[ "$hash" =~ ^[a-f0-9]+$ ]]
}

@test "hash functions handle empty files" {
	local file="${TB_TMPDIR}/empty_hash.txt"
	touch "$file"
	local h
	h="$(sha256 "$file")"
	[[ -n "$h" ]]
	[[ "${#h}" -eq 64 ]]
}
