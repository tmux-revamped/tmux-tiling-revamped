#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_VALIDATE_LOADED:-}" ]] && return 0
_TILING_REVAMPED_VALIDATE_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/error-logger.sh"

validate_layout() {
  local action="${1:-check}"

  local current_layout
  current_layout=$(get_current_layout)

  [[ -z "${current_layout}" ]] && return 0

  local pane_count
  pane_count=$(get_pane_count)

  if (( pane_count <= 1 )) && [[ "${current_layout}" != "monocle" ]]; then
    if [[ "${action}" == "fix" ]]; then
      set_window_option "@tiling_revamped_layout" ""
      log_error "validate" "Cleared stale layout '${current_layout}' (only 1 pane remains)"
    fi
    return 1
  fi

  return 0
}

export -f validate_layout
