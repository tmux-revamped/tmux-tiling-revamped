#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/platform.sh"
  UNAME_CALLS="${TEST_TMPDIR}/uname-calls"
  : >"${UNAME_CALLS}"
}

teardown() {
  cleanup_test_environment
}

uname() {
  printf '%s\n' "$*" >>"${UNAME_CALLS}"
  command uname "$@"
}

@test "platform-memo - repeated checks run uname -s once" {
  # Arrange
  is_macos || true

  # Act
  is_linux || true
  is_bsd || true

  # Assert
  [ "$(grep -c -- '-s' "${UNAME_CALLS}")" -eq 1 ]
}

@test "platform-memo - repeated apple silicon checks run uname -m once" {
  # Arrange
  is_apple_silicon || true

  # Act
  is_apple_silicon || true

  # Assert
  [ "$(grep -c -- '-m' "${UNAME_CALLS}")" -eq 1 ]
}

@test "platform-memo - platform_os after a check reuses the cached value" {
  # Arrange
  is_macos || true

  # Act
  local os
  os="$(platform_os)"

  # Assert
  [ "${os}" = "$(command uname -s)" ]
  [ "$(grep -c -- '-s' "${UNAME_CALLS}")" -eq 1 ]
}
