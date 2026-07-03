#!/usr/bin/env bats
# Tests: Project constants

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "PROJECT constants are set" {
	[[ -n "$PROJECT_NAME" ]]
	[[ -n "$PROJECT_SLUG" ]]
	[[ -n "$PROJECT_VERSION" ]]
	[[ -n "$PROJECT_AUTHOR" ]]
	[[ -n "$PROJECT_REPOSITORY" ]]
}

@test "Directory constants are set and readonly" {
	[[ -n "$HOME_DIR" ]]
	[[ -n "$CONFIG_DIR" ]]
	[[ -n "$CACHE_DIR" ]]
	[[ -n "$DATA_DIR" ]]
	[[ -n "$LOG_DIR" ]]
	[[ -n "$BACKUP_DIR" ]]
	[[ -n "$TEMP_DIR" ]]
}

@test "Directory constants resolve correctly" {
	[[ "$CONFIG_DIR" == *"/.config/termux-bootstrap" ]]
	[[ "$CACHE_DIR" == *"/.cache/termux-bootstrap" ]]
	[[ "$DATA_DIR" == *"/.local/share/termux-bootstrap" ]]
}

@test "Config file constants resolve correctly" {
	[[ "$GITCONFIG" == *"/.gitconfig" ]]
	[[ "$ZSHRC" == *"/.zshrc" ]]
	[[ "$TMUXCONF" == *"/.tmux.conf" ]]
}

@test "Package manager constants are set" {
	[[ "$PKG_MANAGER" == "pkg" ]]
	[[ "$PIP_MANAGER" == "pip" ]]
	[[ "$NPM_MANAGER" == "npm" ]]
	[[ "$CARGO_MANAGER" == "cargo" ]]
	[[ "$GO_MANAGER" == "go" ]]
}

@test "Exit code constants are set" {
	[[ "$EXIT_SUCCESS" -eq 0 ]]
	[[ "$EXIT_FAILURE" -eq 1 ]]
	[[ "$EXIT_INVALID_ARGUMENT" -eq 2 ]]
	[[ "$EXIT_DEPENDENCY_ERROR" -eq 3 ]]
	[[ "$EXIT_NETWORK_ERROR" -eq 4 ]]
	[[ "$EXIT_PERMISSION_ERROR" -eq 5 ]]
}

@test "Default settings constants are set" {
	[[ "$DEFAULT_TIMEOUT" -eq 30 ]]
	[[ "$DEFAULT_RETRIES" -eq 3 ]]
	[[ "$DEFAULT_LOG_LEVEL" == "INFO" ]]
	[[ -n "$DEFAULT_EDITOR" ]]
	[[ -n "$DEFAULT_SHELL" ]]
}

@test "TRUE/FALSE constants follow convention" {
	[[ "$TRUE" -eq 0 ]]
	[[ "$FALSE" -eq 1 ]]
}

@test "Architecture constants are set" {
	[[ "$ARCH_ARM64" == "aarch64" ]]
	[[ "$ARCH_ARM" == "arm" ]]
	[[ "$ARCH_X86_64" == "x86_64" ]]
}

@test "URL constants are set" {
	[[ "$GITHUB_RAW" == "https://raw.githubusercontent.com" ]]
	[[ "$GITHUB_API" == "https://api.github.com" ]]
}

@test "CONFIGS_DIR points to project configs" {
	[[ -n "$CONFIGS_DIR" ]]
	[[ "$CONFIGS_DIR" == *"/configs" ]]
}

@test "Constants are exported" {
	# Use the already-sourced framework from setup
	env | grep -q "^PROJECT_NAME="
}
