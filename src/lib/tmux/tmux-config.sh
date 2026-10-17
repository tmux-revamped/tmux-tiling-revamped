#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_TMUX_CONFIG_LOADED:-}" ]] && return 0
_TILING_REVAMPED_TMUX_CONFIG_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-ops.sh"

_TILING_REVAMPED_DISPATCHER="${LIB_DIR}/../tiling.sh"
TILING_APPLYING_TTL=10

tiling_popup_command() {
  local dispatcher
  printf -v dispatcher '%q' "${_TILING_REVAMPED_DISPATCHER}"
  printf '%s %s' "${dispatcher}" "${1}"
}

is_option_enabled() {
  local value
  value=$(get_tmux_option "${1}" "0")
  [[ "${value}" == "1" || "${value}" == "true" ]]
}

is_window_option_enabled() {
  local value
  value=$(get_window_option "${1}" "0")
  [[ "${value}" == "1" || "${value}" == "true" ]]
}

get_numeric_option() {
  local value
  value=$(get_tmux_option "${1}" "${2}")

  if ! [[ "${value}" =~ ^[0-9]+$ ]]; then
    echo "${2}"
    return
  fi

  local min="${3:-0}"
  local max="${4:-999999}"

  (( value < min )) && echo "${min}" && return
  (( value > max )) && echo "${max}" && return
  echo "${value}"
}

get_current_layout() {
  get_window_option "@tiling_revamped_layout" ""
}

set_current_layout() {
  if declare -f push_layout_history &>/dev/null && [[ "${1}" != "$(get_current_layout)" ]]; then
    push_layout_history
  fi
  set_window_option "@tiling_revamped_layout" "${1}"
}

is_auto_apply_enabled() {
  local window_val
  window_val=$(get_window_option "@tiling_revamped_enabled" "")
  if [[ -n "${window_val}" ]]; then
    [[ "${window_val}" == "1" ]]
    return
  fi
  is_option_enabled "@tiling_revamped_auto_apply"
}

is_applying() {
  local started now number_pattern='^[0-9]+$'
  started=$(get_window_option "@tiling_revamped_applying" "")
  [[ "${started}" =~ ${number_pattern} ]] || return 1
  now=$(date +%s)
  (( now >= started && now - started < TILING_APPLYING_TTL ))
}

set_applying() {
  if [[ "${1:-1}" == "0" ]]; then
    tmux set-option -wqu "@tiling_revamped_applying" 2>/dev/null || true
    return 0
  fi
  set_window_option "@tiling_revamped_applying" "$(date +%s)"
}

_reapply_current_layout() {
  local current_layout
  current_layout=$(get_current_layout)
  [[ -z "${current_layout}" ]] && return 0

  local flags
  flags=$(get_window_option "@tiling_revamped_orientation" "brvc")

  case "${current_layout}" in
    dwindle) _apply_bsp_layout "false" "${flags}" ;;
    spiral)  _apply_bsp_layout "true"  "${flags}" ;;
    grid)
      set_applying 1
      tmux select-layout tiled 2>/dev/null || true
      set_applying 0
      ;;
    deck)
      set_applying 1
      tmux select-layout even-horizontal 2>/dev/null || true
      set_applying 0
      ;;
    main-vertical)   apply_layout_main_vertical ;;
    main-horizontal) apply_layout_main_horizontal ;;
    main-center)     apply_layout_main_center ;;
    *)       ;;
  esac
}

export -f tiling_popup_command
export -f _reapply_current_layout
export -f is_option_enabled
export -f is_window_option_enabled
export -f get_numeric_option
export -f get_current_layout
export -f set_current_layout
export -f is_auto_apply_enabled
export -f is_applying
export -f set_applying
