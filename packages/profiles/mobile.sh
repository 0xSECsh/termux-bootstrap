#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/profiles/mobile.sh
# Description: Mobile development profile
# ==============================================================================

install_profile_mobile() {

        load_module core base

        load_module core editors

        load_module core shell

        load_module core utils

        load_module development python

        load_module cybersecurity mobile

        log_success "Mobile profile installed."

}
