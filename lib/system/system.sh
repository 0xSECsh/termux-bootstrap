#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: lib/system.sh
# Description: System information helpers
# ==============================================================================

: "${PROJECT_NAME:?}"
: "${PROJECT_VERSION:?}"

# ------------------------------------------------------------------------------
# Operating System
# ------------------------------------------------------------------------------

get_os() {

	uname -s

}

get_kernel() {

	uname -r

}

get_architecture() {

	uname -m

}

# ------------------------------------------------------------------------------
# Android
# ------------------------------------------------------------------------------

get_android_version() {

	command -v getprop >/dev/null 2>&1 || return 0

	getprop ro.build.version.release

}

get_android_sdk() {

	command -v getprop >/dev/null 2>&1 || return 0

	getprop ro.build.version.sdk

}

get_device_model() {

	command -v getprop >/dev/null 2>&1 || return 0

	getprop ro.product.model

}

get_device_manufacturer() {

	command -v getprop >/dev/null 2>&1 || return 0

	getprop ro.product.manufacturer

}

# ------------------------------------------------------------------------------
# Shell
# ------------------------------------------------------------------------------

get_shell() {

	basename "$SHELL"

}

get_bash_version() {

	bash --version | head -n1

}

# ------------------------------------------------------------------------------
# CPU
# ------------------------------------------------------------------------------

get_cpu() {

	if [[ -r /proc/cpuinfo ]]; then
		grep -m1 "model name" /proc/cpuinfo | cut -d':' -f2 | xargs ||
			grep -m1 "Hardware" /proc/cpuinfo | cut -d':' -f2 | xargs
	elif command -v sysctl >/dev/null 2>&1; then
		sysctl -n machdep.cpu.brand_string 2>/dev/null
	fi

}

get_cpu_cores() {

	if command -v nproc >/dev/null 2>&1; then
		nproc
	else
		getconf _NPROCESSORS_ONLN
	fi

}

# ------------------------------------------------------------------------------
# Memory
# ------------------------------------------------------------------------------

get_memory_total() {

	if [[ -r /proc/meminfo ]]; then
		awk '/MemTotal/ { printf "%.0f MB\n", $2 / 1024 }' /proc/meminfo
	elif command -v sysctl >/dev/null 2>&1; then
		local memory_bytes

		memory_bytes="$(sysctl -n hw.memsize 2>/dev/null)"

		[[ -n "$memory_bytes" ]] || return 0

		awk "BEGIN { printf \"%.0f MB\n\", $memory_bytes / 1024 / 1024 }"
	fi

}

# ------------------------------------------------------------------------------
# Storage
# ------------------------------------------------------------------------------

get_storage_total() {

	df -h "$HOME" | awk 'NR==2 {print $2}'

}

get_storage_available() {

	df -h "$HOME" | awk 'NR==2 {print $4}'

}

# ------------------------------------------------------------------------------
# Termux
# ------------------------------------------------------------------------------

get_termux_version() {

	if command -v termux-info >/dev/null 2>&1; then
		termux-info | awk -F': ' '/TERMUX_VERSION/ {print $2}'
	else
		echo "Unknown"
	fi

}

# ------------------------------------------------------------------------------
# Network
# ------------------------------------------------------------------------------

get_hostname() {

	hostname

}

# ------------------------------------------------------------------------------
# Package Managers
# ------------------------------------------------------------------------------

get_pkg_version() {

	command -v pkg >/dev/null 2>&1 || return 0

	pkg --version 2>/dev/null | head -n1

}

get_python_version() {

	python --version 2>/dev/null

}

get_go_version() {

	go version 2>/dev/null

}

get_rust_version() {

	rustc --version 2>/dev/null

}

get_node_version() {

	node --version 2>/dev/null

}

# ------------------------------------------------------------------------------
# System Detection
# ------------------------------------------------------------------------------

system_detect() {

	SYSTEM_OS="$(get_os)"
	SYSTEM_KERNEL="$(get_kernel)"
	SYSTEM_ARCH="$(get_architecture)"

	export SYSTEM_OS
	export SYSTEM_KERNEL
	export SYSTEM_ARCH

}

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------

system_summary() {

	cat <<EOF

Project       : ${PROJECT_NAME}
Version       : ${PROJECT_VERSION}

OS            : $(get_os)
Kernel        : $(get_kernel)
Architecture  : $(get_architecture)

Android       : $(get_android_version)
SDK           : $(get_android_sdk)

Manufacturer  : $(get_device_manufacturer)
Model         : $(get_device_model)

CPU           : $(get_cpu)
CPU Cores     : $(get_cpu_cores)

Memory        : $(get_memory_total)

Storage       : $(get_storage_total)
Available     : $(get_storage_available)

Shell         : $(get_shell)

Termux        : $(get_termux_version)

EOF

}
