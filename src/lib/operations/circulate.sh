#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_CIRCULATE_LOADED:-}" ]] && return 0
_TILING_REVAMPED_CIRCULATE_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

# circulate_panes: shift all pane positions by one step.
#
# next - tmux rotate-window -U: last pane becomes first  (counter-clockwise)
# prev - tmux rotate-window -D: first pane becomes last  (clockwise)
#
# After rotating positions, the current layout is re-applied so that the
# new arrangement uses the correct sizes for each slot.
circulate_panes() {
  local direction="${1:-next}"
  local pane_count
  pane_count=$(get_pane_count)

  (( pane_count <= 1 )) && return 0

  local selected_pane
  selected_pane=$(get_current_pane)

  if [[ "${direction}" == "prev" ]]; then
    tmux rotate-window -D 2>/dev/null || true
  else
    tmux rotate-window -U 2>/dev/null || true
  fi

  _reapply_current_layout

  # Restore focus to the same pane (it may have moved slots)
  tmux select-pane -t "${selected_pane}" 2>/dev/null || true
}

export -f circulate_panes
