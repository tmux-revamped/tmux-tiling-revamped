#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_BALANCE_LOADED:-}" ]] && return 0
_TILING_REVAMPED_BALANCE_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

balance_panes() {
  local current_layout
  current_layout=$(get_current_layout)

  set_applying 1

  case "${current_layout}" in
    grid)
      tmux select-layout tiled 2>/dev/null || true
      ;;
    deck)
      tmux select-layout even-horizontal 2>/dev/null || true
      ;;
    monocle)
      ;;
    dwindle)
      local flags
      flags=$(get_window_option "@tiling_revamped_orientation" "brvc")
      _apply_bsp_layout "false" "${flags}"
      ;;
    spiral)
      local flags
      flags=$(get_window_option "@tiling_revamped_orientation" "brvs")
      _apply_bsp_layout "true" "${flags}"
      ;;
    main-center)
      apply_layout_main_center
      ;;
    main-vertical)
      apply_layout_main_vertical
      ;;
    main-horizontal)
      apply_layout_main_horizontal
      ;;
    *)
      tmux select-layout even-vertical 2>/dev/null || true
      ;;
  esac

  set_applying 0
}

export -f balance_panes
