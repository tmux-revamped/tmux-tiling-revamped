#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2154

t() {
  command tmux -S "${TILING_SOCKET}" "$@"
}

wait_for() {
  local delay
  for delay in 0.01 0.02 0.05 0.1 0.1 0.2 0.2 0.5 0.5 1 1 1 2 2; do
    "$@" && return 0
    sleep "${delay}"
  done
  "$@" && return 0
  command tmux -S "${HOST}" capture-pane -p -t host || :
  t show-options -w || :
  return 1
}

attached() {
  local clients
  clients=$(t list-clients -F x 2>/dev/null)
  [[ -n "${clients}" ]]
}

shape() {
  local layout
  layout=$(t display-message -p -t test '#{window_layout} #{P:#{pane_id}}')
  cksum <<<"${layout}"
}

reshaped() {
  local now
  now=$(shape)
  [[ "${now}" != "$1" ]]
}

shaped() {
  local now
  now=$(shape)
  [[ "${now}" == "$1" ]]
}

layout_is() {
  local now
  now=$(t show-option -wqv -t test @tiling_revamped_layout)
  [[ "${now}" == "$1" ]]
}

layout_set() {
  local now
  now=$(t show-option -wqv -t test @tiling_revamped_layout)
  [[ -n "${now}" && "${now}" != "$1" ]]
}

panes_are() {
  local count
  count=$(t display-message -p -t test '#{window_panes}')
  [[ "${count}" == "$1" ]]
}

first_pane_is() {
  local first
  first=$(t list-panes -t test -F '#{pane_id}' | head -n 1)
  [[ "${first}" == "$1" ]]
}

active_is() {
  local now
  now=$(t display-message -p -t test '#{pane_id}')
  [[ "${now}" == "$1" ]]
}

synchronized() {
  local now
  now=$(t display-message -p -t test '#{pane_synchronized}')
  [[ "${now}" == "$1" ]]
}

marked() {
  local marks
  marks=$(t show-option -gqv @tiling_revamped_marks)
  [[ "${marks}" == *"$1"* ]]
}

said() {
  local messages
  messages=$(t show-messages)
  [[ "${messages}" == *"$1"* ]]
}

host_shows() {
  local screen
  screen=$(command tmux -S "${HOST}" capture-pane -p -t host)
  [[ "${screen}" == *"$1"* ]]
}

host_lacks() {
  ! host_shows "$1"
}

press() {
  local key
  for key in "$@"; do
    command tmux -S "${HOST}" send-keys -t host "${key}"
  done
}

chord() {
  press C-b "$1"
}

setup() {
  unset BASH_ENV FZF_DEFAULT_OPTS FZF_DEFAULT_COMMAND
  PLUGIN_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  PLUGIN="${PLUGIN_DIR}/tmux-tiling-revamped.tmux"
  if ((BASH_VERSINFO[0] < 4)); then
    skip "the plugin needs bash 4 or newer and bats runs under bash ${BASH_VERSION}"
  fi
  export HOME="${BATS_TEST_TMPDIR}/home"
  mkdir -p "${HOME}"
  TILING_SOCKET="/tmp/tiling-keys-${BASHPID}-${RANDOM}"
  HOST="${TILING_SOCKET}-host"
  command tmux -S "${TILING_SOCKET}" -f /dev/null new-session -d -s test -x 160 -y 45 "env PS1='$ ' sh"
  t set-option -g default-command "env PS1='$ ' sh"
  t split-window -t test
  t split-window -t test
  command tmux -S "${HOST}" -f /dev/null new-session -d -s host -x 160 -y 45 \
    "env -u TMUX TERM=xterm-256color tmux -S '${TILING_SOCKET}' attach-session -t test"
  wait_for attached
}

plug() {
  t run-shell "bash '${PLUGIN}'"
  START=$(shape)
}

teardown() {
  command tmux -S "${HOST}" kill-server 2>/dev/null || :
  command tmux -S "${TILING_SOCKET}" kill-server 2>/dev/null || :
  rm -f "${TILING_SOCKET}" "${HOST}" 2>/dev/null || :
}

@test "keys - prefix M-D applies dwindle and prefix M-S applies spiral" {
  # Arrange
  plug
  chord M-D
  wait_for layout_is dwindle

  # Act
  chord M-S

  # Assert
  wait_for layout_is spiral
  wait_for reshaped "${START}"
}

@test "keys - prefix M-V applies main-vertical and prefix M-H applies main-horizontal" {
  # Arrange
  plug
  chord M-V
  wait_for layout_is main-vertical

  # Act
  chord M-H

  # Assert
  wait_for layout_is main-horizontal
}

@test "keys - prefix M-O cycles to a layout, then to another" {
  # Arrange
  local first
  plug
  chord M-O
  wait_for layout_set ""
  first=$(t show-option -wqv -t test @tiling_revamped_layout)

  # Act
  chord M-O

  # Assert
  wait_for layout_set "${first}"
}

@test "keys - prefix M-B balances the panes" {
  # Arrange
  plug

  # Act
  chord M-B

  # Assert
  wait_for reshaped "${START}"
}

@test "keys - prefix M-E equalizes the panes" {
  # Arrange
  plug

  # Act
  chord M-E

  # Assert
  wait_for reshaped "${START}"
}

@test "keys - prefix M-M promotes the active pane to the first place" {
  # Arrange
  local active
  plug
  active=$(t display-message -p -t test '#{pane_id}')

  # Act
  chord M-M

  # Assert
  wait_for first_pane_is "${active}"
}

@test "keys - prefix M-C circulates the panes" {
  # Arrange
  plug

  # Act
  chord M-C

  # Assert
  wait_for reshaped "${START}"
}

