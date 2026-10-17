#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_FOCUS_RESIZE_LOADED:-}" ]] && return 0
_TILING_REVAMPED_FOCUS_RESIZE_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

focus_resize_pane() {
  local pane_count
  pane_count=$(get_pane_count)

  (( pane_count <= 1 )) && return 0

  local ratio
  ratio=$(get_numeric_option "@tiling_revamped_focus_ratio" "62" "10" "90")

  local window_width window_height
  window_width=$(get_window_width)
  window_height=$(get_window_height)

  local target_width=$(( window_width * ratio / 100 ))
  local target_height=$(( window_height * ratio / 100 ))

  tmux resize-pane -x "${target_width}" -y "${target_height}" 2>/dev/null || true
}

export -f focus_resize_pane
