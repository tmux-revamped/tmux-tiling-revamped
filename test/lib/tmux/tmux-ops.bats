#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/tmux/tmux-ops.sh"
}

teardown() {
  cleanup_test_environment
}

@test "tmux-ops.sh - functions are defined" {
  function_exists get_tmux_option
  function_exists set_tmux_option
  function_exists unset_tmux_option
}

@test "tmux-ops.sh - get_tmux_option returns the default when unset" {
  [[ "$(get_tmux_option @nope fallback)" == "fallback" ]]
}

@test "tmux-ops.sh - get_tmux_option returns empty when no default is given" {
  [[ -z "$(get_tmux_option @missing)" ]]
}

@test "tmux-ops.sh - set then get round-trips the value" {
  set_tmux_option @foo bar
  [[ "$(get_tmux_option @foo)" == "bar" ]]
}

@test "tmux-ops.sh - a stored value overrides the default" {
  set_tmux_option @foo bar
  [[ "$(get_tmux_option @foo other)" == "bar" ]]
}

@test "tmux-ops.sh - unset removes the option" {
  set_tmux_option @foo bar
  unset_tmux_option @foo
  [[ -z "$(get_tmux_option @foo)" ]]
}

@test "tmux-ops.sh - the window and pane helpers are defined" {
  function_exists get_window_option
  function_exists get_pane_option
  function_exists set_window_option
  function_exists set_pane_option
}

@test "tmux-ops.sh - the geometry helpers are defined" {
  function_exists get_current_pane
  function_exists get_current_window
  function_exists get_pane_count
  function_exists get_pane_width
  function_exists get_pane_height
  function_exists get_window_width
  function_exists get_window_height
  function_exists get_window_panes
}

@test "tmux-ops.sh - a window option round-trips and falls back" {
  [[ "$(get_window_option @win fallback)" == "fallback" ]]
  set_window_option @win value

  [[ "$(get_window_option @win)" == "value" ]]
}

@test "tmux-ops.sh - a pane option round-trips with and without a target" {
  [[ "$(get_pane_option @pane fallback)" == "fallback" ]]
  set_pane_option @pane value
  [[ "$(get_pane_option @pane)" == "value" ]]

  set_pane_option @pane other "%1"
  [[ -n "$(get_pane_option @pane '' '%1')" ]]
}

@test "tmux-ops.sh - every geometry helper runs" {
  run get_current_pane
  [[ "${status}" -eq 0 ]]
  run get_current_window
  [[ "${status}" -eq 0 ]]
  run get_pane_count
  [[ "${status}" -eq 0 ]]
  run get_pane_width
  [[ "${status}" -eq 0 ]]
  run get_pane_height
  [[ "${status}" -eq 0 ]]
  run get_window_width
  [[ "${status}" -eq 0 ]]
  run get_window_height
  [[ "${status}" -eq 0 ]]
  run get_window_panes
  [[ "${status}" -eq 0 ]]
}

@test "tmux-ops.sh - the pane geometry helpers accept a target" {
  run get_pane_width "%1"
  [[ "${status}" -eq 0 ]]

  run get_pane_height "%1"
  [[ "${status}" -eq 0 ]]
}
