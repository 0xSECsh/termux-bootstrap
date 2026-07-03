#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap: Update Command
# ==============================================================================

# ------------------------------------------------------------------------------
# Command Entry Point
# ------------------------------------------------------------------------------

cmd_update() {
        local subcmd="${1:-all}"
        shift || true

        case "$subcmd" in
                all)
                        cmd_update_all "$@"
                        ;;
                repos)
                        cmd_update_repos "$@"
                        ;;
                packages)
                        cmd_update_packages "$@"
                        ;;
                framework)
                        cmd_update_framework "$@"
                        ;;
                -h | --help)
                        _update_help
                        ;;
                *)
                        log_error "Unknown update subcommand: ${subcmd}"
                        return "$EXIT_INVALID_ARGUMENT"
                        ;;
        esac
}

# ------------------------------------------------------------------------------
# Update All - Repos + Packages + Framework
# ------------------------------------------------------------------------------

cmd_update_all() {
        local failed=0

        ui_section "Full Update"

        # Check internet connectivity
        if ! check_internet; then
                log_error "No internet connection available"
                return "$EXIT_NETWORK_ERROR"
        fi

        # Step 1: Update repositories
        ui_key_value "  Step" "1/3 - Updating repositories"
        if ! cmd_update_repos; then
                log_warning "Repository update failed, continuing..."
                ((failed++))
        fi

        # Step 2: Update packages
        ui_key_value "  Step" "2/3 - Updating packages"
        if ! cmd_update_packages; then
                log_warning "Package update failed, continuing..."
                ((failed++))
        fi

        # Step 3: Update framework
        ui_key_value "  Step" "3/3 - Updating framework"
        if ! cmd_update_framework; then
                log_warning "Framework update failed, continuing..."
                ((failed++))
        fi

        # Summary
        printf "\n"
        if [[ "$failed" -eq 0 ]]; then
                log_success "Full update completed successfully"
        else
                log_warning "Update completed with ${failed} failure(s)"
        fi

        return 0
}

# ------------------------------------------------------------------------------
# Update Repos - Update package manager repositories
# ------------------------------------------------------------------------------

cmd_update_repos() {
        require_internet

        ui_section "Update Repositories"

        spinner_run "Updating package database" pkg_update

        log_success "Repositories updated"
        return 0
}

# ------------------------------------------------------------------------------
# Update Packages - Upgrade all installed packages
# ------------------------------------------------------------------------------

cmd_update_packages() {
        require_internet

        ui_section "Update Packages"

        # Update database first
        spinner_run "Updating package database" pkg_update

        # Upgrade all packages
        spinner_run "Upgrading installed packages" pkg_upgrade

        # Clean up
        spinner_run "Removing unused packages" pkg_autoremove

        log_success "Packages updated"
        return 0
}

# ------------------------------------------------------------------------------
# Update Framework - Pull latest changes from repository
# ------------------------------------------------------------------------------

cmd_update_framework() {
        require_internet
        require_command git

        ui_section "Update Framework"

        local repo_dir
        repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

        # Check if we're in a git repository
        if [[ ! -d "${repo_dir}/.git" ]]; then
                log_error "Not a git repository: ${repo_dir}"
                return "$EXIT_FAILURE"
        fi
        # Fetch latest changes
        spinner_run "Fetching updates" git -C "$repo_dir" fetch origin 2>/dev/null

        # Check if there are updates
        local current_branch
        current_branch="$(git -C "$repo_dir" rev-parse --abbrev-ref HEAD)"

        local local_hash remote_hash
        local_hash="$(git -C "$repo_dir" rev-parse HEAD)"
        remote_hash="$(git -C "$repo_dir" rev-parse "origin/${current_branch}" 2>/dev/null)" || true

        if [[ -z "$remote_hash" ]]; then
                ui_key_value "  Status" "No remote tracking branch"
                log_warning "Cannot check for updates - no remote branch: origin/${current_branch}"
                return 0
        fi

        if [[ "$local_hash" == "$remote_hash" ]]; then
                ui_key_value "  Status" "Already up to date"
                log_success "Framework is up to date"
                return 0
        fi

        # Show what will be updated
        local commits_behind
        commits_behind="$(git -C "$repo_dir" rev-list --count "HEAD..origin/${current_branch}" 2>/dev/null)" || commits_behind="unknown"

        ui_key_value "  Branch" "$current_branch"
        ui_key_value "  Behind" "${commits_behind} commit(s)"

        # Backup current state
        local backup_dir="${BACKUP_DIR:-${HOME}/.config/termux-bootstrap/backups}"
        create_directory "$backup_dir"

        local backup_name
        backup_name="framework-$(date +%Y%m%d-%H%M%S)"

        spinner_run "Creating backup" git -C "$repo_dir" archive \
                --format=tar.gz \
                --output="${backup_dir}/${backup_name}.tar.gz" \
                HEAD

        log_info "Backup created: ${backup_dir}/${backup_name}.tar.gz"

        # Pull changes
        spinner_run "Pulling updates" git -C "$repo_dir" pull origin "$current_branch" 2>/dev/null

        # Show updated version
        local new_version
        new_version="$(<"${repo_dir}/VERSION")"

        if [[ -n "$new_version" ]]; then
                ui_key_value "  Version" "$new_version"
        fi

        log_success "Framework updated successfully"
        return 0
}

# ------------------------------------------------------------------------------
# Help
# ------------------------------------------------------------------------------

_update_help() {
        cat <<'EOF'
Usage: bootstrap update [subcommand]

Update repositories, packages, and framework.

Subcommands:
  all           Update everything (default)
  repos         Update package repositories only
  packages      Upgrade installed packages only
  framework     Update the framework itself

Options:
  -h, --help    Show this help

Examples:
  bootstrap update              # Full update
  bootstrap update repos        # Update repositories only
  bootstrap update packages     # Upgrade packages only
  bootstrap update framework    # Update framework only
EOF
}
