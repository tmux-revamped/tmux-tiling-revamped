#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_SPIRAL_LOADED:-}" ]] && return 0
_TILING_REVAMPED_SPIRAL_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/layouts/dwindle.sh"

apply_layout_spiral() {
  local flags="${1:-}"
  _apply_bsp_layout "true" "${flags}"
  set_current_layout "spiral"

  local stored_flags="${flags:-$(get_window_option "@tiling_revamped_orientation" "brvs")}"
  case "${stored_flags}" in
    *s*) ;;
    *c*) stored_flags="${stored_flags//c/s}" ;;
    *)   stored_flags="${stored_flags}s" ;;
  esac
  set_window_option "@tiling_revamped_orientation" "${stored_flags}"
}

export -f apply_layout_spiral
