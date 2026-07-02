#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: core/version.sh
# Description: Version and project information
# ==============================================================================

: "${PROJECT_NAME:?}"
: "${PROJECT_VERSION:?}"
: "${PROJECT_AUTHOR:?}"
: "${PROJECT_REPOSITORY:?}"

# ------------------------------------------------------------------------------
# Version
# ------------------------------------------------------------------------------

show_version() {

	printf "%s %s\n" \
		"$PROJECT_NAME" \
		"$PROJECT_VERSION"

}

# ------------------------------------------------------------------------------
# Banner
# ------------------------------------------------------------------------------

show_banner() {

	cat <<EOF

████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗
╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝
   ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝
   ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗
   ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝

$PROJECT_NAME
Version : $PROJECT_VERSION

EOF

}

# ------------------------------------------------------------------------------
# About
# ------------------------------------------------------------------------------

show_about() {

	cat <<EOF

Project     : $PROJECT_NAME
Version     : $PROJECT_VERSION
Author      : $PROJECT_AUTHOR

Repository
----------

$PROJECT_REPOSITORY

Description
-----------

A modular and extensible bootstrap framework for Termux.

Designed for:

 • Development
 • Cybersecurity
 • OSINT
 • Reverse Engineering
 • Mobile Pentesting
 • AI Tools

EOF

}

# ------------------------------------------------------------------------------
# License
# ------------------------------------------------------------------------------

show_license() {

	cat <<EOF

This project is distributed under the MIT License.

Copyright (c) $(date +%Y) $PROJECT_AUTHOR

See the LICENSE file for details.

EOF

}

# ------------------------------------------------------------------------------
# System Information
# ------------------------------------------------------------------------------

show_build_info() {

	cat <<EOF

Project      : $PROJECT_NAME
Version      : $PROJECT_VERSION

Architecture : $(get_architecture)
OS           : $(get_os)
Kernel       : $(get_kernel)

Shell        : $(get_shell)
Termux       : $(get_termux_version)

EOF

}

# ------------------------------------------------------------------------------
# CLI Information
# ------------------------------------------------------------------------------

show_help_header() {

	show_banner

	printf "Usage:\n\n"

	printf "  bootstrap.sh [OPTIONS]\n\n"

}

# ------------------------------------------------------------------------------
# Full Information
# ------------------------------------------------------------------------------

show_info() {

	show_banner

	show_about

	printf "\n"

	show_build_info

}
