#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_RESIZE_MASTER_LOADED:-}" ]] && return 0
_TILING_REVAMPED_RESIZE_MASTER_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

# resize_master: grow or shrink the master pane by a configurable step.
#
# The step size is @tiling_revamped_resize_step (default 5, percentage points).
# Resizing adjusts the stored ratio and re-applies the current layout so the
# master pane reflects the new proportion.
#
# Usage:
#   resize_master grow     # increase master ratio by step
#   resize_master shrink   # decrease master ratio by step
resize_master() {
  local direction="${1:-grow}"
  local pane_count
  pane_count=$(get_pane_count)

  (( pane_count <= 1 )) && return 0

  local step
  step=$(get_numeric_option "@tiling_revamped_resize_step" "5" "1" "20")

  local current_layout
  current_layout=$(get_current_layout)

  # Determine which ratio option to adjust based on the active layout
  local ratio_option="" default_ratio="60"
  case "${current_layout}" in
    main-vertical|main-horizontal)
      ratio_option="@tiling_revamped_master_ratio"
      default_ratio="60"
      ;;
    main-center)
      ratio_option="@tiling_revamped_main_center_ratio"
      default_ratio="60"
      ;;
    *)
      # For BSP and other layouts, resize the first pane directly
      local first_pane
      first_pane=$(tmux list-panes -F '#{pane_id}' 2>/dev/null | head -1)
      if [[ "${direction}" == "grow" ]]; then
        tmux resize-pane -t "${first_pane}" -R "${step}" 2>/dev/null || true
        tmux resize-pane -t "${first_pane}" -D "${step}" 2>/dev/null || true
      else
        tmux resize-pane -t "${first_pane}" -L "${step}" 2>/dev/null || true
        tmux resize-pane -t "${first_pane}" -U "${step}" 2>/dev/null || true
      fi
      return 0
      ;;
  esac

  local ratio
  ratio=$(get_numeric_option "${ratio_option}" "${default_ratio}" "10" "90")

  if [[ "${direction}" == "grow" ]]; then
    ratio=$(( ratio + step ))
    (( ratio > 90 )) && ratio=90
  else
    ratio=$(( ratio - step ))
    (( ratio < 10 )) && ratio=10
  fi

  set_tmux_option "${ratio_option}" "${ratio}"

  # Re-apply the layout with the updated ratio
  case "${current_layout}" in
    main-vertical)   apply_layout_main_vertical ;;
    main-horizontal) apply_layout_main_horizontal ;;
    main-center)     apply_layout_main_center ;;
  esac
}

export -f resize_master
