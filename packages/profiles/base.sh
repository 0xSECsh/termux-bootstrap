#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/profiles/base.sh
# Description: Base profile with essential packages only
# ==============================================================================

install_profile_base() {

        load_module core base

        log_success "Base profile installed."

}
