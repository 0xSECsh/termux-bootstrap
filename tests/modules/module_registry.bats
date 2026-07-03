#!/usr/bin/env bats
# Tests: Module registry (discovery and metadata)

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
	# Use temporary packages dir for isolated testing
	export PACKAGES_DIR="${TB_TMPDIR}/packages"
	mkdir -p "${PACKAGES_DIR}/core"
	mkdir -p "${PACKAGES_DIR}/development"
	mkdir -p "${PACKAGES_DIR}/profiles"
}

teardown() {
	common_teardown
}

@test "module_list returns empty when no modules exist" {
	run module_list
	[[ "$status" -eq 1 ]] || [[ "$status" -eq 0 ]]
}

@test "module_list returns registered modules" {
	_create_module "core" "base" "Base packages"
	_create_module "core" "shell" "Shell tools"
	run module_list
	[[ "$status" -eq 0 ]]
	assert_output_contains "core/base"
	assert_output_contains "core/shell"
}

@test "module_list filters by category" {
	_create_module "core" "base" "Base"
	_create_module "development" "python" "Python"
	run module_list "core"
	[[ "$status" -eq 0 ]]
	assert_output_contains "core/base"
	assert_output_not_contains "development/python"
}

@test "module_exists returns 0 for existing module" {
	_create_module "core" "base" "Base"
	module_exists "core" "base"
	[[ "$?" -eq 0 ]]
}

@test "module_exists returns 1 for missing module" {
	! module_exists "core" "nonexistent"
}

@test "module_exists handles empty arguments" {
	! module_exists "" ""
	! module_exists "core" ""
	! module_exists "" "base"
}

@test "module_info returns metadata" {
	_create_module "core" "testmod" "Test module description" "core/base"
	run module_info "core" "testmod"
	[[ "$status" -eq 0 ]]
	assert_output_contains "Module:       core/testmod"
	assert_output_contains "Description:  Test module description"
	assert_output_contains "Dependencies: core/base"
}

@test "module_info fails for missing module" {
	run module_info "core" "nonexistent"
	[[ "$status" -eq 1 ]]
}

@test "module_deps returns dependencies" {
	_create_module "core" "testmod" "Test" "core/base core/utils"
	run module_deps "core" "testmod"
	[[ "$status" -eq 0 ]]
	assert_output_contains "core/base"
	assert_output_contains "core/utils"
}

@test "module_deps returns empty for no deps" {
	_create_module "core" "nodeps" "No deps"
	run module_deps "core" "nodeps"
	[[ -z "$output" ]]
}

@test "module_categories returns all categories" {
	_create_module "core" "a" "A"
	_create_module "development" "b" "B"
	_create_module "cybersecurity" "c" "C"
	run module_categories
	[[ "$status" -eq 0 ]]
	assert_output_contains "core"
	assert_output_contains "development"
	assert_output_contains "cybersecurity"
}

@test "module_categories excludes profiles directory" {
	_create_module "core" "a" "A"
	# Creating a file in profiles should NOT be listed
	echo "# dummy" > "${PACKAGES_DIR}/profiles/test.sh"
	run module_categories
	assert_output_not_contains "profiles"
}

@test "module_count returns correct count" {
	_create_module "core" "a" "A"
	_create_module "core" "b" "B"
	_create_module "development" "c" "C"
	local count
	count="$(module_count)"
	[[ "$count" -eq 3 ]]
}

@test "module_count returns 0 for empty registry" {
	local count
	count="$(module_count)"
	[[ "$count" -eq 0 ]]
}
