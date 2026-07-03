#!/usr/bin/env bats
# Tests: Retry utility

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "retry succeeds on first attempt" {
	run retry 3 true
	[[ "$status" -eq 0 ]]
}

@test "retry fails after all attempts exhausted" {
	run retry 3 false
	[[ "$status" -eq 1 ]]
}

@test "retry requires at least one argument (command)" {
	run retry 3
	[[ "$status" -eq 1 ]]
}

@test "retry succeeds when command eventually succeeds" {
	local counter_file="${TB_TMPDIR}/counter.txt"
	echo "0" > "$counter_file"
	local script="${TB_TMPDIR}/eventually_pass.sh"
	cat > "$script" <<SCRIPT
#!/usr/bin/env bash
c="\$(cat "${counter_file}" 2>/dev/null || echo 0)"
c=\$((c + 1))
echo "\$c" > "${counter_file}" 2>/dev/null || true
[ "\$c" -ge 2 ]
SCRIPT
	chmod +x "$script"
	run retry 5 "$script"
	[[ "$status" -eq 0 ]]
}

@test "retry with 1 attempt runs command once" {
	run retry 1 true
	[[ "$status" -eq 0 ]]
	run retry 1 false
	[[ "$status" -eq 1 ]]
}

@test "retry works with complex commands" {
	run retry 3 test -f /etc/passwd
	[[ "$status" -eq 0 ]]
}
