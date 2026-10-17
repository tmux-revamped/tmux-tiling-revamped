#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_AUTOSPLIT_LOADED:-}" ]] && return 0
_TILING_REVAMPED_AUTOSPLIT_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

autosplit_pane() {
  local width height
  width=$(get_pane_width)
  height=$(get_pane_height)

  if (( width == 0 || height == 0 )); then
    log_error "autosplit" "Could not read pane dimensions"
    return 1
  fi

  if (( width > height * 2 )); then
    tmux split-window -h -c "#{pane_current_path}" 2>/dev/null || true
  else
    tmux split-window -v -c "#{pane_current_path}" 2>/dev/null || true
  fi
}

export -f autosplit_pane
