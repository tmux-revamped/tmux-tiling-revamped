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

use_recording_tmux() {
  TMUX_CALLS="${TEST_TMPDIR}/tmux-calls"
  : >"${TMUX_CALLS}"
  tmux() {
    printf '%s\n' "$*" >>"${TMUX_CALLS}"
    case "${1}" in
      list-panes) printf '%%1: [80x24]\n%%2: [80x24]\n' ;;
      display-message) printf '42\n' ;;
    esac
    return 0
  }
}

@test "tmux-ops.sh - get_current_pane asks for the pane id" {
  # Arrange
  use_recording_tmux

  # Act
  run get_current_pane

  # Assert
  [ "${output}" = "42" ]
  [ "$(cat "${TMUX_CALLS}")" = "display-message -p #{pane_id}" ]
}

@test "tmux-ops.sh - get_current_window asks for the window id" {
  # Arrange
  use_recording_tmux

  # Act
  run get_current_window

  # Assert
  [ "${output}" = "42" ]
  [ "$(cat "${TMUX_CALLS}")" = "display-message -p #{window_id}" ]
}

@test "tmux-ops.sh - get_pane_count counts the listed panes" {
  # Arrange
  use_recording_tmux

  # Act
  run get_pane_count

  # Assert
  [ "${output}" = "2" ]
  [ "$(cat "${TMUX_CALLS}")" = "list-panes" ]
}

@test "tmux-ops.sh - get_pane_width without a target reads the current pane" {
  # Arrange
  use_recording_tmux

  # Act
  run get_pane_width

  # Assert
  [ "${output}" = "42" ]
  [ "$(cat "${TMUX_CALLS}")" = "display-message -p #{pane_width}" ]
}

@test "tmux-ops.sh - get_pane_width passes the target pane" {
  # Arrange
  use_recording_tmux

  # Act
  run get_pane_width "%1"

  # Assert
  [ "${output}" = "42" ]
  [ "$(cat "${TMUX_CALLS}")" = "display-message -p -t %1 #{pane_width}" ]
}

@test "tmux-ops.sh - get_pane_height without a target reads the current pane" {
  # Arrange
  use_recording_tmux

  # Act
  run get_pane_height

  # Assert
  [ "${output}" = "42" ]
  [ "$(cat "${TMUX_CALLS}")" = "display-message -p #{pane_height}" ]
}

@test "tmux-ops.sh - get_pane_height passes the target pane" {
  # Arrange
  use_recording_tmux

  # Act
  run get_pane_height "%1"

  # Assert
  [ "${output}" = "42" ]
  [ "$(cat "${TMUX_CALLS}")" = "display-message -p -t %1 #{pane_height}" ]
}

@test "tmux-ops.sh - get_window_width asks for the window width" {
  # Arrange
  use_recording_tmux

  # Act
  run get_window_width

  # Assert
  [ "${output}" = "42" ]
  [ "$(cat "${TMUX_CALLS}")" = "display-message -p #{window_width}" ]
}

@test "tmux-ops.sh - get_window_height asks for the window height" {
  # Arrange
  use_recording_tmux

  # Act
  run get_window_height

  # Assert
  [ "${output}" = "42" ]
  [ "$(cat "${TMUX_CALLS}")" = "display-message -p #{window_height}" ]
}

@test "tmux-ops.sh - get_window_panes asks for the pane count" {
  # Arrange
  use_recording_tmux

  # Act
  run get_window_panes

  # Assert
  [ "${output}" = "42" ]
  [ "$(cat "${TMUX_CALLS}")" = "display-message -p #{window_panes}" ]
}

@test "tmux-ops.sh - a failing display-message falls back to zero" {
  # Arrange
  tmux() { return 1; }

  # Act
  run get_pane_width "%1"

  # Assert
  [ "${output}" = "0" ]
}

use_option_server() {
  TMUX_CALLS="${TEST_TMPDIR}/tmux-calls"
  : >"${TMUX_CALLS}"
  tmux() {
    printf '%s\n' "$*" >>"${TMUX_CALLS}"
    [ "${1}" = "show-option" ] || return 0
    case "${3}" in
      @empty)
        if [ "${2}" = "-gqv" ]; then printf '\n'; else printf '@empty ""\n'; fi
        ;;
      @set)
        if [ "${2}" = "-gqv" ]; then printf 'value\n'; else printf '@set value\n'; fi
        ;;
    esac
    return 0
  }
}

@test "tmux-ops.sh - get_tmux_option keeps an option explicitly set to empty" {
  # Arrange
  use_option_server

  # Act
  run get_tmux_option @empty fallback

  # Assert
  [ "${status}" -eq 0 ]
  [ "${output}" = "" ]
}

@test "tmux-ops.sh - get_tmux_option returns the default for an unset option" {
  # Arrange
  use_option_server

  # Act
  run get_tmux_option @absent fallback

  # Assert
  [ "${output}" = "fallback" ]
  [ "$(cat "${TMUX_CALLS}")" = "$(printf 'show-option -gqv @absent\nshow-option -gq @absent')" ]
}

@test "tmux-ops.sh - get_tmux_option returns a set value with one query" {
  # Arrange
  use_option_server

  # Act
  run get_tmux_option @set fallback

  # Assert
  [ "${output}" = "value" ]
  [ "$(cat "${TMUX_CALLS}")" = "show-option -gqv @set" ]
}

@test "tmux-ops.sh - get_tmux_option with no default queries once" {
  # Arrange
  use_option_server

  # Act
  run get_tmux_option @absent

  # Assert
  [ "${output}" = "" ]
  [ "$(cat "${TMUX_CALLS}")" = "show-option -gqv @absent" ]
}
