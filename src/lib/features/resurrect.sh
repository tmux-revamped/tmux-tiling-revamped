#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_RESURRECT_LOADED:-}" ]] && return 0
_TILING_REVAMPED_RESURRECT_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

_restore_window_layout() {
  local win="${1}" pane="${2}"
  local layout flags
  layout=$(tmux show-option -wqv -t "${win}" "@tiling_revamped_layout" 2>/dev/null)
  [[ -z "${layout}" ]] && return 0

  flags=$(tmux show-option -wqv -t "${win}" "@tiling_revamped_orientation" 2>/dev/null)
  [[ -z "${flags}" ]] && flags="brvc"

  tmux select-window -t "${win}" 2>/dev/null || return 0

  (
    export TMUX_PANE="${pane}"
    case "${layout}" in
      dwindle)         _apply_bsp_layout "false" "${flags}" ;;
      spiral)          _apply_bsp_layout "true" "${flags}" ;;
      grid)            apply_layout_grid ;;
      main-vertical)   apply_layout_main_vertical ;;
      main-horizontal) apply_layout_main_horizontal ;;
      main-center)     apply_layout_main_center ;;
      deck)            apply_layout_deck ;;
      monocle)         ;; # Zoom state is not restorable
    esac
  )
}

restore_layouts() {
  local -a windows=() starting_windows=()
  local win pane active
  while IFS='|' read -r win pane active; do
    [[ -z "${win}" ]] && continue
    windows+=("${win}|${pane}")
    [[ "${active}" == "1" ]] && starting_windows+=("${win}")
  done < <(tmux list-windows -a -F '#{window_id}|#{pane_id}|#{window_active}' 2>/dev/null)

  local entry
  for entry in ${windows[@]+"${windows[@]}"}; do
    _restore_window_layout "${entry%%|*}" "${entry#*|}"
  done

  for win in ${starting_windows[@]+"${starting_windows[@]}"}; do
    tmux select-window -t "${win}" 2>/dev/null || true
  done
}

export -f _restore_window_layout
export -f restore_layouts
