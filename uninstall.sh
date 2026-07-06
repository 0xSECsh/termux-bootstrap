#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap — Uninstaller
#
# Removes Termux Bootstrap configuration files and cached data.
# Installed packages are not removed automatically to avoid breaking
# dependencies with manually installed software.
#
# Usage:
#   ./uninstall.sh [--force]
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()    { printf "${CYAN}[INFO]${NC}    %s\n" "$*"; }
log_success() { printf "${GREEN}[OK]${NC}      %s\n" "$*"; }
log_warning() { printf "${YELLOW}[WARN]${NC}    %s\n" "$*"; }
log_error()   { printf "${RED}[ERROR]${NC}   %s\n" "$*"; }

# Directories managed by the framework
FRAMEWORK_DIRS=(
        "${HOME}/.config/termux-bootstrap"
        "${HOME}/.cache/termux-bootstrap"
        "${HOME}/.local/share/termux-bootstrap"
)

FORCE=false

for arg in "$@"; do
        case "$arg" in
                --force) FORCE=true ;;
                -h | --help)
                        printf "Usage: %s [--force]\n" "$0"
                        printf "\n"
                        printf "Options:\n"
                        printf "  --force   Skip confirmation prompt\n"
                        printf "  -h, --help  Show this help\n"
                        exit 0
                        ;;
                *)
                        log_error "Unknown option: $arg"
                        exit 1
                        ;;
        esac
done

printf "\n"
printf "${CYAN}Termux Bootstrap Uninstaller${NC}\n"
printf "============================\n\n"

# Check what exists
found_any=false
for dir in "${FRAMEWORK_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
                found_any=true
                break
        fi
done

if [[ "$found_any" == false ]]; then
        log_info "No Termux Bootstrap data found. Nothing to remove."
        exit 0
fi

# Show what will be removed
log_info "The following directories will be removed:"
printf "\n"
for dir in "${FRAMEWORK_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
                printf "  %s\n" "$dir"
        fi
done
printf "\n"

if [[ "$SCRIPT_DIR" == *"termux-bootstrap"* ]] && [[ -d "$SCRIPT_DIR" ]]; then
        log_warning "Bootstrap source directory detected: ${SCRIPT_DIR}"
        log_warning "It will NOT be removed automatically."
        log_info "To remove it: rm -rf ${SCRIPT_DIR}"
        printf "\n"
fi

# Confirm
if [[ "$FORCE" != true ]]; then
        printf "Proceed with removal? [y/N]: "
        read -r answer
        case "${answer,,}" in
                y | yes)
                        ;;
                *)
                        log_info "Aborted."
                        exit 0
                        ;;
        esac
fi

# Remove directories
for dir in "${FRAMEWORK_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
                rm -rf "$dir"
                log_success "Removed: ${dir}"
        fi
done

printf "\n"
log_success "Termux Bootstrap has been uninstalled."
log_info "Manually installed packages were not removed."
log_info "To remove them: pkg uninstall <package-name>"
printf "\n"
