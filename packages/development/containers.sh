#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/development/containers.sh
# Description: Container runtime packages
# ==============================================================================

install_development_containers() {

	pkg_install_many \
		docker \
		podman

}
