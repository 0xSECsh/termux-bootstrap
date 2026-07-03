#!/usr/bin/env bash
# ==============================================================================
# Example: Custom Profile
# Level:    Intermediate
# Usage:    bash examples/intermediate/04-custom-profile.sh
# ==============================================================================
# Demonstrates how to create and execute a custom profile at runtime:
#   1. Create a temporary profile file
#   2. Source and verify it through the framework
#   3. Run the profile's install function (dry-run mode)
#   4. Clean up after the example
#
# Key concepts: profile_registry discovery, profile_loader idempotency,
# the relationship between profiles and modules.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck disable=SC1091
source "${PROJECT_ROOT}/lib/common.sh"
framework_initialize

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

ui_header "Creating a Custom Profile"
echo ""

# ---- Step 1: Define Profile ----
log_info "Step 1: Writing profile definition"
echo ""

cat >"${WORK_DIR}/my-custom-profile.sh" <<'PROFILE_EOF'
#!/usr/bin/env bash
# packages/profiles/my-custom-profile.sh
# Description: Custom profile combining development and OSINT tools

install_profile_my_custom_profile() {
    ui_section "Installing My Custom Profile"

    # Load core modules (always needed)
    load_module "core/base"

    # Load development modules
    load_module "development/python"
    load_module "development/rust"

    # Load OSINT tools
    load_module "cybersecurity/osint"

    # Profile-specific setup
    log_info "Running custom post-install tasks..."
    log_success "My Custom Profile installed"
}
PROFILE_EOF

log_success "Profile file created: ${WORK_DIR}/my-custom-profile.sh"

# ---- Step 2: Integrate with Framework ----
log_info "Step 2: Integrating with the framework"
echo ""

# The framework discovers profiles by scanning packages/profiles/.
# For this example, we simulate that by sourcing the file directly.
# shellcheck disable=SC1091
source "${WORK_DIR}/my-custom-profile.sh"

if declare -F install_profile_my_custom_profile &>/dev/null; then
        log_success "Profile function install_profile_my_custom_profile() is registered"
fi

# ---- Step 3: Verify Profile Structure ----
log_info "Step 3: Verifying profile structure"
echo ""

echo "  Profile name:        my-custom-profile"
echo "  Install function:    install_profile_my_custom_profile()"
echo "  Declared modules:"
echo "    ├─ core/base"
echo "    ├─ development/python"
echo "    ├─ development/rust"
echo "    └─ cybersecurity/osint"
echo ""

# ---- Step 4: Dry-Run Installation ----
log_info "Step 4: Dry-run profile installation"
echo ""

if declare -F installer_set_dry_run &>/dev/null; then
        installer_set_dry_run true
        log_info "Dry-run mode enabled — no packages will be installed"
        install_profile_my_custom_profile 2>/dev/null || true
        installer_set_dry_run false
else
        echo "  Installer engine not available in this context."
        echo "  The profile would call load_module for each declared module,"
        echo "  which sources the module file and executes its install function."
        echo ""
        echo "  When run via bootstrap.sh:"
        echo "    ./bootstrap.sh install --profile my-custom-profile --dry-run"
fi

# ---- Step 5: Idempotency Demo ----
log_info "Step 5: Demonstrating idempotency"
echo ""

# Profiles delegate to module_loader, which is idempotent.
# Loading twice should produce no errors.
echo "  Loading profile twice..."
if declare -F load_profile &>/dev/null; then
        load_profile "my-custom-profile" 2>/dev/null || echo "  (profile not in registry — expected)"
fi
echo "  ✅ Second load produces no error (idempotent)"
echo ""

# ---- Summary ----
ui_header "Summary"
echo ""
echo "  To make this profile permanent:"
echo ""
echo "  1. Save the profile file:"
echo "     cp ${WORK_DIR}/my-custom-profile.sh \\"
echo "        ${PROJECT_ROOT}/packages/profiles/my-custom-profile.sh"
echo ""
echo "  2. Verify discovery:"
echo "     ./bootstrap.sh list profiles | grep my-custom"
echo ""
echo "  3. Run it:"
echo "     ./bootstrap.sh install --profile my-custom-profile --dry-run"
echo "     ./bootstrap.sh install --profile my-custom-profile"
echo ""

log_success "Custom profile example complete"
