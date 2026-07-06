#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/profiles/researcher.sh
# Description: Researcher profile with OSINT and recon tools
# ==============================================================================

install_profile_researcher() {

        load_module core base

        load_module core editors

        load_module core shell

        load_module core utils

        load_module cybersecurity osint

        load_module cybersecurity recon

        load_module cybersecurity threat-hunting

        log_success "Researcher profile installed."

}
