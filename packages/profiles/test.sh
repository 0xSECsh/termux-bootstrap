#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/profiles/test.sh
# Description: Test profile for validation
# ==============================================================================

install_profile_test() {

        load_module core base

        load_module core editors

        log_success "Test profile installed."

}
