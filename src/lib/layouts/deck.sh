#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_DECK_LOADED:-}" ]] && return 0
_TILING_REVAMPED_DECK_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

apply_layout_deck() {
  local pane_count
  pane_count=$(get_pane_count)

  (( pane_count <= 1 )) && { set_current_layout "deck"; return 0; }

  trap 'set_applying 0' RETURN
  set_applying 1
  tmux select-layout even-horizontal 2>/dev/null || true
  set_current_layout "deck"
}

export -f apply_layout_deck
