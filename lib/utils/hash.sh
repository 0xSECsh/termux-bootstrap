#!/usr/bin/env bash
#
# ==============================================================================
# Hash Helpers
# ==============================================================================

sha256() {

	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum -- "$1" | awk '{print $1}'
	else
		shasum -a 256 -- "$1" | awk '{print $1}'
	fi

}

sha1() {

	if command -v sha1sum >/dev/null 2>&1; then
		sha1sum -- "$1" | awk '{print $1}'
	else
		shasum -a 1 -- "$1" | awk '{print $1}'
	fi

}

md5() {

	if command -v md5sum >/dev/null 2>&1; then
		md5sum -- "$1" | awk '{print $1}'
	else
		md5 -q "$1"
	fi

}
