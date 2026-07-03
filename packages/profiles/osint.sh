#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/profiles/osint.sh
# Description: OSINT profile
# ==============================================================================

install_profile_osint() {

        load_module core base

        load_module core editors

        load_module core shell

        load_module core utils

        load_module cybersecurity osint

        load_module cybersecurity recon

        log_success "OSINT profile installed."

}
