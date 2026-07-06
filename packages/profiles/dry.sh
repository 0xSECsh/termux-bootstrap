#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/profiles/dry.sh
# Description: Dry-run validation profile
# ==============================================================================

install_profile_dry() {

        load_module core base

        load_module core editors

        load_module core shell

        load_module core utils

        log_success "Dry-run profile validated."

}
