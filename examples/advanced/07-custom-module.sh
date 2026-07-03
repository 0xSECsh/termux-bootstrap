#!/usr/bin/env bash
# ==============================================================================
# Example: Creating a Custom Module
# Level:    Advanced
# Usage:    bash examples/advanced/07-custom-module.sh
# ==============================================================================
# Demonstrates how to create a production-quality module:
#   1. Module file structure and conventions
#   2. Declaring dependencies
#   3. Package installation with wrappers
#   4. Verification and logging
#   5. Integration with the module system
#
# Key concepts: module API, dependency declaration, package wrappers,
# logging conventions, verification patterns.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck disable=SC1091
source "${PROJECT_ROOT}/lib/common.sh"
framework_initialize

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

ui_header "Creating a Production Module"
echo ""

# ---- Step 1: Module Template ----
log_info "Step 1: Module structure and conventions"
echo ""

cat <<'STRUCTURE_EOF'
  Every module follows this structure:

  packages/<category>/<name>.sh
  ┌─────────────────────────────────────────────────────────┐
  │ #!/usr/bin/env bash                                     │
  │ # packages/<category>/<name>.sh                         │
  │ # Description: One-line description of what this        │
  │ #              module provides                          │
  │                                                         │
  │ install_<category>_<name>() {                           │
  │     local -a packages                                   │
  │     packages=(                                          │
  │         "pkg1"                                          │
  │         "pkg2"                                          │
  │     )                                                   │
  │                                                         │
  │     log_info "Installing <category>/<name>..."          │
  │                                                         │
  │     # Install system packages                           │
  │     pkg_install_many "${packages[@]}"                   │
  │                                                         │
  │     # Install language-specific packages                │
  │     pip_install "python-pkg"                            │
  │                                                         │
  │     # Verify installation                               │
  │     if command -v tool &>/dev/null; then                │
  │         log_success "<category>/<name> installed"       │
  │     else                                                │
  │         log_error "Installation verification failed"    │
  │     fi                                                  │
  │ }                                                       │
  └─────────────────────────────────────────────────────────┘

STRUCTURE_EOF

# ---- Step 2: Create a Real Module ----
log_info "Step 2: Creating a development/data-science module"
echo ""

cat >"${WORK_DIR}/data_science.sh" <<'MODULE_EOF'
#!/usr/bin/env bash
# packages/development/data_science.sh
# Description: Data science tools — Python scientific stack

# Dependencies declared as a function (discovered by module_registry)
install_development_data_science_depends() {
    echo "development/python"
}

install_development_data_science() {
    log_info "Installing development/data-science..."

    # ---- System packages ----
    local -a system_pkgs
    system_pkgs=(
        "python"
        "python-pip"
    )
    pkg_install_many "${system_pkgs[@]}"

    # ---- Python packages ----
    local -a python_pkgs
    python_pkgs=(
        "numpy"
        "pandas"
        "scipy"
        "matplotlib"
        "scikit-learn"
    )
    pip_install "${python_pkgs[@]}"

    # ---- Verification ----
    local verified=true
    for cmd in python pip3; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "Required command not found: ${cmd}"
            verified=false
        fi
    done

    if [[ "$verified" == "true" ]]; then
        log_success "development/data-science installed"
        log_info "Python version: $(python --version 2>/dev/null || echo 'unknown')"
    else
        log_error "development/data-science installation incomplete"
        return 1
    fi
}
MODULE_EOF

log_success "Module file created: ${WORK_DIR}/data_science.sh"
echo ""

# ---- Step 3: Examine Module Components ----
log_info "Step 3: Module anatomy"
echo ""

echo "  Every module has these components:"
echo ""
echo "  ┌─────────────────────────────────────────────────────────────┐"
echo "  │  1. File header:  # Description: ...                       │"
echo "  │  2. Depends fn:   install_<cat>_<name>_depends() { ... }   │"
echo "  │  3. Install fn:   install_<cat>_<name>() { ... }           │"
echo "  │  4. Packages:     Declared as local arrays                 │"
echo "  │  5. Wrappers:     pkg_install_many, pip_install, ...       │"
echo "  │  6. Logging:      log_info, log_success, log_error         │"
echo "  │  7. Verification: command -v <tool> checks                 │"
echo "  └─────────────────────────────────────────────────────────────┘"
echo ""

# ---- Step 4: Module Dependencies ----
log_info "Step 4: Dependency declaration patterns"
echo ""

cat <<'DEPS_EOF'
  Three patterns for declaring dependencies:

  Pattern 1: Separate depends function (recommended)
  ┌──────────────────────────────────────────────────────┐
  │ install_data_science_depends() {                     │
  │     echo "development/python"                        │
  │ }                                                    │
  └──────────────────────────────────────────────────────┘
  → module_registry discovers this automatically

  Pattern 2: Inline require_module in install function
  ┌──────────────────────────────────────────────────────┐
  │ install_data_science() {                             │
  │     require_module "development/python" "strict"     │
  │     # ...                                            │
  │ }                                                    │
  └──────────────────────────────────────────────────────┘
  → Dependency checked at install time

  Pattern 3: Optional dependency
  ┌──────────────────────────────────────────────────────┐
  │ install_my_module() {                                │
  │     require_module "some/module" "optional"          │
  │     # Continues even if module not found             │
  │ }                                                    │
  └──────────────────────────────────────────────────────┘
  → Non-fatal if dependency is missing

DEPS_EOF

# ---- Step 5: Best Practices ----
log_info "Step 5: Production module best practices"
echo ""

cat <<'BEST_PRACTICES_EOF'
  ✅ DO:
     • Use framework wrappers (pkg_install_many, pip_install, ..., not raw pkg/pip)
     • Use framework logging (log_info, log_success, ..., not echo/printf)
     • Use framework error handling (die, assert_file, ..., not exit 1)
     • Declare all dependencies explicitly
     • Verify installation with command -v checks
     • Use local variables, not globals
     • Keep modules focused on one capability

  ❌ DON'T:
     • Call pkg, pip, npm, cargo, or go directly
     • Use echo or printf for operational messages
     • Use exit 1 inside module code
     • Assume packages exist without verification
     • Create files outside designated directories
     • Modify user configuration automatically

  📋 Checklist for new modules:
     □ Single responsibility (one capability)
     □ Explicitly declared dependencies
     □ Framework wrappers for package management
     □ Framework logging (info, success, error)
     □ Verification after installation
     □ Idempotent (safe to run multiple times)
     □ ShellCheck clean
     □ shfmt formatted (8-space indent, -ci style)
     □ BATS tests in tests/modules/
     □ Documentation in MODULES.md

BEST_PRACTICES_EOF

# ---- Step 6: Integration ----
log_info "Step 6: Integration with the framework"
echo ""

echo "  To add this module to your project:"
echo ""
echo "  1. Save to packages/:"
echo "     cp ${WORK_DIR}/data_science.sh \\"
echo "        ${PROJECT_ROOT}/packages/development/data_science.sh"
echo ""
echo "  2. Verify discovery:"
echo "     ./bootstrap.sh list modules | grep data_science"
echo ""
echo "  3. Test installation:"
echo "     ./bootstrap.sh install --module development/data_science --dry-run"
echo "     ./bootstrap.sh install --module development/data_science"
echo ""
echo "  4. Add to a profile:"
echo "     echo 'load_module \"development/data_science\"' >> \\"
echo "        packages/profiles/developer.sh"
echo ""

log_success "Custom module creation example complete"
