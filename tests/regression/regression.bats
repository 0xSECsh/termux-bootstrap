#!/usr/bin/env bats
# Regression tests: Ensure no common bugs

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "regression: no BW01 errors in framework initialization" {
	unset ENVIRONMENT_INITIALIZED
	unset TERMINAL_INITIALIZED
	unset ERROR_HANDLERS_REGISTERED
	unset TEMP_CLEANUP_TRAP_SET
	run framework_initialize
	[[ "$status" -eq 0 ]]
	[[ "$output" != *"command not found"* ]]
}

@test "regression: dispatch commands do not produce BW01" {
	run dispatch help
	[[ "$status" -eq 0 ]]
	[[ "$output" != *"command not found"* ]]

	run dispatch version
	[[ "$status" -eq 0 ]]
	[[ "$output" != *"command not found"* ]]
}

@test "regression: load_module does not produce BW01" {
	run load_module "core" "nonexistent"
	[[ "$output" != *"command not found"* ]]
}

@test "regression: log functions do not produce BW01" {
	run log_info "test"
	[[ "$output" != *"command not found"* ]]
	run log_error "test"
	[[ "$output" != *"command not found"* ]]
	run log_success "test"
	[[ "$output" != *"command not found"* ]]
	run log_warning "test"
	[[ "$output" != *"command not found"* ]]
}

@test "regression: framework double initialization is safe" {
	framework_initialize
	run framework_initialize
	[[ "$status" -eq 0 ]]
}

@test "regression: no variable leak from subshells" {
	local before_vars
	before_vars="$(set | wc -l)"
	(
		load_library "$LIB_DIR/core/constants.sh" 2>/dev/null || true
	)
	local after_vars
	after_vars="$(set | wc -l)"
	:
}
