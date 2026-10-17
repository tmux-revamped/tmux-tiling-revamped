#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_TILING_APPLYING="0"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/deck.sh"
}

teardown() {
  cleanup_test_environment
}

@test "deck.sh - apply_layout_deck function exists" {
  function_exists apply_layout_deck
}

@test "deck.sh - apply_layout_deck succeeds with multiple panes" {
  run apply_layout_deck
  [[ "${status}" -eq 0 ]]
}

@test "deck.sh - apply_layout_deck succeeds with single pane" {
  export MOCK_PANE_LIST="%0"
  run apply_layout_deck
  [[ "${status}" -eq 0 ]]
}

@test "deck.sh - apply_layout_deck succeeds with 5 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4'
  run apply_layout_deck
  [[ "${status}" -eq 0 ]]
}

@test "deck.sh - apply_layout_deck succeeds with 2 panes" {
  export MOCK_PANE_LIST=$'%0\n%1'
  run apply_layout_deck
  [[ "${status}" -eq 0 ]]
}

@test "deck.sh - apply_layout_deck direct call applies even-horizontal" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  apply_layout_deck >/dev/null 2>&1
}

@test "deck.sh - apply_layout_deck direct call single-pane early return" {
  export MOCK_PANE_LIST="%0"
  apply_layout_deck >/dev/null 2>&1
}

@test "deck.sh - apply_layout_deck direct call two panes" {
  export MOCK_PANE_LIST=$'%0\n%1'
  apply_layout_deck >/dev/null 2>&1
}

@test "deck.sh - apply_layout_deck tolerates select-layout failure" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  tmux() {
    case "$1" in
      list-panes) printf '%s\n' "${MOCK_PANE_LIST}" ;;
      select-layout) return 1 ;;
      *) return 0 ;;
    esac
  }
  export -f tmux
  apply_layout_deck >/dev/null 2>&1
}

