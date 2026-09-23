#!/usr/bin/env bash
#
# tmux-ops.sh: thin wrappers over tmux option get/set.
#
# Every plugin in the family reads and writes its state through these helpers.
# The cache layer builds on top of them, which is why all runtime state lives in
# tmux server user-options and never in temp files.

[[ -n "${_TMUX_PLUGIN_TMUX_OPS_LOADED:-}" ]] && return 0
_TMUX_PLUGIN_TMUX_OPS_LOADED=1

# get_tmux_option OPTION [DEFAULT] -> the global option value, or DEFAULT if unset.
get_tmux_option() {
  local option="${1}"
  local default="${2:-}"
  local value
  value=$(tmux show-option -gqv "${option}" 2>/dev/null)
  [[ -z "${value}" ]] && echo "${default}" || echo "${value}"
}

# set_tmux_option OPTION VALUE -> store a global option.
set_tmux_option() {
  tmux set-option -gq "${1}" "${2}" 2>/dev/null
}

get_window_option() {
  local option="${1}"
  local default="${2:-}"
  local value
  value=$(tmux show-option -wqv "${option}" 2>/dev/null)
  [[ -z "${value}" ]] && echo "${default}" || echo "${value}"
}

get_pane_option() {
  local option="${1}"
  local default="${2:-}"
  local pane="${3:-}"
  local value
  if [[ -n "${pane}" ]]; then
    value=$(tmux show-option -pqv -t "${pane}" "${option}" 2>/dev/null)
  else
    value=$(tmux show-option -pqv "${option}" 2>/dev/null)
  fi
  [[ -z "${value}" ]] && echo "${default}" || echo "${value}"
}

set_window_option() {
  tmux set-option -wq "${1}" "${2}" 2>/dev/null
}

set_pane_option() {
  if [[ -n "${3:-}" ]]; then
    tmux set-option -pq -t "${3}" "${1}" "${2}" 2>/dev/null
  else
    tmux set-option -pq "${1}" "${2}" 2>/dev/null
  fi
}

get_current_pane() {
  tmux display-message -p '#{pane_id}' 2>/dev/null || echo ""
}

get_current_window() {
  tmux display-message -p '#{window_id}' 2>/dev/null || echo ""
}

get_pane_count() {
  tmux list-panes 2>/dev/null | wc -l | tr -d ' '
}

get_pane_width() {
  local pane="${1:-}"
  if [[ -n "${pane}" ]]; then
    tmux display-message -p -t "${pane}" '#{pane_width}' 2>/dev/null || echo "0"
  else
    tmux display-message -p '#{pane_width}' 2>/dev/null || echo "0"
  fi
}

get_pane_height() {
  local pane="${1:-}"
  if [[ -n "${pane}" ]]; then
    tmux display-message -p -t "${pane}" '#{pane_height}' 2>/dev/null || echo "0"
  else
    tmux display-message -p '#{pane_height}' 2>/dev/null || echo "0"
  fi
}

get_window_width() {
  tmux display-message -p '#{window_width}' 2>/dev/null || echo "0"
}

get_window_height() {
  tmux display-message -p '#{window_height}' 2>/dev/null || echo "0"
}

get_window_panes() {
  tmux display-message -p '#{window_panes}' 2>/dev/null || echo "0"
}

# unset_tmux_option OPTION -> remove a global option.
unset_tmux_option() {
  tmux set-option -gqu "${1}" 2>/dev/null
}

export -f get_tmux_option
export -f set_tmux_option
export -f unset_tmux_option
export -f get_window_option
export -f get_pane_option
export -f set_window_option
export -f set_pane_option
export -f get_current_pane
export -f get_current_window
export -f get_pane_count
export -f get_pane_width
export -f get_pane_height
export -f get_window_width
export -f get_window_height
export -f get_window_panes
