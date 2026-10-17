#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_SWAP_BIGGEST_LOADED:-}" ]] && return 0
_TILING_REVAMPED_SWAP_BIGGEST_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

swap_biggest() {
  local pane_count
  pane_count=$(get_pane_count)
  (( pane_count <= 1 )) && return 0

  local current
  current=$(get_current_pane)

  local biggest="" max_area=-1
  local id width height area
  while read -r id width height _; do
    [[ -z "${id}" ]] && continue
    [[ "${width}" =~ ^[0-9]+$ ]] || continue
    [[ "${height}" =~ ^[0-9]+$ ]] || continue
    area=$(( width * height ))
    if (( area > max_area )); then
      max_area="${area}"
      biggest="${id}"
    fi
  done < <(tmux list-panes -F '#{pane_id} #{pane_width} #{pane_height}' 2>/dev/null)

  [[ -z "${biggest}" ]] && return 0
  [[ "${biggest}" == "${current}" ]] && return 0

  tmux swap-pane -s "${current}" -t "${biggest}" 2>/dev/null || return 1

  _reapply_current_layout
}

export -f swap_biggest
