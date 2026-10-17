#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_MAIN_HORIZONTAL_LOADED:-}" ]] && return 0
_TILING_REVAMPED_MAIN_HORIZONTAL_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

# Main-horizontal layout: one large top pane, remaining panes placed
# side by side below.  Wraps tmux's built-in main-horizontal layout
# and sizes the master pane to @tiling_revamped_master_ratio percent.
apply_layout_main_horizontal() {
  local pane_count
  pane_count=$(get_pane_count)

  (( pane_count <= 1 )) && { set_current_layout "main-horizontal"; return 0; }

  local window_height
  window_height=$(get_window_height)

  local ratio
  ratio=$(get_numeric_option "@tiling_revamped_master_ratio" "60" "20" "90")
  local master_height=$(( window_height * ratio / 100 ))

  local first_pane
  first_pane=$(tmux list-panes -F '#{pane_id}' 2>/dev/null | head -1)

  trap 'set_applying 0' RETURN
  set_applying 1
  tmux select-layout main-horizontal 2>/dev/null || true
  tmux resize-pane -t "${first_pane}" -y "${master_height}" 2>/dev/null || true
  set_current_layout "main-horizontal"
}

export -f apply_layout_main_horizontal
