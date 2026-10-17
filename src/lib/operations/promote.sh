#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_PROMOTE_LOADED:-}" ]] && return 0
_TILING_REVAMPED_PROMOTE_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

promote_pane() {
  local -a panes
  while IFS= read -r _p; do panes+=("$_p"); done < <(tmux list-panes -F '#{pane_id}' 2>/dev/null)
  local pane_count="${#panes[@]}"

  (( pane_count <= 1 )) && return 0

  local current_pane
  current_pane=$(get_current_pane)

  local master_pane="${panes[0]}"

  if [[ "${current_pane}" == "${master_pane}" ]]; then
    if (( pane_count > 1 )); then
      tmux swap-pane -s "${panes[0]}" -t "${panes[1]}" 2>/dev/null || true
    fi
  else
    tmux swap-pane -s "${current_pane}" -t "${master_pane}" 2>/dev/null || true
  fi

  _reapply_current_layout
}

export -f promote_pane
