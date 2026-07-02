#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: tests/run.sh
# Description: Test suite runner
# ==============================================================================

set -e

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$TESTS_DIR"

echo "=============================================="

echo " Termux Bootstrap - Test Suite"

echo "=============================================="

echo ""

# Ensure bats is available
if ! command -v bats &>/dev/null; then

	echo "ERROR: bats not found. Install it with: npm install -g bats"

	exit 1

fi

# Count test files and labels
total_files=0

for test_file in test-*.bats; do

	[[ -f "$test_file" ]] || continue

	((total_files++))

done

echo "Found ${total_files} test file(s)"

echo ""

# Run all tests
bats "${@:-test-*.bats}"
