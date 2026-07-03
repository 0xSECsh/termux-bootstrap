#!/usr/bin/env bats
# Tests: Profile loader (loading, state tracking, duplicate prevention)

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
	export PACKAGES_DIR="${TB_TMPDIR}/packages"
	mkdir -p "${PACKAGES_DIR}/profiles"
	mkdir -p "${PACKAGES_DIR}/core"
}

teardown() {
	common_teardown
}

@test "load_profile loads a profile successfully" {
	_create_module "core" "base"
	_create_profile "testp" "core base"
	run load_profile "testp"
	[[ "$status" -eq 0 ]]
}

@test "load_profile marks profile as loaded" {
	_create_module "core" "base"
	_create_profile "simple" "core base"
	load_profile "simple"
	profile_loaded "simple"
	[[ "$?" -eq 0 ]]
}

@test "load_profile prevents double loading" {
	_create_module "core" "base"
	_create_profile "dup" "core base"
	load_profile "dup"
	run load_profile "dup"
	[[ "$status" -eq 0 ]]
}

@test "load_profile fails for missing profile" {
	run load_profile "nonexistent"
	[[ "$status" -eq 1 ]]
}

@test "load_profile handles empty argument" {
	run load_profile ""
	[[ "$status" -eq 1 ]]
}

@test "profile_loaded returns 0 for loaded profile" {
	_create_module "core" "base"
	_create_profile "check" "core base"
	load_profile "check"
	profile_loaded "check"
	[[ "$?" -eq 0 ]]
}

@test "profile_loaded returns 1 for unloaded profile" {
	! profile_loaded "unloaded"
}

@test "profile_loaded handles empty argument" {
	! profile_loaded ""
}

@test "profile_sourced tracks source state" {
	_create_module "core" "base"
	_create_profile "src" "core base"
	! profile_sourced "src"
	load_profile "src"
	profile_sourced "src"
}

@test "profile_ran tracks execution state" {
	_create_module "core" "base"
	_create_profile "exec" "core base"
	! profile_ran "exec"
	load_profile "exec"
	profile_ran "exec"
}

@test "profile_loaded_list returns loaded profiles" {
	_create_module "core" "base"
	_create_profile "first" "core base"
	_create_profile "second" "core base"
	load_profile "first"
	load_profile "second"
	local list
	list="$(profile_loaded_list | sort)"
	[[ "$list" == *"first"* ]]
	[[ "$list" == *"second"* ]]
}

@test "profile_loaded_count returns count" {
	_create_module "core" "base"
	_create_profile "a" "core base"
	_create_profile "b" "core base"
	load_profile "a"
	load_profile "b"
	local count
	count="$(profile_loaded_count)"
	[[ "$count" -eq 2 ]]
}

@test "profile_loaded_count returns 0 initially" {
	local count
	count="$(profile_loaded_count)"
	[[ "$count" -eq 0 ]]
}

@test "load_profile with no install function does not fail" {
	cat > "${PACKAGES_DIR}/profiles/noop.sh" <<'EOF'
#!/usr/bin/env bash
# Description: No function profile
EOF
	run load_profile "noop"
	[[ "$status" -eq 0 ]]
}
