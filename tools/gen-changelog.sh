#!/usr/bin/env bash
# ==============================================================================
# Termux Bootstrap — Automated CHANGELOG Generator
# File: tools/gen-changelog.sh
#
# Reads git log since the last tag and generates a Keep a Changelog formatted
# entry for the unreleased section. Supports conventional commit parsing.
#
# Usage:
#   ./tools/gen-changelog.sh              # preview unreleased entries
#   ./tools/gen-changelog.sh --write      # write entries into CHANGELOG.md
#   ./tools/gen-changelog.sh --verify     # check changelog is up to date
#   ./tools/gen-changelog.sh --full       # regenerate full changelog from all tags
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CHANGELOG="${PROJECT_ROOT}/CHANGELOG.md"
WRITE=false
VERIFY=false
FULL=false

for arg in "$@"; do
        case "$arg" in
                --write) WRITE=true ;;
                --verify) VERIFY=true ;;
                --full) FULL=true ;;
        esac
done

# --- Utilities ---

log_info() { printf "  [INFO] %s\n" "$*"; }
log_error() { printf "  [ERROR] %s\n" "$*" >&2; }
log_success() { printf "  [OK] %s\n" "$*"; }

# --- Extract version from VERSION ---

get_version() {
        local v
        v="$(<"${PROJECT_ROOT}/VERSION")"
        v="$(echo "$v" | tr -d '[:space:]')"
        echo "$v"
}

# --- Classify conventional commit ---

classify_commit() {
        local msg="$1"
        local type desc

        if [[ "$msg" =~ ^(feat|fix|docs|style|refactor|perf|test|chore|ci|build|revert|security)(\(.*\))?:\ (.+) ]]; then
                type="${BASH_REMATCH[1]}"
                desc="${BASH_REMATCH[3]}"
                desc="${desc%.}"
                desc="${desc^^}"
                desc="${desc:0:1}${desc:1}"

                case "$type" in
                        feat) echo "Added|$desc" ;;
                        fix) echo "Fixed|$desc" ;;
                        docs) echo "Documentation|$desc" ;;
                        style) echo "Styling|$desc" ;;
                        refactor) echo "Changed|$desc" ;;
                        perf) echo "Performance|$desc" ;;
                        test) echo "Testing|$desc" ;;
                        chore) echo "Housekeeping|$desc" ;;
                        ci) echo "CI/CD|$desc" ;;
                        build) echo "Build|$desc" ;;
                        revert) echo "Fixed|$desc" ;;
                        security) echo "Security|$desc" ;;
                        *) echo "Other|$msg" ;;
                esac
        else
                echo "Other|$msg"
        fi
}

# --- Get commits since last tag ---

get_unreleased_commits() {
        local tag
        tag="$(git -C "$PROJECT_ROOT" tag --list 'v*' --sort=-version:refname | head -1 2>/dev/null || true)"

        if [[ -n "$tag" ]]; then
                git -C "$PROJECT_ROOT" log "${tag}..HEAD" --format="%s" --reverse 2>/dev/null
        else
                git -C "$PROJECT_ROOT" log --format="%s" --reverse 2>/dev/null
        fi
}

# --- Get commits between two tags ---

get_tag_commits() {
        local from="$1"
        local to="${2:-HEAD}"
        git -C "$PROJECT_ROOT" log "${from}..${to}" --format="%s" --reverse 2>/dev/null
}

# --- Build changelog section from commits ---

build_section() {
        local version="$1"
        local date="$2"
        local commits="$3"
        local has_content=false
        local output=""
        local -A sections=()

        # Initialize sections
        sections["Added"]=""
        sections["Changed"]=""
        sections["Deprecated"]=""
        sections["Removed"]=""
        sections["Fixed"]=""
        sections["Security"]=""
        sections["Documentation"]=""
        sections["Performance"]=""
        sections["Testing"]=""
        sections["Housekeeping"]=""
        sections["CI/CD"]=""
        sections["Build"]=""
        sections["Styling"]=""
        sections["Other"]=""

        while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                result="$(classify_commit "$line")"
                IFS='|' read -r section desc <<<"$result"
                if [[ -n "$desc" ]]; then
                        sections["$section"]+="  - ${desc}
"
                        has_content=true
                fi
        done <<<"$commits"

        $has_content || return 1

        output+="## [${version}] - ${date}
"
        for section in Added Changed Deprecated Removed Fixed Security Documentation Performance Testing Housekeeping CI/CD Build Styling Other; do
                if [[ -n "${sections[$section]}" ]]; then
                        output+="
### ${section}
"
                        output+="${sections[$section]}"
                fi
        done

        echo "$output"
        return 0
}

