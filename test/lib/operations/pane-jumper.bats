#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0|$0|@0|main:1.0 zsh shell\n%5|$1|@2|work:2.1 vim editor'
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/pane-jumper.sh"
}

teardown() {
  cleanup_test_environment
}

@test "pane-jumper.sh - functions exist" {
  function_exists _pane_jumper_has_popup
  function_exists _pane_jumper_list
  function_exists _pane_jumper_fallback
  function_exists _pane_jumper_select
  function_exists pane_jumper
}

@test "pane-jumper.sh - source guard prevents double loading" {
  [[ "${_TILING_REVAMPED_PANE_JUMPER_LOADED}" == "1" ]]
}

@test "pane-jumper.sh - popup supported on tmux 3.4" {
  run _pane_jumper_has_popup
  [[ "${status}" -eq 0 ]]
}

@test "pane-jumper.sh - popup supported on a major above 3" {
  tmux() { [[ "$1" == "-V" ]] && echo "tmux 4.0"; return 0; }
  export -f tmux
  run _pane_jumper_has_popup
  [[ "${status}" -eq 0 ]]
}

@test "pane-jumper.sh - popup unsupported on tmux 3.1" {
  tmux() { [[ "$1" == "-V" ]] && echo "tmux 3.1"; return 0; }
  export -f tmux
  run _pane_jumper_has_popup
  [[ "${status}" -eq 1 ]]
}

@test "pane-jumper.sh - popup unsupported when the version is unparseable" {
  tmux() { [[ "$1" == "-V" ]] && echo "tmux next"; return 0; }
  export -f tmux
  run _pane_jumper_has_popup
  [[ "${status}" -eq 1 ]]
}

@test "pane-jumper.sh - popup unsupported when minor is non-numeric" {
  tmux() { [[ "$1" == "-V" ]] && echo "tmux 3.x"; return 0; }
  export -f tmux
  run _pane_jumper_has_popup
  [[ "${status}" -eq 1 ]]
}

@test "pane-jumper.sh - list enumerates every pane" {
  run _pane_jumper_list
  [[ "${output}" == *"%0"* ]]
  [[ "${output}" == *"%5"* ]]
}

@test "pane-jumper.sh - fallback invokes choose-tree" {
  tmux() {
    if [[ "$1" == "choose-tree" ]]; then echo "choose-tree $*"; fi
    return 0
  }
  export -f tmux
  run _pane_jumper_fallback
  [[ "${output}" == *"choose-tree"* ]]
}

@test "pane-jumper.sh - select is a no-op for empty input" {
  run _pane_jumper_select ""
  [[ "${status}" -eq 0 ]]
}

@test "pane-jumper.sh - select is a no-op when the pane id is missing" {
  tmux() { echo "$*"; return 0; }
  export -f tmux
  run _pane_jumper_select "solo"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" != *"select-pane"* ]]
}

@test "pane-jumper.sh - select switches session, window, and pane" {
  tmux() { echo "$*"; return 0; }
  export -f tmux
  run _pane_jumper_select '%5|$1|@2|work:2.1 vim editor'
  [[ "${output}" == *'switch-client -t $1'* ]]
  [[ "${output}" == *"select-window -t @2"* ]]
  [[ "${output}" == *"select-pane -t %5"* ]]
}

@test "pane-jumper.sh - select targets ids when the session name has spaces" {
  # Arrange
  tmux() { echo "$*"; return 0; }
  export -f tmux

  # Act
  run _pane_jumper_select '%7|$3|@9|my work:1.0 vim a | b'

  # Assert
  [[ "${output}" == *'switch-client -t $3'* ]] || false
  [[ "${output}" == *"select-window -t @9"* ]] || false
  [[ "${output}" == *"select-pane -t %7"* ]]
}

@test "pane-jumper.sh - falls back when fzf is absent" {
  export MOCK_HAS_FZF="0"
  tmux() {
    if [[ "$1" == "choose-tree" ]]; then echo "fallback"; fi
    return 0
  }
  export -f tmux
  run pane_jumper
  [[ "${output}" == *"fallback"* ]]
}

@test "pane-jumper.sh - falls back when the popup is unsupported" {
  export MOCK_HAS_FZF="1"
  tmux() {
    case "$1" in
      -V) echo "tmux 3.1" ;;
      choose-tree) echo "fallback" ;;
      list-panes) printf '%s\n' "${MOCK_PANE_LIST}" ;;
    esac
    return 0
  }
  export -f tmux
  run pane_jumper
  [[ "${output}" == *"fallback"* ]]
}

@test "pane-jumper.sh - returns 0 when no panes are listed" {
  export MOCK_HAS_FZF="1"
  tmux() {
    case "$1" in
      -V) echo "tmux 3.4" ;;
      list-panes) printf '' ;;
    esac
    return 0
  }
  export -f tmux
  run pane_jumper
  [[ "${status}" -eq 0 ]]
}

@test "pane-jumper.sh - returns 0 when the selection is empty" {
  export MOCK_HAS_FZF="1"
  export MOCK_FZF_SELECTION=""
  run pane_jumper
  [[ "${status}" -eq 0 ]]
}

@test "pane-jumper.sh - selects the pane returned by fzf" {
  export MOCK_HAS_FZF="1"
  export MOCK_FZF_SELECTION='%5|$1|@2|work:2.1 vim editor'
  _pane_jumper_select() { echo "selected:$1"; }
  export -f _pane_jumper_select
  run pane_jumper
  [[ "${output}" == *'selected:%5|$1|@2|work:2.1 vim editor'* ]]
}

@test "pane-jumper.sh - an fzf without --tmux runs the jumper in a popup" {
  # Arrange
  export MOCK_HAS_FZF="1"
  export MOCK_FZF_VERSION="0.52.0"
  export MOCK_TMUX_LOG="${TEST_TMPDIR}/tmux.log"

  # Act
  pane_jumper

  # Assert
  grep -q '^display-popup -E -w 70% -h 60% TILING_REVAMPED_IN_POPUP=1 .*tiling\.sh pane-jump$' "${MOCK_TMUX_LOG}"
}
