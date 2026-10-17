#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_PRESETS_LOADED:-}" ]] && return 0
_TILING_REVAMPED_PRESETS_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/has-command.sh"

save_preset() {
  local preset_name="${1:-}"

  if [[ -z "${preset_name}" ]]; then
    log_error "presets" "save_preset requires a name argument"
    return 1
  fi

  preset_name="${preset_name//[^a-zA-Z0-9_-]/}"
  [[ -z "${preset_name}" ]] && return 1

  local layout flags master_ratio
  layout=$(get_current_layout)
  flags=$(get_window_option "@tiling_revamped_orientation" "brvc")
  master_ratio=$(get_tmux_option "@tiling_revamped_main_center_ratio" "60")

  local preset_value="${layout}:${flags}:${master_ratio}"
  set_tmux_option "@tiling_revamped_preset_${preset_name}" "${preset_value}"
}

_open_preset_picker() {
  if ! has_command fzf; then
    log_error "presets" "No preset name given and fzf is not installed"
    return 1
  fi

  tmux display-popup -E "$(tiling_popup_command "preset-pick")" 2>/dev/null || true
}

preset_pick() {
  local preset_name
  preset_name=$(tmux show-options -g 2>/dev/null \
    | grep '@tiling_revamped_preset_' \
    | sed 's/@tiling_revamped_preset_//' \
    | cut -d' ' -f1 \
    | fzf --prompt="Apply preset: " --height=10) || return 0
  [[ -z "${preset_name}" ]] && return 0

  apply_preset "${preset_name}"
}

apply_preset() {
  local preset_name="${1:-}"

  if [[ -z "${preset_name}" ]]; then
    _open_preset_picker
    return
  fi

  local preset_value
  preset_value=$(get_tmux_option "@tiling_revamped_preset_${preset_name}" "")

  if [[ -z "${preset_value}" ]]; then
    log_error "presets" "Preset not found: ${preset_name}"
    return 1
  fi

  local layout flags master_ratio
  IFS=':' read -r layout flags master_ratio <<< "${preset_value}"

  [[ -n "${master_ratio}" ]] \
    && set_tmux_option "@tiling_revamped_main_center_ratio" "${master_ratio}"

  [[ -n "${flags}" ]] \
    && set_window_option "@tiling_revamped_orientation" "${flags}"

  case "${layout}" in
    dwindle)         apply_layout_dwindle "" ;;
    spiral)          apply_layout_spiral "" ;;
    grid)            apply_layout_grid ;;
    main-vertical)   apply_layout_main_vertical ;;
    main-horizontal) apply_layout_main_horizontal ;;
    main-center)     apply_layout_main_center ;;
    monocle)         apply_layout_monocle ;;
    deck)            apply_layout_deck ;;
    *)               log_error "presets" "Unknown layout in preset: ${layout}" ; return 1 ;;
  esac
}

export -f save_preset
export -f _open_preset_picker
export -f preset_pick
export -f apply_preset
