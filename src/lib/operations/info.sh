#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_INFO_LOADED:-}" ]] && return 0
_TILING_REVAMPED_INFO_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

_decode_orientation() {
  local flags="${1:-brvc}"
  local desc=""

  case "${flags}" in *t*) desc="top";; *) desc="bottom";; esac
  case "${flags}" in *l*) desc="${desc}-left";; *) desc="${desc}-right";; esac
  case "${flags}" in *h*) desc="${desc}, horizontal";; *) desc="${desc}, vertical";; esac
  case "${flags}" in *s*) desc="${desc}, spiral";; *) desc="${desc}, corner";; esac

  echo "${desc}"
}

show_info() {
  local layout pane_count flags orientation history_depth

  layout=$(get_current_layout)
  [[ -z "${layout}" ]] && layout="(none)"

  pane_count=$(get_pane_count)
  flags=$(get_window_option "@tiling_revamped_orientation" "brvc")
  orientation=$(_decode_orientation "${flags}")

  local history
  history=$(get_window_option "@tiling_revamped_layout_history" "")
  if [[ -n "${history}" ]]; then
    local -a parts
    IFS='|' read -ra parts <<< "${history}"
    history_depth="${#parts[@]}"
  else
    history_depth=0
  fi

  local master_ratio
  master_ratio=$(get_tmux_option "@tiling_revamped_master_ratio" "60")

  local split_ratio
  split_ratio=$(get_tmux_option "@tiling_revamped_split_ratio" "50")

  echo "Layout:      ${layout}"
  echo "Panes:       ${pane_count}"
  echo "Orientation: ${flags} (${orientation})"
  echo "Master:      ${master_ratio}%"
  echo "BSP split:   ${split_ratio}%"
  echo "Undo depth:  ${history_depth}"
}

export -f _decode_orientation
export -f show_info
