#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_ID="%1"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/app-rules.sh"
  promote_pane() { echo "promoted"; }
  set_pane_option() { echo "set-pane $1=$2 on ${3:-current}"; }
  export -f promote_pane set_pane_option
}

teardown() {
  cleanup_test_environment
}

@test "app-rules.sh - functions exist" {
  function_exists resolve_app_action
  function_exists _apply_app_action
  function_exists apply_app_rules
}

@test "app-rules.sh - source guard prevents double loading" {
  [[ "${_TILING_REVAMPED_APP_RULES_LOADED}" == "1" ]]
}

@test "app-rules.sh - resolve returns nothing for an empty command" {
  export MOCK_TMUX_OPTION_VALUE=$'vim:master'
  run resolve_app_action ""
  [[ -z "${output}" ]]
}

@test "app-rules.sh - resolve returns nothing when no rules are set" {
  export MOCK_TMUX_OPTION_VALUE=""
  run resolve_app_action vim
  [[ -z "${output}" ]]
}

@test "app-rules.sh - resolve matches an exact command" {
  export MOCK_TMUX_OPTION_VALUE=$'vim:master\nlazygit:float'
  run resolve_app_action lazygit
  [[ "${output}" == "float" ]]
}

@test "app-rules.sh - resolve matches a glob pattern" {
  export MOCK_TMUX_OPTION_VALUE=$'python*:scratchpad\nvim:master'
  run resolve_app_action python3.12
  [[ "${output}" == "scratchpad" ]]
}

@test "app-rules.sh - resolve returns the first matching rule" {
  export MOCK_TMUX_OPTION_VALUE=$'v*:master\nvim:float'
  run resolve_app_action vim
  [[ "${output}" == "master" ]]
}

@test "app-rules.sh - resolve returns nothing when nothing matches" {
  export MOCK_TMUX_OPTION_VALUE=$'vim:master\nlazygit:float'
  run resolve_app_action zsh
  [[ -z "${output}" ]]
}

@test "app-rules.sh - resolve skips blank, colon-less, and empty-field lines" {
  export MOCK_TMUX_OPTION_VALUE=$'\nvim\n:master\nlazygit:\nhtop:master'
  run resolve_app_action htop
  [[ "${output}" == "master" ]]
}

@test "app-rules.sh - _apply_app_action master promotes the pane" {
  run _apply_app_action master
  [[ "${output}" == "promoted" ]]
}

@test "app-rules.sh - _apply_app_action float tags the pane" {
  run _apply_app_action float
  [[ "${output}" == *"@tiling_revamped_float=1"* ]]
}

@test "app-rules.sh - _apply_app_action scratchpad tags the pane" {
  run _apply_app_action scratchpad
  [[ "${output}" == *"@tiling_revamped_scratchpad=1"* ]]
}

@test "app-rules.sh - _apply_app_action rejects an unknown action" {
  run _apply_app_action teleport
  [[ "${status}" -eq 1 ]]
}

@test "app-rules.sh - apply_app_rules runs the matched action for the pane command" {
  tmux() {
    case "$1" in
      display-message) echo "vim" ;;
      show-option) printf '%s\n' 'vim:master' ;;
    esac
    return 0
  }
  export -f tmux
  run apply_app_rules
  [[ "${output}" == "promoted" ]]
}

@test "app-rules.sh - apply_app_rules is a no-op when the command has no rule" {
  tmux() {
    case "$1" in
      display-message) echo "zsh" ;;
      show-option) printf '%s\n' 'vim:master' ;;
    esac
    return 0
  }
  export -f tmux
  run apply_app_rules
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
}
