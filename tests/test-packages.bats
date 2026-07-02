#!/usr/bin/env bats
#
# ==============================================================================
# Termux Bootstrap
# File: tests/test-packages.bats
# Description: Package management abstraction tests
# ==============================================================================

source "$(dirname "${BATS_TEST_FILENAME}")/helpers.bash" 2>/dev/null || true

setup() {

	export BATS_TMPDIR
	BATS_TMPDIR="$(mktemp -d)"

	export PATH="${BATS_TMPDIR}/bin:${PATH}"

	# Mock pkg to prevent real package operations
	mkdir -p "${BATS_TMPDIR}/bin"

	cat >"${BATS_TMPDIR}/bin/pkg" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
	chmod +x "${BATS_TMPDIR}/bin/pkg"

	# Mock dpkg for pkg_is_installed
	cat >"${BATS_TMPDIR}/bin/dpkg" <<'MOCK'
#!/usr/bin/env bash
if [[ "$1" == "-s" ]]; then
    exit 0
fi
exit 1
MOCK
	chmod +x "${BATS_TMPDIR}/bin/dpkg"

	# Initialize framework to load packages.sh
	framework_initialize

}

teardown() {

	rm -rf "${BATS_TMPDIR:-}"

}

# ------------------------------------------------------------------------------
# Package Update / Upgrade
# ------------------------------------------------------------------------------

@test "pkg_update function exists" {

	type pkg_update

}

@test "pkg_upgrade function exists" {

	type pkg_upgrade

}

# ------------------------------------------------------------------------------
# Installation
# ------------------------------------------------------------------------------

@test "pkg_install function exists" {

	type pkg_install

}

@test "pkg_install_many function exists" {

	type pkg_install_many

}

@test "install_packages function exists" {

	type install_packages

}

@test "install_packages is an alias for pkg_install_many" {

	run install_packages "bash"

	assert_status_zero

}

@test "pkg_install_many handles empty input" {

	run pkg_install_many

	assert_status_zero

}

# ------------------------------------------------------------------------------
# Package Status
# ------------------------------------------------------------------------------

@test "pkg_is_installed function exists" {

	type pkg_is_installed

}

@test "pkg_search function exists" {

	type pkg_search

}

@test "pkg_list function exists" {

	type pkg_list

}

# ------------------------------------------------------------------------------
# Removal
# ------------------------------------------------------------------------------

@test "pkg_remove function exists" {

	type pkg_remove

}

@test "pkg_reinstall function exists" {

	type pkg_reinstall

}

@test "pkg_autoremove function exists" {

	type pkg_autoremove

}

@test "pkg_clean function exists" {

	type pkg_clean

}

# ------------------------------------------------------------------------------
# Python
# ------------------------------------------------------------------------------

@test "pip_install function exists" {

	type pip_install

}

@test "pip_upgrade function exists" {

	type pip_upgrade

}

# ------------------------------------------------------------------------------
# Node.js
# ------------------------------------------------------------------------------

@test "npm_install function exists" {

	type npm_install

}

@test "npm_update function exists" {

	type npm_update

}

# ------------------------------------------------------------------------------
# Rust
# ------------------------------------------------------------------------------

@test "cargo_install function exists" {

	type cargo_install

}

@test "cargo_update function exists" {

	type cargo_update

}

# ------------------------------------------------------------------------------
# Go
# ------------------------------------------------------------------------------

@test "go_install function exists" {

	type go_install

}

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

@test "install_if_missing skips when command exists" {

	run install_if_missing "bash" "bash"

	assert_status_zero

}

@test "install_if_missing function exists" {

	type install_if_missing

}
