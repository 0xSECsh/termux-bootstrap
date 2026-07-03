#!/usr/bin/env bats
# Tests: Profile registry (discovery and metadata)

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
	export PACKAGES_DIR="${TB_TMPDIR}/packages"
	mkdir -p "${PACKAGES_DIR}/profiles"
}

teardown() {
	common_teardown
}

_create_stub_profile() {
	local name="$1" desc="$2"
	cat > "${PACKAGES_DIR}/profiles/${name}.sh" <<EOF
#!/usr/bin/env bash
# Description: ${desc}

install_profile_${name}() {
	:
}
EOF
}

@test "profile_list returns empty when no profiles exist" {
	run profile_list
	[[ "$status" -eq 0 ]] || [[ "$status" -eq 1 ]]
}

@test "profile_list returns discovered profiles" {
	_create_stub_profile "developer" "Dev tools"
	_create_stub_profile "minimal" "Minimal setup"
	run profile_list
	[[ "$status" -eq 0 ]]
	assert_output_contains "developer"
	assert_output_contains "minimal"
}

@test "profile_exists returns 0 for existing profile" {
	_create_stub_profile "developer" "Dev tools"
	profile_exists "developer"
	[[ "$?" -eq 0 ]]
}

@test "profile_exists returns 1 for missing profile" {
	! profile_exists "nonexistent"
}

@test "profile_exists handles empty argument" {
	! profile_exists ""
}

@test "profile_info returns metadata" {
	_create_stub_profile "testprof" "Test profile description"
	run profile_info "testprof"
	[[ "$status" -eq 0 ]]
	assert_output_contains "Profile:      testprof"
	assert_output_contains "Description:  Test profile description"
}

@test "profile_info fails for missing profile" {
	run profile_info "nonexistent"
	[[ "$status" -eq 1 ]]
}

@test "profile_count returns correct count" {
	_create_stub_profile "a" "A"
	_create_stub_profile "b" "B"
	local count
	count="$(profile_count)"
	[[ "$count" -eq 2 ]]
}

@test "profile_count returns 0 for empty directory" {
	local count
	count="$(profile_count)"
	[[ "$count" -eq 0 ]]
}

@test "profile_modules returns module list" {
	cat > "${PACKAGES_DIR}/profiles/complex.sh" <<'EOF'
#!/usr/bin/env bash
# Description: Complex profile

install_profile_complex() {
	load_module core base
	load_module core shell
	load_module development python
}
EOF
	run profile_modules "complex"
	[[ "$status" -eq 0 ]]
	assert_output_contains "core base"
	assert_output_contains "core shell"
	assert_output_contains "development python"
}

@test "profile_modules returns empty for no modules" {
	_create_stub_profile "empty" "Empty profile"
	run profile_modules "empty"
	[[ -z "$output" ]]
}
