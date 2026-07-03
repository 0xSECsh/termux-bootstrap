# Mock framework for BATS tests
# Provides mock_command() and standard mocks for external tools.

MOCK_DIR=""

mock_init() {
	MOCK_DIR="$(mktemp -d "/tmp/bats-mocks.XXXXXX")"
	export MOCK_DIR
	export PATH="${MOCK_DIR}:${PATH}"
}

mock_cleanup() {
	[[ -n "${MOCK_DIR}" && -d "${MOCK_DIR}" ]] && rm -rf "${MOCK_DIR}"
	MOCK_DIR=""
}

# Create a mock script at the given name.
# Usage: mock_command <name> [exit_code] [stdout] [stderr]
# If no args given, creates a no-op mock (exits 0).
# Use --follow to call the real command after logging.
mock_command() {
	local name="$1"
	shift
	[[ -z "${MOCK_DIR}" ]] && { echo "mock_init not called" >&2; return 1; }

	local exit_code=0
	local stdout=""
	local stderr=""
	local follow=false
	local var_mode=false

	while [[ $# -gt 0 ]]; do
		case "$1" in
			--exit) exit_code="$2"; shift 2 ;;
			--stdout) stdout="$2"; shift 2 ;;
			--stderr) stderr="$2"; shift 2 ;;
			--follow) follow=true; shift ;;
			--var) var_mode=true; shift ;;
			*) break ;;
		esac
	done

	# If --var mode, read from environment variable
	if $var_mode; then
		local var_name="${name}_EXIT"
		exit_code="${!var_name:-0}"
		local out_var="${name}_STDOUT"
		stdout="${!out_var:-}"
		local err_var="${name}_STDERR"
		stderr="${!err_var:-}"
	fi

	local mock_file="${MOCK_DIR}/${name}"

	cat > "$mock_file" << 'SCRIPT'
#!/usr/bin/env bash
SCRIPT
	# Add call logging
	cat >> "$mock_file" << SCRIPT
echo "MOCK:${name}:\$@" >> "${MOCK_DIR}/${name}.log" 2>/dev/null || true
SCRIPT

	if [[ -n "$stdout" ]]; then
		printf 'printf "%%s\\n" %q\n' "$stdout" >> "$mock_file"
	fi

	if [[ -n "$stderr" ]]; then
		printf 'printf "%%s\\n" %q >&2\n' "$stderr" >> "$mock_file"
	fi

	if [[ "$exit_code" -ne 0 ]]; then
		echo "exit $exit_code" >> "$mock_file"
	fi

	chmod +x "$mock_file"
}

# ---- Standard mocks ----

mock_standard_tools() {
	mock_command pkg
	mock_command dpkg
	mock_command pip
	mock_command npm
	mock_command cargo
	mock_command go
	mock_command git
	mock_command curl
	mock_command wget
	mock_command jq
	mock_command tput --exit 0
	# Set tput to return 80 for cols and 24 for lines via mock script
	cat >> "${MOCK_DIR}/tput" << 'TPUTSCRIPT'
case "$1" in
	cols) echo 80 ;;
	lines) echo 24 ;;
esac
TPUTSCRIPT
	mock_command clear
	mock_command reset
	mock_command ping --exit 0
	mock_command getprop
	mock_command termux-info
	mock_command shred --exit 1
	mock_command nproc --stdout 8
	# Smarter stat mock: handle %s (size) and %Y/%m (timestamp)
	cat > "${MOCK_DIR}/stat" << 'STATSCRIPT'
#!/usr/bin/env bash
case "$*" in
	*%s*) echo 12345 ;;
	*%[Ym]*) echo "$(date +%s)" ;;
	*) echo 0 ;;
esac
STATSCRIPT
	chmod +x "${MOCK_DIR}/stat"
	mock_command uname --var
	mock_command hostname --stdout "test-host"
}

# Create a smarter uname mock
mock_command_uname() {
	[[ -z "${MOCK_DIR}" ]] && { echo "mock_init not called" >&2; return 1; }
	local os="${1:-Linux}"
	local kernel="${2:-6.1.0}"
	local arch="${3:-aarch64}"

	cat > "${MOCK_DIR}/uname" << SCRIPT
#!/usr/bin/env bash
case "\$1" in
	-s) printf '%s\n' "$os" ;;
	-r) printf '%s\n' "$kernel" ;;
	-m) printf '%s\n' "$arch" ;;
	*) printf '%s\n' "$os" ;;
esac
SCRIPT
	chmod +x "${MOCK_DIR}/uname"
}

# Mock has for capabilities - fix specific capabilities
mock_has_termux() {
	export TERMUX_VERSION="0.118.0"
}

mock_has_not_termux() {
	unset TERMUX_VERSION
}
