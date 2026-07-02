#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: lib/constants.sh
# Description: Global project constants
# ==============================================================================

# ------------------------------------------------------------------------------
# Project Information
# ------------------------------------------------------------------------------

readonly PROJECT_NAME="Termux Bootstrap"
readonly PROJECT_SLUG="termux-bootstrap"
readonly PROJECT_AUTHOR="0xSEC"
readonly PROJECT_REPOSITORY="https://github.com/0xSECsh/termux-bootstrap"

# ------------------------------------------------------------------------------
# Version
# ------------------------------------------------------------------------------

readonly PROJECT_VERSION="0.1.0"

# ------------------------------------------------------------------------------
# Directories
# ------------------------------------------------------------------------------

readonly HOME_DIR="${HOME}"

readonly CONFIG_DIR="${HOME_DIR}/.config/${PROJECT_SLUG}"

readonly CONFIGS_DIR="${LIB_DIR}/../configs"

readonly CACHE_DIR="${HOME_DIR}/.cache/${PROJECT_SLUG}"

readonly DATA_DIR="${HOME_DIR}/.local/share/${PROJECT_SLUG}"

readonly LOG_DIR="${DATA_DIR}/logs"

readonly BACKUP_DIR="${DATA_DIR}/backup"

readonly TEMP_DIR="/tmp/${PROJECT_SLUG}.$$"

# ------------------------------------------------------------------------------
# Log Files
# ------------------------------------------------------------------------------

readonly LOG_FILE="${LOG_DIR}/install.log"

readonly ERROR_LOG="${LOG_DIR}/error.log"

# ------------------------------------------------------------------------------
# Package Managers
# ------------------------------------------------------------------------------

readonly PKG_MANAGER="pkg"

readonly PIP_MANAGER="pip"

readonly NPM_MANAGER="npm"

readonly CARGO_MANAGER="cargo"

readonly GO_MANAGER="go"

# ------------------------------------------------------------------------------
# Configuration Files
# ------------------------------------------------------------------------------

readonly GITCONFIG="${HOME}/.gitconfig"

readonly ZSHRC="${HOME}/.zshrc"

readonly TMUXCONF="${HOME}/.tmux.conf"

readonly FASTFETCH_CONFIG="${HOME}/.config/fastfetch/config.json"

# ------------------------------------------------------------------------------
# Supported Architectures
# ------------------------------------------------------------------------------

readonly ARCH_ARM64="aarch64"

readonly ARCH_ARM="arm"

readonly ARCH_X86_64="x86_64"

# ------------------------------------------------------------------------------
# URLs
# ------------------------------------------------------------------------------

readonly GITHUB_RAW="https://raw.githubusercontent.com"

readonly GITHUB_API="https://api.github.com"

# ------------------------------------------------------------------------------
# Exit Codes
# ------------------------------------------------------------------------------

readonly EXIT_SUCCESS=0

readonly EXIT_FAILURE=1

readonly EXIT_INVALID_ARGUMENT=2

readonly EXIT_DEPENDENCY_ERROR=3

readonly EXIT_NETWORK_ERROR=4

readonly EXIT_PERMISSION_ERROR=5

# ------------------------------------------------------------------------------
# Default Settings
# ------------------------------------------------------------------------------

readonly DEFAULT_TIMEOUT=30

readonly DEFAULT_RETRIES=3

readonly DEFAULT_LOG_LEVEL="INFO"

readonly DEFAULT_EDITOR="micro"

readonly DEFAULT_SHELL="zsh"

# ------------------------------------------------------------------------------
# Script Behaviour
# ------------------------------------------------------------------------------

readonly TRUE=0

readonly FALSE=1

export \
	PROJECT_NAME \
	PROJECT_SLUG \
	PROJECT_AUTHOR \
	PROJECT_REPOSITORY \
	PROJECT_VERSION \
	HOME_DIR \
	CONFIG_DIR \
	CONFIGS_DIR \
	CACHE_DIR \
	DATA_DIR \
	LOG_DIR \
	BACKUP_DIR \
	TEMP_DIR \
	LOG_FILE \
	ERROR_LOG \
	PKG_MANAGER \
	PIP_MANAGER \
	NPM_MANAGER \
	CARGO_MANAGER \
	GO_MANAGER \
	GITCONFIG \
	ZSHRC \
	TMUXCONF \
	FASTFETCH_CONFIG \
	ARCH_ARM64 \
	ARCH_ARM \
	ARCH_X86_64 \
	GITHUB_RAW \
	GITHUB_API \
	EXIT_SUCCESS \
	EXIT_FAILURE \
	EXIT_INVALID_ARGUMENT \
	EXIT_DEPENDENCY_ERROR \
	EXIT_NETWORK_ERROR \
	EXIT_PERMISSION_ERROR \
	DEFAULT_TIMEOUT \
	DEFAULT_RETRIES \
	DEFAULT_LOG_LEVEL \
	DEFAULT_EDITOR \
	DEFAULT_SHELL \
	TRUE \
	FALSE
