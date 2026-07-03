#!/usr/bin/env bash
# ==============================================================================
# Example: Hello Termux Bootstrap
# Level:    Beginner
# Usage:    bash examples/beginner/01-hello-world.sh [--no-color]
# ==============================================================================
# This example demonstrates the most basic framework operations:
#   1. Loading the framework
#   2. Displaying version and build info
#   3. Understanding the help system
#   4. Checking the environment
#
# Expected output: Version string, build info, and help summary.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck disable=SC1091
source "${PROJECT_ROOT}/lib/common.sh"

# Initialize framework (creates dirs, sets up logging, detects system)
framework_initialize

# ---- Step 1: Show Version ----
ui_header "Step 1: Version Information"
show_version # Prints: Termux Bootstrap 0.1.0
echo ""

# ---- Step 2: Show Build Info  ----
ui_header "Step 2: Build Information"
show_build_info # Shows architecture, OS, kernel, shell
echo ""

# ---- Step 3: Show Help ----
ui_header "Step 3: Help System"
dispatch_help # Shows available commands
echo ""

# ---- Step 4: Quick Summary ----
ui_header "Step 4: Environment Summary"
log_info "Framework initialized successfully"
log_info "Project root: ${PROJECT_ROOT}"
log_info "Library dir:  ${LIB_DIR}"
log_info "Config dir:   ${CONFIG_DIR}"
log_info "System:       ${SYSTEM_OS}/${SYSTEM_ARCH}"
[[ -n "${SYSTEM_KERNEL:-}" ]] && log_info "Kernel:       ${SYSTEM_KERNEL}"
log_success "Hello Termux Bootstrap — framework is ready"
echo ""

# ---- Step 5: Show About ----
echo "---"
show_about
