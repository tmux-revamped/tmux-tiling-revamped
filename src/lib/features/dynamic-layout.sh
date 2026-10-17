#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_DYNAMIC_LAYOUT_LOADED:-}" ]] && return 0
_TILING_REVAMPED_DYNAMIC_LAYOUT_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/error-logger.sh"

_dynamic_layout_enabled() {
  local map
  map=$(get_tmux_option "@tiling_revamped_dynamic_layout" "")
  [[ -n "${map}" ]]
}

resolve_dynamic_layout() {
  local count="${1:-0}"
  local map
  map=$(get_tmux_option "@tiling_revamped_dynamic_layout" "")
  [[ -z "${map}" ]] && return 0

  local -a pairs
  read -ra pairs <<< "${map}"

  local best_threshold=-1 best_layout=""
  local pair threshold layout
  for pair in "${pairs[@]}"; do
    threshold="${pair%%:*}"
    layout="${pair##*:}"
    [[ "${threshold}" =~ ^[0-9]+$ ]] || continue
    [[ -z "${layout}" || "${layout}" == "${threshold}" ]] && continue
    if (( threshold <= count )) && (( threshold > best_threshold )); then
      best_threshold="${threshold}"
      best_layout="${layout}"
    fi
  done

  [[ -n "${best_layout}" ]] && printf '%s\n' "${best_layout}"
  return 0
}

_apply_dynamic_resolved() {
  local layout="${1:-}"
  case "${layout}" in
    dwindle)         apply_layout_dwindle "" ;;
    spiral)          apply_layout_spiral "" ;;
    grid)            apply_layout_grid ;;
    main-center)     apply_layout_main_center ;;
    main-vertical)   apply_layout_main_vertical ;;
    main-horizontal) apply_layout_main_horizontal ;;
    monocle)         apply_layout_monocle ;;
    deck)            apply_layout_deck ;;
    *)               log_error "dynamic-layout" "Unknown layout: ${layout}"; return 1 ;;
  esac
}

apply_dynamic_layout() {
  local count layout
  count=$(get_window_panes)
  layout=$(resolve_dynamic_layout "${count}")
  [[ -z "${layout}" ]] && return 0
  _apply_dynamic_resolved "${layout}"
}

export -f _dynamic_layout_enabled
export -f resolve_dynamic_layout
export -f _apply_dynamic_resolved
export -f apply_dynamic_layout
