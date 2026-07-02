#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/profiles/reverse.sh
# Description: Reverse engineering profile
# ==============================================================================

install_profile_reverse() {

	load_module core base

	load_module core editors

	load_module core shell

	load_module core utils

	load_module cybersecurity reverse

	load_module cybersecurity mobile

	log_success "Reverse engineering profile installed."

}
