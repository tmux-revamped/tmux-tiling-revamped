#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_ROTATE_LOADED:-}" ]] && return 0
_TILING_REVAMPED_ROTATE_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

rotate_layout() {
  local degrees="${1:-90}"
  local current_layout
  current_layout=$(get_current_layout)

  local flags
  flags=$(get_window_option "@tiling_revamped_orientation" "brvc")

  case "${degrees}" in
    90|270)
      if [[ "${flags}" == *h* ]]; then
        flags="${flags//h/v}"
      elif [[ "${flags}" == *v* ]]; then
        flags="${flags//v/h}"
      else
        flags="${flags}h"
      fi
      ;;
    180)
      local new_flags=""
      [[ "${flags}" == *t* ]] && new_flags="${new_flags}b" || new_flags="${new_flags}t"
      [[ "${flags}" == *r* ]] && new_flags="${new_flags}l" || new_flags="${new_flags}r"
      [[ "${flags}" == *h* ]] && new_flags="${new_flags}h" || new_flags="${new_flags}v"
      [[ "${flags}" == *s* ]] && new_flags="${new_flags}s" || new_flags="${new_flags}c"
      flags="${new_flags}"
      ;;
    *)
      log_error "rotate" "Unknown rotation degrees: ${degrees}"
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

export -f rotate_layout
