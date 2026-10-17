#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_MONOCLE_LOADED:-}" ]] && return 0
_TILING_REVAMPED_MONOCLE_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

apply_layout_monocle() {
  local is_zoomed
  is_zoomed=$(tmux display-message -p '#{window_zoomed_flag}' 2>/dev/null || echo "0")

  if [[ "${is_zoomed}" == "1" ]]; then
    tmux resize-pane -Z 2>/dev/null || true
    local prev_layout
    prev_layout=$(get_window_option "@tiling_revamped_monocle_prev_layout" "dwindle")
    set_current_layout "${prev_layout}"
  else
    local current
    current=$(get_current_layout)
    [[ -n "${current}" && "${current}" != "monocle" ]] \
      && set_window_option "@tiling_revamped_monocle_prev_layout" "${current}"
    tmux resize-pane -Z 2>/dev/null || true
    set_current_layout "monocle"
  fi
}

export -f apply_layout_monocle
