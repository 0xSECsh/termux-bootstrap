#!/usr/bin/env bash
# ==============================================================================
# Example: Framework Programming API
# Level:    Advanced
# Usage:    bash examples/advanced/09-framework-api.sh
# ==============================================================================
# Demonstrates using the framework libraries as a Bash development platform:
#   1. Logging system (levels, file output, caller context)
#   2. Cache system (TTL-based storage)
#   3. Retry mechanism (exponential backoff)
#   4. Secure temp files
#   5. String manipulation utilities
#   6. Hash computation
#   7. Random generation
#   8. Time utilities
#
# Key concepts: These examples show how to use the framework as a development
# library for building your own Bash tools — not just for provisioning.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck disable=SC1091
source "${PROJECT_ROOT}/lib/common.sh"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

ui_header "Framework API Demonstration"
echo ""
log_info "This example uses the framework libraries as a Bash development platform."
echo ""

# ==============================================================================
# Section 1: Logging System
# ==============================================================================
ui_section "1. Logging System"
echo ""

log_info "Demonstrating all log levels:"
log_debug "This is a debug message (only visible with LOG_LEVEL=DEBUG)"
log_info "This is an informational message"
log_success "This is a success message"
log_warning "This is a warning message"
log_error "This is an error message (continues execution)"

echo ""
log_info "Log entries include caller context:"
log_info "This message shows its source file and line number"

echo ""
log_info "Log file location: ${LOG_FILE}"
log_info "Error log:         ${ERROR_LOG}"
echo ""

# ==============================================================================
# Section 2: Cache System
# ==============================================================================
ui_section "2. Cache System"
echo ""

log_info "Cache directory: ${CACHE_DIR}"

if declare -F cache_initialize &>/dev/null; then
        cache_initialize

        # Store a value
        cache_set "demo_key" "hello_world" 60
        log_success "Cached value with 60s TTL"

        # Retrieve it
        value="$(cache_get "demo_key" 2>/dev/null || echo "miss")"
        log_info "Retrieved from cache: '${value}'"

        # Cache statistics
        cache_statistics 2>/dev/null || true
else
        log_warning "Cache system not available"
fi
echo ""

# ==============================================================================
# Section 3: Retry Mechanism
# ==============================================================================
ui_section "3. Retry Mechanism"
echo ""

log_info "Demonstrating retry with a flaky operation:"

flaky_operation() {
        local attempt="${1:-1}"
        if [[ "$attempt" -lt 3 ]]; then
                return 1
        fi
        return 0
}

if declare -F retry &>/dev/null; then
        log_info "Retrying flaky operation (succeeds on attempt 3)..."
        if retry 3 1 flaky_operation 3 2>/dev/null; then
                log_success "Operation succeeded after retries"
        else
                log_error "Operation failed after retries"
        fi
else
        log_warning "Retry system not available"
fi
echo ""

# ==============================================================================
# Section 4: Secure Temp Files
# ==============================================================================
ui_section "4. Secure Temp Files"
echo ""

if declare -F create_secure_temp_file &>/dev/null; then
        tmpfile="$(create_secure_temp_file 2>/dev/null)"
        log_success "Created temp file: ${tmpfile}"
        echo "data" >"$tmpfile"
        log_info "Wrote data, size: $(stat -c%s "$tmpfile" 2>/dev/null || wc -c <"$tmpfile")"

        tmpdir="$(create_secure_temp_dir 2>/dev/null)"
        log_success "Created temp dir: ${tmpdir}"
elif declare -F mktemp &>/dev/null; then
        # Fallback using system mktemp
        tmpfile="$(mktemp "${WORK_DIR}/tmp.XXXXXX")"
        log_success "Created temp file: ${tmpfile}"
        tmpdir="$(mktemp -d "${WORK_DIR}/tmpdir.XXXXXX")"
        log_success "Created temp dir: ${tmpdir}"
fi
echo ""

# ==============================================================================
# Section 5: String Utilities
# ==============================================================================
ui_section "5. String Utilities"
echo ""

test_str="  Hello World!  "

if declare -F trim &>/dev/null; then
        log_info "Original: '${test_str}'"
        log_info "Trimmed:  '$(trim "${test_str}")'"
fi

if declare -F to_lower &>/dev/null; then
        log_info "Lower:    $(to_lower "HELLO WORLD")"
fi

if declare -F to_upper &>/dev/null; then
        log_info "Upper:    $(to_upper "hello world")"
fi
echo ""

# ==============================================================================
# Section 6: Hash Computation
# ==============================================================================
ui_section "6. Hash Computation"
echo ""

demo_text="Termux Bootstrap"

if declare -F sha256 &>/dev/null; then
        log_info "SHA256('${demo_text}') = $(sha256 "${demo_text}")"
fi

if declare -F sha1 &>/dev/null; then
        log_info "SHA1('${demo_text}')   = $(sha1 "${demo_text}")"
fi

if declare -F md5 &>/dev/null; then
        log_info "MD5('${demo_text}')    = $(md5 "${demo_text}")"
fi
echo ""

# ==============================================================================
# Section 7: Random Generation
# ==============================================================================
ui_section "7. Random Generation"
echo ""

if declare -F random_string &>/dev/null; then
        log_info "Random(8):   $(random_string 8)"
        log_info "Random(16):  $(random_string 16)"
        log_info "Random(32):  $(random_string 32)"
fi
echo ""

# ==============================================================================
# Section 8: Time Utilities
# ==============================================================================
ui_section "8. Time Utilities"
echo ""

if declare -F timestamp &>/dev/null; then
        log_info "Current timestamp: $(timestamp)"
fi

if declare -F epoch &>/dev/null; then
        log_info "Current epoch:     $(epoch)"
fi

if declare -F pause &>/dev/null; then
        log_info "Pausing for 0.5 seconds..."
        pause 0.5
        log_success "Resumed"
fi
echo ""

# ==============================================================================
# Summary
# ==============================================================================
ui_header "API Demonstration Summary"
echo ""

echo "  Available libraries and their key functions:"
echo ""
echo "  Library         | Functions demonstrated"
echo "  ----------------|-------------------------"
echo "  logging.sh      | log_info, log_success, log_warning, log_error, log_debug"
echo "  cache.sh        | cache_set, cache_get, cache_statistics"
echo "  retry.sh        | retry"
echo "  temp.sh         | create_secure_temp_file, create_secure_temp_dir"
echo "  string.sh       | trim, to_lower, to_upper"
echo "  hash.sh         | sha256, sha1, md5"
echo "  random.sh       | random_string"
echo "  time.sh         | timestamp, epoch, pause"
echo ""

log_success "Framework API demonstration complete"
log_info "Full log written to: ${LOG_FILE}"
