#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_VALIDATE_LOADED:-}" ]] && return 0
_TILING_REVAMPED_VALIDATE_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/error-logger.sh"

# validate_layout: check if stored layout metadata matches actual pane state.
# Returns 0 if valid or no layout stored. Returns 1 if mismatch detected.
# With "fix" argument, clears the stored layout on mismatch.
validate_layout() {
  local action="${1:-check}"

  local current_layout
  current_layout=$(get_current_layout)

  # No layout stored: nothing to validate
  [[ -z "${current_layout}" ]] && return 0

  local pane_count
  pane_count=$(get_pane_count)

  # Single pane with a layout stored: stale metadata from killed panes
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
