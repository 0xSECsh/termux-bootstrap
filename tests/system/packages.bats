#!/usr/bin/env bats
# Tests: Package manager abstraction layer

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "pkg_install calls pkg install" {
	run pkg_install "testpkg"
	[[ "$status" -eq 0 ]]
}

@test "pkg_remove calls pkg uninstall" {
	run pkg_remove "testpkg"
	[[ "$status" -eq 0 ]]
}

@test "pkg_install_many installs packages" {
	run pkg_install_many "pkg1" "pkg2" "pkg3"
	[[ "$status" -eq 0 ]]
}

@test "pkg_update calls pkg update" {
	run pkg_update
	[[ "$status" -eq 0 ]]
}

@test "pkg_upgrade calls pkg upgrade" {
	run pkg_upgrade
	[[ "$status" -eq 0 ]]
}

@test "pkg_reinstall removes then installs" {
	run pkg_reinstall "testpkg"
	[[ "$status" -eq 0 ]]
}

@test "pkg_search calls pkg search" {
	run pkg_search "testpkg"
	[[ "$status" -eq 0 ]]
}

@test "pkg_list calls pkg list-installed" {
	run pkg_list
	[[ "$status" -eq 0 ]]
}

@test "pkg_autoremove calls pkg autoremove" {
	run pkg_autoremove
	[[ "$status" -eq 0 ]]
}

@test "pkg_clean calls pkg autoclean" {
	run pkg_clean
	[[ "$status" -eq 0 ]]
}

@test "pip_install calls pip" {
	run pip_install "requests"
	[[ "$status" -eq 0 ]]
}

@test "pip_upgrade calls pip upgrade" {
	run pip_upgrade "requests"
	[[ "$status" -eq 0 ]]
}

@test "npm_install calls npm" {
	run npm_install "express"
	[[ "$status" -eq 0 ]]
}

@test "npm_update calls npm update" {
	run npm_update
	[[ "$status" -eq 0 ]]
}

@test "cargo_install calls cargo" {
	run cargo_install "bat"
	[[ "$status" -eq 0 ]]
}

@test "cargo_update calls cargo install-update" {
	run cargo_update
	[[ "$status" -eq 0 ]]
}

@test "go_install calls go" {
	run go_install "github.com/tool"
	[[ "$status" -eq 0 ]]
}

@test "install_if_missing checks before installing" {
	local cmd="${TB_TMPDIR}/mytestcmd"
	touch "$cmd"
	chmod +x "$cmd"
	export PATH="${TB_TMPDIR}:${PATH}"
	# testcmd already exists, so it should skip install
	run install_if_missing "mytestcmd" "somepkg"
	[[ "$status" -eq 0 ]]
}

@test "install_if_missing installs when missing" {
	run install_if_missing "_nonexistent_cmd_" "somepkg"
	[[ "$status" -eq 0 ]]
}

@test "install_packages delegates to pkg_install_many" {
	run install_packages "pkg1" "pkg2"
	[[ "$status" -eq 0 ]]
}

@test "pkg_is_installed checks dpkg" {
	run pkg_is_installed "somepkg"
	[[ "$status" -eq 0 ]]
}
