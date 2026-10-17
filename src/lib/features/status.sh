#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_STATUS_LOADED:-}" ]] && return 0
_TILING_REVAMPED_STATUS_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

# layout_icon: map a layout name to a single status glyph.
# Glyphs are emitted as UTF-8 byte escapes so the source stays plain ASCII.
# Unknown or empty names produce no output.
layout_icon() {
  local layout="${1:-}"
  case "${layout}" in
    dwindle)         printf '\xe2\x97\xa7' ;;
    spiral)          printf '\xe2\x97\x89' ;;
    grid)            printf '\xe2\x96\xa6' ;;
    main-vertical)   printf '\xe2\x96\x8c' ;;
    main-horizontal) printf '\xe2\x96\x80' ;;
    main-center)     printf '\xe2\x96\xa3' ;;
    monocle)         printf '\xe2\x97\x8f' ;;
    deck)            printf '\xe2\x96\xa4' ;;
    *)               printf '' ;;
  esac
}

# layout_status: print the active layout for the status line.
# Emits "<icon> <name>" for a known layout, the bare name for an unknown one,
# and nothing when no layout is set for the window.
layout_status() {
  local layout icon
  layout=$(get_current_layout)
  [[ -z "${layout}" ]] && return 0

  icon=$(layout_icon "${layout}")
  if [[ -n "${icon}" ]]; then
    printf '%s %s\n' "${icon}" "${layout}"
  else
    printf '%s\n' "${layout}"
  fi
}

export -f layout_icon
export -f layout_status
