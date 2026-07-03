#!/usr/bin/env bats
# Integration tests: Complete end-to-end scenarios

setup() {
	export TB_INT_CONFIGS_DIR
	TB_INT_CONFIGS_DIR="$(mktemp -d "/tmp/bats-int-configs.XXXXXX")"
	export CONFIGS_DIR="${TB_INT_CONFIGS_DIR}"
	export TB_INT_PACKAGES_DIR
	TB_INT_PACKAGES_DIR="$(mktemp -d "/tmp/bats-int-packages.XXXXXX")"
	export PACKAGES_DIR="${TB_INT_PACKAGES_DIR}"
	mkdir -p "${PACKAGES_DIR}/core" "${PACKAGES_DIR}/development" "${PACKAGES_DIR}/profiles"
	mkdir -p "${CONFIGS_DIR}/git" "${CONFIGS_DIR}/zsh"
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
	[[ -n "${TB_INT_CONFIGS_DIR:-}" && -d "${TB_INT_CONFIGS_DIR}" ]] && rm -rf "${TB_INT_CONFIGS_DIR}"
	[[ -n "${TB_INT_PACKAGES_DIR:-}" && -d "${TB_INT_PACKAGES_DIR}" ]] && rm -rf "${TB_INT_PACKAGES_DIR}"
}

@test "integration: load framework, list modules" {
	_create_module "core" "base"
	_create_module "development" "python"
	run module_list
	[[ "$status" -eq 0 ]]
	assert_output_contains "core/base"
	assert_output_contains "development/python"
}

@test "integration: load framework, list profiles" {
	_create_module "core" "base"
	_create_profile "minimal" "core base"
	run profile_list
	[[ "$status" -eq 0 ]]
	assert_output_contains "minimal"
}

@test "integration: install profile through installer" {
	_create_module "core" "base"
	_create_module "core" "editors"
	_create_profile "dev" "core base" "core editors"
	installer_install_profile "dev"
	profile_loaded "dev"
	[[ "$?" -eq 0 ]]
	module_loaded "core" "base"
	[[ "$?" -eq 0 ]]
	module_loaded "core" "editors"
	[[ "$?" -eq 0 ]]
}

@test "integration: dry-run does not install" {
	_create_module "core" "base"
	_create_profile "dry" "core base"
	installer_set_dry_run true
	installer_install_profile "dry"
	! profile_loaded "dry"
}

@test "integration: config merge and status" {
	cat > "${CONFIGS_DIR}/git/.gitconfig" <<'EOF'
[user]
	name = Test
EOF
	run config_merge "git" ".gitconfig" false
	[[ "$status" -eq 0 ]]
	assert_file_exists "${HOME}/.gitconfig"
	run config_status "git" ".gitconfig"
	[[ "$output" == "up_to_date" ]]
}

@test "integration: framework -> modules -> profiles -> config" {
	_create_module "core" "base"
	_create_module "core" "shell"
	_create_profile "full" "core base" "core shell"
	cat > "${CONFIGS_DIR}/git/.gitconfig" <<'EOF'
[user]
	name = Test
EOF

	# 1. Load profile
	installer_install_profile "full"

	# 2. Verify modules loaded
	module_loaded "core" "base"
	[[ "$?" -eq 0 ]]
	module_loaded "core" "shell"
	[[ "$?" -eq 0 ]]

	# 3. Config merge
	run config_merge_all false
	[[ "$status" -eq 0 ]]

	# 4. Config validation
	run config_validate_all
	[[ "$status" -eq 0 ]]

	# 5. Listing
	run module_list
	[[ "$status" -eq 0 ]]
}

@test "integration: dispatch commands through CLI" {
	_create_module "core" "base"
	_create_profile "test" "core base"

	# Test each command dispatches without error
	run dispatch help
	[[ "$status" -eq 0 ]]

	run dispatch version
	[[ "$status" -eq 0 ]]

	run dispatch config list
	[[ "$status" -eq 0 ]]
}

@test "integration: dependency resolution order" {
	_create_module "core" "base"
	_create_module "core" "utils"
	_create_module "development" "python"
	_create_module "development" "nodejs"

	# Set up nodejs to depend on python
	cat > "${PACKAGES_DIR}/development/nodejs.sh" <<'EOF'
#!/usr/bin/env bash
# Depends: development/python

install_development_nodejs() {
	return 0
}
EOF

	run resolve_module_deps "development" "nodejs"
	[[ "$status" -eq 0 ]]
	# Dependencies should include python
	assert_output_contains "development/python"
	# The module itself
	assert_output_contains "development/nodejs"
}

@test "integration: batch install with dedup" {
	_create_module "core" "base"
	_create_module "core" "utils"
	_create_module "development" "python"

	installer_install_batch "core/base" "core/utils" "development/python"

	module_loaded "core" "base"
	[[ "$?" -eq 0 ]]
	module_loaded "core" "utils"
	[[ "$?" -eq 0 ]]
	module_loaded "development" "python"
	[[ "$?" -eq 0 ]]
}
