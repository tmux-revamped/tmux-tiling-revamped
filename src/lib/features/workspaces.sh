#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_WORKSPACES_LOADED:-}" ]] && return 0
_TILING_REVAMPED_WORKSPACES_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

record_last_window() {
  local current
  current=$(get_current_window)
  [[ -z "${current}" ]] && return 0
  set_tmux_option "@tiling_revamped_last_window" "${current}"
}

switch_workspace() {
  local target="${1:-1}"

  if ! [[ "${target}" =~ ^[0-9]+$ ]]; then
    log_error "workspaces" "Invalid workspace number: ${target}"
    return 1
  fi

  record_last_window

  if tmux select-window -t ":${target}" 2>/dev/null; then
    return 0
  fi

  tmux new-window -t ":${target}" 2>/dev/null || return 1
}

move_to_workspace() {
  local target="${1:-1}"

  if ! [[ "${target}" =~ ^[0-9]+$ ]]; then
    log_error "workspaces" "Invalid workspace number: ${target}"
    return 1
  fi

  local current_pane
  current_pane=$(get_current_pane)
  [[ -z "${current_pane}" ]] && return 1

  if ! tmux select-window -t ":${target}" 2>/dev/null; then
    tmux new-window -d -t ":${target}" 2>/dev/null || return 1
  fi

  tmux join-pane -t ":${target}" -s "${current_pane}" 2>/dev/null || return 1

  tmux select-window -t ":${target}" 2>/dev/null || true
}

workspace_back_and_forth() {
  local last
  last=$(get_tmux_option "@tiling_revamped_last_window" "")
  [[ -z "${last}" ]] && return 0

  local current
  current=$(get_current_window)
  [[ "${last}" == "${current}" ]] && return 0

  [[ -n "${current}" ]] && set_tmux_option "@tiling_revamped_last_window" "${current}"

  tmux select-window -t "${last}" 2>/dev/null || return 1
}

export -f record_last_window
export -f switch_workspace
export -f move_to_workspace
export -f workspace_back_and_forth
