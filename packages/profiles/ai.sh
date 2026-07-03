#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/profiles/ai.sh
# Description: AI/ML profile
# ==============================================================================

install_profile_ai() {

        load_module core base

        load_module core editors

        load_module core shell

        load_module core utils

        load_module development python

        load_module ai ai

        log_success "AI/ML profile installed."

}
