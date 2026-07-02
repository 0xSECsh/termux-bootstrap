#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/profiles/developer.sh
# Description: Developer profile
# ==============================================================================

install_profile_developer() {

	load_module core base

	load_module core editors

	load_module core shell

	load_module core utils

	load_module development python

	load_module development nodejs

	load_module development golang

	load_module development rust

	load_module development containers

	log_success "Developer profile installed."

}