# --- Generate full changelog ---

generate_full() {
        local output=""

        output+="# Changelog
"
        output+="
> All notable changes to Termux Bootstrap are documented in this file.
"
        output+="
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
"
        output+="
---
"

        # Unreleased section
        local unreleased
        unreleased="$(get_unreleased_commits)"
        local has_unreleased=false
        local section
        section="$(build_section "Unreleased" "$(date +%Y-%m-%d)" "$unreleased")" && has_unreleased=true

        if $has_unreleased; then
                output+="
${section}
"
        fi

        # Walk all tags in reverse order
        local tags=()
        while IFS= read -r tag; do
                tags+=("$tag")
        done < <(git -C "$PROJECT_ROOT" tag --list 'v*' --sort=-version:refname)

        local prev_tag=""
        local ver date_str tag_commits sec

        for tag in "${tags[@]}"; do
                ver="${tag#v}"
                date_str="$(git -C "$PROJECT_ROOT" log -1 --format="%as" "$tag" 2>/dev/null || date +%Y-%m-%d)"

                if [[ -z "$prev_tag" ]]; then
                        tag_commits="$(get_tag_commits "${tag}" HEAD 2>/dev/null || true)"
                else
                        tag_commits="$(get_tag_commits "${tag}" "${prev_tag}" 2>/dev/null || true)"
                fi

                sec="$(build_section "$ver" "$date_str" "$tag_commits")" || true
                if [[ -n "$sec" ]]; then
                        output+="
${sec}
"
                fi
                prev_tag="$tag"
        done

        # Also include commits before the first tag
        first_tag="${tags[-1]:-}"
        if [[ -n "$first_tag" ]]; then
                tag_commits="$(get_tag_commits "" "${first_tag}" 2>/dev/null || true)"
                sec="$(build_section "0.1.0" "$(git -C "$PROJECT_ROOT" log -1 --format="%as" "$first_tag" 2>/dev/null || date +%Y-%m-%d)" "$tag_commits")" || true
        fi

        echo "$output"
}

# --- Generate unreleased section only ---

generate_unreleased() {
        local unreleased
        unreleased="$(get_unreleased_commits)"

        if [[ -z "$unreleased" ]]; then
                echo "No unreleased commits found."
                return 0
        fi

        local section
        section="$(build_section "Unreleased" "$(date +%Y-%m-%d)" "$unreleased")" || {
                echo "No significant changes to categorize."
                return 0
        }

        echo "$section"
}

# --- Verify changelog is current ---

do_verify() {
        local unreleased
        unreleased="$(get_unreleased_commits)"

        # Check if unreleased section exists in CHANGELOG
        if ! grep -q "^## \[Unreleased\]" "$CHANGELOG" 2>/dev/null; then
                log_error "CHANGELOG.md is missing the [Unreleased] section"
                return 1
        fi

        if [[ -z "$unreleased" ]]; then
                # No unreleased commits — nothing to check
                return 0
        fi

        # Check if changelog contains the latest unreleased commit message
        local latest_commit
        latest_commit="$(echo "$unreleased" | tail -1)"
        if grep -qF "$latest_commit" "$CHANGELOG" 2>/dev/null; then
                log_success "CHANGELOG.md is up to date"
                return 0
        else
                log_error "CHANGELOG.md is outdated — unreleased commits are not documented"
                return 1
        fi
}

# --- Main ---

cd "$PROJECT_ROOT"

if $FULL; then
        log_info "Generating full changelog..."
        generate_full
        exit 0
fi

if $VERIFY; then
        do_verify
        exit $?
fi

if $WRITE; then
        generate_unreleased >/tmp/gen-changelog-preview.md
        log_info "Review generated content: /tmp/gen-changelog-preview.md"
        log_info "To insert into CHANGELOG.md, manually move [Unreleased] items into"
        log_info "a dated version section after the tag is created."
        exit 0
fi

# Default: preview
generate_unreleased
