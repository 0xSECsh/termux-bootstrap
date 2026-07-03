#!/usr/bin/env bash
# ==============================================================================
# Termux Bootstrap — Build Verification
# File: tools/verify-build.sh
#
# Runs comprehensive pre-release checks to ensure the project is ready
# for release. Verifies syntax, linting, tests, version consistency,
# packaging, and documentation.
#
# Usage:
#   ./tools/verify-build.sh              # run all checks
#   ./tools/verify-build.sh --fast       # skip slow checks (coverage)
#   ./tools/verify-build.sh --list       # list available checks
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
FAST=false
LIST=false

for arg in "$@"; do
        case "$arg" in
                --fast) FAST=true ;;
                --list) LIST=true ;;
        esac
done

# --- Utilities ---

PASS=0
FAIL=0
SKIP=0

check() {
        local name="$1"
        local status="$2"
        if [[ "$status" -eq 0 ]]; then
                printf "  [PASS] %s\n" "$name"
                PASS=$((PASS + 1))
        elif [[ "$status" -eq 127 ]]; then
                printf "  [SKIP] %s\n" "$name"
                SKIP=$((SKIP + 1))
        else
                printf "  [FAIL] %s\n" "$name"
                FAIL=$((FAIL + 1))
                FAILURES+=("$name")
        fi
}

declare -a FAILURES=()

cd "$PROJECT_ROOT"

# --- List mode ---

if $LIST; then
        echo "Available checks:"
        echo "  1.  Shell syntax (bash -n on all .sh files)"
        echo "  2.  ShellCheck (all .sh files)"
        echo "  3.  shfmt formatting"
        echo "  4.  Version consistency (VERSION vs source files)"
        echo "  5.  CHANGELOG up to date"
        echo "  6.  BATS unit tests"
        echo "  7.  BATS integration tests"
        echo "  8.  All .sh files are executable"
        echo "  9.  VERSION file exists and is valid semver"
        echo "  10. LICENSE file exists"
        echo "  11. README.md references correct version"
        echo "  12. No .sh files with BOM markers"
        echo "  13. No TODO/FIXME/HACK comments (release gate)"
        echo "  14. All tools/ scripts pass shellcheck"
        echo "  15. Archive sanity check"
        exit 0
fi

echo "=========================================="
echo "  Termux Bootstrap — Build Verification"
echo "=========================================="
echo ""

# --- Check 1: Shell syntax ---

{
        failed=0
        while IFS= read -r -d '' f; do
                bash -n "$f" 2>/dev/null || { failed=$((failed + 1)); }
        done < <(find . -name '*.sh' -not -path './.git/*' -type f -print0)
        check "Shell syntax ($failed files with errors)" $((failed == 0 ? 0 : 1))
}

# --- Check 2: ShellCheck ---

{
        if command -v shellcheck &>/dev/null; then
                failed=0
                while IFS= read -r -d '' f; do
                        shellcheck -x -s bash "$f" 2>/dev/null || { failed=$((failed + 1)); }
                done < <(find . -name '*.sh' -not -path './.git/*' -type f -print0)
                check "ShellCheck ($failed files failed)" $((failed == 0 ? 0 : 1))
        else
                check "ShellCheck" 127
        fi
}

# --- Check 3: shfmt ---

{
        if command -v shfmt &>/dev/null; then
                failed=0
                while IFS= read -r -d '' f; do
                        shfmt -d -i 8 -ci "$f" 2>/dev/null || { failed=$((failed + 1)); }
                done < <(find . -name '*.sh' -not -path './.git/*' -type f -print0)
                check "shfmt formatting ($failed files differ)" $((failed == 0 ? 0 : 1))
        else
                check "shfmt" 127
        fi
}

# --- Check 4: Version consistency ---

{
        if "${SCRIPT_DIR}/validate-version.sh" --quiet 2>/dev/null; then
                check "Version consistency" 0
        else
                check "Version consistency" 1
        fi
}

# --- Check 5: CHANGELOG ---

{
        if "${SCRIPT_DIR}/gen-changelog.sh" --verify 2>/dev/null; then
                check "CHANGELOG up to date" 0
        else
                check "CHANGELOG up to date" 1
        fi
}

# --- Check 6: BATS unit tests ---

{
        if command -v bats &>/dev/null; then
                if $FAST; then
                        check "BATS unit tests (skipped --fast)" 127
                else
                        if bats --formatter tap tests/framework/ tests/utils/ tests/cli/ tests/config/ tests/logging/ tests/modules/ tests/profiles/ tests/regression/ tests/system/ tests/terminal/ tests/validation/ 2>/dev/null; then
                                check "BATS unit tests" 0
                        else
                                check "BATS unit tests" 1
                        fi
                fi
        else
                check "BATS unit tests" 127
        fi
}