@test "keys - prefix M-W swaps the active pane with the biggest one" {
  # Arrange
  local active
  plug
  active=$(t display-message -p -t test '#{pane_id}')

  # Act
  chord M-W

  # Assert
  wait_for first_pane_is "${active}"
}

@test "keys - prefix M-A splits the active pane" {
  # Arrange
  plug

  # Act
  chord M-A

  # Assert
  wait_for panes_are 4
}

@test "keys - prefix M-G grows the master pane and prefix M-X shrinks it" {
  # Arrange
  local grown
  plug
  chord M-G
  wait_for reshaped "${START}"
  grown=$(shape)

  # Act
  chord M-X

  # Assert
  wait_for reshaped "${grown}"
}

@test "keys - prefix M-Y turns synchronized panes on, and off again" {
  # Arrange
  plug
  chord M-Y
  wait_for synchronized 1

  # Act
  chord M-Y

  # Assert
  wait_for synchronized 0
}

@test "keys - prefix M-F flips a dwindle layout and prefix M-R rotates it" {
  # Arrange
  local dwindle flipped
  plug
  chord M-D
  wait_for layout_is dwindle
  dwindle=$(shape)
  chord M-F
  wait_for reshaped "${dwindle}"
  flipped=$(shape)

  # Act
  chord M-R

  # Assert
  wait_for reshaped "${flipped}"
}

@test "keys - prefix M-F and prefix M-R say what they act on when no dwindle or spiral is applied" {
  # Arrange
  plug
  chord M-F
  wait_for said "tmux-tiling-revamped: flip acts on the dwindle and spiral layouts; apply one first"

  # Act
  chord M-R

  # Assert
  wait_for said "tmux-tiling-revamped: rotate acts on the dwindle and spiral layouts; apply one first"
}

@test "keys - prefix M-U goes back one layout and prefix M-Z forward again" {
  # Arrange
  plug
  chord M-D
  wait_for layout_is dwindle
  chord M-V
  wait_for layout_is main-vertical
  chord M-U
  wait_for layout_is dwindle

  # Act
  chord M-Z

  # Assert
  wait_for layout_is main-vertical
}

@test "keys - prefix M-U and prefix M-Z say so when there is nothing to undo or redo" {
  # Arrange
  plug
  chord M-U
  wait_for said "tmux-tiling-revamped: nothing to undo in this window"

  # Act
  chord M-Z

  # Assert
  wait_for said "tmux-tiling-revamped: nothing to redo in this window"
}

@test "keys - prefix M-P and prefix M-N say the focus history is off, which is the default" {
  # Arrange
  plug
  chord M-P
  wait_for said "tmux-tiling-revamped: focus history is off; set @tiling_revamped_focus_history to 1"
  t clear-history -t test
  t run-shell 'tmux display-message "between the two keys"'

  # Act
  chord M-N

  # Assert
  wait_for said "between the two keys"
  run t show-messages
  [[ "${output}" == *"between the two keys"*"focus history is off"* ]]
}

@test "keys - prefix M-I opens the help overlay, and Enter closes it as it says" {
  # Arrange
  plug

  # Act
  chord M-I

  # Assert
  wait_for host_shows "Balance panes"
  wait_for host_shows "Press Enter to close"
  press Enter
  wait_for host_lacks "Press Enter to close"
}

@test "keys - prefix M-L opens the layout picker" {
  # Arrange
  command -v fzf >/dev/null || skip "fzf is not installed"
  plug

  # Act
  chord M-L

  # Assert
  wait_for host_shows "Select layout"
}

@test "keys - prefix M-Q opens the pane jumper" {
  # Arrange
  command -v fzf >/dev/null || skip "fzf is not installed"
  plug

  # Act
  chord M-Q

  # Assert
  wait_for host_shows "Jump to pane"
}

@test "keys - prefix M-K names the pane, and prefix M-J picks it and jumps back" {
  # Arrange
  local marked
  command -v fzf >/dev/null || skip "fzf is not installed"
  plug
  marked=$(t display-message -p -t test '#{pane_id}')
  chord M-K
  wait_for host_shows "Mark name:"
  press markedpane Enter
  wait_for marked "markedpane:${marked}"
  t select-pane -t test.0
  chord M-J
  wait_for host_shows "Jump to mark:"
  wait_for host_shows "1/1"

  # Act
  press Enter

  # Assert
  wait_for active_is "${marked}"
}

@test "keys - prefix M-J says so when no pane is marked" {
  # Arrange
  command -v fzf >/dev/null || skip "fzf is not installed"
  plug

  # Act
  chord M-J

  # Assert
  wait_for said "tmux-tiling-revamped: no pane is marked yet"
}

@test "keys - prefix M-T opens the scratchpad, a shell in a popup" {
  # Arrange
  plug
  chord M-T
  wait_for host_shows "$ "

  # Act
  press "echo scratch-pad-here" Enter

  # Assert
  wait_for host_shows "scratch-pad-here"
  run t list-panes -t test -F x
  [[ "${#lines[@]}" -eq 3 ]]
}

@test "keys - the four swap keys move the active pane when set" {
  # Arrange
  local before
  t set-option -g @tiling_revamped_key_swap_up F1
  t set-option -g @tiling_revamped_key_swap_down F2
  t set-option -g @tiling_revamped_key_swap_left F3
  t set-option -g @tiling_revamped_key_swap_right F4
  plug
  chord F1
  wait_for reshaped "${START}"
  before=$(shape)
  chord F2
  wait_for reshaped "${before}"
  chord M-V
  wait_for layout_is main-vertical
  before=$(shape)
  chord F3
  wait_for reshaped "${before}"
  before=$(shape)

  # Act
  chord F4

  # Assert
  wait_for reshaped "${before}"
}
