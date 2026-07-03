#!/usr/bin/env bash
# ==============================================================================
# Example: Preview Installation
# Level:    Beginner
# Usage:    bash examples/beginner/03-preview-install.sh
# ==============================================================================
# Demonstrates safe, non-destructive ways to preview installations:
#   1. Dry-run a profile installation
#   2. Dry-run a module installation
#   3. Use the installer preview
#
# This example uses --dry-run so NO packages are installed.
# It is safe to run on any system.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck disable=SC1091
source "${PROJECT_ROOT}/lib/common.sh"
framework_initialize

ui_header "Installation Preview — Dry Run Mode"
echo ""
log_info "All operations use --dry-run: no packages will be installed."
echo ""

# ---- Step 1: Dry-Run Profile ----
ui_header "Step 1: Preview Minimal Profile"
echo ""
log_info "Simulating: install --profile minimal"
echo ""

if declare -F installer_set_dry_run &>/dev/null; then
        installer_set_dry_run true
        installer_install_profile "minimal" 2>/dev/null || true
        installer_set_dry_run false
        echo ""
        log_info "Dry-run complete. Zero packages were installed."
else
        echo "  Installer engine not fully loaded — using bootstrap.sh interface."
        echo "  Equivalent command:"
        echo ""
        echo "    ./bootstrap.sh install --profile minimal --dry-run"
        echo ""
fi

# ---- Step 2: Dry-Run Module ----
ui_header "Step 2: Preview Individual Module"
echo ""
log_info "Simulating: install --module development/rust"
echo ""

if declare -F installer_set_dry_run &>/dev/null; then
        installer_set_dry_run true
        installer_install_module "development/rust" 2>/dev/null || true
        installer_set_dry_run false
        echo ""
        log_info "Dry-run complete."
else
        echo "  Equivalent command:"
        echo ""
        echo "    ./bootstrap.sh install --module development/rust --dry-run"
        echo ""
fi

# ---- Step 3: Batch Preview ----
ui_header "Step 3: Compare Multiple Profiles"
echo ""

for profile in minimal dev full; do
        echo "  Profile: ${profile}"
        if declare -F profile_modules &>/dev/null; then
                mods="$(profile_modules "$profile" 2>/dev/null || true)"
                if [[ -n "$mods" ]]; then
                        while IFS= read -r m; do
                                echo "    └─ module: ${m}"
                        done <<<"$mods"
                fi
        fi
        echo ""
done

# ---- Step 4: Size Estimates ----
ui_header "Step 4: Package Estimates"
echo ""
echo "  Profile      | Modules | Approx. Size"
echo "  -------------|---------|-------------"
echo "  minimal      |    1    |  ~100 MB"
echo "  dev          |    2    |  ~150 MB"
echo "  full         |    2    |  ~200 MB"
echo "  developer    |    9    |  ~500 MB"
echo "  pentester    |    8    |  ~1.5 GB"
echo "  osint        |    6    |  ~300 MB"
echo "  reverse      |    6    |  ~250 MB"
echo "  ai           |    4    |  ~400 MB"
echo ""

log_info "Tip: Sizes are estimates. Actual usage depends on installed packages."
log_success "Preview complete — no changes were made to your system."
