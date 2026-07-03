#!/usr/bin/env bats
# Tests: Module loader (dynamic loading, dependencies, state tracking)

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
	export PACKAGES_DIR="${TB_TMPDIR}/packages"
	mkdir -p "${PACKAGES_DIR}/core" "${PACKAGES_DIR}/profiles"
}

teardown() {
	common_teardown
}

@test "load_module loads a module successfully" {
	_create_module "core" "base" "Base packages"
	run load_module "core" "base"
	[[ "$status" -eq 0 ]]
}

@test "load_module marks module as loaded" {
	_create_module "core" "base" "Base"
	load_module "core" "base"
	module_loaded "core" "base"
	[[ "$?" -eq 0 ]]
}

@test "load_module prevents double loading" {
	_create_module "core" "base" "Base"
	load_module "core" "base"
	run load_module "core" "base"
	[[ "$status" -eq 0 ]]
}

@test "load_module fails for missing module" {
	run load_module "core" "nonexistent"
	[[ "$status -eq 1" ]]
}

@test "load_module handles empty arguments" {
	run load_module "" ""
	[[ "$status" -eq 1 ]]
	run load_module "core" ""
	[[ "$status" -eq 1 ]]
}

@test "require_module loads dependencies before module" {
	_create_module "core" "base" "Base"
	_create_module "core" "shell" "Shell" "core/base"
	require_module "core" "shell"
	[[ "$?" -eq 0 ]]
	module_loaded "core" "base"
	[[ "$?" -eq 0 ]]
}

@test "require_module fails when strict and dependency missing" {
	_create_module "core" "main" "Main" "core/missing_dep"
	run require_module "core" "main" true
	[[ "$status" -eq 1 ]]
}

@test "require_module warns on optional dependency failure" {
	_create_module "core" "main" "Main" "core/missing_dep"
	run require_module "core" "main" false
	# Should succeed despite missing optional dep (logs a warning)
	[[ "$status" -eq 0 ]]
}

@test "module_loaded returns 0 for loaded module" {
	_create_module "core" "base" "Base"
	load_module "core" "base"
	module_loaded "core" "base"
	[[ "$?" -eq 0 ]]
}

@test "module_loaded returns 1 for unloaded module" {
	! module_loaded "core" "base"
}

@test "module_loaded returns 1 for empty args" {
	! module_loaded "" ""
}

@test "module_sourced returns correct state" {
	_create_module "core" "base" "Base"
	! module_sourced "core" "base"
	load_module "core" "base"
	module_sourced "core" "base"
}

@test "module_ran returns correct state" {
	_create_module "core" "base" "Base"
	! module_ran "core" "base"
	load_module "core" "base"
	module_ran "core" "base"
}

@test "module_loaded_list returns loaded modules" {
	_create_module "core" "base" "Base"
	_create_module "development" "python" "Python"
	load_module "core" "base"
	load_module "development" "python"
	local list
	list="$(module_loaded_list | sort)"
	[[ "$list" == *"core/base"* ]]
	[[ "$list" == *"development/python"* ]]
}

@test "module_loaded_count returns count" {
	_create_module "core" "a" "A"
	_create_module "core" "b" "B"
	load_module "core" "a"
	load_module "core" "b"
	local count
	count="$(module_loaded_count)"
	[[ "$count" -eq 2 ]]
}

@test "module_loaded_count returns 0 initially" {
	local count
	count="$(module_loaded_count)"
	[[ "$count" -eq 0 ]]
}

@test "resolve_module_deps resolves dependencies" {
	_create_module "core" "base" "Base"
	_create_module "core" "shell" "Shell" "core/base"
	run resolve_module_deps "core" "shell"
	[[ "$status" -eq 0 ]]
	assert_output_contains "core/base"
	assert_output_contains "core/shell"
}

@test "resolve_module_deps handles circular references" {
	_create_module "core" "a" "A" "core/b"
	_create_module "core" "b" "B" "core/a"
	run resolve_module_deps "core" "a"
	[[ "$status" -eq 0 ]]
}

@test "resolve_module_deps handles empty args" {
	run resolve_module_deps "" ""
	[[ "$status" -eq 1 ]]
}
