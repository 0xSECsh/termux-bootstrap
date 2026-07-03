# Assertions library — all assertion functions return 1 on failure

assert_success() {
	local status="${1:-$status}"
	if [[ "$status" -ne 0 ]]; then
		echo "Expected success (exit 0), got exit ${status}" >&2
		[[ -n "${output-}" ]] && echo "Output: ${output}" >&2
		return 1
	fi
	return 0
}

assert_failure() {
	local expected="${1:-1}"
	local actual="${2:-$status}"
	if [[ "$actual" -ne "$expected" ]]; then
		echo "Expected exit ${expected}, got ${actual}" >&2
		[[ -n "${output-}" ]] && echo "Output: ${output}" >&2
		return 1
	fi
	return 0
}

assert_output() {
	local expected="$1"
	if [[ "${output-}" != "$expected" ]]; then
		echo "Expected output: '${expected}'" >&2
		echo "Actual output:   '${output-}'" >&2
		return 1
	fi
	return 0
}

assert_output_contains() {
	local expected="$1"
	if [[ "${output-}" != *"$expected"* ]]; then
		echo "Expected output to contain: '${expected}'" >&2
		echo "Actual output: '${output-}'" >&2
		return 1
	fi
	return 0
}

assert_output_not_contains() {
	local unexpected="$1"
	if [[ "${output-}" == *"$unexpected"* ]]; then
		echo "Expected output NOT to contain: '${unexpected}'" >&2
		echo "Actual output: '${output-}'" >&2
		return 1
	fi
	return 0
}

assert_output_matches() {
	local pattern="$1"
	if [[ ! "${output-}" =~ $pattern ]]; then
		echo "Expected output to match: ${pattern}" >&2
		echo "Actual output: '${output-}'" >&2
		return 1
	fi
	return 0
}

assert_file_exists() {
	if [[ ! -f "$1" ]]; then
		echo "Expected file to exist: $1" >&2
		return 1
	fi
	return 0
}

assert_file_not_exists() {
	if [[ -f "$1" ]]; then
		echo "Expected file NOT to exist: $1" >&2
		return 1
	fi
	return 0
}

assert_dir_exists() {
	if [[ ! -d "$1" ]]; then
		echo "Expected directory to exist: $1" >&2
		return 1
	fi
	return 0
}

assert_dir_not_exists() {
	if [[ -d "$1" ]]; then
		echo "Expected directory NOT to exist: $1" >&2
		return 1
	fi
	return 0
}

assert_file_contains() {
	local file="$1"
	local expected="$2"
	if [[ ! -f "$file" ]]; then
		echo "File does not exist: ${file}" >&2
		return 1
	fi
	if ! grep -qF "$expected" "$file" 2>/dev/null; then
		echo "Expected file to contain: '${expected}'" >&2
		echo "File contents: $(cat "$file" 2>/dev/null)" >&2
		return 1
	fi
	return 0
}

assert_file_not_contains() {
	local file="$1"
	local unexpected="$2"
	if [[ ! -f "$file" ]]; then
		return 0
	fi
	if grep -qF "$unexpected" "$file" 2>/dev/null; then
		echo "Expected file NOT to contain: '${unexpected}'" >&2
		echo "File contents: $(cat "$file" 2>/dev/null)" >&2
		return 1
	fi
	return 0
}

assert_equals() {
	local expected="$1"
	local actual="$2"
	if [[ "$expected" != "$actual" ]]; then
		echo "Expected: '${expected}'" >&2
		echo "Actual:   '${actual}'" >&2
		return 1
	fi
	return 0
}

assert_not_equals() {
	local unexpected="$1"
	local actual="$2"
	if [[ "$unexpected" == "$actual" ]]; then
		echo "Expected values to differ, both are: '${actual}'" >&2
		return 1
	fi
	return 0
}

assert_empty() {
	if [[ -n "${1-}" ]]; then
		echo "Expected empty string, got: '${1}'" >&2
		return 1
	fi
	return 0
}

assert_not_empty() {
	if [[ -z "${1-}" ]]; then
		echo "Expected non-empty string" >&2
		return 1
	fi
	return 0
}

assert_var_set() {
	local var_name="$1"
	if [[ -z "${!var_name-}" && "${!var_name+x}" != "x" ]]; then
		echo "Expected variable to be set: ${var_name}" >&2
		return 1
	fi
	return 0
}


