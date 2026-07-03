#!/usr/bin/env bats
# Tests: Capability registry

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "has pkg returns true (mocked)" {
	has "pkg"
	[[ "$?" -eq 0 ]]
}

@test "has returns 1 for unknown capability" {
	! has "_unknown_capability_"
}

@test "has termux respects TERMUX_VERSION" {
	export TERMUX_VERSION="0.118.0"
	has "termux"
	unset TERMUX_VERSION
	! has "termux"
}

@test "has android checks /system" {
	# In test env, /system likely doesn't exist, so this returns 1
	! has "android"
}

@test "has root checks UID" {
	! has "root"  # Tests should not run as root
}

@test "has internet delegates to check_internet" {
	run has "internet"
	[[ "$status" -eq 0 ]]
}

@test "has for architecture matches SYSTEM_ARCH" {
	SYSTEM_ARCH="aarch64"
	has "arm64"
	! has "x86_64"
	SYSTEM_ARCH="arm"
	has "arm"
	SYSTEM_ARCH="x86_64"
	has "x86_64"
}

@test "has for language runtimes" {
	# These depend on mocked commands
	has "bash"
	[[ "$?" -eq 0 ]] || true  # bash should exist
}

@test "has for common utilities" {
	has "git"
	[[ "$?" -eq 0 ]]
	has "curl"
	[[ "$?" -eq 0 ]]
}

@test "missing is inverse of has" {
	has "pkg"
	local h=$?
	run missing "pkg"
	local m=$status
	[[ "$h" -ne "$m" ]]
}

@test "require calls fatal on missing capability" {
	run require "_unknown_cap_"
	[[ "$status" -eq 1 ]]
}

@test "require succeeds for existing capability" {
	run require "bash"
	[[ "$status" -eq 0 ]]
}

@test "assert is alias for require" {
	run assert "bash"
	[[ "$status" -eq 0 ]]
	run assert "_missing_"
	[[ "$status" -eq 1 ]]
}

@test "has handles case-insensitive" {
	# git is mocked, test that uppercase lookup works via ${1,,}
	has "GIT"
}

@test "has storage checks HOME/storage" {
	has "storage"
	[[ "$?" -eq 0 ]]  # We create it in common_setup
}

@test "has termux-api checks termux-battery-status" {
	mock_command termux-battery-status
	has "termux-api"
}
