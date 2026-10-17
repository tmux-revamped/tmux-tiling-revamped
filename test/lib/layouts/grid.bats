#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3'
  export MOCK_TILING_APPLYING="0"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/grid.sh"
}

teardown() {
  cleanup_test_environment
}

@test "grid.sh - apply_layout_grid function exists" {
  function_exists apply_layout_grid
}

@test "grid.sh - apply_layout_grid succeeds with multiple panes" {
  run apply_layout_grid
  [[ "${status}" -eq 0 ]]
}

@test "grid.sh - apply_layout_grid succeeds with single pane" {
  export MOCK_PANE_LIST="%0"
  run apply_layout_grid
  [[ "${status}" -eq 0 ]]
}

@test "grid.sh - apply_layout_grid succeeds with 2 panes" {
  export MOCK_PANE_LIST=$'%0\n%1'
  run apply_layout_grid
  [[ "${status}" -eq 0 ]]
}

@test "grid.sh - apply_layout_grid succeeds with 6 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5'
  run apply_layout_grid
  [[ "${status}" -eq 0 ]]
}

@test "grid.sh - apply_layout_grid succeeds with 9 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5\n%6\n%7\n%8'
  run apply_layout_grid
  [[ "${status}" -eq 0 ]]
}

@test "grid.sh - apply_layout_grid direct call applies tiled layout" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3'
  apply_layout_grid >/dev/null 2>&1
}

@test "grid.sh - apply_layout_grid direct call single-pane early return" {
  export MOCK_PANE_LIST="%0"
  apply_layout_grid >/dev/null 2>&1
}

@test "grid.sh - apply_layout_grid direct call two panes" {
  export MOCK_PANE_LIST=$'%0\n%1'
  apply_layout_grid >/dev/null 2>&1
}

@test "grid.sh - apply_layout_grid tolerates select-layout failure" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  tmux() {
    case "$1" in
      list-panes) printf '%s\n' "${MOCK_PANE_LIST}" ;;
      select-layout) return 1 ;;
      *) return 0 ;;
    esac
  }
  export -f tmux
  apply_layout_grid >/dev/null 2>&1
}

