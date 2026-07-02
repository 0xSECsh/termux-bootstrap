#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: lib/capabilities.sh
# Description: Capability Registry
# ==============================================================================

# ------------------------------------------------------------------------------
# Registry
# ------------------------------------------------------------------------------

has() {

	local capability="${1,,}"

	case "$capability" in

	# ------------------------------------------------------------------
	# Environment
	# ------------------------------------------------------------------

	termux)

		[[ -n "${TERMUX_VERSION:-}" ]]
		;;

	android)

		[[ -d "/system" ]]
		;;

	root)

		[[ "$(id -u)" -eq 0 ]]
		;;

	internet)

		check_internet
		;;

	# ------------------------------------------------------------------
	# Package Managers
	# ------------------------------------------------------------------

	pkg)

		command_exists pkg
		;;

	pip)

		command_exists pip
		;;

	npm)

		command_exists npm
		;;

	cargo)

		command_exists cargo
		;;

	go)

		command_exists go
		;;

	# ------------------------------------------------------------------
	# Languages
	# ------------------------------------------------------------------

	python)

		command_exists python
		;;

	node)

		command_exists node
		;;

	rust)

		command_exists rustc
		;;

	# ------------------------------------------------------------------
	# Shells
	# ------------------------------------------------------------------

	bash)

		command_exists bash
		;;

	zsh)

		command_exists zsh
		;;

	# ------------------------------------------------------------------
	# Editors
	# ------------------------------------------------------------------

	micro)

		command_exists micro
		;;

	nano)

		command_exists nano
		;;

	vim)

		command_exists vim
		;;

	nvim | neovim)

		command_exists nvim
		;;

	# ------------------------------------------------------------------
	# Utilities
	# ------------------------------------------------------------------

	git)

		command_exists git
		;;

	curl)

		command_exists curl
		;;

	wget)

		command_exists wget
		;;

	jq)

		command_exists jq
		;;

	yq)

		command_exists yq
		;;

	tmux)

		command_exists tmux
		;;

	fastfetch)

		command_exists fastfetch
		;;

	tree)

		command_exists tree
		;;

	# ------------------------------------------------------------------
	# Cybersecurity
	# ------------------------------------------------------------------

	nmap)

		command_exists nmap
		;;

	tcpdump)

		command_exists tcpdump
		;;

	ffmpeg)

		command_exists ffmpeg
		;;

	# ------------------------------------------------------------------
	# Termux API
	# ------------------------------------------------------------------

	termux-api)

		command_exists termux-battery-status
		;;

	storage)

		[[ -d "$HOME/storage" ]]
		;;

	# ------------------------------------------------------------------
	# Architecture
	# ------------------------------------------------------------------

	arm64)

		[[ "${SYSTEM_ARCH:-$(uname -m)}" == "aarch64" ]]
		;;

	arm)

		[[ "${SYSTEM_ARCH:-$(uname -m)}" == "arm" ]]
		;;

	x86_64)

		[[ "${SYSTEM_ARCH:-$(uname -m)}" == "x86_64" ]]
		;;

	*)

		return 1
		;;

	esac

}

# ------------------------------------------------------------------------------
# Missing
# ------------------------------------------------------------------------------

missing() {

	! has "$1"

}

# ------------------------------------------------------------------------------
# Require
# ------------------------------------------------------------------------------

require() {

	local capability="$1"

	if ! has "$capability"; then

		fatal "Required capability not available: ${capability}"

	fi

}

# ------------------------------------------------------------------------------
# Assert
# ------------------------------------------------------------------------------

assert() {

	require "$@"

}
