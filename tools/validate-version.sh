#!/usr/bin/env bash
# ==============================================================================
# Termux Bootstrap — Version Validation
# File: tools/validate-version.sh
#
# Ensures the version in VERSION is consistent across the project.
# Since constants.sh now reads from VERSION dynamically, this tool validates
# the VERSION file and checks for consistency in key locations.
#
# Usage:
#   ./tools/validate-version.sh              # validate all files
#   ./tools/validate-version.sh --quiet      # only exit code, no output
#   ./tools/validate-version.sh --list       # list all version locations found
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
QUIET=false
LIST=false

for arg in "$@"; do
        case "$arg" in
                --quiet) QUIET=true ;;
                --list) LIST=true ;;
        esac
done

# --- Source of truth ---

TRUTH_FILE="${PROJECT_ROOT}/VERSION"
if [[ ! -f "$TRUTH_FILE" ]]; then
        echo "ERROR: VERSION file not found at ${TRUTH_FILE}" >&2
        exit 1
fi

TRUTH_VERSION="$(<"$TRUTH_FILE")"
TRUTH_VERSION="$(echo "$TRUTH_VERSION" | tr -d '[:space:]')"

if [[ -z "$TRUTH_VERSION" ]]; then
        echo "ERROR: VERSION file is empty" >&2
        exit 1
fi

# --- Semantic version regex ---

SEMVER_RE='^v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$'
if [[ ! "$TRUTH_VERSION" =~ $SEMVER_RE ]]; then
        echo "ERROR: Version '${TRUTH_VERSION}' does not match semver (X.Y.Z or X.Y.Z-pre.N)" >&2
        exit 1
fi

# --- Locations to check ---

declare -a LOCATIONS=()
MISMATCHES=0

# 1. VERSION file itself
LOCATIONS+=("VERSION|${TRUTH_VERSION}|truth")

# 2. lib/core/constants.sh — verify it reads from VERSION dynamically
CONSTANTS="${PROJECT_ROOT}/lib/core/constants.sh"
if [[ -f "$CONSTANTS" ]]; then
        if grep -q 'PROJECT_VERSION=' "$CONSTANTS" | grep -q 'readonly' 2>/dev/null; then
                LOCATIONS+=("lib/core/constants.sh|(dynamic from VERSION)|readonly PROJECT_VERSION")
        fi
fi

# 3. CHANGELOG.md heading for current version
CHANGELOG="${PROJECT_ROOT}/CHANGELOG.md"
if [[ -f "$CHANGELOG" ]]; then
        if grep -q "^## \\[${TRUTH_VERSION}\\]" "$CHANGELOG" 2>/dev/null; then
                LOCATIONS+=("CHANGELOG.md|${TRUTH_VERSION}|changelog heading")
        elif grep -q "^## \\[Unreleased\\]" "$CHANGELOG" 2>/dev/null; then
                LOCATIONS+=("CHANGELOG.md|(Unreleased)|changelog heading (no version tag yet)")
        else
                LOCATIONS+=("CHANGELOG.md|(missing)|changelog heading")
        fi
fi

# 4. Git tag (informational only)
if git -C "$PROJECT_ROOT" rev-parse --git-dir &>/dev/null; then
        latest_tag="$(git -C "$PROJECT_ROOT" tag --list 'v*' --sort=-version:refname | head -1 2>/dev/null || true)"
        if [[ -n "$latest_tag" ]]; then
                LOCATIONS+=("(git tag: ${latest_tag})|${latest_tag#v}|latest git tag")
        fi
fi

# 5. Library/module files with hardcoded PROJECT_VERSION (should read from VERSION)
while IFS= read -r -d '' f; do
        rel_f="${f#"${PROJECT_ROOT}"/}"
        [[ "$rel_f" == "lib/core/constants.sh" ]] && continue
        # Only check lib/, modules/, and bootstrap.sh
        [[ "$rel_f" == lib/* ]] || [[ "$rel_f" == modules/* ]] || [[ "$rel_f" == "bootstrap.sh" ]] || continue
        if grep -Eq '^[^#]*PROJECT_VERSION=' "$f" 2>/dev/null; then
                LOCATIONS+=("$rel_f|(hardcoded)|PROJECT_VERSION in source")
        fi
done < <(find "$PROJECT_ROOT" -name '*.sh' -not -path '*/.git/*' -type f -print0)

# --- Evaluate ---

if $LIST; then
        echo "Version truth: ${TRUTH_VERSION} (from VERSION)"
        echo ""
        printf "%-60s %-20s %s\n" "Location" "Declared" "Source"
        printf "%-60s %-20s %s\n" "--------" "--------" "------"
        for loc in "${LOCATIONS[@]}"; do
                IFS='|' read -r file declared src <<<"$loc"
                printf "%-60s %-20s %s\n" "$file" "$declared" "$src"
        done
        exit 0
fi

for loc in "${LOCATIONS[@]}"; do
        IFS='|' read -r file declared src <<<"$loc"
        if [[ "$src" == "PROJECT_VERSION in source" ]]; then
                echo "HARDCODED: ${file} has PROJECT_VERSION (should read from VERSION dynamically)"
                MISMATCHES=$((MISMATCHES + 1))
        fi
        if [[ "$src" == "latest git tag" ]]; then
                if [[ "$declared" != "$TRUTH_VERSION" ]]; then
                        echo "INFO: Git tag v${declared} differs from VERSION (${TRUTH_VERSION})"
                fi
                continue
        fi
done

if $QUIET; then
        exit $MISMATCHES
fi

if [[ $MISMATCHES -eq 0 ]]; then
        echo "OK: Version ${TRUTH_VERSION} is consistent across ${#LOCATIONS[@]} locations"
else
        echo "FAILED: ${MISMATCHES} issue(s) found" >&2
fi

exit $MISMATCHES
