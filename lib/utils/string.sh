#!/usr/bin/env bash
#
# ==============================================================================
# String Helpers
# ==============================================================================

to_lower() {

	printf "%s\n" "${1,,}"

}

to_upper() {

	printf "%s\n" "${1^^}"

}

trim() {

	local value="$*"

	value="${value#"${value%%[![:space:]]*}"}"
	value="${value%"${value##*[![:space:]]}"}"

	printf "%s\n" "$value"

}
