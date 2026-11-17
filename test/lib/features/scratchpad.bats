#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/scratchpad.sh"
}

teardown() {
  cleanup_test_environment
}

@test "scratchpad.sh - toggle_scratchpad function exists" {
  function_exists toggle_scratchpad
}

@test "scratchpad.sh - toggle_scratchpad with default name succeeds" {
  run toggle_scratchpad
  [[ "${status}" -eq 0 ]]
}

@test "scratchpad.sh - toggle_scratchpad with custom name succeeds" {
  run toggle_scratchpad "htop"
  [[ "${status}" -eq 0 ]]
}

@test "scratchpad.sh - toggle_scratchpad sanitizes name" {
  run toggle_scratchpad 'my scratch!pad'
  [[ "${status}" -eq 0 ]]
}

@test "scratchpad.sh - toggle_scratchpad with command argument" {
  run toggle_scratchpad "htop" "htop"
  [[ "${status}" -eq 0 ]]
}

@test "scratchpad.sh - toggle_scratchpad with dashes and underscores in name" {
  run toggle_scratchpad "my-scratch_pad"
  [[ "${status}" -eq 0 ]]
}

@test "scratchpad.sh - toggle_scratchpad with empty name falls back to default" {
  run toggle_scratchpad ""
  [[ "${status}" -eq 0 ]]
}

@test "scratchpad.sh - a command holding a quote and a hash reaches the session whole, and the popup command holds no hash" {
  # Arrange
  local capture="${TEST_TMPDIR}/popup-cmd" stubs="${TEST_TMPDIR}/stubs"
  mkdir -p "${stubs}"
  printf '#!/bin/sh\nfor a in "$@"; do printf "[%%s]\\n" "$a"; done\n' >"${stubs}/tmux"
  chmod +x "${stubs}/tmux"
  tmux() {
    case "${1}" in
      display-popup) printf '%s' "${!#}" >"${capture}" ;;
      *) printf '\n' ;;
    esac
    return 0
  }
  export -f tmux

  # Act
  toggle_scratchpad notes "echo it's #1"

  # Assert
  run grep -c '#' "${capture}"
  [[ "${output}" == "0" ]] || false
  unset -f tmux
  PATH="${stubs}:${PATH}" run sh -c "$(cat "${capture}")"
  [[ "${lines[3]}" == "[_scratch_notes]" ]] || false
  [[ "${lines[4]}" == "[echo it's #1]" ]]
}
