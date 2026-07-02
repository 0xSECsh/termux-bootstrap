#!/usr/bin/env bash
#
# ==============================================================================
# Download Helpers
# ==============================================================================

download() {

	local url="$1"
	local output="$2"

	[[ -n "$output" ]] || die "Output path is required"

	curl -fsSL -o "$output" -- "$url"

}

download_quiet() {

	local url="$1"
	local output="$2"

	curl -fsSL --silent -o "$output" -- "$url"

}
