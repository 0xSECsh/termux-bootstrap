#!/usr/bin/env bash
# ==============================================================================
# Example: Error Handling Patterns
# Level:    Advanced
# Usage:    bash examples/advanced/10-error-handling.sh
# ==============================================================================
# Demonstrates professional error handling patterns using the framework:
#   1. Assertions for preconditions
#   2. Die vs Panic vs Warn
#   3. Signal handling (interrupt safety)
#   4. Rollback pattern
#   5. Error recovery and cleanup
#   6. Defensive programming patterns
#
# Key concepts: The framework provides die/panic/warn/assert functions that
# must be used instead of raw exit 1 or echo error messages.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck disable=SC1091
source "${PROJECT_ROOT}/lib/common.sh"
framework_initialize

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

ui_header "Error Handling Patterns"
echo ""

# ==============================================================================
# Pattern 1: Assertions
# ==============================================================================
ui_section "1. Precondition Assertions"
echo ""

log_info "The framework provides 5 assertion guards:"
echo ""

cat <<'ASSERT_EOF'
  assert_file(path)       → die if file doesn't exist
  assert_directory(path)  → die if directory doesn't exist
  assert_command(cmd)     → die if command not found
  assert_capability(name) → die if capability missing
  assert_variable(name)   → die if variable is unset

ASSERT_EOF

log_info "Demonstrating safe assertions (these will pass):"

# Create a test file and directory to demonstrate
touch "${WORK_DIR}/test.txt"
mkdir -p "${WORK_DIR}/subdir"

# These should all pass
assert_file "${WORK_DIR}/test.txt" && log_success "assert_file passed"
assert_directory "${WORK_DIR}/subdir" && log_success "assert_directory passed"
assert_variable "PROJECT_ROOT" && log_success "assert_variable passed"
assert_command "bash" && log_success "assert_command passed"
echo ""

# ==============================================================================
# Pattern 2: Die vs Panic vs Warn
# ==============================================================================
ui_section "2. Die vs Panic vs Warn"
echo ""

cat <<'DIE_EOF'
  ┌─────────────────────┬──────────┬────────────┬─────────────────┐
  │ Function            │ Severity │ Stacktrace │ Continues?      │
  ├─────────────────────┼──────────┼────────────┼─────────────────┤
  │ die()               │ FATAL    │ No         │ Exits (code 1)  │
  │ panic()             │ FATAL    │ Yes        │ Exits (code 1)  │
  │ log_fatal()         │ FATAL    │ No         │ Exits (code 1)  │
  │ log_error()         │ ERROR    │ No         │ Yes             │
  │ log_warning()       │ WARN     │ No         │ Yes             │
  │ log_info()          │ INFO     │ No         │ Yes             │
  │ log_success()       │ OK       │ No         │ Yes             │
  └─────────────────────┴──────────┴────────────┴─────────────────┘

  When to use each:

  die()     → Expected error (e.g., file not found, bad input)
              User can fix the issue and re-run.

  panic()   → Unexpected error / invariant violated
              This is a bug. Shows full stack trace.

  log_error → Recoverable error (e.g., optional package failed)
              Continues execution, logs the failure.

  log_warning → Non-critical issue (e.g., deprecated feature)
                Continues execution, user should be aware.

DIE_EOF

log_info "Demonstrating safe warnings (non-fatal):"
log_warning "This is a recoverable issue — execution continues"
log_error "This is a recoverable error — execution continues"
log_success "All non-fatal demonstrations passed"
echo ""

# ==============================================================================
# Pattern 3: Error Recovery
# ==============================================================================
ui_section "3. Error Recovery Pattern"
echo ""

cat <<'RECOVERY_EOF'
  The recommended recovery pattern:

  ┌────────────────────────────────────────────────────────────┐
  │ if ! dangerous_operation; then                             │
  │     log_error "Operation failed"                           │
  │     cleanup                                                │
  │     return 1                                               │
  │ fi                                                         │
  └────────────────────────────────────────────────────────────┘

  Not:
  ┌────────────────────────────────────────────────────────────┐
  │ dangerous_operation                                        │
  │ # No error check — silent failure                          │
  └────────────────────────────────────────────────────────────┘

  And not:
  ┌────────────────────────────────────────────────────────────┐
  │ dangerous_operation || exit 1  # Raw exit without context  │
  └────────────────────────────────────────────────────────────┘

RECOVERY_EOF

demonstrate_recovery() {
        local step_name="$1"
        local should_fail="${2:-false}"

        log_info "  Executing: ${step_name}"

        if [[ "$should_fail" == "true" ]]; then
                log_error "  Step '${step_name}' failed: simulated error"
                return 1
        fi

        log_success "  Step '${step_name}' completed"
        return 0
}

