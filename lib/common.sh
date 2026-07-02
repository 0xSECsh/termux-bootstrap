#!/usr/bin/env bash
#
# ==============================================================================
# Termux Bootstrap
# File: lib/common.sh
# Description: Framework loader
# ==============================================================================

if [[ "${TERMUX_BOOTSTRAP_COMMON_LOADED:-false}" == true ]]; then
	return 0
fi

readonly TERMUX_BOOTSTRAP_COMMON_LOADED=true

# ------------------------------------------------------------------------------
# Library Directory
# ------------------------------------------------------------------------------

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
readonly LIB_DIR

# ------------------------------------------------------------------------------
# Loaded Libraries Registry
# ------------------------------------------------------------------------------

declare -Ag LOADED_LIBRARIES=()

# ------------------------------------------------------------------------------
# Library Loader
# ------------------------------------------------------------------------------

load_library() {

	local library="$1"

	if [[ -n "${LOADED_LIBRARIES[$library]:-}" ]]; then
		return 0
	fi

	if [[ ! -f "$library" ]]; then

		printf "ERROR: Unable to load library:\n"
		printf "  %s\n" "$library"

		exit 1

	fi

	# shellcheck disable=SC1090
	source "$library"

	LOADED_LIBRARIES["$library"]=1

}

# ------------------------------------------------------------------------------
# Framework Initialization
# ------------------------------------------------------------------------------

framework_initialize() {

	load_library "$LIB_DIR/core/constants.sh"

	load_library "$LIB_DIR/terminal/colors.sh"

	load_library "$LIB_DIR/terminal/terminal.sh"

	load_library "$LIB_DIR/terminal/logging.sh"

	load_library "$LIB_DIR/core/errors.sh"

	load_library "$LIB_DIR/utils/filesystem.sh"

	load_library "$LIB_DIR/utils/download.sh"

	load_library "$LIB_DIR/utils/archive.sh"

	load_library "$LIB_DIR/utils/hash.sh"

	load_library "$LIB_DIR/utils/json.sh"

	load_library "$LIB_DIR/utils/random.sh"

	load_library "$LIB_DIR/utils/retry.sh"

	load_library "$LIB_DIR/utils/string.sh"

	load_library "$LIB_DIR/utils/time.sh"

	load_library "$LIB_DIR/utils/cache.sh"

	load_library "$LIB_DIR/utils/temp.sh"

	load_library "$LIB_DIR/system/system.sh"

	load_library "$LIB_DIR/system/validation.sh"

	load_library "$LIB_DIR/system/capabilities.sh"

	load_library "$LIB_DIR/system/packages.sh"

	load_library "$LIB_DIR/../modules/module_registry.sh"

	load_library "$LIB_DIR/../modules/module_loader.sh"

	load_library "$LIB_DIR/core/environment.sh"

	load_library "$LIB_DIR/core/version.sh"

	load_library "$LIB_DIR/terminal/progress.sh"

	load_library "$LIB_DIR/terminal/spinner.sh"

	load_library "$LIB_DIR/terminal/ui.sh"

	load_library "$LIB_DIR/core/dispatcher.sh"

	register_error_handlers

	initialize_environment

	initialize_terminal

	system_detect

}
