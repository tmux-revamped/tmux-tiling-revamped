#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_SWAP_DIRECTION_LOADED:-}" ]] && return 0
_TILING_REVAMPED_SWAP_DIRECTION_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/error-logger.sh"

# swap_pane_direction: swap the focused pane with its neighbor in the
# given direction (U/D/L/R).
#
# After swapping, the current layout is re-applied so sizes recalculate
# correctly for the new pane positions.
swap_pane_direction() {
  local direction="${1:-R}"

  local pane_count
  pane_count=$(get_pane_count)
  (( pane_count <= 1 )) && return 0

  local target
  case "${direction}" in
    U) target="{up-of}" ;;
    D) target="{down-of}" ;;
    L) target="{left-of}" ;;
    R) target="{right-of}" ;;
    *)
      log_error "swap" "Unknown swap direction: ${direction}"
      return 1
      ;;
  esac

  local current_pane
  current_pane=$(get_current_pane)

  # Find the neighbor pane in the requested direction
  local neighbor
  neighbor=$(tmux display-message -p -t "${target}" '#{pane_id}' 2>/dev/null) || return 0

  # No neighbor in that direction, or neighbor is self
  [[ -z "${neighbor}" || "${neighbor}" == "${current_pane}" ]] && return 0

  tmux swap-pane -s "${current_pane}" -t "${neighbor}" 2>/dev/null || true

  _reapply_current_layout

  # Restore focus to the swapped pane (it moved to the neighbor's position)
  tmux select-pane -t "${current_pane}" 2>/dev/null || true
}

export -f swap_pane_direction
