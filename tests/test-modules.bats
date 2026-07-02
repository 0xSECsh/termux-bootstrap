#!/usr/bin/env bats
#
# ==============================================================================
# Termux Bootstrap
# File: tests/test-modules.bats
# Description: Module and profile loading tests
# ==============================================================================

source "$(dirname "${BATS_TEST_FILENAME}")/helpers.bash" 2>/dev/null || true

# PACKAGES_DIR is already set by cli.sh

setup() {

	export BATS_TMPDIR
	BATS_TMPDIR="$(mktemp -d)"

	export PATH="${BATS_TMPDIR}/bin:${PATH}"

	# Mock pkg/dpkg for idempotent package checks
	mkdir -p "${BATS_TMPDIR}/bin"

	cat >"${BATS_TMPDIR}/bin/pkg" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
	chmod +x "${BATS_TMPDIR}/bin/pkg"

	cat >"${BATS_TMPDIR}/bin/dpkg" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
	chmod +x "${BATS_TMPDIR}/bin/dpkg"

	# Initialize framework to load cli.sh and module functions
	framework_initialize

}

teardown() {

	rm -rf "${BATS_TMPDIR:-}"

}

# ------------------------------------------------------------------------------
# Module Loader
# ------------------------------------------------------------------------------

@test "load_module loads core/base" {

	run load_module "core" "base"

	assert_status_zero

}

@test "load_module fails for non-existent module" {

	run load_module "core" "nonexistent_module_xyz"

	assert_status_error 1

}

@test "load_module makes install function available" {

	load_module "core" "base"

	type install_core_base

}

@test "load_module handles modules with hyphens" {

	run load_module "cybersecurity" "threat-hunting"

	assert_status_zero

}

# ------------------------------------------------------------------------------
# Core Modules
# ------------------------------------------------------------------------------

@test "core/base install function exists" {

	load_module "core" "base"

	type install_core_base

}

@test "core/base is idempotent" {

	load_module "core" "base"

	run install_core_base

	assert_status_zero

}

@test "core/editors install function exists" {

	load_module "core" "editors"

	type install_core_editors

}

@test "core/shell install function exists" {

	load_module "core" "shell"

	type install_core_shell

}

@test "core/utils install function exists" {

	load_module "core" "utils"

	type install_core_utils

}

# ------------------------------------------------------------------------------
# Development Modules
# ------------------------------------------------------------------------------

@test "development/python install function exists" {

	load_module "development" "python"

	type install_development_python

}

@test "development/nodejs install function exists" {

	load_module "development" "nodejs"

	type install_development_nodejs

}

@test "development/golang install function exists" {

	load_module "development" "golang"

	type install_development_golang

}

@test "development/rust install function exists" {

	load_module "development" "rust"

	type install_development_rust

}

@test "development/containers install function exists" {

	load_module "development" "containers"

	type install_development_containers

}

# ------------------------------------------------------------------------------
# Cybersecurity Modules
# ------------------------------------------------------------------------------

@test "cybersecurity/pentest install function exists" {

	load_module "cybersecurity" "pentest"

	type install_cybersecurity_pentest

}

@test "cybersecurity/osint install function exists" {

	load_module "cybersecurity" "osint"

	type install_cybersecurity_osint

}

@test "cybersecurity/recon install function exists" {

	load_module "cybersecurity" "recon"

	type install_cybersecurity_recon

}

@test "cybersecurity/reverse install function exists" {

	load_module "cybersecurity" "reverse"

	type install_cybersecurity_reverse

}

@test "cybersecurity/mobile install function exists" {

	load_module "cybersecurity" "mobile"

	type install_cybersecurity_mobile

}

@test "cybersecurity/wireless install function exists" {

	load_module "cybersecurity" "wireless"

	type install_cybersecurity_wireless

}

@test "cybersecurity/threat-hunting install function exists" {

	load_module "cybersecurity" "threat-hunting"

	type install_cybersecurity_threat_hunting

}

# ------------------------------------------------------------------------------
# AI Modules
# ------------------------------------------------------------------------------

@test "ai/ai install function exists" {

	load_module "ai" "ai"

	type install_ai_ai

}

# ------------------------------------------------------------------------------
# All Modules Are Idempotent
# ------------------------------------------------------------------------------

@test "all core modules are idempotent" {

	load_module "core" "base"

	load_module "core" "editors"

	load_module "core" "shell"

	load_module "core" "utils"

	run install_core_base

	assert_status_zero

	run install_core_editors

	assert_status_zero

	run install_core_shell

	assert_status_zero

	run install_core_utils

	assert_status_zero

}

# ------------------------------------------------------------------------------
# Profile Loading
# ------------------------------------------------------------------------------

@test "developer profile install function exists" {

	source "${PACKAGES_DIR}/profiles/developer.sh"

	type install_profile_developer

}

@test "pentester profile install function exists" {

	source "${PACKAGES_DIR}/profiles/pentester.sh"

	type install_profile_pentester

}

@test "osint profile install function exists" {

	source "${PACKAGES_DIR}/profiles/osint.sh"

	type install_profile_osint

}

@test "reverse profile install function exists" {

	source "${PACKAGES_DIR}/profiles/reverse.sh"

	type install_profile_reverse

}

@test "ai profile install function exists" {

	source "${PACKAGES_DIR}/profiles/ai.sh"

	type install_profile_ai

}

@test "full profile install function exists" {

	source "${PACKAGES_DIR}/profiles/full.sh"

	type install_profile_full

}

# ------------------------------------------------------------------------------
# Profile → Module Dispatch
# ------------------------------------------------------------------------------

@test "developer profile orchestrates modules" {

	source "${PACKAGES_DIR}/profiles/developer.sh"

	run install_profile_developer

	assert_status_zero

}

@test "ai profile orchestrates modules" {

	source "${PACKAGES_DIR}/profiles/ai.sh"

	run install_profile_ai

	assert_status_zero

}

# ------------------------------------------------------------------------------
# CLI Integration
# ------------------------------------------------------------------------------

@test "dispatch_help displays command options" {

	run dispatch_help

	assert_output_contains "help"

	assert_output_contains "version"

	assert_output_contains "doctor"

}

@test "list_profiles discovers profile files" {

	run list_profiles

	assert_output_contains "developer"

	assert_output_contains "full"

}

@test "dispatch with --version shows version" {

	run dispatch version

	assert_status_zero

	assert_output_contains "$PROJECT_NAME"

}

@test "dispatch with help shows help" {

	run dispatch help

	assert_status_zero

	assert_output_contains "help"

}
