#!/usr/bin/env bats
# Tests: System information functions

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "get_os returns OS name" {
	run get_os
	[[ "$status" -eq 0 ]]
	[[ -n "$output" ]]
}

@test "get_kernel returns kernel version" {
	run get_kernel
	[[ "$status" -eq 0 ]]
	[[ -n "$output" ]]
}

@test "get_architecture returns architecture" {
	run get_architecture
	[[ "$status" -eq 0 ]]
	[[ -n "$output" ]]
}

@test "get_hostname returns hostname" {
	run get_hostname
	[[ "$status" -eq 0 ]]
	[[ -n "$output" ]]
}

@test "get_shell returns shell name" {
	run get_shell
	[[ "$status" -eq 0 ]]
	[[ -n "$output" ]]
}

@test "get_bash_version returns version" {
	run get_bash_version
	[[ "$status" -eq 0 ]]
	[[ -n "$output" ]]
}

@test "get_cpu_cores returns number of cores" {
	run get_cpu_cores
	[[ "$status" -eq 0 ]]
	[[ "$output" -gt 0 ]]
}

@test "get_storage_total returns storage info" {
	run get_storage_total
	[[ "$status" -eq 0 ]]
}

@test "get_storage_available returns available storage" {
	run get_storage_available
	[[ "$status" -eq 0 ]]
}

@test "system_detect sets environment variables" {
	unset SYSTEM_OS SYSTEM_KERNEL SYSTEM_ARCH
	system_detect
	[[ -n "$SYSTEM_OS" ]]
	[[ -n "$SYSTEM_KERNEL" ]]
	[[ -n "$SYSTEM_ARCH" ]]
}

@test "system_summary returns non-empty" {
	run system_summary
	[[ "$status" -eq 0 ]]
	[[ -n "$output" ]]
	assert_output_contains "$PROJECT_NAME"
}

@test "get_termux_version returns Unknown" {
	run get_termux_version
	# Since termux-info is mocked
	[[ "$status" -eq 0 ]]
}

@test "get_pkg_version handles missing pkg gracefully" {
	# pkg is mocked, so it should return version
	run get_pkg_version
	[[ "$status" -eq 0 ]]
}
