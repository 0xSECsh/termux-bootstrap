#!/usr/bin/env bats
# Tests: Archive extraction

setup() {
	source "${BATS_TEST_DIRNAME}/../helpers/common.bash"
	common_setup
}

teardown() {
	common_teardown
}

@test "extract returns 1 for unknown format" {
	run extract "${TB_TMPDIR}/unknown.xyz"
	[[ "$status" -eq 1 ]]
}

@test "extract handles tar.gz format" {
	echo "test" > "${TB_TMPDIR}/testfile.txt"
	tar -czf "${TB_TMPDIR}/test.tar.gz" -C "${TB_TMPDIR}" testfile.txt
	run extract "${TB_TMPDIR}/test.tar.gz"
	[[ "$status" -eq 0 ]]
}

@test "extract handles zip format" {
	if ! command -v zip &>/dev/null; then
		skip "zip not available"
	fi
	echo "test" > "${TB_TMPDIR}/testfile.txt"
	(cd "${TB_TMPDIR}" && zip -q test.zip testfile.txt)
	run extract "${TB_TMPDIR}/test.zip"
	[[ "$status" -eq 0 ]]
}

@test "extract handles tgz format" {
	echo "test" > "${TB_TMPDIR}/testfile.txt"
	tar -czf "${TB_TMPDIR}/test.tgz" -C "${TB_TMPDIR}" testfile.txt
	run extract "${TB_TMPDIR}/test.tgz"
	[[ "$status" -eq 0 ]]
}

@test "extract handles tar.xz format" {
	echo "test" > "${TB_TMPDIR}/testfile.txt"
	tar -cJf "${TB_TMPDIR}/test.tar.xz" -C "${TB_TMPDIR}" testfile.txt
	run extract "${TB_TMPDIR}/test.tar.xz"
	[[ "$status" -eq 0 ]]
}

@test "extract handles tar format" {
	echo "test" > "${TB_TMPDIR}/testfile.txt"
	tar -cf "${TB_TMPDIR}/test.tar" -C "${TB_TMPDIR}" testfile.txt
	run extract "${TB_TMPDIR}/test.tar"
	[[ "$status" -eq 0 ]]
}
