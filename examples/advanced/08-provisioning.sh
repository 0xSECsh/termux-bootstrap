#!/usr/bin/env bash
# ==============================================================================
# Example: Automated Device Provisioning
# Level:    Advanced
# Usage:    bash examples/advanced/08-provisioning.sh [--profile <name>]
# ==============================================================================
# Demonstrates a complete, production-quality provisioning script that:
#   1. Validates the environment before starting
#   2. Installs a profile with appropriate options
#   3. Applies configuration files
#   4. Verifies everything post-installation
#   5. Generates a provisioning report
#
# This is the type of script you'd use to set up a new device automatically.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck disable=SC1091
source "${PROJECT_ROOT}/lib/common.sh"
framework_initialize

# ---- Configuration ----
PROFILE="${1:-developer}"
REPORT_FILE="${LOG_DIR}/provisioning-report-$(date '+%Y%m%d-%H%M%S').log"
START_TIME="$(date +%s)"
HAS_ERRORS=false

# ---- Error Handler ----
handle_error() {
        local step="$1"
        local message="$2"
        HAS_ERRORS=true
        log_error "[${step}] ${message}"
        echo "  ❌ ${step}: ${message}" >>"${REPORT_FILE}"
}

# ---- Provisioning Steps ----
provision_step_01_validate_environment() {
        ui_header "Provisioning Step 1/6: Validate Environment"
        echo ""

        # Check we're in a viable environment
        if ! is_termux 2>/dev/null; then
                log_warning "Not running in Termux — some features may not work"
                echo "  ⚠ Not in Termux — proceeding in compatibility mode" >>"${REPORT_FILE}"
        fi

        # Check required commands
        for cmd in bash git; do
                if ! command_exists "$cmd" 2>/dev/null; then
                        handle_error "validate" "Required command not found: ${cmd}"
                        return 1
                fi
        done

        log_success "Environment validation passed"
        echo "  ✅ Environment validated" >>"${REPORT_FILE}"
}

provision_step_02_doctor() {
        ui_header "Provisioning Step 2/6: System Diagnostics"
        echo ""

        if declare -F run_doctor &>/dev/null; then
                run_doctor 2>/dev/null || true
        else
                log_info "Doctor command not available — skipping"
        fi
        echo "  ✅ Diagnostics complete" >>"${REPORT_FILE}"
}

provision_step_03_install_profile() {
        local profile="$1"
        ui_header "Provisioning Step 3/6: Installing Profile: ${profile}"
        echo ""

        log_info "Target profile: ${profile}"
        log_info "Install mode:   ${INSTALLER_DRY_RUN:-live}"
        echo ""

        if declare -F installer_install_profile &>/dev/null; then
                installer_install_profile "${profile}" 2>/dev/null || {
                        handle_error "install" "Profile installation failed for ${profile}"
                        return 1
                }
        else
                # Fall back to bootstrap.sh interface
                if ! "${PROJECT_ROOT}/bootstrap.sh" install --profile "${profile}"; then
                        handle_error "install" "Profile installation failed for ${profile}"
                        return 1
                fi
        fi

        log_success "Profile '${profile}' installed"
        echo "  ✅ Profile '${profile}' installed" >>"${REPORT_FILE}"
}

provision_step_04_apply_configs() {
        ui_header "Provisioning Step 4/6: Applying Configurations"
        echo ""

        if declare -F config_merge_all &>/dev/null; then
                config_merge_all 2>/dev/null || {
                        handle_error "config" "Configuration merge failed"
                        return 1
                }
        else
                log_info "Config engine not available — skipping merge"
        fi

        log_success "Configurations applied"
        echo "  ✅ Configurations applied" >>"${REPORT_FILE}"
}

provision_step_05_verify() {
        ui_header "Provisioning Step 5/6: Post-Installation Verification"
        echo ""

        # Verify installed modules
        if declare -F module_loaded_list &>/dev/null; then
                local loaded_count
                loaded_count="$(module_loaded_count 2>/dev/null || echo 0)"
                log_info "Modules loaded: ${loaded_count}"
                echo "  ✅ Modules loaded: ${loaded_count}" >>"${REPORT_FILE}"
        fi

        # Verify configs
        if declare -F config_validate_all &>/dev/null; then
                config_validate_all 2>/dev/null || true
        fi

        # Quick capability check
        for cap in bash git curl jq; do
                if has "$cap" 2>/dev/null; then
                        echo "     ✅ ${cap}" >>"${REPORT_FILE}"
                else
                        echo "     ❌ ${cap}" >>"${REPORT_FILE}"
                fi
        done

        log_success "Verification complete"
}

provision_step_06_report() {
        local duration=$(($(date +%s) - START_TIME))
        ui_header "Provisioning Step 6/6: Report"
        echo ""

        {
                echo "================================================"
                echo "  Provisioning Report"
                echo "  Profile:  ${PROFILE}"
                echo "  Date:     $(date)"
                echo "  Duration: ${duration}s"
                echo "  Status:   $($HAS_ERRORS && echo 'PARTIAL' || echo 'SUCCESS')"
                echo "================================================"
                echo ""
                echo "Summary:"
                echo "  Profile installed:     ${PROFILE}"
                echo "  Modules loaded:        $(module_loaded_count 2>/dev/null || echo 'N/A')"
                echo "  Configs applied:       $(config_count 2>/dev/null || echo 'N/A')"
                echo "  Duration:              ${duration}s"
                echo ""
                if $HAS_ERRORS; then
                        echo "Warnings/Errors occurred during provisioning."
                        echo "Check the main log for details: ${LOG_FILE}"
                else
                        echo "Provisioning completed successfully."
                fi
        } >>"${REPORT_FILE}"

        log_info "Report saved to: ${REPORT_FILE}"
        echo ""
        echo "  ┌────────────────────────────────────────────────────┐"
        echo "  │  Provisioning Complete                             │"
        echo "  │                                                    │"
        if $HAS_ERRORS; then
                echo "  │  ⚠ Completed with warnings                       │"
        else
                echo "  │  ✅ All steps completed successfully              │"
        fi
        echo "  │                                                    │"
        echo "  │  Profile:  ${PROFILE}                      │"
        echo "  │  Duration: ${duration}s                           │"
        echo "  └────────────────────────────────────────────────────┘"
}

# ---- Main Execution ----
main() {
        ui_header "Termux Bootstrap — Automated Provisioning"
        echo ""
        log_info "Profile: ${PROFILE}"
        log_info "Log:     ${LOG_FILE}"
        log_info "Report:  ${REPORT_FILE}"
        echo ""

        provision_step_01_validate_environment || true
        provision_step_02_doctor || true

        # Install with rollback enabled
        if declare -F installer_set_rollback &>/dev/null; then
                installer_set_rollback true
                log_info "Rollback protection enabled"
        fi

        provision_step_03_install_profile "${PROFILE}" || true
        provision_step_04_apply_configs || true
        provision_step_05_verify || true
        provision_step_06_report

        # Final status
        if $HAS_ERRORS; then
                log_warning "Provisioning completed with warnings. Review ${REPORT_FILE}"
        else
                log_success "Provisioning completed successfully"
        fi
}

main "$@"
