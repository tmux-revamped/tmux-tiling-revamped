#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_WINDOW_WIDTH="200"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_TILING_ORIENTATION="brvc"
  export MOCK_HAS_FZF="1"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/swap-pick.sh"
}

teardown() {
  cleanup_test_environment
}

@test "swap-pick.sh - swap_pick function exists" {
  function_exists swap_pick
}

@test "swap-pick.sh - swap_pick fails when fzf is not installed" {
  export MOCK_HAS_FZF="0"
  run swap_pick
  [[ "${status}" -eq 1 ]]
}

@test "swap-pick.sh - swap_pick returns 0 with single pane" {
  export MOCK_PANE_LIST="%0"
  run swap_pick
  [[ "${status}" -eq 0 ]]
}

@test "swap-pick.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_SWAP_PICK_LOADED}" ]]
  [[ "${_TILING_REVAMPED_SWAP_PICK_LOADED}" == "1" ]]
}

@test "swap-pick.sh - swap_pick direct call fails without fzf" {
  export MOCK_HAS_FZF="0"
  run swap_pick
  [[ "${status}" -eq 1 ]]
}

@test "swap-pick.sh - swap_pick direct call returns 0 with single pane" {
  export MOCK_PANE_LIST="%0"
  swap_pick >/dev/null 2>&1
}

@test "swap-pick.sh - swap_pick returns 0 when pane list is empty after filter" {
  tmux() {
    case "$1" in
      list-panes) printf '%s\n' '%0 zsh /tmp' ;;
      display-message)
        shift
        while [[ $# -gt 0 ]]; do
          case "$1" in
            -p) shift; [[ "$1" == '#{pane_id}' ]] && printf '%s\n' '%0'; return 0 ;;
            -t) shift ;;
          esac
          shift
        done ;;
      *) return 0 ;;
    esac
  }
  export -f tmux
  swap_pick >/dev/null 2>&1
}

@test "swap-pick.sh - swap_pick returns 0 when selection is empty" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_FZF_SELECTION=""
  tmux() {
    case "$1" in
      list-panes) printf '%s\n' '%1 vim /a' '%2 zsh /b' ;;
      display-message)
        shift
        while [[ $# -gt 0 ]]; do
          case "$1" in
            -p) shift; [[ "$1" == '#{pane_id}' ]] && printf '%s\n' '%0'; return 0 ;;
            -t) shift ;;
          esac
          shift
        done ;;
      *) return 0 ;;
    esac
  }
  export -f tmux
  swap_pick >/dev/null 2>&1
}

@test "swap-pick.sh - swap_pick swaps and reapplies on valid selection" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_FZF_SELECTION="%2 zsh /b"
  export MOCK_TILING_LAYOUT="dwindle"
  _apply_bsp_layout() { return 0; }
  export -f _apply_bsp_layout
  tmux() {
    case "$1" in
      list-panes) printf '%s\n' '%1 vim /a' '%2 zsh /b' ;;
      display-message)
        shift
        while [[ $# -gt 0 ]]; do
          case "$1" in
            -p) shift; [[ "$1" == '#{pane_id}' ]] && printf '%s\n' '%0'; return 0 ;;
            -t) shift ;;
          esac
          shift
        done ;;
      swap-pane) return 0 ;;
      *) return 0 ;;
    esac
  }
  export -f tmux
  swap_pick >/dev/null 2>&1
}

@test "swap-pick.sh - swap_pick returns 1 when swap-pane fails" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_FZF_SELECTION="%2 zsh /b"
  tmux() {
    case "$1" in
      list-panes) printf '%s\n' '%1 vim /a' '%2 zsh /b' ;;
      display-message)
        shift
        while [[ $# -gt 0 ]]; do
          case "$1" in
            -p) shift; [[ "$1" == '#{pane_id}' ]] && printf '%s\n' '%0'; return 0 ;;
            -t) shift ;;
          esac
          shift
        done ;;
      swap-pane) return 1 ;;
      *) return 0 ;;
    esac
  }
  export -f tmux
  run swap_pick
  [[ "${status}" -eq 1 ]]
}

@test "swap-pick.sh - an fzf without --tmux runs the picker in a popup" {
  # Arrange
  export MOCK_FZF_VERSION="0.52.0"
  export MOCK_TMUX_LOG="${TEST_TMPDIR}/tmux.log"

  # Act
  swap_pick

  # Assert
  grep -q '^display-popup -E -w 60% -h 30% TILING_REVAMPED_IN_POPUP=1 .*tiling\.sh swap-pick$' "${MOCK_TMUX_LOG}"
}
