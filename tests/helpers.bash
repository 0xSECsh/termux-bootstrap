#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: tests/helpers.bash
# Description: Shared test helpers and environment
# ==============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh" 2>/dev/null || true

setup() {

	export BATS_TMPDIR
	BATS_TMPDIR="$(mktemp -d)"

	# Initialize framework per test (idempotent, guarded)
	framework_initialize

}

teardown() {

	rm -rf "${BATS_TMPDIR:-}"

}

# ------------------------------------------------------------------------------
# Mock helpers
# ------------------------------------------------------------------------------

mock_command() {

	local cmd="$1"

	local exit_code="${2:-0}"

	mkdir -p "${BATS_TMPDIR}/mocks"

	cat >"${BATS_TMPDIR}/mocks/${cmd}" <<MOCK
#!/usr/bin/env bash
exit ${exit_code}
MOCK

	chmod +x "${BATS_TMPDIR}/mocks/${cmd}"

}

prepend_mock_path() {

	export PATH="${BATS_TMPDIR}/mocks:${PATH}"

}

# ------------------------------------------------------------------------------
# Assertion helpers
# ------------------------------------------------------------------------------

assert_output_contains() {

	local expected="$1"

	if [[ "$output" != *"$expected"* ]]; then

		echo "Expected output to contain: ${expected}"

		echo "Actual output: ${output}"

		return 1

	fi

}

assert_output_matches() {

	local pattern="$1"

	if [[ ! "$output" =~ $pattern ]]; then

		echo "Expected output to match: ${pattern}"

		echo "Actual output: ${output}"

		return 1

	fi

}

assert_status_zero() {

	if [[ "$status" -ne 0 ]]; then

		echo "Expected status 0, got ${status}"

		echo "Output: ${output}"

		return 1

	fi

}

assert_status_error() {

	local expected="${1:-1}"

	if [[ "$status" -ne "$expected" ]]; then

		echo "Expected status ${expected}, got ${status}"

		echo "Output: ${output}"

		return 1

	fi

}
