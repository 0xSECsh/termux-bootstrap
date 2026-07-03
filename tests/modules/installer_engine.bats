#!/usr/bin/env bats
# Tests: Installer engine (dry-run, rollback, batch install)

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
	export PACKAGES_DIR="${TB_TMPDIR}/packages"
	mkdir -p "${PACKAGES_DIR}/core" "${PACKAGES_DIR}/development"
	mkdir -p "${PACKAGES_DIR}/profiles"
	installer_reset
}

teardown() {
	common_teardown
}

@test "installer_set_dry_run toggles mode" {
	installer_set_dry_run true
	installer_is_dry_run
	installer_set_dry_run false
	! installer_is_dry_run
}

@test "installer_is_dry_run returns false by default" {
	! installer_is_dry_run
}

@test "installer_install_module with dry-run does not execute" {
	_create_module "core" "base"
	installer_set_dry_run true
	run installer_install_module "core" "base"
	[[ "$status" -eq 0 ]]
	# Module should NOT be loaded (dry-run)
	! module_loaded "core" "base"
}

@test "installer_install_module installs module" {
	_create_module "core" "base"
	installer_install_module "core" "base"
	module_loaded "core" "base"
}

@test "installer_install_module skips already installed" {
	_create_module "core" "base"
	installer_install_module "core" "base"
	run installer_install_module "core" "base"
	[[ "$status" -eq 0 ]]
}

@test "installer_install_module fails for missing module" {
	run installer_install_module "core" "nonexistent"
	[[ "$status" -eq 1 ]]
}

@test "installer_install_module handles empty arguments" {
	run installer_install_module "" ""
	[[ "$status" -eq 1 ]]
}

@test "installer_install_profile installs profile" {
	_create_module "core" "base"
	_create_profile "simple" "core base"
	run installer_install_profile "simple"
	[[ "$status" -eq 0 ]]
}

@test "installer_install_profile skips already installed" {
	_create_module "core" "base"
	_create_profile "dup" "core base"
	installer_install_profile "dup"
	run installer_install_profile "dup"
	[[ "$status" -eq 0 ]]
}

@test "installer_install_profile with dry-run does nothing" {
	_create_module "core" "base"
	_create_profile "dry" "core base"
	installer_set_dry_run true
	run installer_install_profile "dry"
	[[ "$status" -eq 0 ]]
	! module_loaded "core" "base"
}

@test "installer_install_profile fails for missing profile" {
	run installer_install_profile "nonexistent"
	[[ "$status" -eq 1 ]]
}

@test "installer_install_batch installs multiple modules" {
	_create_module "core" "a"
	_create_module "core" "b"
	_create_module "development" "c"
	run installer_install_batch "core/a" "core/b" "development/c"
	[[ "$status" -eq 0 ]]
}

@test "installer_install_batch handles invalid module format" {
	run installer_install_batch "invalid_format"
	[[ "$status" -eq 1 ]]
}

@test "installer_install_batch with empty args fails" {
	run installer_install_batch
	[[ "$status" -eq 1 ]]
}

@test "installer_preview shows dry-run info" {
	_create_module "core" "base"
	installer_set_dry_run false
	run installer_preview "core/base"
	[[ "$status" -eq 0 ]]
}

@test "installer_is_dry_run_enabled matches set state" {
	installer_set_dry_run true
	installer_is_dry_run_enabled
	[[ "$?" -eq 0 ]]
}

@test "installer_rollback_stack_empty returns true initially" {
	installer_rollback_stack_empty
	[[ "$?" -eq 0 ]]
}

@test "installer_track_package tracks packages" {
	_installer_track_package "testpkg"
	_installer_is_package_tracked "testpkg"
	[[ "$?" -eq 0 ]]
}

@test "installer_installed_packages lists tracked" {
	_installer_track_package "pkg1"
	_installer_track_package "pkg2"
	local list
	list="$(installer_installed_packages | sort)"
	[[ "$list" == *"pkg1"* ]]
	[[ "$list" == *"pkg2"* ]]
}

@test "installer_installed_count returns count" {
	_installer_track_package "pkg1"
	_installer_track_package "pkg2"
	local count
	count="$(installer_installed_count)"
	[[ "$count" -eq 2 ]]
}

@test "installer_reset clears all state" {
	installer_set_dry_run true
	_installer_track_package "test"
	installer_reset
	! installer_is_dry_run
	local count
	count="$(installer_installed_count)"
	[[ "$count" -eq 0 ]]
}

@test "installer defaults have rollback enabled" {
	installer_rollback_stack_empty
	[[ "$?" -eq 0 ]]
}
