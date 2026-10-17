#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_FLIP_LOADED:-}" ]] && return 0
_TILING_REVAMPED_FLIP_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

flip_layout() {
  local direction="${1:-h}"
  local current_layout
  current_layout=$(get_current_layout)

  local flags
  flags=$(get_window_option "@tiling_revamped_orientation" "brvc")

  case "${direction}" in
    h)
      if [[ "${flags}" == *l* ]]; then
        flags="${flags//l/r}"
      else
        flags="${flags//r/l}"
      fi
      ;;
    v)
      if [[ "${flags}" == *t* ]]; then
        flags="${flags//t/b}"
      else
        flags="${flags//b/t}"
      fi
      ;;
    *)
      log_error "flip" "Unknown flip direction: ${direction}"
      return 1
      ;;
  esac

  set_window_option "@tiling_revamped_orientation" "${flags}"

  case "${current_layout}" in
    dwindle) _apply_bsp_layout "false" "${flags}" ;;
    spiral)  _apply_bsp_layout "true"  "${flags}" ;;
    *)       return 0 ;;
  esac
}

export -f flip_layout
