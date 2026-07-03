#!/usr/bin/env bash
# ==============================================================================
# Example: Configuration Lifecycle
# Level:    Intermediate
# Usage:    bash examples/intermediate/05-config-lifecycle.sh
# ==============================================================================
# Demonstrates the complete configuration management lifecycle:
#   1. List managed configurations and their status
#   2. Validate configuration files
#   3. Merge configurations (smart-merge vs overwrite)
#   4. Read and write configuration values
#   5. Understand config states
#
# This example works on the test directories — no real configs are modified.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck disable=SC1091
source "${PROJECT_ROOT}/lib/common.sh"
framework_initialize

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

ui_header "Configuration Lifecycle Demonstration"
echo ""
log_info "Working in isolated directory: ${WORK_DIR}"
echo ""

# ---- Step 1: List Managed Configs ----
log_info "Step 1: Listing managed configurations"
echo ""

if declare -F config_list &>/dev/null; then
        config_list
else
        echo "  Managed configurations (from config_engine path map):"
        echo "    git       → ~/.gitconfig"
        echo "    zsh       → ~/.zshrc"
        echo "    tmux      → ~/.tmux.conf"
        echo "    nvim      → ~/.config/nvim/"
        echo "    micro     → ~/.config/micro/"
        echo "    fastfetch → ~/.config/fastfetch/"
fi
echo ""

# ---- Step 2: Check Config Status ----
log_info "Step 2: Checking configuration status"
echo ""

for app in git zsh tmux; do
        echo -n "  ${app}: "
        if declare -F config_status &>/dev/null; then
                st="$(config_status "$app" 2>/dev/null || echo "not_installed")"
                case "$st" in
                        not_installed) echo "🔴 Not installed" ;;
                        up_to_date) echo "🟢 Up to date" ;;
                        modified) echo "🟡 Modified (customized)" ;;
                        missing) echo "⚫ Source missing" ;;
                        *) echo "${st}" ;;
                esac
        else
                echo "check via: ./bootstrap.sh config validate --all"
        fi
done
echo ""

# ---- Step 3: Validate ----
log_info "Step 3: Validate configurations"
echo ""

if declare -F config_validate &>/dev/null; then
        echo "  Validating git config..."
        config_validate "git" 2>/dev/null || echo "  → Not installed (expected)"
        echo ""
        echo "  Validating all configs..."
        config_validate_all 2>/dev/null || true
else
        echo "  Equivalent command: ./bootstrap.sh config validate --all"
fi
echo ""

# ---- Step 4: Understand Merge Modes ----
log_info "Step 4: Merge modes explained"
echo ""

cat <<'MERGE_EOF'
  The configuration engine supports two merge modes:

  ┌────────────────────────────────────────────────────────────────┐
  │  Smart Merge (default)                                         │
  │                                                                │
  │  Reads the user's existing config, adds lines from the source  │
  │  that are missing, and preserves all user customizations.      │
  │                                                                │
  │  Use:  ./bootstrap.sh config merge git                         │
  └────────────────────────────────────────────────────────────────┘

  ┌────────────────────────────────────────────────────────────────┐
  │  Overwrite Merge (--overwrite)                                 │
  │                                                                │
  │  Replaces the user's config entirely with the shipped source.  │
  │  Creates a backup before overwriting.                          │
  │                                                                │
  │  Use:  ./bootstrap.sh config merge git --overwrite             │
  └────────────────────────────────────────────────────────────────┘

  Config file state machine:

    NOT INSTALLED ──merge──→ UP TO DATE
         ↑                     │
         │            user edits│
         │                     ↓
         │                  MODIFIED
         │                     │
         └───merge --overwrite─┘

MERGE_EOF

# ---- Step 5: Demo with a Temp Config ----
log_info "Step 5: Merge demonstration (sandboxed)"
echo ""

# Create a fake source config
cat >"${WORK_DIR}/source.conf" <<<"color.ui = auto"
cat >"${WORK_DIR}/source.conf" <<'CONF_EOF'
[user]
    name = Default User
    email = default@example.com
[core]
    editor = micro
[init]
    defaultBranch = main
CONF_EOF

# Create a fake user config with customizations
cat >"${WORK_DIR}/user.conf" <<'CONF_EOF'
[user]
    name = Jane Developer
    email = jane@example.com
[core]
    editor = nvim
CONF_EOF

log_info "Source config:   ${WORK_DIR}/source.conf"
log_info "User config:     ${WORK_DIR}/user.conf"
echo ""

log_info "Source content:"
cat "${WORK_DIR}/source.conf" | sed 's/^/  /'
echo ""

log_info "User content (has customizations):"
cat "${WORK_DIR}/user.conf" | sed 's/^/  /'
echo ""

log_info "Smart merge would:"
echo "  ✅ Preserve user.name = Jane Developer"
echo "  ✅ Preserve core.editor = nvim"
echo "  ➕ Add [init] defaultBranch = main (from source)"
echo ""

log_info "Overwrite merge would:"
echo "  ❌ Replace everything with source content"
echo "  💾 Backup original to user.conf.bak"
echo ""

# ---- Step 6: Config Status ----
log_info "Step 6: Interpreting config status from CLI"
echo ""

echo "  When you run 'config validate', each config shows:"
echo ""
echo "    not_installed → No user config exists. Run 'config merge'."
echo "    up_to_date    → User config matches source. Nothing to do."
echo "    modified      → User config differs. Run 'config merge --overwrite' to reset."
echo "    missing       → Source template is gone. Check configs/ directory."
echo ""

log_success "Configuration lifecycle demonstration complete"
echo ""
echo "  Real commands to try:"
echo "    ./bootstrap.sh config list"
echo "    ./bootstrap.sh config validate --all"
echo "    ./bootstrap.sh config merge git"
echo "    ./bootstrap.sh config show git"
