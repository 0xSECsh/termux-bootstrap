# Filesystem helpers for tests

# Write content to a file, creating parent directories
write_test_file() {
	local file="$1"
	local content="$2"
	mkdir -p "$(dirname "$file")"
	printf '%s\n' "$content" > "$file"
}

# Get the size of a file in bytes
get_file_size() {
	local file="$1"
	stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo "0"
}

# Create a test module file that's valid for loading
create_test_module_file() {
	local file="$1"
	local func_name="$2"
	cat > "$file" <<EOF
#!/usr/bin/env bash
# Description: Test module for ${func_name}

${func_name}() {
	return 0
}
EOF
}
