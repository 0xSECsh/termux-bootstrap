#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/profiles/full.sh
# Description: Full profile (all modules)
# ==============================================================================

install_profile_full() {

	load_module core base

	load_module core editors

	load_module core shell

	load_module core utils

	load_module development python

	load_module development nodejs

	load_module development golang

	load_module development rust

	load_module development containers

	load_module cybersecurity pentest

	load_module cybersecurity osint

	load_module cybersecurity reverse

	load_module cybersecurity mobile

	load_module cybersecurity recon

	load_module cybersecurity wireless

	load_module cybersecurity threat-hunting

	load_module ai ai

	log_success "Full profile installed."

}
