#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_UNDO_LAYOUT_LOADED:-}" ]] && return 0
_TILING_REVAMPED_UNDO_LAYOUT_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

TILING_MAX_UNDO_DEPTH=10

_stack_push() {
  local option="${1}"
  local entry="${2}"
  [[ -z "${entry}" ]] && return 0

  local history
  history=$(get_window_option "${option}" "")

  if [[ -n "${history}" ]]; then
    history="${entry}|${history}"
  else
    history="${entry}"
  fi

  local -a parts
  IFS='|' read -ra parts <<< "${history}"
  if (( ${#parts[@]} > TILING_MAX_UNDO_DEPTH )); then
    local trimmed=""
    local i
    for (( i = 0; i < TILING_MAX_UNDO_DEPTH; i++ )); do
      [[ -n "${trimmed}" ]] && trimmed="${trimmed}|"
      trimmed="${trimmed}${parts[i]}"
    done
    history="${trimmed}"
  fi

  set_window_option "${option}" "${history}"
}

_current_entry() {
  local layout
  layout=$(get_current_layout)
  [[ -z "${layout}" ]] && return 0

  local flags
  flags=$(get_window_option "@tiling_revamped_orientation" "brvc")
  printf '%s:%s\n' "${layout}" "${flags}"
}

_apply_layout_entry() {
  local layout="${1}"
  local flags="${2}"

  case "${layout}" in
    dwindle)         _apply_bsp_layout "false" "${flags}"; set_current_layout "dwindle" ;;
    spiral)          _apply_bsp_layout "true" "${flags}"; set_current_layout "spiral" ;;
    grid)            apply_layout_grid ;;
    main-vertical)   apply_layout_main_vertical ;;
    main-horizontal) apply_layout_main_horizontal ;;
    main-center)     apply_layout_main_center ;;
    monocle)         apply_layout_monocle ;;
    deck)            apply_layout_deck ;;
    *)               return 1 ;;
  esac
}

push_layout_history() {
  [[ "${TILING_REVAMPED_REPLAYING:-0}" == "1" ]] && return 0
  [[ "${TILING_REVAMPED_AUTOMATIC:-0}" == "1" ]] && return 0

  local entry
  entry=$(_current_entry)
  [[ -z "${entry}" ]] && return 0

  local history
  history=$(get_window_option "@tiling_revamped_layout_history" "")
  [[ "${history%%|*}" == "${entry}" ]] && return 0

  _stack_push "@tiling_revamped_layout_history" "${entry}"
  set_window_option "@tiling_revamped_layout_redo" ""
}

undo_layout() {
  local history
  history=$(get_window_option "@tiling_revamped_layout_history" "")
  [[ -z "${history}" ]] && return 0

  local entry="${history%%|*}"
  local remaining="${history#*|}"
  [[ "${remaining}" == "${history}" ]] && remaining=""
  set_window_option "@tiling_revamped_layout_history" "${remaining}"

  local layout="${entry%%:*}"
  local flags="${entry#*:}"
  [[ -z "${layout}" ]] && return 0

  local prev_entry
  prev_entry=$(_current_entry)

  [[ -n "${flags}" ]] && set_window_option "@tiling_revamped_orientation" "${flags}"

  local rc
  TILING_REVAMPED_REPLAYING=1
  _apply_layout_entry "${layout}" "${flags}"
  rc=$?
  TILING_REVAMPED_REPLAYING=0

  (( rc == 0 )) && _stack_push "@tiling_revamped_layout_redo" "${prev_entry}"
  return "${rc}"
}

redo_layout() {
  local redo
  redo=$(get_window_option "@tiling_revamped_layout_redo" "")
  [[ -z "${redo}" ]] && return 0

  local entry="${redo%%|*}"
  local remaining="${redo#*|}"
  [[ "${remaining}" == "${redo}" ]] && remaining=""
  set_window_option "@tiling_revamped_layout_redo" "${remaining}"

  local layout="${entry%%:*}"
  local flags="${entry#*:}"
  [[ -z "${layout}" ]] && return 0

  local prev_entry
  prev_entry=$(_current_entry)

  [[ -n "${flags}" ]] && set_window_option "@tiling_revamped_orientation" "${flags}"

  local rc
  TILING_REVAMPED_REPLAYING=1
  _apply_layout_entry "${layout}" "${flags}"
  rc=$?
  TILING_REVAMPED_REPLAYING=0

  (( rc == 0 )) && _stack_push "@tiling_revamped_layout_history" "${prev_entry}"
  return "${rc}"
}

export -f _stack_push
export -f _current_entry
export -f _apply_layout_entry
export -f push_layout_history
export -f undo_layout
export -f redo_layout
