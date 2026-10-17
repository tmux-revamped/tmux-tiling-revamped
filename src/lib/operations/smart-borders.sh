#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_SMART_BORDERS_LOADED:-}" ]] && return 0
_TILING_REVAMPED_SMART_BORDERS_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

smart_borders() {
  is_option_enabled "@tiling_revamped_smart_borders" || return 0

  local count
  count=$(get_window_panes)
  [[ "${count}" =~ ^[0-9]+$ ]] || return 0

  if (( count <= 1 )); then
    set_window_option "pane-border-status" "off"
  else
    local restore
    restore=$(get_tmux_option "@tiling_revamped_border_status" "top")
    set_window_option "pane-border-status" "${restore}"
  fi
}

export -f smart_borders
