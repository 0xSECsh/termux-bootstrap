#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: utils/cache.sh
# Description: Cache management utilities
# ==============================================================================

: "${CACHE_DIR:?}"

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------

cache_initialize() {

	create_directory "$CACHE_DIR"

}

# ------------------------------------------------------------------------------
# Cache Path
# ------------------------------------------------------------------------------

cache_path() {

	local key="$1"

	printf "%s/%s.cache\n" "$CACHE_DIR" "$key"

}

# ------------------------------------------------------------------------------
# Cache Exists
# ------------------------------------------------------------------------------

cache_exists() {

	local key="$1"
	local file

	file="$(cache_path "$key")"

	[[ -f "$file" ]]

}

# ------------------------------------------------------------------------------
# Get
# ------------------------------------------------------------------------------

cache_get() {

	local key="$1"

	local file

	file="$(cache_path "$key")"

	[[ -f "$file" ]] || return 1

	cat "$file"

}

# ------------------------------------------------------------------------------
# Set
# ------------------------------------------------------------------------------

cache_set() {

	local key="$1"
	local file
	local tmp

	shift

	file="$(cache_path "$key")"
	tmp="${file}.$$.$RANDOM"

	printf "%s\n" "$*" >"$tmp"

	mv -- "$tmp" "$file"

}

# ------------------------------------------------------------------------------
# Delete
# ------------------------------------------------------------------------------

cache_delete() {

	local key="$1"
	local file

	file="$(cache_path "$key")"

	rm -f -- "$file"

}

# ------------------------------------------------------------------------------
# Clear
# ------------------------------------------------------------------------------

cache_clear() {

	[[ -n "$CACHE_DIR" && "$CACHE_DIR" != "/" ]] || return 1

	find "$CACHE_DIR" \
		-mindepth 1 \
		-maxdepth 1 \
		-exec rm -rf -- {} +

}

# ------------------------------------------------------------------------------
# List
# ------------------------------------------------------------------------------

cache_list() {

	find "$CACHE_DIR" \
		-maxdepth 1 \
		-name "*.cache" \
		-type f 2>/dev/null | while IFS= read -r file; do
		basename "$file"
	done

}

# ------------------------------------------------------------------------------
# Size
# ------------------------------------------------------------------------------

cache_size() {

	if [[ -d "$CACHE_DIR" ]]; then

		du -sh "$CACHE_DIR" 2>/dev/null | awk '{print $1}'

	else

		printf "0B\n"

	fi

}

# ------------------------------------------------------------------------------
# Age
# ------------------------------------------------------------------------------

cache_age() {

	local key="$1"

	local file

	file="$(cache_path "$key")"

	[[ -f "$file" ]] || return 1

	if stat -c "%Y" "$file" >/dev/null 2>&1; then
		stat -c "%Y" "$file"
	else
		stat -f "%m" "$file"
	fi

}

# ------------------------------------------------------------------------------
# Expiration
# ------------------------------------------------------------------------------

cache_expired() {

	local key="$1"
	local ttl="$2"

	local file
	local now
	local modified

	file="$(cache_path "$key")"

	[[ -f "$file" ]] || return 0

	if stat -c "%Y" "$file" >/dev/null 2>&1; then
		modified="$(stat -c "%Y" "$file")"
	else
		modified="$(stat -f "%m" "$file")"
	fi

	now="$(date +%s)"

	((now - modified > ttl))

}

# ------------------------------------------------------------------------------
# Remember
# ------------------------------------------------------------------------------

cache_remember() {

	local key="$1"
	local ttl="$2"

	shift 2

	if cache_exists "$key"; then

		if ! cache_expired "$key" "$ttl"; then

			cache_get "$key"

			return 0

		fi

	fi

	local output

	output="$("$@")"

	cache_set "$key" "$output"

	printf "%s\n" "$output"

}

# ------------------------------------------------------------------------------
# Statistics
# ------------------------------------------------------------------------------

cache_statistics() {

	printf "Cache Directory : %s\n" "$CACHE_DIR"

	printf "Cache Size      : %s\n" "$(cache_size)"

	printf "Entries         : "

	find "$CACHE_DIR" \
		-name "*.cache" \
		-type f | wc -l

}