log_info "Demonstrating recovery pattern:"
demonstrate_recovery "download packages" "false" || true
demonstrate_recovery "install packages" "true" || {
        log_warning "Continuing despite package install failure"
}
demonstrate_recovery "configure application" "false" || true
echo ""

# ==============================================================================
# Pattern 4: Cleanup Trap Pattern
# ==============================================================================
ui_section "4. Cleanup Trap Pattern"
echo ""

cat <<'TRAP_EOF'
  The framework provides automatic cleanup via:

    register_temp_cleanup()

  When developing scripts that create temp resources:

  ┌────────────────────────────────────────────────────────────┐
  │ WORK_DIR="$(mktemp -d)"                                    │
  │ trap 'rm -rf "${WORK_DIR}"' EXIT                           │
  │ # ... use WORK_DIR ...                                     │
  │ # Temp dir is cleaned up automatically on script exit,     │
  │ # even if the script crashes or is interrupted.            │
  └────────────────────────────────────────────────────────────┘

TRAP_EOF

log_info "This script uses a cleanup trap for WORK_DIR"
log_info "Temp directory: ${WORK_DIR}"
log_info "Will be cleaned up on exit regardless of how this script terminates"
echo ""

# ==============================================================================
# Pattern 5: Defensive Programming
# ==============================================================================
ui_section "5. Defensive Programming"
echo ""

cat <<'DEFENSIVE_EOF'
  Defensive Bash patterns used throughout the framework:

  1. Guard variables (prevent double-loading)
  ┌────────────────────────────────────────────────────────────┐
  │ if [[ -n "${LIB_MY_LIB_LOADED:-}" ]]; then return 0; fi   │
  │ readonly LIB_MY_LIB_LOADED=true                            │
  └────────────────────────────────────────────────────────────┘

  2. Strict mode
  ┌────────────────────────────────────────────────────────────┐
  │ set -euo pipefail                                          │
  └────────────────────────────────────────────────────────────┘

  3. Default values for unset variables
  ┌────────────────────────────────────────────────────────────┐
  │ local timeout="${TIMEOUT:-30}"                             │
  └────────────────────────────────────────────────────────────┘

  4. Check before creating
  ┌────────────────────────────────────────────────────────────┐
  │ if [[ ! -d "$dir" ]]; then mkdir -p "$dir"; fi            │
  └────────────────────────────────────────────────────────────┘

  5. Idempotent operations
  ┌────────────────────────────────────────────────────────────┐
  │ if ! module_loaded "$name"; then                           │
  │     load_module "$name"                                    │
  │ fi                                                         │
  └────────────────────────────────────────────────────────────┘

DEFENSIVE_EOF

# ==============================================================================
# Pattern 6: Framework Guard Variables
# ==============================================================================
ui_section "6. Framework Guard Variables"
echo ""

log_info "Framework state guards currently active:"
echo ""
echo "  Variable                          | Status"
echo "  ----------------------------------|--------"
echo "  TERMUX_BOOTSTRAP_COMMON_LOADED    | ${TERMUX_BOOTSTRAP_COMMON_LOADED:-false}"
echo "  ENVIRONMENT_INITIALIZED           | ${ENVIRONMENT_INITIALIZED:-false}"
echo "  TERMINAL_INITIALIZED              | ${TERMINAL_INITIALIZED:-false}"
echo "  ERROR_HANDLERS_REGISTERED         | ${ERROR_HANDLERS_REGISTERED:-false}"
echo "  TEMP_CLEANUP_TRAP_SET             | ${TEMP_CLEANUP_TRAP_SET:-false}"
echo ""

log_info "These guards prevent re-initialization and double-loading"
echo ""

# ==============================================================================
# Summary
# ==============================================================================
ui_header "Summary: Error Handling Quick Reference"
echo ""

cat <<'SUMMARY_EOF'
  ┌─────────────────────────────────────────────────────────────────────┐
  │                      QUICK REFERENCE                                │
  ├─────────────────────────────────────────────────────────────────────┤
  │                                                                     │
  │  ✅ DO:                                                             │
  │     assert_file "$path"        # Validate preconditions             │
  │     die "Message"              # Expected, user-correctable error   │
  │     panic "Message"            # Unexpected, should-not-happen      │
  │     log_error "Message"        # Recoverable error, continues       │
  │     trap cleanup EXIT          # Always clean up temp resources     │
  │                                                                     │
  │  ❌ DON'T:                                                          │
  │     exit 1                     # Never in modules                   │
  │     echo "Error: ..."          # Use logging instead                │
  │     || exit 1                  # Use die with context               │
  │     set +e                     # Avoid disabling strict mode        │
  │                                                                     │
  └─────────────────────────────────────────────────────────────────────┘

SUMMARY_EOF

log_success "Error handling patterns demonstration complete"
