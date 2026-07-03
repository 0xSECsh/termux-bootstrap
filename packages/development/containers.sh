#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: packages/development/containers.sh
# Description: Container runtime packages
# ==============================================================================

install_development_containers() {

        # Docker and Podman have no supported daemon on a non-rooted Android
        # kernel and are not in the Termux repositories. proot-distro is the
        # standard Termux way to run full Linux distributions.
        pkg_install proot-distro

}
