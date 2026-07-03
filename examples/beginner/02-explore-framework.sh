#!/usr/bin/env bash
# ==============================================================================
# Example: Explore the Framework
# Level:    Beginner
# Usage:    bash examples/beginner/02-explore-framework.sh
# ==============================================================================
# Demonstrates how to explore what the framework offers:
#   1. List all available profiles
#   2. List all available modules
#   3. Query module information
#   4. Check capabilities
#   5. Run the doctor (diagnostics)
#
# Expected output: Tables of profiles, modules, capabilities, and system info.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck disable=SC1091
source "${PROJECT_ROOT}/lib/common.sh"
framework_initialize

# ---- Step 1: Explore Profiles ----
ui_header "Step 1: Available Profiles"
echo ""
echo "Profile discovery via module_registry and profile_registry:"
echo ""

profile_count 2>/dev/null || echo "  (profile_count not available, using module_list)"
if declare -F profile_exists &>/dev/null; then
        for p in minimal dev full developer pentester osint reverse ai; do
                if profile_exists "$p"; then
                        desc="$(profile_info "$p" 2>/dev/null || true)"
                        echo "  ✅ $p"
                        [[ -n "$desc" ]] && echo "      $(echo "$desc" | head -1)"
                else
                        echo "  ⬜ $p"
                fi
        done
fi

# ---- Step 2: Explore Modules ----
ui_header "Step 2: Module Categories"
echo ""
module_categories 2>/dev/null || echo "  (module_categories unavailable, listing manually)"
echo ""
if declare -F module_list &>/dev/null; then
        echo "Modules by category:"
        for cat in core development cybersecurity ai; do
                echo ""
                echo "  [${cat}]"
                # Using the filesystem to list modules (what module_registry does internally)
                dir="${PROJECT_ROOT}/packages/${cat}"
                if [[ -d "$dir" ]]; then
                        for mod in "${dir}"/*.sh; do
                                name="$(basename "${mod}" .sh)"
                                echo "    └─ ${name}"
                        done
                fi
        done
fi

# ---- Step 3: Module Information ----
ui_header "Step 3: Module Information"
echo ""
if declare -F module_info &>/dev/null; then
        echo "Module details for development/rust:"
        module_info "development/rust" 2>/dev/null || echo "  (use bootstrap.sh module info instead)"
else
        echo "  Use: ./bootstrap.sh module info development/rust"
fi
echo ""
echo "Module details for cybersecurity/pentest:"
if declare -F module_deps &>/dev/null; then
        echo "  Dependencies: $(module_deps "cybersecurity/pentest" 2>/dev/null || echo 'core/base')"
fi

# ---- Step 4: Capability Check ----
ui_header "Step 4: Capability Check"
echo ""
for cap in bash git curl jq python node rust termux internet; do
        if has "$cap" 2>/dev/null; then
                log_success "Capability '${cap}' is available"
        else
                log_info "Capability '${cap}' is not available"
        fi
done

# ---- Step 5: Doctor Summary ----
ui_header "Step 5: Quick Doctor Summary"
echo ""
if declare -F run_doctor &>/dev/null; then
        # Doctor runs real checks; wrap in subshell to avoid script exit
        (run_doctor 2>/dev/null) || true
else
        echo "  Run: ./bootstrap.sh doctor"
        echo ""
        # Manual checks
        echo "  Checking environment..."
        echo "    Termux:      $(is_termux 2>/dev/null && echo '✅' || echo '❌ (not Termux)')"
        echo "    Internet:    $(check_internet 2>/dev/null && echo '✅' || echo '❌')"
        echo "    Bash:        ${BASH_VERSION}"
fi

# ---- Step 6: Environment Variables ----
ui_header "Step 6: Framework Constants"
echo ""
echo "  PROJECT_NAME:  ${PROJECT_NAME}"
echo "  PROJECT_VERSION: ${PROJECT_VERSION}"
echo "  CONFIG_DIR:    ${CONFIG_DIR}"
echo "  CACHE_DIR:     ${CACHE_DIR}"
echo "  DATA_DIR:      ${DATA_DIR}"
echo "  LOG_FILE:      ${LOG_FILE}"
echo "  DEFAULT_SHELL: ${DEFAULT_SHELL}"
echo "  DEFAULT_EDITOR: ${DEFAULT_EDITOR}"

log_success "Framework exploration complete"
