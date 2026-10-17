#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/has-command.sh"
}

teardown() {
  cleanup_test_environment
}

@test "has-command.sh - has_command is defined" {
  function_exists has_command
}

@test "has-command.sh - has_command is true for an existing command" {
  has_command bash
}

@test "has-command.sh - has_command is false for a missing command" {
  ! has_command this-command-should-not-exist-abcxyz
}
