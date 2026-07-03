#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: system/packages.sh
# Description: Package manager abstraction layer
# ==============================================================================

# ------------------------------------------------------------------------------
# Package Database
# ------------------------------------------------------------------------------

pkg_update() {

        log_info "Updating package database..."

        pkg update -y

}

pkg_upgrade() {

        log_info "Upgrading installed packages..."

        pkg upgrade -y

}

# ------------------------------------------------------------------------------
# Package Installation
# ------------------------------------------------------------------------------

pkg_install() {

        local package="$1"

        if pkg_is_installed "$package"; then

                log_info "Package already installed: ${package}"

                return 0

        fi

        log_info "Installing package: ${package}"

        pkg install -y "$package" || return 1

        declare -F installer_record_installed_package >/dev/null 2>&1 &&
                installer_record_installed_package "$package"

}

pkg_install_many() {

        local -a to_install=()
        local package

        for package in "$@"; do

                if pkg_is_installed "$package"; then

                        log_info "Package already installed: ${package}"

                else

                        to_install+=("$package")

                fi

        done

        if [[ ${#to_install[@]} -gt 0 ]]; then

                log_info "Installing packages: ${to_install[*]}"

                local failed=0 p

                # Best-effort: a single unresolvable name aborts the whole apt
                # transaction, so on batch failure retry each package on its own
                # to install the ones that are available.
                if ! pkg install -y "${to_install[@]}"; then
                        log_warning "Batch install failed; retrying packages individually"
                        for p in "${to_install[@]}"; do
                                pkg_is_installed "$p" && continue
                                if ! pkg install -y "$p"; then
                                        log_error "Failed to install package: ${p}"
                                        failed=1
                                fi
                        done
                fi

                # Record everything now installed so a later failure rolls it back.
                for p in "${to_install[@]}"; do
                        pkg_is_installed "$p" || continue
                        declare -F installer_record_installed_package >/dev/null 2>&1 &&
                                installer_record_installed_package "$p"
                done

                return "$failed"

        fi

}

# ------------------------------------------------------------------------------
# Package Removal
# ------------------------------------------------------------------------------

pkg_remove() {

        local package="$1"

        log_info "Removing package: ${package}"

        pkg uninstall -y "$package"

}

pkg_reinstall() {

        local package="$1"

        pkg_remove "$package"

        pkg_install "$package"

}

# ------------------------------------------------------------------------------
# Package Information
# ------------------------------------------------------------------------------

pkg_search() {

        local package="$1"

        pkg search "$package"

}

pkg_list() {

        pkg list-installed

}

pkg_is_installed() {

        local package="$1"

        dpkg -s "$package" >/dev/null 2>&1

}

# ------------------------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------------------------

pkg_autoremove() {

        log_info "Removing unused packages..."

        pkg autoremove -y

}

pkg_clean() {

        log_info "Cleaning package cache..."

        pkg autoclean

}

# ------------------------------------------------------------------------------
# Python (pip)
# ------------------------------------------------------------------------------

pip_install() {

        local package="$1"

        log_info "Installing Python package: ${package}"

        pip install "$package"

}

pip_upgrade() {

        local package="$1"

        pip install --upgrade "$package"

}

# ------------------------------------------------------------------------------
# Node.js (npm)
# ------------------------------------------------------------------------------

npm_install() {

        local package="$1"

        log_info "Installing Node package: ${package}"

        npm install -g "$package"

}

npm_update() {

        npm update -g

}

# ------------------------------------------------------------------------------
# Rust (cargo)
# ------------------------------------------------------------------------------

cargo_install() {

        local package="$1"

        log_info "Installing Cargo package: ${package}"

        cargo install "$package"

}

cargo_update() {

        cargo install-update -a

}

# ------------------------------------------------------------------------------
# Go
# ------------------------------------------------------------------------------

go_install() {

        local package="$1"

        log_info "Installing Go package: ${package}"

        go install "$package"

}

# ------------------------------------------------------------------------------
# Generic Helpers
# ------------------------------------------------------------------------------

install_if_missing() {

        local command="$1"
        local package="$2"

        if command_exists "$command"; then

                log_info "${package} already available."

                return 0

        fi

        pkg_install "$package"

}

install_packages() {

        pkg_install_many "$@"

}
