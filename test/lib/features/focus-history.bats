#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_ID="%0"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/focus-history.sh"
  get_window_option() {
    local f="${TEST_TMPDIR}/wopt_${1//[^a-zA-Z0-9]/_}"
    if [[ -f "${f}" ]]; then cat "${f}"; else printf '%s' "${2:-}"; fi
  }
  set_window_option() {
    printf '%s' "$2" > "${TEST_TMPDIR}/wopt_${1//[^a-zA-Z0-9]/_}"
  }
  export -f get_window_option set_window_option
}

teardown() {
  cleanup_test_environment
}

wopt() {
  get_window_option "$1" ""
}

@test "focus-history.sh - functions exist" {
  function_exists _focus_pane_alive
  function_exists focus_history_record
  function_exists _focus_history_step
  function_exists focus_history_back
  function_exists focus_history_forward
}

@test "focus-history.sh - source guard prevents double loading" {
  [[ "${_TILING_REVAMPED_FOCUS_HISTORY_LOADED}" == "1" ]]
}

@test "focus-history.sh - _focus_pane_alive rejects an empty id" {
  run _focus_pane_alive ""
  [[ "${status}" -eq 1 ]]
}

@test "focus-history.sh - _focus_pane_alive detects a live pane" {
  export MOCK_PANE_LIST=$'%0\n%1'
  run _focus_pane_alive "%1"
  [[ "${status}" -eq 0 ]]
}

@test "focus-history.sh - _focus_pane_alive rejects a dead pane" {
  export MOCK_PANE_LIST=$'%0\n%1'
  run _focus_pane_alive "%9"
  [[ "${status}" -eq 1 ]]
}

@test "focus-history.sh - record clears the nav guard and skips" {
  set_window_option "@tiling_revamped_focus_nav" "1"
  focus_history_record
  [[ "$(wopt @tiling_revamped_focus_nav)" == "0" ]]
  [[ -z "$(wopt @tiling_revamped_focus_stack)" ]]
}

@test "focus-history.sh - record ignores an empty pane id" {
  get_current_pane() { printf ''; }
  export -f get_current_pane
  focus_history_record
  [[ -z "$(wopt @tiling_revamped_focus_stack)" ]]
}

@test "focus-history.sh - record pushes the first pane" {
  export MOCK_PANE_ID="%0"
  focus_history_record
  [[ "$(wopt @tiling_revamped_focus_stack)" == "%0" ]]
  [[ "$(wopt @tiling_revamped_focus_pos)" == "0" ]]
}

@test "focus-history.sh - record appends the next pane" {
  set_window_option "@tiling_revamped_focus_stack" "%0"
  set_window_option "@tiling_revamped_focus_pos" "0"
  export MOCK_PANE_ID="%1"
  focus_history_record
  [[ "$(wopt @tiling_revamped_focus_stack)" == "%0 %1" ]]
  [[ "$(wopt @tiling_revamped_focus_pos)" == "1" ]]
}

@test "focus-history.sh - record skips a duplicate tail" {
  set_window_option "@tiling_revamped_focus_stack" "%0 %1"
  set_window_option "@tiling_revamped_focus_pos" "1"
  export MOCK_PANE_ID="%1"
  focus_history_record
  [[ "$(wopt @tiling_revamped_focus_stack)" == "%0 %1" ]]
}

@test "focus-history.sh - record truncates forward history" {
  set_window_option "@tiling_revamped_focus_stack" "%0 %1 %2"
  set_window_option "@tiling_revamped_focus_pos" "1"
  export MOCK_PANE_ID="%3"
  focus_history_record
  [[ "$(wopt @tiling_revamped_focus_stack)" == "%0 %1 %3" ]]
  [[ "$(wopt @tiling_revamped_focus_pos)" == "2" ]]
}

@test "focus-history.sh - record keeps the whole stack when pos is non-numeric" {
  set_window_option "@tiling_revamped_focus_stack" "%0 %1"
  set_window_option "@tiling_revamped_focus_pos" "none"
  export MOCK_PANE_ID="%2"
  focus_history_record
  [[ "$(wopt @tiling_revamped_focus_stack)" == "%0 %1 %2" ]]
}

@test "focus-history.sh - record caps the stack at the maximum" {
  export MOCK_TMUX_OPTION_VALUE="3"
  set_window_option "@tiling_revamped_focus_stack" "%0 %1 %2"
  set_window_option "@tiling_revamped_focus_pos" "2"
  export MOCK_PANE_ID="%3"
  focus_history_record
  [[ "$(wopt @tiling_revamped_focus_stack)" == "%1 %2 %3" ]]
  [[ "$(wopt @tiling_revamped_focus_pos)" == "2" ]]
}

@test "focus-history.sh - back is a no-op when pos is non-numeric" {
  run focus_history_back
  [[ "${status}" -eq 0 ]]
}

@test "focus-history.sh - back is a no-op on an empty stack" {
  set_window_option "@tiling_revamped_focus_stack" ""
  set_window_option "@tiling_revamped_focus_pos" "0"
  run focus_history_back
  [[ "${status}" -eq 0 ]]
}

@test "focus-history.sh - back moves the cursor to the previous pane" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  set_window_option "@tiling_revamped_focus_stack" "%0 %1 %2"
  set_window_option "@tiling_revamped_focus_pos" "2"
  focus_history_back
  [[ "$(wopt @tiling_revamped_focus_pos)" == "1" ]]
  [[ "$(wopt @tiling_revamped_focus_nav)" == "1" ]]
}

@test "focus-history.sh - back stops at the start of the stack" {
  export MOCK_PANE_LIST=$'%0\n%1'
  set_window_option "@tiling_revamped_focus_stack" "%0 %1"
  set_window_option "@tiling_revamped_focus_pos" "0"
  focus_history_back
  [[ "$(wopt @tiling_revamped_focus_pos)" == "0" ]]
}

@test "focus-history.sh - back skips a dead pane" {
  export MOCK_PANE_LIST=$'%0\n%2'
  set_window_option "@tiling_revamped_focus_stack" "%0 %1 %2"
  set_window_option "@tiling_revamped_focus_pos" "2"
  focus_history_back
  [[ "$(wopt @tiling_revamped_focus_pos)" == "0" ]]
}

@test "focus-history.sh - forward moves the cursor to the next pane" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  set_window_option "@tiling_revamped_focus_stack" "%0 %1 %2"
  set_window_option "@tiling_revamped_focus_pos" "0"
  focus_history_forward
  [[ "$(wopt @tiling_revamped_focus_pos)" == "1" ]]
}

@test "focus-history.sh - forward stops at the end of the stack" {
  export MOCK_PANE_LIST=$'%0\n%1'
  set_window_option "@tiling_revamped_focus_stack" "%0 %1"
  set_window_option "@tiling_revamped_focus_pos" "1"
  focus_history_forward
  [[ "$(wopt @tiling_revamped_focus_pos)" == "1" ]]
}
