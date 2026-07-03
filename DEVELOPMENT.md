# Development Guide

> Guide for developers contributing to Termux Bootstrap — setup, standards, and practices.

---

## Table of Contents

- [Development Setup](#development-setup)
- [Code Standards](#code-standards)
- [Architecture Conventions](#architecture-conventions)
- [Library Rules](#library-rules)
- [Working with Modules](#working-with-modules)
- [Working with Profiles](#working-with-profiles)
- [Testing Practices](#testing-practices)
- [Error Handling](#error-handling)
- [Logging](#logging)
- [Package Management](#package-management)
- [UI Components](#ui-components)
- [Git Workflow](#git-workflow)
- [CI/CD](#cicd)

---

## Development Setup

### Prerequisites

```bash
# Install development tools
pkg install git shellcheck shfmt bats jq

# Verify tools
shellcheck --version
shfmt --version
bats --version
```

### Clone and Initialize

```bash
git clone https://github.com/0xSECsh/termux-bootstrap.git
cd termux-bootstrap

# The framework loads libraries dynamically during testing
# No build step required
```

### Verify Setup

```bash
# Run linter on a single file
shellcheck -x -s bash lib/core/constants.sh

# Check formatting
shfmt -d -i 8 -ci lib/core/constants.sh

# Run the test suite
./tests/run_tests.sh
```

---

## Code Standards

### ShellCheck Compliance

All code must pass ShellCheck with no warnings or errors:

```bash
# Run ShellCheck on all files
find . -name '*.sh' -not -path './.git/*' \
  -exec shellcheck -x -s bash {} +
```

### shfmt Formatting

All code must be formatted with shfmt:

```bash
# Check formatting
find . -name '*.sh' -not -path './.git/*' \
  -exec shfmt -d -i 8 -ci {} +

# Apply formatting
find . -name '*.sh' -not -path './.git/*' \
  -exec shfmt -w -i 8 -ci {} +
```

Configuration: `-i 8` (8-space indent), `-ci` (switch/case indent).

### Bash Requirements

- **Minimum:** Bash 5.0+
- **Shebang:** `#!/usr/bin/env bash`
- **Strict mode:** `set -euo pipefail`

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Variables | `SCREAMING_SNAKE_CASE` for constants | `PROJECT_NAME` |
| Variables | `snake_case` for locals | `local file_path` |
| Functions | `snake_case()` | `load_module()` |
| Internal functions | Prefix with `_` | `_stacktrace()` |
| Module install fns | `install_<cat>_<name>()` | `install_development_rust()` |
| Profile install fns | `install_profile_<name>()` | `install_profile_developer()` |
| CLI handlers | `cmd_<name>()` | `cmd_install()` |
| Files | `<name>.sh` | `packages.sh` |
| Test files | `<name>.bats` | `cache.bats` |
| Guard variables | `SCREAMING_SNAKE_CASE` | `ENVIRONMENT_INITIALIZED` |

### Formatting Rules

```bash
# 1. 8-space indentation (no tabs)
if [[ -n "$var" ]]; then
        handle_var
fi

# 2. Case labels indented
case "$x" in
        start)
                start_service
                ;;
        stop)
                stop_service
                ;;
esac

# 3. Function definition format
my_function() {
        local arg1="$1"
        local result
        result="$(do_something "$arg1")"
        printf '%s\n' "$result"
}

# 4. Quotes — always quote variables unless intentional
printf '%s\n' "$variable"       # Good
printf '%s\n' $variable         # Bad (unless word-splitting intended)

# 5. [[ ]] over [ ] for tests
[[ -n "$name" ]]                # Good
[ -n "$name" ]                  # Avoid

# 6. Prefer printf over echo
printf '%s\n' "message"         # Good
echo "message"                  # Avoid (unportable with flags)
```

---

## Architecture Conventions

### Library Loading

**NEVER** source libraries directly. Always go through `load_library()`:

```bash
# Good
load_library "core/constants"

# Bad — bypasses guard
source "${LIB_DIR}/core/constants.sh"
```

### Initialization

Libraries must define functions only. **Never** execute code during sourcing:

```bash
# Good
my_function() {
        printf '%s\n' "hello"
}

# Bad — executes on source
initialize_something()
```

All initialization must occur through `framework_initialize()` or per-module init functions.

### Guard Pattern

Libraries that track state use guard variables:

```bash
if [[ -z "${ENVIRONMENT_INITIALIZED:-}" ]]; then
        ENVIRONMENT_INITIALIZED=true
        # do initialization
fi
```

### Idempotency

All operations must be safe to run multiple times:

```bash
# Good: checks before creating
if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
fi

# Bad: assumes directory doesn't exist
mkdir -p "$dir"  # (this is actually safe, but the pattern is the point)
```

---

## Library Rules

Every library file must follow these rules:

1. **Define functions only** — No top-level code execution
2. **No automatic initialization** — `framework_initialize()` is the sole entry point
3. **No automatic file creation** — Let the initialization handle it
4. **No automatic package installation** — Let the installer engine handle it
5. **No automatic configuration modification** — Let the config engine handle it

### When Adding a New Library

```bash
# 1. Create the file
touch lib/<layer>/<name>.sh

# 2. Add it to common.sh's load order
vim lib/common.sh

# 3. Create tests
touch tests/<layer>/<name>.bats

# 4. Verify loading
./tests/run_tests.sh
```

### File Structure Template

```bash
# ==============================================================================
# <Section> — <Library Description>
# ==============================================================================
# <Detailed description of what this library provides>
#
# <Usage notes or examples>
# ==============================================================================

# Guard against double-loading
if [[ -n "${LIB_MY_LIBRARY_LOADED:-}" ]]; then
        return 0
fi
readonly LIB_MY_LIBRARY_LOADED=true

# ---- Public Functions ----

# Description of the function
# Arguments:
#   $1 - first argument
#   $2 - second argument
# Output:
#   Description of output
# Returns:
#   0 on success, non-zero on failure
my_function() {
        local arg1="${1:?missing argument}"
        # implementation
}
```

---

## Working with Modules

### Creating a New Module

```bash
# 1. Create the module file
cat > packages/development/my-tools.sh << 'EOF'
# packages/development/my-tools.sh
# Description: Custom development tools

install_development_my_tools() {
    local -a packages
    packages=("tool1" "tool2")
    
    log_info "Installing development/my-tools..."
    pkg_install_many "${packages[@]}"
    log_success "development/my-tools installed"
}
EOF

# 2. Verify discovery
./bootstrap.sh list modules | grep my-tools

# 3. Install
./bootstrap.sh install --module development/my-tools --dry-run
./bootstrap.sh install --module development/my-tools
```

### Module Dependencies

Declare dependencies within the module or use a depends function:

```bash
# Method 1: Inline dependency declaration
install_development_my_tools() {
    require_module "development/python" "strict"
    # ... installation logic
}

# Method 2: Separate depends function
install_development_my_tools_depends() {
    echo "development/python"
    echo "core/base"
}
```

---

## Working with Profiles

### Creating a New Profile

```bash
# Create the profile
cat > packages/profiles/my-profile.sh << 'EOF'
# packages/profiles/my-profile.sh
# Description: My custom profile

install_profile_my_profile() {
    load_module "core/base"
    load_module "development/python"
    load_module "development/my-tools"
    log_success "my-profile installed"
}
EOF

# Verify
./bootstrap.sh list profiles | grep my-profile
```

### Profile Module Loading

Use `load_module` for profiles. The function is idempotent:

```bash
install_profile_developer() {
    # Core
    load_module "core/base"
    load_module "core/editors"
    load_module "core/shell"
    load_module "core/utils"
    
    # Development
    load_module "development/python"
    load_module "development/nodejs"
    load_module "development/golang"
    load_module "development/rust"
    load_module "development/containers"
}
```

---

## Testing Practices

### Write Tests First (TDD)

Prefer test-driven development:

1. Write a failing test
2. Implement the function
3. Verify the test passes
4. Refactor as needed

### Test File Structure

```bash
#!/usr/bin/env bats

setup() {
    load "../helpers/common"
    load "../helpers/assertions"
}

teardown() {
    # Cleanup is automatic via common.bash
}

@test "my_function does what it should" {
    run my_function "input"
    assert_success
    assert_output "expected output"
}

@test "my_function handles edge case" {
    run my_function ""
    assert_failure
    assert_output --partial "error message"
}
```

### Test Categories

| When adding... | Add tests to... |
|----------------|-----------------|
| New library function | `tests/utils/` or appropriate category |
| New module installer | `tests/modules/installer_engine.bats` |
| New CLI command | `tests/cli/dispatcher.bats` |
| New config feature | `tests/config/config_engine.bats` |
| New system helper | `tests/system/` |
| Bug fix | `tests/regression/regression.bats` |

---

## Error Handling

### Rules

1. **Never use `exit 1`** directly in modules — use `die` or `panic`
2. **Use assertions** for precondition checks:
   - `assert_file "$path"` — File must exist
   - `assert_directory "$path"` — Directory must exist
   - `assert_command "pkg"` — Command must be available
   - `assert_capability "termux"` — Capability must be present
   - `assert_variable "VAR"` — Variable must be set
3. **`die` for expected errors** — user-correctable issues
4. **`panic` for unexpected errors** — bugs or invariants violated

### Pattern

```bash
install_my_module() {
    assert_command "pkg" || return 1
    assert_capability "internet" || return 1
    
    if ! pkg_install_many "${packages[@]}"; then
        die "Failed to install ${packages[*]}"
    fi
    
    log_success "Module installed"
}
```

---

## Logging

### Rules

1. **Never use `printf`, `echo`, or `print`** for operational messages
2. **Use logging functions exclusively:**
   - `log_info` — Routine progress
   - `log_success` — Positive outcomes
   - `log_warning` — Non-critical issues
   - `log_error` — Recoverable errors
   - `log_debug` — Development details
   - `log_fatal` — Unrecoverable errors (exits)
3. **Use `log_error_with_cause`** when providing root cause information
4. **Use `log_start`, `log_finish`, `log_skip`** for multi-step operations

### Pattern

```bash
install_module() {
    log_start "Installing module"
    
    if packages_exist; then
        log_info "Found ${#packages[@]} packages to install"
        pkg_install_many "${packages[@]}"
        log_success "All packages installed"
    else
        log_skip "No packages to install"
    fi
    
    log_finish "Module installation complete"
}
```

---

## Package Management

### Rules

1. **Never call package managers directly:**
   - ❌ `pkg install nmap`
   - ❌ `pip install numpy`
   - ❌ `npm install -g bats`
   - ✅ `pkg_install_many "nmap"`
   - ✅ `pip_install "numpy"`
   - ✅ `npm_install "bats"`

2. **Use `install_if_missing` for command-based checks:**
   ```bash
   install_if_missing "rustc" "rust"
   ```

3. **Prefer `pkg_install_many` for batch installations:**
   ```bash
   pkg_install_many "nmap" "hydra" "sqlmap"
   ```

---

## UI Components

### Rules

1. **Never print raw text for interactive elements**
2. **Use UI components:**
   - `ui_header "Title"` — Screen header
   - `ui_section "Section"` — Section divider
   - `ui_confirm "Question?"` — y/N prompt
   - `ui_menu "Title" "Option1" "Option2"` — Menu
   - `ui_summary "Section" "Item1" "Item2"` — Summary display
   - `ui_box "message"` — Boxed message
3. **Use status indicators for success/failure:**
   - `ui_success "Done"`
   - `ui_warning "Check this"`
   - `ui_error "Something failed"`
   - `ui_info "Note:"`

---

## Git Workflow

### Branch Strategy

```
main          ── Production-ready code
  ├── develop  ── Integration branch
  │    ├── feature/*   ── New features
  │    ├── fix/*       ── Bug fixes
  │    └── refactor/*  ── Code improvements
```

### Commit Messages

```
<type>(<scope>): <description>

<body>

<footer>
```

**Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`
**Scopes:** `core`, `module`, `profile`, `cli`, `config`, `test`, `docs`

### Pre-Commit Checklist

```bash
# 1. Format check
shfmt -d -i 8 -ci lib/ modules/ commands/ packages/

# 2. Syntax check
bash -n lib/*.sh modules/*.sh commands/*.sh

# 3. ShellCheck
find . -name '*.sh' -not -path './.git/*' -exec shellcheck -x -s bash {} +

# 4. Test suite
./tests/run_tests.sh
```

---

## CI/CD

### Local CI Simulation

```bash
# Simulate the CI pipeline locally:
# 1. Syntax check
find . -name '*.sh' -not -path './.git/*' -exec bash -n {} +

# 2. ShellCheck
find . -name '*.sh' -not -path './.git/*' -exec shellcheck -x -s bash {} +

# 3. Format check
find . -name '*.sh' -not -path './.git/*' -exec shfmt -d -i 8 -ci {} +

# 4. Tests
./tests/run_tests.sh
```

### CI Pipeline

See `.github/workflows/` for the complete CI pipeline definition.
