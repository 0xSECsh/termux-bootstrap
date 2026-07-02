#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/cybersecurity/recon.sh
# Description: Reconnaissance and information gathering packages
# ==============================================================================

install_cybersecurity_recon() {

	pkg_install_many \
		subfinder \
		httpx \
		nuclei \
		naabu \
		dnsx \
		assetfinder \
		amass

}
