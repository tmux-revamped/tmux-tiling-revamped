#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_EQUALIZE_LOADED:-}" ]] && return 0
_TILING_REVAMPED_EQUALIZE_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

equalize_panes() {
  local pane_count
  pane_count=$(get_pane_count)

  (( pane_count <= 1 )) && return 0

  local flags
  flags=$(get_window_option "@tiling_revamped_orientation" "brvc")

  set_applying 1

  if [[ "${flags}" == *h* ]]; then
    tmux select-layout even-horizontal 2>/dev/null || true
  else
    tmux select-layout even-vertical 2>/dev/null || true
  fi

  set_applying 0
}

export -f equalize_panes
