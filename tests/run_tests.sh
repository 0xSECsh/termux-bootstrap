#!/usr/bin/env bash
# ==============================================================================
# Termux Bootstrap - Test Runner
# ==============================================================================
# Runs all BATS tests with proper configuration and reporting.
#
# Usage:
#   ./tests/run_tests.sh              # Run all tests
#   ./tests/run_tests.sh <category>   # Run specific category
#   ./tests/run_tests.sh --list       # List available test categories
#
# Categories: framework, cli, modules, profiles, config, logging,
#             utils, validation, system, terminal, integration, regression
# ==============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly PROJECT_ROOT

# Colors
readonly R='\033[31m'
readonly G='\033[32m'
readonly C='\033[36m'
readonly N='\033[0m'
readonly BOLD='\033[1m'

# Defaults
JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"
FORMAT="${FORMAT:-pretty}"

TARGET="${1:-all}"
shift || true

# Map categories to directories
declare -A CATEGORIES=(
        [framework]="framework"
        [cli]="cli"
        [modules]="modules"
        [profiles]="profiles"
        [config]="config"
        [logging]="logging"
        [utils]="utils"
        [validation]="validation"
        [system]="system"
        [terminal]="terminal"
        [integration]="integration"
        [regression]="regression"
)

usage() {
        cat <<EOF
${BOLD}Usage:${N} $(basename "$0") [category] [options]

${BOLD}Categories:${N}
$(for c in "${!CATEGORIES[@]}"; do printf "  %-15s %s\n" "$c" "${CATEGORIES[$c]} tests"; done)
  all               Run all tests

${BOLD}Options:${N}
  --list            List available categories
  --coverage        Show test file count per category
  --help            Show this help message

${BOLD}Environment:${N}
  JOBS=<number>     Parallel jobs (default: ${JOBS})
  FORMAT=<format>   BATS output format (pretty|tap|junit)
EOF
        exit 0
}

if [[ "$TARGET" == "--help" ]]; then
        usage
fi

if [[ "$TARGET" == "--list" ]]; then
        echo -e "${BOLD}Available test categories:${N}"
        for c in "${!CATEGORIES[@]}"; do
                dir="${PROJECT_ROOT}/tests/${CATEGORIES[$c]}"
                count=0
                [[ -d "$dir" ]] && count="$(find "$dir" -name '*.bats' -type f 2>/dev/null | wc -l)"
                printf "  %-15s %d test file(s)\n" "$c" "$count"
        done
        exit 0
fi

if [[ "$TARGET" == "--coverage" ]]; then
        echo -e "${BOLD}Test coverage per category:${N}"
        total=0
        for c in "${!CATEGORIES[@]}"; do
                dir="${PROJECT_ROOT}/tests/${CATEGORIES[$c]}"
                count=0
                [[ -d "$dir" ]] && count="$(find "$dir" -name '*.bats' -type f 2>/dev/null | wc -l)"
                printf "  %-15s %3d test file(s)\n" "$c" "$count"
                total=$((total + count))
        done
        printf "  ${BOLD}%-15s %3d test file(s)${N}\n" "TOTAL" "$total"
        exit 0
fi

# Build BATS args
BATS_ARGS=()

case "$FORMAT" in
        tap) BATS_ARGS+=("--formatter" "tap") ;;
        junit) BATS_ARGS+=("--formatter" "junit") ;;
        pretty) ;;
        *) BATS_ARGS+=("--formatter" "pretty") ;;
esac

# Determine test paths
if [[ "$TARGET" == "all" ]]; then
        TEST_PATHS=()
        for c in "${!CATEGORIES[@]}"; do
                dir="${PROJECT_ROOT}/tests/${CATEGORIES[$c]}"
                [[ -d "$dir" ]] && TEST_PATHS+=("$dir")
        done
else
        found=false
        for c in "${!CATEGORIES[@]}"; do
                if [[ "$TARGET" == "$c" ]]; then
                        dir="${PROJECT_ROOT}/tests/${CATEGORIES[$c]}"
                        if [[ ! -d "$dir" ]]; then
                                echo -e "${R}Error:${N} Test category '$TARGET' has no directory: $dir" >&2
                                exit 1
                        fi
                        TEST_PATHS=("$dir")
                        found=true
                        break
                fi
        done
        if [[ "$found" == false ]]; then
                echo -e "${R}Error:${N} Unknown category: $TARGET" >&2
                echo "Use --list to see available categories." >&2
                exit 1
        fi
fi

# Ensure bats is available
if ! command -v bats &>/dev/null; then
        echo -e "${R}Error:${N} bats is not installed." >&2
        echo "Install with: npm install -g bats" >&2
        echo "Or:           apt install bats" >&2
        exit 1
fi

# Clear any leftover state
unset TB_TMPDIR
unset ENVIRONMENT_INITIALIZED
unset TERMINAL_INITIALIZED
unset ERROR_HANDLERS_REGISTERED
unset TEMP_CLEANUP_TRAP_SET

# Header
echo -e "${BOLD}${C}============================================${N}"
echo -e "${BOLD}${C}  Termux Bootstrap - Test Suite${N}"
echo -e "${BOLD}${C}============================================${N}"
echo -e "${BOLD}Category:${N} $TARGET"
echo -e "${BOLD}Jobs:${N}     $JOBS"
echo -e "${BOLD}BATS:${N}    $(bats --version 2>/dev/null || echo 'unknown')"
echo

# Run tests
START_TS="$(date +%s)"
set +e
if command -v bats &>/dev/null && bats --help 2>/dev/null | grep -q -- '--jobs'; then
        BATS_ARGS+=("--jobs" "$JOBS")
fi
if [[ ${#TEST_PATHS[@]} -eq 1 ]]; then
        bats "${BATS_ARGS[@]}" "${TEST_PATHS[0]}"
else
        bats "${BATS_ARGS[@]}" "${TEST_PATHS[@]}"
fi
EXIT_CODE=$?
set -e

END_TS="$(date +%s)"
DURATION=$((END_TS - START_TS))

echo
echo -e "${BOLD}${C}============================================${N}"
echo -e "${BOLD}${C}  Test Suite Complete${N}"
echo -e "${BOLD}${C}============================================${N}"
echo -e "Duration: ${DURATION}s"

if [[ "$EXIT_CODE" -eq 0 ]]; then
        echo -e "${G}${BOLD}All tests passed.${N}"
else
        echo -e "${R}${BOLD}Some tests failed (exit code: ${EXIT_CODE}).${N}"
fi

exit "$EXIT_CODE"
