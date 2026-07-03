#!/usr/bin/env bats
# Tests: Configuration engine (read, write, merge, validate, status)

setup() {
	# Create configs dir before framework loads (CONFIGS_DIR is readonly after)
	export TB_CONFIGS_DIR
	TB_CONFIGS_DIR="$(mktemp -d "/tmp/bats-configs.XXXXXX")"
	export CONFIGS_DIR="${TB_CONFIGS_DIR}"
	mkdir -p "${CONFIGS_DIR}/git" "${CONFIGS_DIR}/zsh" "${CONFIGS_DIR}/tmux"
	cat > "${CONFIGS_DIR}/git/.gitconfig" <<'EOF'
[user]
	name = Test User
	email = test@example.com
[core]
	editor = nano
EOF
	cat > "${CONFIGS_DIR}/zsh/.zshrc" <<'EOF'
# ZSH config
export EDITOR=nano
EOF
	cat > "${CONFIGS_DIR}/tmux/.tmux.conf" <<'EOF'
set -g default-terminal 'screen-256color'
EOF
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
	[[ -n "${TB_CONFIGS_DIR:-}" && -d "${TB_CONFIGS_DIR}" ]] && rm -rf "${TB_CONFIGS_DIR}"
}

@test "config_exists returns 0 for known config" {
	config_exists "git" ".gitconfig"
	[[ "$?" -eq 0 ]]
}

@test "config_exists returns 1 for unknown config" {
	! config_exists "nonexistent" "file"
}

@test "config_exists handles empty arguments" {
	! config_exists "" ""
}

@test "config_list lists config files" {
	run config_list
	[[ "$status" -eq 0 ]]
	assert_output_contains "git/.gitconfig"
	assert_output_contains "zsh/.zshrc"
	assert_output_contains "tmux/.tmux.conf"
}

@test "config_count returns correct count" {
	local count
	count="$(config_count)"
	[[ "$count" -eq 3 ]]
}

@test "config_read returns file content" {
	run config_read "git" ".gitconfig"
	[[ "$status" -eq 0 ]]
	assert_output_contains "[user]"
	assert_output_contains "Test User"
}

@test "config_read fails for missing file" {
	run config_read "git" "nonexistent"
	[[ "$status" -eq 1 ]]
}

@test "config_read handles empty arguments" {
	run config_read "" ""
	[[ "$status" -eq 1 ]]
}

@test "config_resolve_path returns correct path" {
	local path
	path="$(config_resolve_path "git" ".gitconfig")"
	[[ "$path" == "${HOME}/.gitconfig" ]]
}

@test "config_resolve_path handles mapped paths" {
	local path
	path="$(config_resolve_path "zsh" ".zshrc")"
	[[ "$path" == "${HOME}/.zshrc" ]]
}

@test "config_resolve_path handles unmapped app" {
	local path
	path="$(config_resolve_path "customapp" "config.json")"
	[[ "$path" == "${HOME}/.config/customapp/config.json" ]]
}

@test "config_resolve_path handles empty arguments" {
	run config_resolve_path "" ""
	[[ "$status" -eq 1 ]]
}

@test "config_write creates file at resolved path" {
	run config_write "git" ".gitconfig" "new content"
	[[ "$status" -eq 0 ]]
	assert_file_exists "${HOME}/.gitconfig"
	assert_file_contains "${HOME}/.gitconfig" "new content"
}

@test "config_write handles empty arguments" {
	run config_write "" "file" "content"
	[[ "$status" -eq 1 ]]
}

@test "config_read_key reads specific key" {
	run config_read_key "git" ".gitconfig" "core.editor"
	[[ "$status" -eq 0 ]]
	[[ "$output" == "nano" ]]
}

@test "config_read_key reads user section key" {
	run config_read_key "git" ".gitconfig" "user.name"
	[[ "$output" == "Test User" ]]
}

@test "config_validate succeeds for valid config" {
	run config_validate "git" ".gitconfig"
	[[ "$status" -eq 0 ]]
}

@test "config_validate fails for missing source" {
	run config_validate "git" "nonexistent"
	[[ "$status" -eq 1 ]]
}

@test "config_validate handles empty arguments" {
	run config_validate "" ""
	[[ "$status" -eq 1 ]]
}

@test "config_validate_all returns valid/total" {
	run config_validate_all
	[[ "$status" -eq 0 ]]
	[[ "$output" == "3/3 configs valid" ]]
}

@test "config_status returns not_installed for missing" {
	run config_status "git" ".gitconfig"
	[[ "$output" == "not_installed" ]]
}

@test "config_status returns up_to_date when files match" {
	config_merge "git" ".gitconfig" false >/dev/null 2>&1 || true
	run config_status "git" ".gitconfig"
	[[ "$output" == "up_to_date" ]]
}

@test "config_status returns modified when files differ" {
	cp "${CONFIGS_DIR}/git/.gitconfig" "${HOME}/.gitconfig"
	echo "# extra" >> "${HOME}/.gitconfig"
	run config_status "git" ".gitconfig"
	[[ "$output" == "modified" ]]
}

@test "config_status returns missing for unknown config" {
	run config_status "git" "nonexistent"
	[[ "$output" == "missing" ]]
}

@test "config_merge creates user config from source" {
	run config_merge "git" ".gitconfig" false
	[[ "$status" -eq 0 ]]
	assert_file_exists "${HOME}/.gitconfig"
}

@test "config_merge with overwrite replaces user config" {
	config_merge "git" ".gitconfig" false >/dev/null 2>&1 || true
	echo "# modified" > "${HOME}/.gitconfig"
	config_merge "git" ".gitconfig" true >/dev/null 2>&1 || true
	assert_file_contains "${HOME}/.gitconfig" "[user]"
	assert_file_not_contains "${HOME}/.gitconfig" "# modified"
}

@test "config_merge without overwrite merges new lines" {
	config_merge "git" ".gitconfig" false
	# Should not fail
	[[ "$?" -eq 0 ]]
}

@test "config_merge_all merges all configs" {
	run config_merge_all false
	[[ "$status" -eq 0 ]]
}

@test "config_info returns detailed info" {
	run config_info "git" ".gitconfig"
	[[ "$status" -eq 0 ]]
	assert_output_contains "Config:       git/.gitconfig"
	assert_output_contains "Description:"
	assert_output_contains "Source:"
	assert_output_contains "Destination:"
	assert_output_contains "Status:"
}

@test "config_info fails for missing config" {
	run config_info "git" "nonexistent"
	[[ "$status" -eq 1 ]]
}

@test "config_write_key writes key value pair" {
	config_write_key "git" ".gitconfig" "user.email" "new@example.com"
	assert_file_contains "${HOME}/.gitconfig" "user.email = new@example.com"
}

@test "config_write_key handles empty arguments" {
	run config_write_key "git" ".gitconfig" "" ""
	[[ "$status" -eq 1 ]]
}
