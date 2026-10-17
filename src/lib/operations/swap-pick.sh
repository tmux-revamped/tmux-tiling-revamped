#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_SWAP_PICK_LOADED:-}" ]] && return 0
_TILING_REVAMPED_SWAP_PICK_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/has-command.sh"
source "${LIB_DIR}/utils/error-logger.sh"
source "${LIB_DIR}/utils/picker.sh"

swap_pick() {
  if ! has_command fzf; then
    log_error "swap-pick" "fzf is not installed"
    return 1
  fi

  local current_pane
  current_pane=$(get_current_pane)

  local pane_count
  pane_count=$(get_pane_count)
  (( pane_count <= 1 )) && return 0

  local pane_list
  pane_list=$(tmux list-panes -F '#{pane_id} #{pane_current_command} #{pane_current_path}' 2>/dev/null \
    | grep -v "^${current_pane} ")

  [[ -z "${pane_list}" ]] && return 0

  picker_open_popup "swap-pick" "${TILING_SWAP_PICK_WIDTH}" "${TILING_SWAP_PICK_HEIGHT}" && return 0

  local selected
  selected=$(echo "${pane_list}" \
    | picker_fzf "center,${TILING_SWAP_PICK_WIDTH},${TILING_SWAP_PICK_HEIGHT}" --prompt="Swap with: " 2>/dev/null)

  [[ -z "${selected}" ]] && return 0

  local target_pane="${selected%% *}"

  tmux swap-pane -s "${current_pane}" -t "${target_pane}" 2>/dev/null || return 1

  _reapply_current_layout
}

export -f swap_pick