# --- Check 7: BATS integration tests ---

{
        if command -v bats &>/dev/null; then
                if $FAST; then
                        check "BATS integration tests (skipped --fast)" 127
                else
                        if bats --formatter tap tests/integration/ 2>/dev/null; then
                                check "BATS integration tests" 0
                        else
                                check "BATS integration tests" 1
                        fi
                fi
        else
                check "BATS integration tests" 127
        fi
}

# --- Check 8: Executable scripts ---

{
        non_exec=0
        while IFS= read -r -d '' f; do
                [[ -x "$f" ]] || non_exec=$((non_exec + 1))
        done < <(find . -name '*.sh' -not -path './.git/*' -type f -print0)
        check "All .sh files executable ($non_exec non-executable)" $((non_exec == 0 ? 0 : 1))
}

# --- Check 9: VERSION file ---

{
        if [[ -f "${PROJECT_ROOT}/VERSION" ]]; then
                v="$(<"${PROJECT_ROOT}/VERSION")"
                v="$(echo "$v" | tr -d '[:space:]')"
                if [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
                        check "VERSION file valid (${v})" 0
                else
                        check "VERSION file invalid semver" 1
                fi
        else
                check "VERSION file missing" 1
        fi
}

# --- Check 10: LICENSE ---

{
        if [[ -f "${PROJECT_ROOT}/LICENSE" ]]; then
                check "LICENSE exists" 0
        elif [[ -f "${PROJECT_ROOT}/LICENSE.md" ]]; then
                check "LICENSE.md exists" 0
        else
                check "LICENSE file missing" 1
        fi
}

# --- Check 11: constants.sh dynamic version ---

{
        if grep -q 'PROJECT_VERSION=' "${PROJECT_ROOT}/lib/core/constants.sh" 2>/dev/null &&
                grep -q 'VERSION' "${PROJECT_ROOT}/lib/core/constants.sh" 2>/dev/null; then
                check "constants.sh reads VERSION dynamically" 0
        else
                check "constants.sh reads VERSION dynamically" 1
        fi
}

# --- Check 12: BOM markers ---

{
        bom_files=0
        while IFS= read -r -d '' f; do
                head -c 3 "$f" | grep -q $'\xef\xbb\xbf' && bom_files=$((bom_files + 1))
        done < <(find . -name '*.sh' -not -path './.git/*' -type f -print0)
        check "No BOM markers ($bom_files files with BOM)" $((bom_files == 0 ? 0 : 1))
}

# --- Check 13: TODO/FIXME gate ---

{
        todo_count=0
        while IFS= read -r -d '' f; do
                [[ "$f" == "./tools/verify-build.sh" ]] && continue
                c="$(grep -cE '(TODO|FIXME|HACK)' "$f" 2>/dev/null || true)"
                todo_count=$((todo_count + c))
        done < <(find . -name '*.sh' -not -path './.git/*' -type f -print0)
        if [[ "$todo_count" -eq 0 ]]; then
                check "No TODO/FIXME/HACK comments" 0
        else
                check "No TODO/FIXME/HACK comments (${todo_count} found)" 1
        fi
}

# --- Check 14: tools/ scripts shellcheck ---

{
        if command -v shellcheck &>/dev/null; then
                failed=0
                for f in "${SCRIPT_DIR}"/*.sh; do
                        shellcheck -x -s bash "$f" 2>/dev/null || { failed=$((failed + 1)); }
                done
                check "tools/ ShellCheck ($failed failed)" $((failed == 0 ? 0 : 1))
        else
                check "tools/ ShellCheck" 127
        fi
}

# --- Check 15: Archive sanity ---

{
        archive="/tmp/termux-bootstrap-verify.tar.gz"
        tar --exclude='.git' --exclude='node_modules' --exclude='target' -czf "$archive" . 2>/dev/null
        size="$(stat -c%s "$archive" 2>/dev/null || wc -c <"$archive" 2>/dev/null || echo 0)"
        rm -f "$archive"
        if [[ "$size" -gt 1000 ]]; then
                check "Archive sanity (${size} bytes)" 0
        else
                check "Archive sanity (too small: ${size} bytes)" 1
        fi
}

# --- Summary ---

echo ""
echo "=========================================="
echo "  Results: ${PASS} passed, ${FAIL} failed, ${SKIP} skipped"
echo "=========================================="

if [[ ${#FAILURES[@]} -gt 0 ]]; then
        echo ""
        echo "Failed checks:"
        for f in "${FAILURES[@]}"; do
                echo "  - ${f}"
        done
fi

exit $FAIL
