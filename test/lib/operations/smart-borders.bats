#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/smart-borders.sh"
  CAPTURE="${TEST_TMPDIR}/border.txt"
  export CAPTURE
}

teardown() {
  cleanup_test_environment
}

_capture_set_window_option() {
  set_window_option() { printf '%s %s\n' "$1" "$2" >> "${CAPTURE}"; }
  export -f set_window_option
}

@test "smart-borders.sh - smart_borders function exists" {
  function_exists smart_borders
}

@test "smart-borders.sh - source guard prevents double loading" {
  [[ "${_TILING_REVAMPED_SMART_BORDERS_LOADED}" == "1" ]]
}

@test "smart-borders.sh - no-op when the option is disabled" {
  export MOCK_TMUX_OPTION_VALUE=""
  _capture_set_window_option
  run smart_borders
  [[ "${status}" -eq 0 ]]
  [[ ! -f "${CAPTURE}" ]]
}

@test "smart-borders.sh - hides borders for a single pane" {
  is_option_enabled() { return 0; }
  export -f is_option_enabled
  export MOCK_WINDOW_PANES="1"
  _capture_set_window_option
  run smart_borders
  [[ "${status}" -eq 0 ]]
  [[ "$(cat "${CAPTURE}")" == "pane-border-status off" ]]
}

@test "smart-borders.sh - restores borders for multiple panes" {
  is_option_enabled() { return 0; }
  get_tmux_option() { echo "top"; }
  export -f is_option_enabled get_tmux_option
  export MOCK_WINDOW_PANES="3"
  _capture_set_window_option
  run smart_borders
  [[ "${status}" -eq 0 ]]
  [[ "$(cat "${CAPTURE}")" == "pane-border-status top" ]]
}

@test "smart-borders.sh - honors a custom restore value" {
  is_option_enabled() { return 0; }
  get_tmux_option() { echo "bottom"; }
  export -f is_option_enabled get_tmux_option
  export MOCK_WINDOW_PANES="2"
  _capture_set_window_option
  run smart_borders
  [[ "${status}" -eq 0 ]]
  [[ "$(cat "${CAPTURE}")" == "pane-border-status bottom" ]]
}

@test "smart-borders.sh - no-op when window_panes is not numeric" {
  is_option_enabled() { return 0; }
  export -f is_option_enabled
  export MOCK_WINDOW_PANES="oops"
  _capture_set_window_option
  run smart_borders
  [[ "${status}" -eq 0 ]]
  [[ ! -f "${CAPTURE}" ]]
}
