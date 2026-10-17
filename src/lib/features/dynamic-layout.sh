#!/usr/bin/env bash
#
# dynamic-layout.sh: pick a layout from the live pane count.
#
# The user maps pane-count thresholds to layout names in a single option:
#   set -g @tiling_revamped_dynamic_layout "1:monocle 2:main-vertical 3:dwindle 5:grid"
#
# On each auto-apply hook the winning layout is the one whose threshold is the
# greatest value that does not exceed the current #{window_panes}.  With the map
# above one pane is monocle, two is main-vertical, three or four is dwindle, and
# five or more is grid.  The layout apply functions are provided by the
# dispatcher, which sources every layout module before this one.

[[ -n "${_TILING_REVAMPED_DYNAMIC_LAYOUT_LOADED:-}" ]] && return 0
_TILING_REVAMPED_DYNAMIC_LAYOUT_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/error-logger.sh"

# _dynamic_layout_enabled: true when a non-empty map is configured.
_dynamic_layout_enabled() {
  local map
  map=$(get_tmux_option "@tiling_revamped_dynamic_layout" "")
  [[ -n "${map}" ]]
}

# resolve_dynamic_layout: echo the layout mapped to <count>, or nothing.
# Malformed entries (non-numeric threshold, missing layout) are skipped.
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

# _apply_dynamic_resolved: dispatch a resolved layout name to its apply fn.
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

# apply_dynamic_layout: resolve the layout for the live pane count and apply it.
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
