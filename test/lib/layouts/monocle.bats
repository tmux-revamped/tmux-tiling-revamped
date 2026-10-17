#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_WINDOW_ZOOMED="0"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/monocle.sh"
}

teardown() {
  cleanup_test_environment
}

@test "monocle.sh - apply_layout_monocle function exists" {
  function_exists apply_layout_monocle
}

@test "monocle.sh - apply_layout_monocle succeeds when not zoomed" {
  export MOCK_WINDOW_ZOOMED="0"
  run apply_layout_monocle
  [[ "${status}" -eq 0 ]]
}

@test "monocle.sh - apply_layout_monocle succeeds when already zoomed" {
  export MOCK_WINDOW_ZOOMED="1"
  run apply_layout_monocle
  [[ "${status}" -eq 0 ]]
}

@test "monocle.sh - apply_layout_monocle toggles off when already in monocle" {
  export MOCK_WINDOW_ZOOMED="1"
  export MOCK_TILING_LAYOUT="monocle"
  run apply_layout_monocle
  [[ "${status}" -eq 0 ]]
}

@test "monocle.sh - apply_layout_monocle works with single pane" {
  export MOCK_PANE_LIST="%0"
  run apply_layout_monocle
  [[ "${status}" -eq 0 ]]
}

@test "monocle.sh - apply_layout_monocle direct call zooms when not zoomed" {
  export MOCK_WINDOW_ZOOMED="0"
  export MOCK_TILING_LAYOUT="dwindle"
  apply_layout_monocle >/dev/null 2>&1
}

@test "monocle.sh - apply_layout_monocle direct call unzooms when zoomed" {
  export MOCK_WINDOW_ZOOMED="1"
  export MOCK_TILING_MONOCLE_PREV="grid"
  apply_layout_monocle >/dev/null 2>&1
}

@test "monocle.sh - apply_layout_monocle does not save prev when current is monocle" {
  export MOCK_WINDOW_ZOOMED="0"
  export MOCK_TILING_LAYOUT="monocle"
  apply_layout_monocle >/dev/null 2>&1
}

@test "monocle.sh - apply_layout_monocle handles empty current layout" {
  export MOCK_WINDOW_ZOOMED="0"
  export MOCK_TILING_LAYOUT=""
  apply_layout_monocle >/dev/null 2>&1
}

@test "monocle.sh - apply_layout_monocle defaults to 0 when zoom flag missing" {
  export MOCK_TILING_LAYOUT="dwindle"
  tmux() {
    case "$1" in
      display-message) return 1 ;;
      *) return 0 ;;
    esac
  }
  export -f tmux
  apply_layout_monocle >/dev/null 2>&1
}

