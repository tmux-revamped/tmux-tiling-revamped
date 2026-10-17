#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_CYCLE_LOADED:-}" ]] && return 0
_TILING_REVAMPED_CYCLE_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

cycle_layout() {
  local direction="${1:-next}"

  local layouts_str
  layouts_str=$(get_tmux_option "@tiling_revamped_cycle_layouts" \
    "dwindle spiral grid main-vertical main-horizontal main-center monocle deck")

  local -a layouts
  read -ra layouts <<< "${layouts_str}"
  local count="${#layouts[@]}"

  (( count == 0 )) && return 0

  local current
  current=$(get_current_layout)

  local current_idx=0
  local i
  for (( i=0; i<count; i++ )); do
    if [[ "${layouts[i]}" == "${current}" ]]; then
      current_idx="${i}"
      break
    fi
  done

  local next_idx
  if [[ "${direction}" == "prev" ]]; then
    next_idx=$(( (current_idx - 1 + count) % count ))
  else
    next_idx=$(( (current_idx + 1) % count ))
  fi

  local next_layout="${layouts[next_idx]}"

  case "${next_layout}" in
    dwindle)         apply_layout_dwindle "" ;;
    spiral)          apply_layout_spiral "" ;;
    grid)            apply_layout_grid ;;
    main-center)     apply_layout_main_center ;;
    main-vertical)   apply_layout_main_vertical ;;
    main-horizontal) apply_layout_main_horizontal ;;
    monocle)         apply_layout_monocle ;;
    deck)            apply_layout_deck ;;
    *)               log_error "cycle" "Unknown layout: ${next_layout}" ;;
  esac
}

export -f cycle_layout
