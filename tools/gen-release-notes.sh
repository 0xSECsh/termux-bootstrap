#!/usr/bin/env bash
# ==============================================================================
# Termux Bootstrap — GitHub Release Notes Generator
# File: tools/gen-release-notes.sh
#
# Generates GitHub-flavored release notes from git log, formatted for use
# as the body of a GitHub Release.
#
# Usage:
#   ./tools/gen-release-notes.sh                    # notes for HEAD
#   ./tools/gen-release-notes.sh v0.1.0             # notes for a specific tag
#   ./tools/gen-release-notes.sh v0.1.0..v0.2.0     # notes for a range
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSION="$(<"${PROJECT_ROOT}/VERSION")"
VERSION="$(echo "$VERSION" | tr -d '[:space:]')"

# --- Range computation ---

RANGE="${1:-}"
if [[ -z "$RANGE" ]]; then
        # Determine range: from last tag to HEAD
        last_tag="$(git -C "$PROJECT_ROOT" tag --list 'v*' --sort=-version:refname | head -1 2>/dev/null || true)"
        if [[ -n "$last_tag" ]]; then
                RANGE="${last_tag}..HEAD"
        else
                RANGE="HEAD"
        fi
fi

# --- Gather commits ---

get_commits_by_type() {
        local type="$1"
        local range="$2"
        git -C "$PROJECT_ROOT" log "$range" --format="%s" --reverse 2>/dev/null | grep -E "^${type}(\(.*\))?:" | sed -E "s/^${type}(\(.*\))?:\ //" | sed 's/^/- /'
}

get_all_commits() {
        local range="$1"
        git -C "$PROJECT_ROOT" log "$range" --format="%s" --reverse 2>/dev/null | grep -vE "^(chore|ci)\(release\)|^Merge " | sed 's/^/- /'
}

# --- Generate release notes ---

generate_notes() {
        local range="$1"
        local version="$2"
        local date_str
        date_str="$(date +%Y-%m-%d)"

        echo "# Termux Bootstrap v${version}"
        echo ""
        echo "**Released:** ${date_str}"
        echo ""
        echo "---"
        echo ""

        # Features
        local features
        features="$(get_commits_by_type "feat" "$range")"
        if [[ -n "$features" ]]; then
                echo "## What's New"
                echo ""
                echo "${features}"
                echo ""
        fi

        # Fixes
        local fixes
        fixes="$(get_commits_by_type "fix" "$range")"
        if [[ -n "$fixes" ]]; then
                echo "## Bug Fixes"
                echo ""
                echo "${fixes}"
                echo ""
        fi

        # Breaking changes
        local breaking
        breaking="$(git -C "$PROJECT_ROOT" log "$range" --format="%s%n%b" --reverse 2>/dev/null | grep -i "BREAKING\|!:" | sed 's/^/- /' || true)"
        if [[ -n "$breaking" ]]; then
                echo "## Breaking Changes"
                echo ""
                echo "${breaking}"
                echo ""
        fi

        # Other changes
        local other
        other="$(git -C "$PROJECT_ROOT" log "$range" --format="%s" --reverse 2>/dev/null | grep -E "^(docs|refactor|perf|test|style|build|ci|revert)" | sed -E 's/^(docs|refactor|perf|test|style|build|ci|revert)(\(.*\))?:\ //' | sed 's/^/- /' || true)"
        if [[ -n "$other" ]]; then
                echo "## Other Changes"
                echo ""
                echo "${other}"
                echo ""
        fi

        # All commits summary
        local all_count
        all_count="$(git -C "$PROJECT_ROOT" log "$range" --format="%s" 2>/dev/null | grep -cvE "^(chore|ci)\(release\)|^Merge " || true)"
        echo "---"
        echo ""
        echo "**Full Changelog:** https://github.com/0xSECsh/termux-bootstrap/compare/v${VERSION}...v${VERSION}"
        echo ""
        echo "**Commits:** ${all_count} commits since last release"
}

# --- Main ---

cd "$PROJECT_ROOT"

# If range looks like a tag reference, resolve it
if [[ "$RANGE" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # Single tag - show notes for that tag
        RANGE="${RANGE}..HEAD"
elif [[ "$RANGE" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+\.\.\.?v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # Already a range, use as-is
        :
fi

generate_notes "$RANGE" "$VERSION"
