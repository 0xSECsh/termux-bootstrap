# Common setup/teardown for all BATS tests

# Guard against double-loading
[[ -n "${_TB_TEST_COMMON_LOADED:-}" ]] && return 0
_TB_TEST_COMMON_LOADED=true

# Locate project root (tests/helpers/ -> project root)
_PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly _PROJECT_ROOT

export BATS_TEST_TIMEOUT=30

# Source all helpers
source "${_PROJECT_ROOT}/tests/helpers/assertions.bash"

# ---------------------------------------------------------------
# Unified setup: creates isolation and loads framework
# ---------------------------------------------------------------
common_setup() {
	# Create isolated workspace
	export TB_TMPDIR
	TB_TMPDIR="$(mktemp -d "/tmp/bats-test.XXXXXX")"

	export TEST_HOME="${TB_TMPDIR}/home"
	mkdir -p "${TEST_HOME}"

	# Save real home for restoration
	export _REAL_HOME="${HOME}"

	# Override HOME to isolate config
	export HOME="${TEST_HOME}"

	# Create standard directories the framework expects
	mkdir -p "${TEST_HOME}/.config" \
		"${TEST_HOME}/.cache" \
		"${TEST_HOME}/.local/share" \
		"${TEST_HOME}/storage"

	# Source mocks helper first (defines mock_init, mock_cleanup etc.)
	source "${_PROJECT_ROOT}/tests/helpers/mocks.bash"

	# Initialize mocks
	mock_init
	mock_standard_tools
	mock_command_uname "Linux" "6.1.0" "aarch64"

	# Source the framework
	source "${_PROJECT_ROOT}/lib/common.sh"

	# Initialize with isolated paths
	framework_initialize

	# Source remaining helpers
	source "${_PROJECT_ROOT}/tests/helpers/fixtures.bash"
	source "${_PROJECT_ROOT}/tests/helpers/filesystem.bash"
}

# ---------------------------------------------------------------
# Teardown
# ---------------------------------------------------------------
common_teardown() {
	# Clean up temp directory
	if [[ -n "${TB_TMPDIR:-}" && -d "${TB_TMPDIR}" ]]; then
		rm -rf "${TB_TMPDIR}"
	fi

	declare -F mock_cleanup >/dev/null 2>&1 && mock_cleanup || true

	# Restore real home
	if [[ -n "${_REAL_HOME:-}" ]]; then
		export HOME="${_REAL_HOME}"
	fi

	# Reset framework state variables
	unset ENVIRONMENT_INITIALIZED
	unset TERMINAL_INITIALIZED
	unset ERROR_HANDLERS_REGISTERED
	unset TEMP_CLEANUP_TRAP_SET
	unset LOG_LEVEL
	unset SYSTEM_OS SYSTEM_KERNEL SYSTEM_ARCH
	# Reset registry caches so next test re-scans
	unset _MODULE_REGISTRY_READY
	unset _PROFILE_REGISTRY_READY
	unset _MODULE_LOADER_LOADED _MODULE_LOADER_SOURCED _MODULE_LOADER_RAN
	unset _PROFILE_LOADER_LOADED _PROFILE_LOADER_SOURCED _PROFILE_LOADER_RAN
	unset _INSTALLER_INSTALLED _INSTALLER_DRY_RUN _INSTALLER_ROLLBACK_ENABLED
}
