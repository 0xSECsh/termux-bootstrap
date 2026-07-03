# Test fixtures for creating isolated test environments

# ---------------------------------------------------------------
# Standard helpers: used across module/profile/installer tests
# ---------------------------------------------------------------

# Create a module file in PACKAGES_DIR
# Usage: _create_module <category> <name> [description] [depends]
_create_module() {
	local cat="$1" name="$2" desc="${3:-}" deps="${4:-}"
	local dir="${PACKAGES_DIR}/${cat}"
	mkdir -p "$dir"
	local func_name="install_${cat}_${name//-/_}"
	cat > "${dir}/${name}.sh" <<EOF
#!/usr/bin/env bash
# Description: ${desc}
# Depends: ${deps}

${func_name}() {
	return 0
}
EOF
}

# Create a profile file in PACKAGES_DIR/profiles
# Usage: _create_profile <name> [modules...]
_create_profile() {
	local name="$1"
	shift
	local modules=("$@")
	local dir="${PACKAGES_DIR}/profiles"
	mkdir -p "$dir"
	{
		printf '#!/usr/bin/env bash\n'
		printf '# Description: Profile %s\n\n' "$name"
		printf 'install_profile_%s() {\n' "$name"
		local m
		for m in "${modules[@]}"; do
			# Match the 8-space indentation real profiles use (shfmt -i 8),
			# so extraction is exercised against production formatting.
			printf '        load_module %s\n' "$m"
		done
		printf '}\n'
	} > "${dir}/${name}.sh"
}
